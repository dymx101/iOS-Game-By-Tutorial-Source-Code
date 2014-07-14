//
//  MyScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

/*
 
 Challenge 1 answers:
 
 1) [SKAction followPath:... duration:...]
 2) [SKAction fadeAlphaTo:... duration:...]
 3) Explanation follows:
 
 Custom actions allow you to easily make a node do soemthing over time that there isn't already an action for. The ActionsCatalog demonstrates three kinds of custom actions: making a node blink, jump, or follow a sin wave.
 
 Custom actions give you a node to work with, and how much time has elapsed. Your job is to update something on the node, based on the percentage of how much time has elapsed vs. the passed in duration.
 
 As an example, here's an explanation of the blink action demo in ActionsCatalog:
 
 1) Divide the duration by the number of blinks the desired in that time period. Call that a "slice" of time. In each slice, the node should be visible for half the time, and invisible for the other half. That is what will make the node appear to blink.
 
 2) fmodf is like the normal modulus operator (%), except it works with fractions instead of integers. It basically returns the remainder of the first parameter (elapsedTime) after being divided by the second parameter (slice). So in this example, it gives you the amount of time that has elapsed in this "slice" calculated ealrier.
 
 3) The hidden property on a node controls whether it is rendered or not. If the remainder calculated above is in the second half of the slice, it should be hidden (invisible). Otherwise it will be visible. Hence, the blink effect!
 
 */

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

#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
  return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                (max - min) + min);
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
  SKAction *_zombieAnimation;
  SKAction *_catCollisionSound;
  SKAction *_enemyCollisionSound;
  BOOL _invincible;
}

