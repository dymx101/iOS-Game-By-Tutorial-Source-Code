//
//  Explosion.m
//  BulletStorm
//
//  Created by Main Account on 10/8/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Explosion.h"

@implementation Explosion

- (instancetype)initWithExplosionType:(ExplosionType)explosionType {
  if ((self = [super initWithImageNamed:@"explosion0001" maxHp:1])) {
    
    int NUM_EXPLOSION_FRAMES = 3;
    float TIME_PER_FRAME = 0.1;
    float ANIM_DURATION = NUM_EXPLOSION_FRAMES * TIME_PER_FRAME;
    
    self.scale = 0;
    
    NSArray * textures = @[
      [SKTexture textureWithImageNamed:@"explosion0001"],
      [SKTexture textureWithImageNamed:@"explosion0002"],
      [SKTexture textureWithImageNamed:@"explosion0003"],
    ];
    SKAction *animation =
      [SKAction animateWithTextures:textures timePerFrame:TIME_PER_FRAME];
    
    [self runAction:[SKAction sequence:@[
      [SKAction group:@[
        animation,
        [SKAction scaleTo:0.5 duration:ANIM_DURATION],
      ]],
      [SKAction group:@[
        [SKAction fadeAlphaTo:0 duration:ANIM_DURATION*2],
        [SKAction scaleTo:1.0 duration:ANIM_DURATION*2]
      ]],
      [SKAction removeFromParent]
    ]]];
    
  }
  return self;
  
}

@end
