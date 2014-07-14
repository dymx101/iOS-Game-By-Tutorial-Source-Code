//
//  Entity.m
//  XBlaster
//
//  Created by Main Account on 8/31/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Entity.h"

@implementation Entity

- (instancetype)initWithPosition:(CGPoint)position
{
  if (self = [super init]) {
    self.texture = [[self class] generateTexture];
    self.size = self.texture.size;
    self.position = position;
    _direction = CGPointZero;
  }
  return self;
}

- (void)update:(CFTimeInterval)delta
{
  // Overridden by subclasses
}

+ (SKTexture *)generateTexture
{
  // Overridden by subclasses
  return nil;
}

- (void)configureCollisionBody
{
  // Overridden by a subclass
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
  // Overridden by a subclass
}

@end
