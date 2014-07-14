//
//  Entity.h
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class MyScene;

typedef NS_OPTIONS(uint32_t, EntityCategory)
{
  EntityCategoryPlayer      = 1 << 0,
  EntityCategoryAsteroid    = 1 << 1,
  EntityCategoryEnemy       = 1 << 2,
  EntityCategoryPlayerLaser = 1 << 3,
  EntityCategoryEnemyLaser  = 1 << 4
};

@interface Entity : SKSpriteNode

@property (nonatomic, assign) int maxHp;

- (instancetype)initWithImageNamed:(NSString *)name maxHp:(int)maxHp;
- (BOOL)dead;
- (void)takeHit;
- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact;
- (void)update:(CFTimeInterval)dt;
- (void)cleanup;
- (void)destroy;

@end
