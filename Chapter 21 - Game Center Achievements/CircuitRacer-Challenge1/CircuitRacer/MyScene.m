//
//  MyScene.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "AnalogControl.h"
#import "SKTUtils.h"
#import "AchievementsHelper.h"
#import "GameKitHelper.h"

static int numberOfPlays = 0;

typedef NS_OPTIONS(uint32_t, CRPhysicsCategory)
{
  CRBodyCar = 1 << 0,
  CRBodyBox = 1 << 1,
};

@interface MyScene()<SKPhysicsContactDelegate>
@end

@implementation MyScene {
  CRCarType _carType;
  CRLevelType _levelType;
  NSTimeInterval _timeInSeconds;
  int _noOfLaps;
  SKSpriteNode *_car;
  SKLabelNode *_laps, *_time;
  int _maxSpeed;
  CGPoint _trackCenter;
  NSTimeInterval _previousTimeInterval;
  SKAction * _boxSoundAction;
  SKAction * _hornSoundAction;
  SKAction * _lapSoundAction;
  SKAction * _nitroSoundAction;
  NSUInteger _noOfCollisionsWithBoxes;
}

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType
             level:(CRLevelType)levelType
{
  if (self = [super initWithSize:size]) {
    _carType = carType;
    _levelType = levelType;
    [self initializeGame];
    _noOfCollisionsWithBoxes = 0;
  }
  return self;
}

- (void)initializeGame
{
  [self loadLevel];

  SKSpriteNode *track = [SKSpriteNode spriteNodeWithImageNamed:
    [NSString stringWithFormat:@"track_%i", _levelType]];

  track.position = CGPointMake(CGRectGetMidX(self.frame),
                               CGRectGetMidY(self.frame));
  [self addChild:track];
  
  [self addCarAtPosition: 
    CGPointMake(CGRectGetMidX(track.frame), 50)];
    
  self.physicsWorld.gravity = CGVectorMake(0, 0);
  CGRect trackFrame = CGRectInset(track.frame, 40, 0);
  self.physicsBody =
    [SKPhysicsBody bodyWithEdgeLoopFromRect:trackFrame];

  [self addObjectsForTrack:track];
  [self addGameUIForTrack:track];
  
  _maxSpeed = 125 * (1 + _carType);
  _trackCenter = track.position;
  
  _boxSoundAction = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
  _hornSoundAction = [SKAction playSoundFileNamed:@"horn.wav" waitForCompletion:NO];
  _lapSoundAction = [SKAction playSoundFileNamed:@"lap.wav" waitForCompletion:NO];
  _nitroSoundAction = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];
  
  self.physicsWorld.contactDelegate = self;
}

- (void)loadLevel
{
  NSString *filePath =
    [NSBundle.mainBundle pathForResource:@"LevelDetails"
                                  ofType:@"plist"];
  NSArray *level = [NSArray arrayWithContentsOfFile:filePath];
  
  NSNumber *timeInSeconds = level[_levelType-1][@"time"];
  _timeInSeconds = [timeInSeconds doubleValue];
  
  NSNumber *laps = level[_levelType-1][@"laps"];
  _noOfLaps = [laps intValue];
}

- (void)addCarAtPosition:(CGPoint)startPosition
{
  _car = 
    [SKSpriteNode spriteNodeWithImageNamed:
      [NSString stringWithFormat:@"car_%i",_carType]];
  _car.position = startPosition;
  [self addChild:_car];
  _car.physicsBody = 
  [SKPhysicsBody bodyWithRectangleOfSize:_car.frame.size];
  _car.physicsBody.categoryBitMask = CRBodyCar;
  _car.physicsBody.collisionBitMask = CRBodyBox;
  _car.physicsBody.contactTestBitMask = CRBodyBox;
  _car.physicsBody.allowsRotation = NO;
}

