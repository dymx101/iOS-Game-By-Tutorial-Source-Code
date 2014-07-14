//
//  MyScene.h
//  CircuitRacer
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@import CoreMotion;

@interface MyScene : SKScene

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType 
             level:(CRLevelType)levelType;

@property (nonatomic, copy) void (^gameOverBlock)(BOOL didWin);
@property (weak, nonatomic) CMMotionManager* motionManager;

@end
