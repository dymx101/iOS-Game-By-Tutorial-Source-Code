//
//  MyScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *bg =
      [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    bg.position =
      CGPointMake(self.size.width/2, self.size.height/2);
    bg.position =
      CGPointMake(self.size.width / 2, self.size.height / 2);
    bg.anchorPoint = CGPointMake(0.5, 0.5); // same as default
    //bg.zRotation = M_PI / 8;
    [self addChild:bg];
    CGSize mySize = bg.size;
    NSLog(@"Size: %@", NSStringFromCGSize(mySize));    
  }
  return self;
}

@end