- (void)addBoxAt:(CGPoint)point
{
  SKSpriteNode *box = 
    [SKSpriteNode spriteNodeWithImageNamed:@"box"];
  box.position = point;
  box.physicsBody = 
    [SKPhysicsBody bodyWithRectangleOfSize:box.size];
  box.physicsBody.categoryBitMask = CRBodyBox;
  box.physicsBody.linearDamping = 1;
  box.physicsBody.angularDamping = 1;
  [self addChild:box];
}

- (void)addObjectsForTrack:(SKSpriteNode*)track
{
  // 1
  SKNode *innerBoundary = [SKNode node];
  innerBoundary.position = track.position;
  [self addChild:innerBoundary];
    
  CGSize size = CGSizeMake(180, 120);
  innerBoundary.physicsBody = 
    [SKPhysicsBody bodyWithRectangleOfSize:size];
  innerBoundary.physicsBody.dynamic = NO;
    
  [self addBoxAt:
    CGPointMake(track.position.x + 130, track.position.y)];
  [self addBoxAt:
    CGPointMake(track.position.x - 200, track.position.y)];
}

- (void)addGameUIForTrack:(SKSpriteNode*)track
{
  _laps = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _laps.text = 
    [NSString stringWithFormat:@"Laps: %i", _noOfLaps];
  _laps.fontSize = 28;
  _laps.fontColor = [UIColor whiteColor];
  _laps.position = CGPointMake(track.position.x,
                               track.position.y + 20);
  [self addChild:_laps];

  _time = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _time.text = 
    [NSString stringWithFormat:@"Time: %.lf", _timeInSeconds];
  _time.fontSize = 28;
  _time.fontColor = [UIColor whiteColor];
  _time.position = CGPointMake(track.position.x, 
                               track.position.y - 10);
  [self addChild:_time];
}

- (void)analogControlUpdated:(AnalogControl*)analogControl
{
  [_car.physicsBody setVelocity:
    CGVectorMake(analogControl.relativePosition.x * _maxSpeed,
                 -analogControl.relativePosition.y *_maxSpeed)];
  
  if (!CGPointEqualToPoint(
       analogControl.relativePosition, CGPointZero)) {
    _car.zRotation =
      CGPointToAngle(
        CGPointMake(analogControl.relativePosition.x,
                    -analogControl.relativePosition.y));
  }

}

-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change
                      context:(void *)context
{
  if ([keyPath isEqualToString:@"relativePosition"]) {
    [self analogControlUpdated:object];
  }
}

- (void)update:(NSTimeInterval)currentTime
{
  if (_previousTimeInterval==0) {
    _previousTimeInterval = currentTime;
  }

  if (self.paused==YES) {
    _previousTimeInterval = currentTime;
    return;
  }
      
  if (currentTime - _previousTimeInterval > 1) {
    _timeInSeconds -= (currentTime - _previousTimeInterval);
    _previousTimeInterval = currentTime;
    _time.text = 
      [NSString stringWithFormat:@"Time: %.lf", _timeInSeconds];
  }

  static float nextProgressAngle = M_PI;

  CGPoint vector = CGPointSubtract(_car.position, _trackCenter);
  float progressAngle = CGPointToAngle(vector) + M_PI;
  
    if (progressAngle > nextProgressAngle &&
       (progressAngle - nextProgressAngle) < M_PI_4) {
    
    //advance on track
    nextProgressAngle += M_PI_2;
    if (nextProgressAngle > 2*M_PI) {
      nextProgressAngle = 0;
    }
          
    if (fabsf(nextProgressAngle-M_PI)<FLT_EPSILON) {
      _noOfLaps -= 1;
      _laps.text = [NSString stringWithFormat:@"Laps: %i", _noOfLaps];
      [self runAction:_lapSoundAction];

    }
  }

  if (_timeInSeconds < 0 || _noOfLaps == 0) {
    self.paused = YES;
    self.gameOverBlock( _noOfLaps == 0 );
    [self reportAchievementsForGameState:( _noOfLaps == 0 )];
  }
  
//  NSLog(@"accelerometer [%.2f, %.2f, %.2f]",   
//  _motionManager.accelerometerData.acceleration.x, 
//  _motionManager.accelerometerData.acceleration.y, 
//  _motionManager.accelerometerData.acceleration.z);

  [self moveCarFromAcceleration];
}

