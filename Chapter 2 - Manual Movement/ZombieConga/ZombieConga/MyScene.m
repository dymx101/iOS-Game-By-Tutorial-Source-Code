//
//  MyScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;

@implementation MyScene
{
  SKSpriteNode *_zombie;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  CGPoint _velocity;
}

-(id)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *bg =
      [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    bg.position =
      CGPointMake(self.size.width/2, self.size.height/2);
    bg.position =
      CGPointMake(self.size.width / 2, self.size.height / 2);
    bg.anchorPoint = CGPointMake(0.5, 0.5); // same as default
    //bg.zRotation = M_PI / 8;
    [self addChild:bg];
    CGSize mySize = bg.size;
    NSLog(@"Size: %@", NSStringFromCGSize(mySize));
    
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [self addChild:_zombie];
    
    //[_zombie setScale:2.0]; // SKNode method
    
  }
  return self;
}

//// Gesture recognizer example
//// Uncomment this, and comment the touchesBegan/Moved/Ended methods to test
//- (void)didMoveToView:(SKView *)view
//{
//  UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//  [self.view addGestureRecognizer:tapRecognizer];
//}
//
//- (void)handleTap:(UITapGestureRecognizer *)recognizer {
//  CGPoint touchLocation = [recognizer locationInView:self.view];
//  touchLocation = [self convertPointFromView:touchLocation];
//  [self moveZombieToward:touchLocation];
//}

- (void)update:(NSTimeInterval)currentTime
{
  if (_lastUpdateTime) {
    _dt = currentTime - _lastUpdateTime;
  } else {
    _dt = 0;
  }
  _lastUpdateTime = currentTime;
  NSLog(@"%0.2f milliseconds since last update", _dt * 1000);
  
  [self moveSprite:_zombie velocity:_velocity];
  [self boundsCheckPlayer];
  [self rotateSprite:_zombie toFace:_velocity];
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
  // 1
  CGPoint amountToMove = CGPointMake(velocity.x * _dt,
                                     velocity.y * _dt);
  NSLog(@"Amount to move: %@",
        NSStringFromCGPoint(amountToMove));
  
  // 2
  sprite.position =
  CGPointMake(sprite.position.x + amountToMove.x,
              sprite.position.y + amountToMove.y);
}

- (void)moveZombieToward:(CGPoint)location
{
  CGPoint offset = CGPointMake(location.x - _zombie.position.x,
                               location.y - _zombie.position.y);
  
  CGFloat length =
    sqrtf(offset.x * offset.x + offset.y * offset.y);
  
  CGPoint direction = CGPointMake(offset.x / length,
                                  offset.y / length);
  _velocity =
    CGPointMake(direction.x * ZOMBIE_MOVE_POINTS_PER_SEC,
                direction.y * ZOMBIE_MOVE_POINTS_PER_SEC);
  
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self.scene];
  [self moveZombieToward:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self.scene];
  [self moveZombieToward:touchLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self.scene];
  [self moveZombieToward:touchLocation];
}

- (void)boundsCheckPlayer
{
  // 1
  CGPoint newPosition = _zombie.position;
  CGPoint newVelocity = _velocity;
  
  // 2
  CGPoint bottomLeft = CGPointZero;
  CGPoint topRight = CGPointMake(self.size.width,
                                 self.size.height);
  
  // 3
  if (newPosition.x <= bottomLeft.x) {
    newPosition.x = bottomLeft.x;
    newVelocity.x = -newVelocity.x;
  }
  if (newPosition.x >= topRight.x) {
    newPosition.x = topRight.x;
    newVelocity.x = -newVelocity.x;
  }
  if (newPosition.y <= bottomLeft.y) {
    newPosition.y = bottomLeft.y;
    newVelocity.y = -newVelocity.y;
  }
  if (newPosition.y >= topRight.y) {
    newPosition.y = topRight.y;
    newVelocity.y = -newVelocity.y;
  }
  
  // 4
  _zombie.position = newPosition;
  _velocity = newVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)direction
{
  sprite.zRotation = atan2f(direction.y, direction.x);
}


@end
