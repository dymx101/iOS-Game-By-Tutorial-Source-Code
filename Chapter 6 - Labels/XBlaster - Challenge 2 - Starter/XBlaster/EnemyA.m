//
//  EnemyA.m
//  XBlaster
//
//  Created by Mike Daley on 21/07/2013.
//  Copyright (c) 2013 www.raywenderlich.com. All rights reserved.
//

#import "EnemyA.h"
#import "MyScene.h"
#import "AISteering.h"

@implementation EnemyA

#pragma mark -
#pragma mark Class Methods

+ (SKTexture *)generateTexture
{
  // This class method allows us to only create the texture for this entity once and then have it reused by all other
  // instances that get created
  static SKTexture *texture = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    // We are going to be using labels to draw all the entities in the game so we create a label
    // that will allow us draw the players ship. First we create a label for the center of the ship...
    SKLabelNode *ship = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    ship.name = @"mainship";
    ship.fontSize = 20.0f;
    ship.text = @"(=⚇=)";
    
    // Create a new SKView instance which we will use to generate a texture from the mainShip node and the use that texture
    // to create a new SKSpriteNode
    SKView *textureView = [SKView new];
    texture = [textureView textureFromNode:ship];
    texture.filteringMode = SKTextureFilteringNearest;
  });
  
  return texture;
}

static SKAction *damageAction = nil;
static SKAction *hitLeftAction = nil;
static SKAction *hitRightAction = nil;
static SKAction *moveBackAction = nil;

+ (void)loadSharedAssets
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    damageAction = [SKAction sequence:@[[SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.0],
                                        [SKAction colorizeWithColorBlendFactor:0.0 duration:1.0]
                                        ]];
    
    hitLeftAction = [SKAction sequence:@[
                                         [SKAction rotateToAngle:GLKMathDegreesToRadians(-15) duration:0.25],
                                         [SKAction rotateToAngle:0 duration:0.5]
                                         ]];
    
    hitRightAction = [SKAction sequence:@[
                                          [SKAction rotateToAngle:GLKMathDegreesToRadians(15) duration:0.25],
                                          [SKAction rotateToAngle:0 duration:0.5]
                                          ]];
    
    moveBackAction = [SKAction sequence:@[[SKAction moveByX:0 y:20 duration:0.25]]];

  });
}
#pragma mark -
#pragma mark Entity Creation

- (id)initWithPosition:(CGPoint)position
{
  if (self = [super initWithPosition:position]) {
    self.name = @"enemy";
    
    // Get an initial waypoint
    CGPoint initialWaypoint = CGPointMake(RandomFloatRange(50, 200),
                                          RandomFloatRange(50, 550));
    
    // Setup the steering AI to move to that waypoint
    _aiSteering = [[AISteering alloc] initWithEntity:self waypoint:initialWaypoint];

    // Setup the enemies health
    SKLabelNode *healthMeterNode = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    _healthMeterText  = @"________";
    healthMeterNode.name = @"healthMeter";
    healthMeterNode.fontSize = 10.0f;
    healthMeterNode.fontColor = [SKColor greenColor];
    healthMeterNode.text = _healthMeterText;
    healthMeterNode.position = CGPointMake(0, 15);
    [self addChild:healthMeterNode];
    
    // Set the initial health of this entity
    self.health = 100;
    self.maxHealth = 100;
    _score = 225;
    _damageTakenPerShot = 5;
    
    // Load any shared assets that this entity will share with other EnemyA instances
    [EnemyA loadSharedAssets];

    [self configureCollisionBody];
    
  }
  return self;
}

#pragma mark -
#pragma mark Update

- (void)update:(CFTimeInterval)delta
{
  // Check to see if we have reached the current waypoint and if so set the next one
  if (_aiSteering.waypointReached) {
    [_aiSteering updateWaypoint:
     CGPointMake(RandomFloatRange(100, self.scene.size.width - 100),
                 RandomFloatRange(100, self.scene.size.height - 100))];
  }
  
  // Update the steering AI which will position the entity based on randomly generated waypoints
  [_aiSteering update:delta];
  
  // Update the health meter
  SKLabelNode *healthMeter = (SKLabelNode *)[self childNodeWithName:@"healthMeter"];
  healthMeter.text = [_healthMeterText substringToIndex:(self.health / 100 * _healthMeterText.length)];
  healthMeter.fontColor = [SKColor colorWithRed:2.0f * (1.0f - self.health / 100.0f)
                                          green:2.0f * self.health / 100.0f
                                           blue:0 alpha:1.0];
  
}

#pragma mark -
#pragma mark Physics and Collision

- (void)configureCollisionBody
{
  self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
  
  self.physicsBody.affectedByGravity = NO;
  
  // Set the category of the physics object that will be used for collisions
  self.physicsBody.categoryBitMask = ColliderTypeEnemy;
  
  // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
  // set the collisionBitMask to 0
  self.physicsBody.collisionBitMask = 0;
  
  // Make sure we get told about these collisions
  self.physicsBody.contactTestBitMask = ColliderTypePlayer | ColliderTypeBullet;
  
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{

  // Get the contact point at which the bodies collided
  CGPoint localContactPoint = [self.scene convertPoint:contact.contactPoint toNode:self];

  // Remove all the current actions. Their current effect on the enemy ship will remain unchanged so the new action
  // will transition smoothly to the new action
  [self removeAllActions];
  
  // Depending on which side the enemy was hit, rotate the ship
  if (localContactPoint.x < 0) {
    [self runAction:hitLeftAction];
  } else {
    [self runAction:hitRightAction];
  }
  
  // Set up an action that will make the entity flash red with damage
  [self runAction:damageAction];
  
  // If the entity is moving down the screen then make the ship slow down by moving it back a little with an action
  if (self.aiSteering.currentDirection.y < 0)
    [self runAction:moveBackAction];
  
  // Reduce the health of the enemy ship
  self.health -= _damageTakenPerShot;
  
  // If the enemies health is now below 0 then add the enemyDeath emitter to the scene and reset the enemies position to off screen
  if (self.health <= 0) {
    
    // Reference the main scene
    MyScene *mainScene = (MyScene*)self.scene;
    
    self.health = self.maxHealth;
    [mainScene increaseScoreBy:_score];
    
    // Now position the entity above the top of the screen so it can fly into view
    self.position = CGPointMake(RandomFloatRange(100, self.scene.size.width - 100),
                                self.scene.size.height + 50);

  }

}

@end
