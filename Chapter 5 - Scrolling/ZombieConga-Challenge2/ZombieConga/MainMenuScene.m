//
//  MainMenuScene.m
//  ZombieConga
//
//  Created by Main Account on 8/28/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MainMenuScene.h"
#import "MyScene.h"

@implementation MainMenuScene

- (instancetype)initWithSize:(CGSize)size {
  if ((self = [super initWithSize:size])) {
    SKSpriteNode * bg = [SKSpriteNode spriteNodeWithImageNamed:@"MainMenu"];
    bg.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:bg];
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  MyScene * myScene =
  [[MyScene alloc] initWithSize:self.size];
  
  SKTransition *reveal =
  [SKTransition doorwayWithDuration:0.5];
  
  [self.view presentScene:myScene transition: reveal];
}

@end
