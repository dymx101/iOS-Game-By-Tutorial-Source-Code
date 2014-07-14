//
//  Entity.h
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Entity : SKSpriteNode

@property (assign,nonatomic) CGPoint direction;
@property (assign,nonatomic) float   health;
@property (assign,nonatomic) float   maxHealth;

+ (SKTexture *)generateTexture;
- (instancetype)initWithPosition:(CGPoint)position;
- (void)update:(CFTimeInterval)delta;

@end
