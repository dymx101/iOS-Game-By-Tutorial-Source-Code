//
//  Bug.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Bug.h"
#import "MyScene.h"
#import "TileMapLayer.h"

@implementation Bug

+ (void)initialize
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedFacingForwardAnim =
    [Bug createAnimWithPrefix:@"bug" suffix:@"ft"];
    sharedFacingBackAnim =
    [Bug createAnimWithPrefix:@"bug" suffix:@"bk"];
    sharedFacingSideAnim =
    [Bug createAnimWithPrefix:@"bug" suffix:@"lt"];
  });
}

- (instancetype)init
{
  SKTextureAtlas *atlas = 
    [SKTextureAtlas atlasNamed: @"characters"];
  SKTexture *texture = [atlas textureNamed:@"bug_ft1"];
  texture.filteringMode = SKTextureFilteringNearest;

  if (self = [super initWithTexture:texture]) {
    self.name = @"bug";
    CGFloat minDiam = MIN(self.size.width, self.size.height);
    minDiam = MAX(minDiam-8, 8);
    self.physicsBody = 
      [SKPhysicsBody bodyWithCircleOfRadius:minDiam/2.0];
    self.physicsBody.categoryBitMask = PCBugCategory;
    self.physicsBody.collisionBitMask = 0;
  }
  return self;
}

- (void)walk
{
  // 1
  TileMapLayer *tileLayer = (TileMapLayer*)self.parent;
  
  // 2
  CGPoint tileCoord = [tileLayer coordForPoint:self.position];
  int randomX = arc4random() % 3 - 1;
  int randomY = arc4random() % 3 - 1;
  CGPoint randomCoord = CGPointMake(tileCoord.x+randomX,
                                    tileCoord.y+randomY);
  // 3
  BOOL didMove = NO;
  MyScene *scene = (MyScene*)self.scene;
  if ([tileLayer isValidTileCoord:randomCoord] &&
      ![scene tileAtCoord:randomCoord
              hasAnyProps:(PCWallCategory | PCWaterCategory | PCBreakableCategory)]) {

    // 4
    didMove = YES;
    CGPoint randomPos = [tileLayer pointForCoord:randomCoord];
    SKAction *moveToPos =
    [SKAction sequence:
     @[[SKAction moveTo:randomPos duration:1],
       [SKAction runBlock:^(void){
      [self walk];
    }]]];
    [self runAction:moveToPos];
    [self faceDirection:CGPointMake(randomX,randomY)];
  }
  // 5
  if (!didMove) {
    [self runAction:
     [SKAction sequence:
      @[[SKAction waitForDuration:0.25 withRange:0.15],
        [SKAction performSelector:@selector(walk)
                         onTarget:self]]]];
  }
}

- (void)start
{
  [self walk];
}

static SKAction *sharedFacingBackAnim = nil;
- (SKAction*)facingBackAnim {
  return sharedFacingBackAnim;
}

static SKAction *sharedFacingForwardAnim = nil;
- (SKAction*)facingForwardAnim {
  return sharedFacingForwardAnim;
}

static SKAction *sharedFacingSideAnim = nil;
- (SKAction*)facingSideAnim {
  return sharedFacingSideAnim;
}

- (void)faceDirection:(CGPoint)dir
{
  // 1
  PCFacingDirection facingDir = self.facingDirection;
  // 2
  if (dir.y != 0 && dir.x != 0) {
    // 3
    facingDir = dir.y < 0 ? PCFacingBack : PCFacingForward;
    self.zRotation = dir.y < 0 ? M_PI_4 : -M_PI_4;
    if (dir.x > 0) {
      self.zRotation *= -1;
    }
  } else {
    // 4
    self.zRotation = 0;
  
    // 5
    if (dir.y == 0) {
      if (dir.x > 0) {
        facingDir = PCFacingRight;
      } else if (dir.x < 0) {
        facingDir = PCFacingLeft;
      }
    } else if (dir.y < 0) {
      facingDir = PCFacingBack;
    } else {
      facingDir = PCFacingForward;
    }
  }
  // 6
  self.facingDirection = facingDir;
}

@end