- (void)spawnEnemy
{
  SKSpriteNode *enemy =
  [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
  enemy.name = @"enemy";
  enemy.position = CGPointMake(
                               self.size.width + enemy.size.width/2,
                               ScalarRandomRange(enemy.size.height/2,
                                                 self.size.height-enemy.size.height/2));
  [self addChild:enemy];
  
  SKAction *actionMove =
    [SKAction moveToX:-enemy.size.width/2 duration:2.0];
  SKAction *actionRemove = [SKAction removeFromParent];
  [enemy runAction:
   [SKAction sequence:@[actionMove, actionRemove]]];

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
    
    // 1
    NSMutableArray *textures =
    [NSMutableArray arrayWithCapacity:10];
    // 2
    for (int i = 1; i < 4; i++) {
      NSString *textureName =
      [NSString stringWithFormat:@"zombie%d", i];
      SKTexture *texture =
      [SKTexture textureWithImageNamed:textureName];
      [textures addObject:texture];
    }
    // 3
    for (int i = 4; i > 1; i--) {
      NSString *textureName =
      [NSString stringWithFormat:@"zombie%d", i];
      SKTexture *texture =
      [SKTexture textureWithImageNamed:textureName];
      [textures addObject:texture];
    }
    // 4
    _zombieAnimation =
    [SKAction animateWithTextures:textures timePerFrame:0.1];
    // 5
    //[_zombie runAction:
    // [SKAction repeatActionForever:_zombieAnimation]];
    
    //[_zombie setScale:2.0]; // SKNode method
    
    [self runAction:[SKAction repeatActionForever:
    [SKAction sequence:@[
      [SKAction performSelector:@selector(spawnEnemy)
                       onTarget:self],
      [SKAction waitForDuration:2.0]]]]];
    
    [self runAction:[SKAction repeatActionForever:
      [SKAction sequence:@[
        [SKAction performSelector:@selector(spawnCat)
                         onTarget:self],
        [SKAction waitForDuration:1.0]]]]];
    
    _catCollisionSound = [SKAction playSoundFileNamed:@"hitCat.wav"
                                    waitForCompletion:NO];
    _enemyCollisionSound =
      [SKAction playSoundFileNamed:@"hitCatLady.wav"
               waitForCompletion:NO];
    
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
  //NSLog(@"%0.2f milliseconds since last update", _dt * 1000);
  
  CGPoint offset = CGPointSubtract(_lastTouchLocation, _zombie.position);
  float distance = CGPointLength(offset);
  if (distance < ZOMBIE_MOVE_POINTS_PER_SEC * _dt) {
    _zombie.position = _lastTouchLocation;
    _velocity = CGPointZero;
    [self stopZombieAnimation];
  } else {
    [self moveSprite:_zombie velocity:_velocity];
    [self boundsCheckPlayer];
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
  }
  
  //[self checkCollisions];
}

- (void)didEvaluateActions {
  [self checkCollisions];
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
  // 1
  CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
  //NSLog(@"Amount to move: %@",
  //      NSStringFromCGPoint(amountToMove));
  
  // 2
  sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveZombieToward:(CGPoint)location
{
  [self startZombieAnimation];
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

- (void)startZombieAnimation
{
  if (![_zombie actionForKey:@"animation"]) {
    [_zombie runAction:
     [SKAction repeatActionForever:_zombieAnimation]
               withKey:@"animation"];
  }
}

- (void)stopZombieAnimation
{
  [_zombie removeActionForKey:@"animation"];
}

- (void)spawnCat
{
  // 1
  SKSpriteNode *cat =
    [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
  cat.name = @"cat";
  cat.position = CGPointMake(
                             ScalarRandomRange(0, self.size.width),
                             ScalarRandomRange(0, self.size.height));
  cat.xScale = 0;
  cat.yScale = 0;
  [self addChild:cat];
  
  // 2
  cat.zRotation = -M_PI / 16;
  
  SKAction *appear = [SKAction scaleTo:1.0 duration:0.5];
  
  SKAction *leftWiggle = [SKAction rotateByAngle:M_PI / 8
                                        duration:0.5];
  SKAction *rightWiggle = [leftWiggle reversedAction];
  SKAction *fullWiggle =[SKAction sequence:
                         @[leftWiggle, rightWiggle]];
  //SKAction *wiggleWait =
  //  [SKAction repeatAction:fullWiggle count:10];
  //SKAction *wait = [SKAction waitForDuration:10.0];
  
  SKAction *scaleUp = [SKAction scaleBy:1.2 duration:0.25];
  SKAction *scaleDown = [scaleUp reversedAction];
  SKAction *fullScale = [SKAction sequence:
                         @[scaleUp, scaleDown, scaleUp, scaleDown]];
  
  SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
  SKAction *groupWait = [SKAction repeatAction:group count:10];
  
  SKAction *disappear = [SKAction scaleTo:0.0 duration:0.5];
  SKAction *removeFromParent = [SKAction removeFromParent];
  [cat runAction:
   [SKAction sequence:@[appear, groupWait, disappear,
                        removeFromParent]]];
}

- (void)checkCollisions
{
  [self enumerateChildNodesWithName:@"cat"
                         usingBlock:^(SKNode *node, BOOL *stop){
                           SKSpriteNode *cat = (SKSpriteNode *)node;
                           if (CGRectIntersectsRect(cat.frame, _zombie.frame)) {
                             [cat removeFromParent];
                             [self runAction:_catCollisionSound];

                           }
                         }];
  
  if (_invincible) return;
  
  [self enumerateChildNodesWithName:@"enemy"
                         usingBlock:^(SKNode *node, BOOL *stop){
                           SKSpriteNode *enemy = (SKSpriteNode *)node;
                           CGRect smallerFrame = CGRectInset(enemy.frame, 20, 20);
                           if (CGRectIntersectsRect(smallerFrame, _zombie.frame)) {
                             //[enemy removeFromParent];
                             [self runAction:_enemyCollisionSound];
                             _invincible = YES;
                             float blinkTimes = 10;
                             float blinkDuration = 3.0;
                             SKAction *blinkAction =
                             [SKAction customActionWithDuration:blinkDuration
                                                    actionBlock:
                              ^(SKNode *node, CGFloat elapsedTime) {
                                float slice = blinkDuration / blinkTimes;
                                float remainder = fmodf(elapsedTime, slice);
                                node.hidden = remainder > slice / 2;
                              }];
                              SKAction *sequence = [SKAction sequence:@[blinkAction, [SKAction runBlock:^{
                               _zombie.hidden = NO;
                               _invincible = NO;
                              }]]];
                              [_zombie runAction:sequence];
                           }
                         }];
}

@end
