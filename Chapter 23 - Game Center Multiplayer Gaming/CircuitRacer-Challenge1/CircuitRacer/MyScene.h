//
//  MyScene.h
//  CircuitRacer
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MultiplayerNetworking.h"

@import CoreMotion;

@interface MyScene : SKScene<MultiplayerProtocol>

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType 
             level:(CRLevelType)levelType;

- (id)initWithSize:(CGSize)size numberOfCars:(NSUInteger)numberOfCars
             level:(CRLevelType)levelType;

@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);
@property (nonatomic, copy) void (^gameEndedBlock)();

@property (weak, nonatomic) CMMotionManager* motionManager;
@property (nonatomic, strong) MultiplayerNetworking *networkingEngine;
@end
