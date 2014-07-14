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
  SKLabelNode *_laps, *_time;
  int _maxSpeed;
  float _maxSteeringAngle;
  CGPoint _trackCenter;
  NSTimeInterval _previousTimeInterval;
  SKAction * _boxSoundAction;
  SKAction * _hornSoundAction;
  SKAction * _lapSoundAction;
  SKAction * _nitroSoundAction;
  NSUInteger _noOfCollisionsWithBoxes;
  int _maxtime;
  NSDictionary *_leaderboardIDMap;
    
  NSMutableArray *_cars, *_playerLabels;
  
  /*Multiplayer challenge 1*/
  NSMutableArray *_playerPhotos;
  /*Multiplayer challenge 1*/
  
  NSUInteger _currentIndex, _noOfCars;
  BOOL _isMultiplayerMode;
}

#pragma mark initialization methods

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType
             level:(CRLevelType)levelType
{
  if (self = [super initWithSize:size]) {
    _carType = carType;
    _levelType = levelType;
    _leaderboardIDMap =
      @{[NSString stringWithFormat:@"%d_%d",
         CRYellowCar, CRLevelEasy] :
          @"com.razeware.circuitracer3.car1_level_easy_fastest_time",
        [NSString stringWithFormat:@"%d_%d",
         CRYellowCar, CRLevelMedium] :
          @"com.razeware.circuitracer3.car1_level_medium_fastest_time",
        [NSString stringWithFormat:@"%d_%d", 
         CRYellowCar, CRLevelHard] :
          @"com.razeware.circuitracer3.car1_level_hard_fastest_time",

        [NSString stringWithFormat:@"%d_%d", CRBlueCar, CRLevelEasy] :
          @"com.razeware.circuitracer3.car2_level_easy_fastest_time",
        [NSString stringWithFormat:@"%d_%d", CRBlueCar,CRLevelMedium]:
          @"com.razeware.circuitracer3.car2_level_medium_fastest_time",
        [NSString stringWithFormat:@"%d_%d", CRBlueCar, CRLevelHard] :
          @"com.razeware.circuitracer3.car2_level_hard_fastest_time",

        [NSString stringWithFormat:@"%d_%d", CRRedCar, CRLevelEasy] :
          @"com.razeware.circuitracer3.car3_level_easy_fastest_time",
        [NSString stringWithFormat:@"%d_%d", CRRedCar, CRLevelMedium]:
          @"com.razeware.circuitracer3.car3_level_medium_fastest_time",
        [NSString stringWithFormat:@"%d_%d", CRRedCar, CRLevelHard] :
          @"com.razeware.circuitracer3.car3_level_hard_fastest_time"
      };
    _noOfCars = 1;
    _cars = [NSMutableArray arrayWithCapacity:_noOfCars];
    [self initializeGame];
    _noOfCollisionsWithBoxes = 0;
  }
  return self;
}

- (id)initWithSize:(CGSize)size numberOfCars:(NSUInteger)numberOfCars level:(CRLevelType)levelType
{
  if (self = [super initWithSize:size]) {
    if (numberOfCars > 2) {
      numberOfCars = 2;
    }
    _levelType = levelType;
    _noOfCars = numberOfCars;
    _cars = [NSMutableArray arrayWithCapacity:_noOfCars];
    _playerLabels = [NSMutableArray arrayWithCapacity:_noOfCars];
    _playerPhotos = [NSMutableArray arrayWithCapacity:_noOfCars];/*Multiplayer challenge 1*/
    _currentIndex = -1;
    if (numberOfCars == 1) {
      [self initializeGame];
    } else {
      [self initializeMultiplayerGame];
    }
  }
  return self;
}

- (void)initializeGame
{
  [self loadLevel];

  SKSpriteNode *track = [self addTrackForLevel:_levelType];
  SKSpriteNode *car = [self addCar:_carType atPosition:CGPointMake(CGRectGetMidX(track.frame), 50)];
  [_cars addObject:car];
  _currentIndex = 0;
  
  [self setupPhysicsBoundariesForTrack:track];
  [self addObjectsForTrack:track];
  [self addLapsLabelForTrack:track];
  [self addTimeLabelForTrack:track];
  
  _maxSpeed = 125 * (1 + _carType);
  _maxSteeringAngle = 0.018f + _carType*0.0075f;
  _trackCenter = track.position;
  
  [self initializeSoundEffects];
  self.physicsWorld.contactDelegate = self;
}

