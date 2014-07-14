//
//  Player.h
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AnimatingSprite.h"

@interface Player : AnimatingSprite

- (void)moveToward:(CGPoint)targetPosition;
- (void)faceCurrentDirection;

@end
