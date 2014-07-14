//
//  LoadingScene.m
//  MemoryHog
//
//  Created by Ray Wenderlich on 9/16/13.
//  Copyright (c) 2013 Rod Strougo. All rights reserved.
//

#import "LoadingScene.h"
#import "MyScene.h"
@implementation LoadingScene

- (id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor blackColor];
    
    SKLabelNode * text = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    text.fontSize = 32.0;
    text.text = @"Loading...";
    text.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:text];
    
    [text runAction:[SKAction repeatActionForever:
                     [SKAction sequence:@[
                                          [SKAction scaleTo:1.5 duration:0.5],
                                          [SKAction scaleTo:1.0 duration:0.5],
                                          ]]]];
    
  }
  return self;
}

- (void)didMoveToView:(SKView *)view {
  
  [self startMySceneWithTextureAtlases:nil];

}

- (void)startMySceneWithTextureAtlases:(NSArray *)textureAtlases {
  
  MyScene * myScene = [[MyScene alloc] initWithSize:self.size textureAtlases:textureAtlases];
  SKTransition *reveal =
  [SKTransition flipHorizontalWithDuration:0.5];
  [self.view presentScene:myScene transition:reveal];
  
}

@end
