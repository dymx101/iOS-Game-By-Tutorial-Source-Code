//
//  MyScene.h
//  BulletStorm
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Explosion.h"

@interface MyScene : SKScene

- (void)createExplosionType:(ExplosionType)explosionType atPosition:(CGPoint)position;

@end
