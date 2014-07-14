//
//  MyScene.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

typedef NS_OPTIONS(uint32_t, CRPhysicsCategory)
{
  CRBodyCar = 1 << 0,
  CRBodyBox = 1 << 1,
};

@implementation MyScene {
  CRCarType _carType;
  CRLevelType _levelType;
  NSTimeInterval _timeInSeconds;
  int _noOfLaps;
  SKSpriteNode *_car;
  SKLabelNode *_laps, *_time;
}

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType
             level:(CRLevelType)levelType
{
  if (self = [super initWithSize:size]) {
    _carType = carType;
    _levelType = levelType;
    [self initializeGame];
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


@end
