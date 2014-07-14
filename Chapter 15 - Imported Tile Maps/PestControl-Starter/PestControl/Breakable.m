//
//  Breakable.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Breakable.h"
#import "MyScene.h"

@implementation Breakable {
  SKTexture *_broken;
}

- (instancetype)initWithWhole:(SKTexture *)whole
                       broken:(SKTexture *)broken {

  if (self = [super initWithTexture:whole]) {

    _broken = broken;
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width*0.8, self.size.height*0.8)];
    self.physicsBody.dynamic = NO;
    self.physicsBody.categoryBitMask = PCBreakableCategory;

  }
  return self;
}

- (void)smashBreakable {
  self.physicsBody = nil;
  self.texture = _broken;
  self.size = _broken.size;
}

@end
