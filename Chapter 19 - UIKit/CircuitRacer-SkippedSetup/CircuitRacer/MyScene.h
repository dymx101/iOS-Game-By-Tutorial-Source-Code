//
//  MyScene.h
//  CircuitRacer
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene

- (id)initWithSize:(CGSize)size carType:(CRCarType)carType 
             level:(CRLevelType)levelType;

@end
