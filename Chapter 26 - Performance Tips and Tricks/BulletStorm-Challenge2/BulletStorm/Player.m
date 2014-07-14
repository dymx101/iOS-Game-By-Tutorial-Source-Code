//
//  Player.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Player.h"
#import "SKEmitterNode+SKTExtras.h"

@implementation Player {
  SKEmitterNode *_emitter;
}

- (instancetype)init {
  if ((self = [super initWithImageNamed:@"player-ship" maxHp:10])) {
    [self configureCollisionBody];
    [self configureParticleSystem];
  }
  return self;
}

- (void)configureCollisionBody {
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
  self.physicsBody.affectedByGravity = NO;
  self.physicsBody.categoryBitMask = EntityCategoryPlayer;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryAsteroid;
}

- (void)configureParticleSystem {
  _emitter = [SKEmitterNode skt_emitterNamed:@"PlayerTrail"];
  _emitter.targetNode = self.parent;
  _emitter.zPosition = -1;
  [self addChild:_emitter];
}

@end
