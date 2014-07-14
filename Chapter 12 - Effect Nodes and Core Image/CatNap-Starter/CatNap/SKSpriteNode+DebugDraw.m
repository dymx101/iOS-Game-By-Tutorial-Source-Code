//
//  SKSpriteNode+DebugDraw.m
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "SKSpriteNode+DebugDraw.h"

//disable debug drawing by setting this to NO
static BOOL kDebugDraw = YES;

@implementation SKSpriteNode (DebugDraw)

- (void)attachDebugFrameFromPath:(CGPathRef)bodyPath
{
  //1
  if (kDebugDraw==NO) return;
    
  //2
  SKShapeNode *shape = [SKShapeNode node];

  //3
  shape.path = bodyPath;
  shape.strokeColor = [SKColor colorWithRed:1.0 green:0 blue:0
                                      alpha:0.5];
  shape.lineWidth = 1.0;

  //4  
  [self addChild:shape];
}

- (void)attachDebugRectWithSize:(CGSize)s
{
  CGPathRef bodyPath = CGPathCreateWithRect(
    CGRectMake(-s.width/2, -s.height/2, s.width, s.height),nil);

  [self attachDebugFrameFromPath:bodyPath];
  CGPathRelease(bodyPath);
}

@end