- (void)initializeMultiplayerGame
{
  _noOfLaps = 5;
  _isMultiplayerMode = YES;
  SKSpriteNode *track = [self addTrackForLevel:_levelType];
    
  _maxSpeed = 200;
  _trackCenter = track.position;
    
  CGFloat xDisplacement = 0;
  for (int i = 1; i <= _noOfCars; i++) {
    //1 Select a car
    CRCarType carType = i;
        
    //2 Set the position
    SKSpriteNode *car = [self addCar:carType atPosition:CGPointMake(CGRectGetMidX(track.frame) + xDisplacement, i % 2 == 0 ? 30 : 70)];
        
    //3 Add to global array
    [_cars addObject:car];
        
    xDisplacement = (i % 2) == 0 ? xDisplacement - 60 : xDisplacement;
  }
  [self initializeSoundEffects];  
  [self setupPhysicsBoundariesForTrack:track];
  [self addLapsLabelForTrack:track];
}

- (void)initializeSoundEffects
{
  _boxSoundAction = [SKAction playSoundFileNamed:@"box.wav" waitForCompletion:NO];
  _hornSoundAction = [SKAction playSoundFileNamed:@"horn.wav" waitForCompletion:NO];
  _lapSoundAction = [SKAction playSoundFileNamed:@"lap.wav" waitForCompletion:NO];
  _nitroSoundAction = [SKAction playSoundFileNamed:@"nitro.wav" waitForCompletion:NO];
}

- (void)setNetworkingEngine:(MultiplayerNetworking *)networkingEngine
{
  _networkingEngine = networkingEngine;
  _networkingEngine.noOfLaps = 5;
}

#pragma mark helper methods

- (void)setupPhysicsBoundariesForTrack:(SKSpriteNode*)track
{
  self.physicsWorld.gravity = CGVectorMake(0, 0);
  CGRect trackFrame = CGRectInset(track.frame, 40, 0);
  self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:trackFrame];

  SKNode *innerBoundary = [SKNode node];
  innerBoundary.position = track.position;
  [self addChild:innerBoundary];
    
  CGSize size = CGSizeMake(180, 120);
  innerBoundary.physicsBody =
  [SKPhysicsBody bodyWithRectangleOfSize:size];
  innerBoundary.physicsBody.dynamic = NO;
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
  
  _maxtime = _timeInSeconds;
}

- (SKSpriteNode*)addTrackForLevel:(CRLevelType)levelType
{
  NSString *trackName = [NSString stringWithFormat:@"track_%i", _levelType];
  SKSpriteNode *track = [SKSpriteNode spriteNodeWithImageNamed:trackName];
    
  track.position = CGPointMake(CGRectGetMidX(self.frame),
                               CGRectGetMidY(self.frame));
  [self addChild:track];
  return track;
}

- (SKSpriteNode*)addCar:(CRCarType)carType atPosition:(CGPoint)startPosition
{
  SKSpriteNode *car = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"car_%i",carType]];
  car.position = startPosition;
  [self addChild:car];
  car.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:car.frame.size];
  car.physicsBody.categoryBitMask = CRBodyCar;
  car.physicsBody.contactTestBitMask = CRBodyBox;
  car.physicsBody.allowsRotation = NO;
  return car;
}

- (SKLabelNode*)addPlayerLabelWithText:(NSString*)text atPosition:(CGPoint)position
{
  NSLog(@"Adding player with label: %@", text);
  SKLabelNode *label =
    [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  label.position = position;
  label.fontSize = 18;
  label.fontColor = [SKColor whiteColor];
  label.text = text;
  [self addChild:label];
  return label;
}

/*Multiplayer challenge 1*/
-(SKSpriteNode*)addPlayerPhotosWithTexture:(SKTexture*)texture atPosition:(CGPoint)position
{
  SKSpriteNode *playerPhoto = [SKSpriteNode spriteNodeWithTexture:texture];
  playerPhoto.position = position;
  playerPhoto.size = CGSizeMake(40, 40);
  [self addChild:playerPhoto];
  return playerPhoto;
}
/*Multiplayer challenge 1*/

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
  [self addBoxAt:
    CGPointMake(track.position.x + 130, track.position.y)];
  [self addBoxAt:
    CGPointMake(track.position.x - 200, track.position.y)];
}

