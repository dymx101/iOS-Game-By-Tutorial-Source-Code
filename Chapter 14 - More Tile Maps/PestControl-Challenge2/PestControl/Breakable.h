//
//  Breakable.h
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Breakable : SKSpriteNode

- (instancetype)initWithWhole:(SKTexture *)whole
                       broken:(SKTexture *)broken;
- (void)smashBreakable;

@end
