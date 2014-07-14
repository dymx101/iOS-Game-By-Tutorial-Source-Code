//
//  MyScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
  return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
  return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
  return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
  return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
  CGFloat length = CGPointLength(a);
  return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
  return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
  return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
  CGFloat difference = b - a;
  CGFloat angle = fmodf(difference, M_PI * 2);
  if (angle >= M_PI) {
    angle -= M_PI * 2;
  }
  return angle;
}

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float ZOMBIE_ROTATE_RADIANS_PER_SEC = 4 * M_PI;

@implementation MyScene
{
  SKSpriteNode *_zombie;
  NSTimeInterval _lastUpdateTime;
  NSTimeInterval _dt;
  CGPoint _velocity;
  CGPoint _lastTouchLocation;
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
  
  CGPoint offset = CGPointSubtract(_lastTouchLocation, _zombie.position);
  float distance = CGPointLength(offset);
  if (distance < ZOMBIE_MOVE_POINTS_PER_SEC * _dt) {
    _zombie.position = _lastTouchLocation;
    _velocity = CGPointZero;
  } else {
    [self moveSprite:_zombie velocity:_velocity];
    [self boundsCheckPlayer];
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
  }
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
  // 1
  CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
  NSLog(@"Amount to move: %@",
        NSStringFromCGPoint(amountToMove));
  
  // 2
  sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location
{
  _lastTouchLocation = location;
  CGPoint offset = CGPointSubtract(location, _zombie.position);
  
  CGPoint direction = CGPointNormalize(offset);
  _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
  
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
              toFace:(CGPoint)velocity
 rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
  float targetAngle = CGPointToAngle(velocity);
  float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
  float amtToRotate = rotateRadiansPerSec * _dt;
  if (ABS(shortest) < amtToRotate) {
    amtToRotate = ABS(shortest);
  }
  sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}


@end
