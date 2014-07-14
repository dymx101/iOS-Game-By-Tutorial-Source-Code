//
//  MyScene.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MyScene.h"
#import "TileMapLayer.h"
#import "TileMapLayerLoader.h"
#import "Player.h"

@implementation MyScene {
  SKNode *_worldNode;
  TileMapLayer *_bgLayer;
  Player *_player;
}

- (id)initWithSize:(CGSize)size 
{
  if (self = [super initWithSize:size]) {
    [self createWorld];
    [self createCharacters];
    [self centerViewOn:_player.position];
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  UITouch *touch = [touches anyObject];
  [_player moveToward:[touch locationInNode:_worldNode]];
}

- (TileMapLayer *)createScenery
{
  return [TileMapLayerLoader tileMapLayerFromFileNamed:
          @"level-1-bg.txt"];
}

- (void)createWorld
{
  _bgLayer = [self createScenery];
  
  _worldNode = [SKNode node];
  [_worldNode addChild:_bgLayer];
  [self addChild:_worldNode];
  
  self.anchorPoint = CGPointMake(0.5, 0.5);
  _worldNode.position =
    CGPointMake(-_bgLayer.layerSize.width / 2,
                -_bgLayer.layerSize.height / 2);
  
  self.physicsWorld.gravity = CGVectorMake(0, 0);
  
  SKNode *bounds = [SKNode node];
  bounds.physicsBody =
    [SKPhysicsBody bodyWithEdgeLoopFromRect:
      CGRectMake(0, 0, 
                 _bgLayer.layerSize.width,
                 _bgLayer.layerSize.height)];
  bounds.physicsBody.categoryBitMask = PCBoundaryCategory;
  bounds.physicsBody.friction = 0;
  [_worldNode addChild:bounds];
  
}

- (void)centerViewOn:(CGPoint)centerOn
{
  _worldNode.position = [self pointToCenterViewOn:centerOn];
}

- (void)createCharacters
{
  _player = [Player node];
  _player.position = CGPointMake(300, 300);
  [_worldNode addChild:_player];
}

- (void)didSimulatePhysics
{
  CGPoint target = [self pointToCenterViewOn:_player.position];
  
  CGPoint newPosition = _worldNode.position;
  newPosition.x += (target.x - _worldNode.position.x) * 0.1f;
  newPosition.y += (target.y - _worldNode.position.y) * 0.1f;
    
  _worldNode.position = newPosition;
}

- (CGPoint)pointToCenterViewOn:(CGPoint)centerOn
{
  CGSize size = self.size;
  
  CGFloat x = Clamp(centerOn.x, size.width / 2,
                    _bgLayer.layerSize.width - size.width / 2);
  
  CGFloat y = Clamp(centerOn.y, size.height / 2,
                    _bgLayer.layerSize.height - size.height/2);
  
  return CGPointMake(-x, -y);
}

@end