- (void)addLapsLabelForTrack:(SKSpriteNode*)track
{
  _laps = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _laps.text = [NSString stringWithFormat:@"Laps: %i", _noOfLaps];
  _laps.fontSize = 28;
  _laps.fontColor = [UIColor whiteColor];
  _laps.position = CGPointMake(track.position.x,
                                 track.position.y + 20);
  [self addChild:_laps];
}

- (void)addTimeLabelForTrack:(SKSpriteNode*)track
{
  _time = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
  _time.text = [NSString stringWithFormat:@"Time: %.lf", _timeInSeconds];
  _time.fontSize = 28;
  _time.fontColor = [UIColor whiteColor];
  _time.position = CGPointMake(track.position.x,
                                 track.position.y - 10);
  [self addChild:_time];
}

- (void)analogControlUpdated:(AnalogControl*)analogControl
{
  SKSpriteNode *car = _cars[_currentIndex];
  [car.physicsBody setVelocity:
    CGVectorMake(analogControl.relativePosition.x * _maxSpeed,
                 -analogControl.relativePosition.y *_maxSpeed)];
  
  if (!CGPointEqualToPoint(
       analogControl.relativePosition, CGPointZero)) {
    car.zRotation =
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

/*Multiplayer challenge 2*/
- (void)tap
{
  [_networkingEngine sendHonkMessage];
}
/*Multiplayer challenge 2*/

#pragma mark update method

- (void)update:(NSTimeInterval)currentTime
{
  if (_previousTimeInterval==0) {
    _previousTimeInterval = currentTime;
  }

  if (self.paused==YES) {
    _previousTimeInterval = currentTime;
    return;
  }
      
  if (currentTime - _previousTimeInterval > 1 && !_isMultiplayerMode) { /*Multiplayer challenge 3*/
    _timeInSeconds -= (currentTime - _previousTimeInterval);
    _previousTimeInterval = currentTime;
    _time.text = 
      [NSString stringWithFormat:@"Time: %.lf", _timeInSeconds];
  }

  static float nextProgressAngle = M_PI;

  if (_currentIndex == -1) {
    return;
  }
  SKSpriteNode *car = _cars[_currentIndex];
  CGPoint vector = CGPointSubtract(car.position, _trackCenter);
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
      [_networkingEngine sendLapComplete];
    }
  }

  if ((_timeInSeconds < 0 || _noOfLaps == 0) && !_isMultiplayerMode) {
    self.paused = YES;
    [self reportScoreToGameCenter];
    self.gameOverBlock( _noOfLaps == 0 );
    [self reportAchievementsForGameState:( _noOfLaps == 0 )];
  }
    
  [self moveCarFromAcceleration:car currentTime:currentTime];/*Multiplayer challenge 1*/
}

-(void)moveCarFromAcceleration:(SKSpriteNode*)car currentTime:(NSTimeInterval)currentTime /*Multiplayer challenge 3*/
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
  if ([UIScreen screens].count>1) {
    [self moveCar:car fromSteering:accel2D];
  } else {
    car.physicsBody.velocity =
      CGVectorMake(accel2D.x * maxAccelerationPerSecond,
                   accel2D.y * maxAccelerationPerSecond);
  }

  //1
  if (accel2D.x!=0 || accel2D.y!=0) {

    //2
    float orientationFromVelocity = 
      CGPointToAngle(CGPointMake(car.physicsBody.velocity.dx,
                                 car.physicsBody.velocity.dy));
    
    float angleDelta = 0.0f;
          
    //3
    if (fabsf(orientationFromVelocity-car.zRotation)>1) {
      //prevent wild rotation
      angleDelta = (orientationFromVelocity-car.zRotation);
    } else {
      //blend rotation
      const float blendFactor = 0.25f;
      angleDelta = 
        (orientationFromVelocity - car.zRotation) * blendFactor;
      angleDelta = 
        ScalarShortestAngleBetween(car.zRotation,
                                   car.zRotation + angleDelta);
    }
          
    //4
    car.zRotation += angleDelta;
  }
  SKLabelNode *playerLabel = _playerLabels[_currentIndex];
  playerLabel.position = CGPointMake(car.position.x, car.position.y + 30);
  NSLog(@"Moving label:%@ X:%f Y:%f", playerLabel.text, playerLabel.position.x, playerLabel.position.y);
    
  /*Multiplayer challenge 3*/
  if (currentTime - _previousTimeInterval >= 0.1 && _isMultiplayerMode) {
    _previousTimeInterval = currentTime;
    [_networkingEngine sendMove:(car.physicsBody.velocity.dx)
                      yPosition:(car.physicsBody.velocity.dy)
                       rotation:car.zRotation];
  }
  /*Multiplayer challenge 3*/
    
  /*Multiplayer challenge 1*/
  if (_playerPhotos.count > 0) {
    SKSpriteNode *photo = _playerPhotos[_currentIndex];
    photo.position = CGPointMake(car.position.x, car.position.y + 70);
  }
  /*Multiplayer challenge 1*/
}

