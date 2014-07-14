//
//  Bullet.m
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

- (instancetype)initWithPosition:(CGPoint)position
{
  if (self = [super initWithPosition:position]) {
    self.name = @"bullet";
    [self configureCollisionBody];
  }
  return self;
}

+ (SKTexture *)generateTexture
{
  // 1 
  static SKTexture *texture = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    // 2
    SKLabelNode *bullet =
      [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    bullet.name = @"bullet";
    bullet.fontSize = 20.0f;
    bullet.fontColor = [SKColor whiteColor];
    bullet.text = @"•";
    
    // 5
    SKView *textureView = [SKView new];
    texture = [textureView textureFromNode:bullet];
    texture.filteringMode = SKTextureFilteringNearest;
  });
  
  return texture;
}

- (void)configureCollisionBody
{
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:5];
  
  self.physicsBody.affectedByGravity = NO;
  
  // Set the category of the physics object that will be used for collisions
  self.physicsBody.categoryBitMask = ColliderTypeBullet;
  
  // We want to know when a collision happens but we dont want the bodies to actually react to each other so we
  // set the collisionBitMask to 0
  self.physicsBody.collisionBitMask = 0;
  
  // Make sure we get told about these collisions
  self.physicsBody.contactTestBitMask = ColliderTypeEnemy;
  
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
  [self removeFromParent];
}

@end
