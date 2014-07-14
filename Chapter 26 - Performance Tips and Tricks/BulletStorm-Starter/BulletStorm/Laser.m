//
//  Laser.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Laser.h"
#import "SKTUtils.h"

@implementation Laser

- (instancetype)initWithLaserType:(LaserType)laserType {
  NSString *imageName;
  int maxHp;
  switch (laserType) {
  case LaserTypePlayer:
    imageName = @"player-bullet";
    maxHp = 1;
    break;
  case LaserTypeEnemy:
    imageName = @"enemy-bullet";
    maxHp = 1;
    break;
  default:
    return nil;
  }
  if ((self = [super initWithImageNamed:imageName maxHp:maxHp])) {
    _laserType = laserType;
  }
  return self;
  
}

- (void)configureCollisionBody
{
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
  self.physicsBody.affectedByGravity = NO;
  self.physicsBody.categoryBitMask = _laserType == LaserTypePlayer ? EntityCategoryPlayerLaser : EntityCategoryEnemyLaser;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = _laserType == LaserTypePlayer ? EntityCategoryAsteroid | EntityCategoryEnemy : EntityCategoryPlayer;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
  [self destroy];
}

- (void)cleanup {
  [self removeFromParent];
}

@end
