//
//  Enemy.m
//  BulletStorm
//
//  Created by Main Account on 10/9/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Enemy.h"
#import "SKEmitterNode+SKTExtras.h"
#import "AISteering.h"
#import "SKTUtils.h"
#import "MyScene.h"

@implementation Enemy {
  SKEmitterNode *_emitter;
  AISteering *_aiSteering;
}

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"enemy-ship" maxHp:2])) {
    [self configureCollisionBody];
  }
  return self;
}

- (void)configureCollisionBody {
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
  self.physicsBody.affectedByGravity = NO;
  self.physicsBody.categoryBitMask = EntityCategoryEnemy;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayerLaser;
}

- (void)update:(CFTimeInterval)dt {
  if (_aiSteering.waypoint.x < self.position.x) {
    if (!_emitter) {
      _emitter = [SKEmitterNode skt_emitterNamed:@"EnemyTrail"];
      _emitter.targetNode = self.parent;
      _emitter.position = CGPointMake(30, 5);
      _emitter.zPosition = -1;
      [self addChild:_emitter];
    }
  }
  
  if (!_aiSteering) {
     CGPoint initialWaypoint = CGPointMake(self.scene.size.width * 0.4,
                                        RandomFloatRange(0, self.scene.size.height));
    _aiSteering = [[AISteering alloc] initWithEntity:self waypoint:initialWaypoint];
  }
  if (_aiSteering.waypointReached) {
    [_aiSteering updateWaypoint:
     CGPointMake(RandomFloatRange(self.scene.size.width * 0.4, self.scene.size.width),
                 RandomFloatRange(0, self.scene.size.height))];
  }
  [_aiSteering update:dt];
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact {
  [self takeHit];
  ExplosionType explosionType;
  if ([self dead]) {
    explosionType = ExplosionTypeLarge;
  } else {
    explosionType = ExplosionTypeSmall;
  }
  MyScene * scene = (MyScene *)self.scene;
  [scene createExplosionType:explosionType atPosition:contact.contactPoint];
}

@end
