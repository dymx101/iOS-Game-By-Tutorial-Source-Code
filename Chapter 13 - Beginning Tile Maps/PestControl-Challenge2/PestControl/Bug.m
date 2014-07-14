//
//  Bug.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "Bug.h"

@implementation Bug

- (instancetype)init
{
  SKTextureAtlas *atlas = 
    [SKTextureAtlas atlasNamed: @"characters"];
  SKTexture *texture = [atlas textureNamed:@"bug_ft1"];
  texture.filteringMode = SKTextureFilteringNearest;

  if (self = [super initWithTexture:texture]) {
    self.name = @"bug";
  }
  return self;
}

@end
