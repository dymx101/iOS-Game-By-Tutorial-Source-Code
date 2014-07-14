//
//  Entity.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Entity.h"
#import "MyScene.h"

@implementation Entity {
  float _hp;
}

- (instancetype)initWithImageNamed:(NSString *)name maxHp:(int)maxHp {
  
  if ((self = [super initWithImageNamed:name])) {
    _maxHp = maxHp;
    _hp = maxHp;
  }
  return self;
  
}

- (BOOL)dead {
  return _hp == 0;
}

- (void)takeHit {
  if (_hp > 0) {
    _hp--;
  }
  if (_hp == 0) {
    [self destroy];
  }
}

- (void)destroy {
  _hp = 0;
  self.physicsBody = nil;
  [self removeAllActions];
  [self runAction:
    [SKAction sequence:@[
      [SKAction fadeAlphaTo:0 duration:0.2],
      [SKAction runBlock:^{
        [self cleanup];
      }]
    ]]
  ];
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact {
}

- (void)cleanup {
  [self removeFromParent];
}

- (void)update:(CFTimeInterval)dt {
}

@end
