//
//  Explosion.h
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Entity.h"

typedef NS_ENUM(int32_t, ExplosionType)
{
  ExplosionTypeSmall = 0,
  ExplosionTypeLarge,
  NumExplosionTypes
};

@interface Explosion : Entity

- (instancetype)initWithExplosionType:(ExplosionType)explosionType;

@end
