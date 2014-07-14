//
//  OldTVNode.m
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "OldTVNode.h"
#import <AVFoundation/AVFoundation.h> 
#import "Physics.h"

@implementation OldTVNode {
  AVPlayer *_player;
  SKVideoNode *_videoNode;
}

- (id)initWithRect:(CGRect)frame
{
  // 1
  if (self = [super initWithImageNamed:@"tv"]) {
    self.name = @"TVNode";
    // 2
    SKSpriteNode *tvMaskNode =
      [SKSpriteNode spriteNodeWithImageNamed:@"tv-mask"];
    tvMaskNode.size = frame.size;
    SKCropNode *cropNode = [SKCropNode node];
    cropNode.maskNode = tvMaskNode;
    // 3
    NSURL *fileURL =
    [NSURL fileURLWithPath:
     [[NSBundle mainBundle] pathForResource:@"BookTrailer"
                                     ofType:@"m4v"]];
    _player = [AVPlayer playerWithURL: fileURL];
    // 4
    _videoNode = [[SKVideoNode alloc] initWithAVPlayer:_player];
    _videoNode.size = 
      CGRectInset(frame, 
                  frame.size.width * .15,
                  frame.size.height * .27).size;
    _videoNode.position = CGPointMake(-frame.size.width * .1,
                                      -frame.size.height * .06);
    // 5
    [cropNode addChild:_videoNode];
    [self addChild:cropNode];
    // 6
    self.position = frame.origin;
    self.size = frame.size;
    // 7
    _player.volume = 0.0;
    
    CGRect bodyRect = CGRectInset(frame, 2, 2);
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: bodyRect.size];

    self.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
    self.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
    
    [_videoNode play];
  }
  return self;
}

@end
