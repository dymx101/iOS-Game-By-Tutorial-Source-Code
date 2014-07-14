//
//  Asteroid.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Asteroid.h"
#import "SKTUtils.h"
#import "MyScene.h"
#import "SKEmitterNode+SKTExtras.h"

@implementation Asteroid {
  SKEmitterNode *_emitter;
}

- (instancetype)initWithAsteroidType:(AsteroidType)asteroidType {
  NSString *imageName;
  int maxHp;
  float rotateDuration;
  float emitterScale;
  float emitterSpeed;
  switch (asteroidType) {
  case AsteroidTypeSmall:
    imageName = @"asteroid-small";
    maxHp = 1;
    rotateDuration = 1.0;
    emitterScale = 1.0;
    emitterSpeed = 0.75;
    break;
  case AsteroidTypeMedium:
    imageName = @"asteroid-medium";
    maxHp = 2;
    rotateDuration = 2.0;
    emitterScale = 2.0;
    emitterSpeed = 1.0;
    break;
  case AsteroidTypeLarge:
    imageName = @"asteroid-large";
    maxHp = 4;
    rotateDuration = 3.0;
    emitterScale = 4.0;
    emitterSpeed = 2.0;
    break;
  default:
    return nil;
  }
  if ((self = [super initWithImageNamed:imageName maxHp:maxHp])) {
    [self configureCollisionBody];
    [self configureEmitterWithScale:emitterScale speed:emitterSpeed];
    [self runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:DegreesToRadians(360) duration:rotateDuration]]];
  }
  return self;
  
}

- (void)configureCollisionBody
{
  self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
  self.physicsBody.affectedByGravity = NO;
  self.physicsBody.categoryBitMask = EntityCategoryAsteroid;
  self.physicsBody.collisionBitMask = 0;
  self.physicsBody.contactTestBitMask = EntityCategoryPlayer;
}

- (void)configureEmitterWithScale:(float)scale speed:(float)speed {
  _emitter = [SKEmitterNode skt_emitterNamed:@"AsteroidTrail"];
  _emitter.zPosition = -1;
  _emitter.particleScale = scale;
  _emitter.particleSpeed *= speed;
  [_emitter advanceSimulationTime:1.0];
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

- (void)update:(CFTimeInterval)dt {
  if (_emitter) {
    if (_emitter.parent == nil) {
      [self.parent addChild:_emitter];
    }
    _emitter.position = self.position;
  }
}

- (void)cleanup {
  [super cleanup];
  [_emitter removeFromParent];
  _emitter = nil;
}

@end
