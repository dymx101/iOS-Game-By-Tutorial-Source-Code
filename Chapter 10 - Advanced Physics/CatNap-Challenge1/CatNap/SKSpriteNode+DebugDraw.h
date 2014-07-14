//
//  SKSpriteNode+DebugDraw.h
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)

- (void)attachDebugRectWithSize:(CGSize)s;
- (void)attachDebugFrameFromPath:(CGPathRef)pathRef;

@end
