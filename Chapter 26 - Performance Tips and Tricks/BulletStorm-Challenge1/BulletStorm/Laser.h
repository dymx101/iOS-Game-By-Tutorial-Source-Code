//
//  Laser.h
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Entity.h"

typedef NS_ENUM(int32_t, LaserType)
{
  LaserTypePlayer = 0,
  LaserTypeEnemy,
  NumLaserTypes
};

@interface Laser : Entity

@property (assign) LaserType laserType;

- (instancetype)initWithLaserType:(LaserType)asteroidType;
- (void)configureCollisionBody;

@end