- (void)moveCar:(SKSpriteNode*)car fromSteering:(CGPoint)steering
{
  float angleDelta = -steering.x * _maxSteeringAngle;
      
  car.zRotation += angleDelta;

  CGPoint directionVector = CGPointForAngle(car.zRotation);
  car.physicsBody.velocity = CGVectorMake(
    directionVector.x * _maxSpeed * 0.67,
    directionVector.y * _maxSpeed * 0.67);

}

#pragma mark Physics contact delegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
  if (contact.bodyA.categoryBitMask +
        contact.bodyB.categoryBitMask == CRBodyCar + CRBodyBox){
    
    _noOfCollisionsWithBoxes += 1;
    
    [self runAction:_boxSoundAction];
  }
}

#pragma mark Game center methods

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

- (void)reportScoreToGameCenter
{
  int64_t timeToComplete = _maxtime - _timeInSeconds;
  [[GameKitHelper sharedGameKitHelper]
   reportScore:timeToComplete
   forLeaderboardID:
     _leaderboardIDMap[[NSString stringWithFormat:@"%d_%d",   
       _carType, _levelType]]];
}

#pragma mark Multiplayer protocol methods
- (void) matchEnded
{
  if (self.gameEndedBlock) {
    self.gameEndedBlock();
  }
}

- (void) setCurrentPlayerIndex:(NSUInteger)index
{
  _currentIndex = index;
}

- (void) setPositionOfCarAtIndex:(NSUInteger)index dx:(CGFloat)dx dy:(CGFloat)dy rotation:(CGFloat)rotation
{
  SKSpriteNode *car = _cars[index];
  [car.physicsBody setVelocity:CGVectorMake(dx, dy)];
  if (rotation != 0) {
    [car setZRotation:rotation];
  }
  SKLabelNode *playerLabel = _playerLabels[index];
  playerLabel.position = CGPointMake(car.position.x, car.position.y + 30);
   
  /*Multiplayer challenge 1*/
  if (_playerPhotos.count > 0) {
    SKSpriteNode *photo = _playerPhotos[index];
    photo.position = CGPointMake(car.position.x, car.position.y + 70);
  }
  /*Multiplayer challenge 1*/
}

- (void) gameOver:(BOOL)didLocalPlayerWin
{
  self.paused = YES;
  self.gameOverBlock(didLocalPlayerWin);
}

- (void)setPlayerLabelsInOrder:(NSArray*)playerAliases
{
  [playerAliases enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
    SKSpriteNode *car = _cars[idx];
    SKLabelNode *label = [self addPlayerLabelWithText:string atPosition:CGPointMake(car.position.x, car.position.y + 30)];
    [_playerLabels addObject:label];
  }];
}

/*Multiplayer challenge 1*/
- (void) setPlayerPhotosInOrder:(NSArray*)playerPhotos
{
  [playerPhotos enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop){
    SKSpriteNode *car = _cars[idx];
    SKTexture *photoTexture = [SKTexture textureWithImage:image];
    SKSpriteNode *photo = [self addPlayerPhotosWithTexture:photoTexture atPosition:CGPointMake(car.position.x, car.position.y + 70)];
    [_playerPhotos addObject:photo];
  }];
}
/*Multiplayer challenge 1*/

/*Multiplayer challenge 2*/
- (void)playHorn
{
  [self runAction:_hornSoundAction];
}
/*Multiplayer challenge 2*/
@end
