//
//  EnemyB.m
//  XBlaster
//
//  Created by Mike Daley on 16/07/2013.
//  Copyright (c) 2013 www.raywenderlich.com. All rights reserved.
//

#import "EnemyB.h"
#import "AISteering.h"

@implementation EnemyB

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
    ship.text = @"⎛⚉⎞";
    
    // Create a new SKView instance which we will use to generate a texture from the mainShip node and the use that texture
    // to create a new SKSpriteNode
    SKView *textureView = [SKView new];
    texture = [textureView textureFromNode:ship];
    texture.filteringMode = SKTextureFilteringNearest;
  });
  
  return texture;
}

#pragma mark -
#pragma mark Entity Creation

- (id)initWithPosition:(CGPoint)position
{
  if (self = [super initWithPosition:position]) {
    
    // Make EnemyB health look different from EnemyA
    SKLabelNode *healthMeterNode = (SKLabelNode *)[self childNodeWithName:@"healthMeter"];
    healthMeterNode.fontSize = 8.0f;
    healthMeterNode.fontColor = [SKColor yellowColor];
    
    // Modify the steering AI to move these enemies differently from EnemyA
    self.aiSteering.maxVelocity = 8.0f;
    self.aiSteering.maxSteeringForce = 0.05f;
    
    // Change the score for this enemy type
    _score = 445;
    _damageTakenPerShot = 10;
  }
  return self;
}

@end
