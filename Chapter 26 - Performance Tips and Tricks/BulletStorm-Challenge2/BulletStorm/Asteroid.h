//
//  Asteroid.h
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Entity.h"

typedef NS_ENUM(int32_t, AsteroidType)
{
  AsteroidTypeSmall = 0,
  AsteroidTypeMedium,
  AsteroidTypeLarge,
  NumAsteroidTypes
};

@interface Asteroid : Entity

- (instancetype)initWithAsteroidType:(AsteroidType)asteroidType;

@end