- (void)moveCarFromAcceleration
{
  GLKVector3 raw = GLKVector3Make(
    _motionManager.accelerometerData.acceleration.x,
    _motionManager.accelerometerData.acceleration.y,
    _motionManager.accelerometerData.acceleration.z);

  if (GLKVector3AllEqualToScalar(raw, 0)) {  
    return;
  }
  
  static GLKVector3 ax, ay, az;
    
  ay = GLKVector3Make(0.63f, 0.0f, -0.92f);
  az = GLKVector3Make(0.0f, 1.0f,  0.0f);
  ax = GLKVector3Normalize(GLKVector3CrossProduct(az, ay));

  CGPoint accel2D = CGPointZero;
  accel2D.x = GLKVector3DotProduct(raw, az);
  accel2D.y = GLKVector3DotProduct(raw, ax);
  accel2D = CGPointNormalize(accel2D);

  /* Challenge Accelerometer Chapter */
  static float accelerationBlendFactor = 0.2;
  static CGPoint lastAccel2D = {0,0};
  
  accel2D.x = lastAccel2D.x + (accel2D.x - lastAccel2D.x) * accelerationBlendFactor;
  accel2D.y = lastAccel2D.y + (accel2D.y - lastAccel2D.y) * accelerationBlendFactor;
  lastAccel2D = accel2D;
  /* Challenge Accelerometer Chapter */

  static const float steerDeadZone = 0.15;
  if (fabsf(accel2D.x) < steerDeadZone) accel2D.x = 0;
  if (fabsf(accel2D.y) < steerDeadZone) accel2D.y = 0;

  float maxAccelerationPerSecond = _maxSpeed;
  _car.physicsBody.velocity =
    CGVectorMake(accel2D.x * maxAccelerationPerSecond,
                 accel2D.y * maxAccelerationPerSecond);

  //1
  if (accel2D.x!=0 || accel2D.y!=0) {

    //2
    float orientationFromVelocity = 
      CGPointToAngle(CGPointMake(_car.physicsBody.velocity.dx,   
                                 _car.physicsBody.velocity.dy));
    
    float angleDelta = 0.0f;
          
    //3
    if (fabsf(orientationFromVelocity-_car.zRotation)>1) {
      //prevent wild rotation
      angleDelta = (orientationFromVelocity-_car.zRotation);
    } else {
      //blend rotation
      const float blendFactor = 0.25f;
      angleDelta = 
        (orientationFromVelocity - _car.zRotation) * blendFactor;
      angleDelta = 
        ScalarShortestAngleBetween(_car.zRotation, 
                                   _car.zRotation + angleDelta);
    }
          
    //4
    _car.zRotation += angleDelta;
  }

}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
  if (contact.bodyA.categoryBitMask +
        contact.bodyB.categoryBitMask == CRBodyCar + CRBodyBox){
    
    _noOfCollisionsWithBoxes += 1;
    
    [self runAction:_boxSoundAction];
  }
}

-(void)reportAchievementsForGameState:(BOOL)hasWon
{
  // 1
  NSMutableArray *achievements = [NSMutableArray array];
    
  // 2
 [achievements addObject:
   [AchievementsHelper collisionAchievement:     
     _noOfCollisionsWithBoxes]];
  //3
  if (hasWon) {
    [achievements addObject:
      [AchievementsHelper achievementForLevel:_levelType]];
  }
  numberOfPlays++;
  [achievements addObject:[AchievementsHelper racingAddictAchievement:numberOfPlays]];
  
  //4
  [[GameKitHelper sharedGameKitHelper]
    reportAchievements:achievements];
}

@end
