//
//  Player.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Player.h"
#import "MyScene.h"

@implementation Player

- (instancetype)init
{
  SKTextureAtlas *atlas = 
    [SKTextureAtlas atlasNamed: @"characters"];
  SKTexture *texture = [atlas textureNamed:@"player_ft1"];
  texture.filteringMode = SKTextureFilteringNearest;

  if (self = [super initWithTexture:texture]) {
    self.name = @"player";
    // 1 
    CGFloat minDiam = MIN(self.size.width, self.size.height);
    minDiam = MAX(minDiam-16, 4);
    self.physicsBody =
      [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];
    // 2
    self.physicsBody.usesPreciseCollisionDetection = YES;
    // 3
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.restitution = 1;
    self.physicsBody.friction = 0;
    self.physicsBody.linearDamping = 0;
    self.physicsBody.categoryBitMask = PCPlayerCategory;
    self.physicsBody.contactTestBitMask = 0xFFFFFFFF;
    self.physicsBody.collisionBitMask =
      PCBoundaryCategory | PCWallCategory | PCWaterCategory | PCFireBugCategory;
    
    self.facingForwardAnim =
      [Player createAnimWithPrefix:@"player" suffix:@"ft"];
    self.facingBackAnim =
      [Player createAnimWithPrefix:@"player" suffix:@"bk"];
    self.facingSideAnim =
      [Player createAnimWithPrefix:@"player" suffix:@"lt"];

  }
  return self;
}

- (void)moveToward:(CGPoint)targetPosition
{
  CGPoint targetVector =
    CGPointNormalize(CGPointSubtract(targetPosition,
                                     self.position));

  targetVector = CGPointMultiplyScalar(targetVector, 300);
  self.physicsBody.velocity = CGVectorMake(targetVector.x,
                                           targetVector.y);
  
  [self faceCurrentDirection];
}

- (void)faceCurrentDirection
{
  // 1
  PCFacingDirection facingDir = self.facingDirection;
  
  // 2
  CGVector dir = self.physicsBody.velocity;
  if (abs(dir.dy) >  abs(dir.dx)) {
    if (dir.dy < 0) {
      facingDir = PCFacingForward;
    } else {
      facingDir = PCFacingBack;
    }
  } else {
    facingDir = (dir.dx > 0) ? PCFacingRight : PCFacingLeft;
  }
  
  // 3
  self.facingDirection = facingDir;
}

@end
