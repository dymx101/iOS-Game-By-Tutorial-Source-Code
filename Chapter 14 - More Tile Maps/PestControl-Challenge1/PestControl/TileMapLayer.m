//
//  TileMapLayer.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "TileMapLayer.h"
#import "Bug.h"
#import "Player.h"
#import "MyScene.h"
#import "Breakable.h"

@implementation TileMapLayer {
  SKTextureAtlas *_atlas;
}

- (SKSpriteNode*)nodeForCode:(unichar)tileCode
{
  SKSpriteNode *tile;

  // 1
  switch (tileCode) {
    case 'x':
      tile = [SKSpriteNode spriteNodeWithTexture:
               [_atlas textureNamed:@"wall"]];
      tile.physicsBody =
        [SKPhysicsBody bodyWithRectangleOfSize:tile.size];
      tile.physicsBody.categoryBitMask = PCWallCategory;
      tile.physicsBody.dynamic = NO;
      tile.physicsBody.friction = 0;
      break;
    case '=':
      tile = [SKSpriteNode spriteNodeWithTexture:
               [_atlas textureNamed:@"stone"]];
      break;
    case 'o':
      tile = [SKSpriteNode spriteNodeWithTexture:
              [_atlas textureNamed:
                RandomFloat() < 0.1 ? @"grass2" : @"grass1"]];
      break;
    case 'w':
      tile = [SKSpriteNode spriteNodeWithTexture:
              [_atlas textureNamed:
                RandomFloat() < 0.1 ? @"water2" : @"water1"]];

      tile.physicsBody =
        [SKPhysicsBody bodyWithRectangleOfSize:tile.size];
      tile.physicsBody.categoryBitMask = PCWaterCategory;
      tile.physicsBody.dynamic = NO;
      tile.physicsBody.friction = 0;
      break;
    case '.':
      return nil;
      break;
    case 'b':
      return [Bug node];
      break;
    case 'p':
      return [Player node];
      break;
    case 't':
      return [[Breakable alloc] initWithWhole:[_atlas textureNamed:@"tree"] broken:[_atlas textureNamed:@"tree-stump"]];
    default:
      NSLog(@"Unknown tile code: %d",tileCode);
      break;
  }
  // 2
  tile.blendMode = SKBlendModeReplace;
  tile.texture.filteringMode = SKTextureFilteringNearest;  
  return tile;
}

- (instancetype)initWithAtlasNamed:(NSString *)atlasName
                          tileSize:(CGSize)tileSize
                              grid:(NSArray *)grid
{
  if (self = [super init])
  {
    _atlas = [SKTextureAtlas atlasNamed:atlasName];

    _tileSize = tileSize;
    _gridSize = CGSizeMake([grid.firstObject length], grid.count);
    _layerSize = CGSizeMake(_tileSize.width * _gridSize.width,
                            _tileSize.height * _gridSize.height);

    for (int row = 0; row < grid.count; row++) {
      NSString *line = grid[row];
      for(int col = 0; col < line.length; col++) {
        SKSpriteNode *tile = 
          [self nodeForCode:[line characterAtIndex:col]];
        if (tile != nil) {
          tile.position = [self positionForRow:row col:col];
          [self addChild:tile];
        }
      }
    }
  }
  return self;
}

- (CGPoint)positionForRow:(NSInteger)row col:(NSInteger)col
{
  return
  CGPointMake(
    col * self.tileSize.width + self.tileSize.width / 2,
    self.layerSize.height -
      (row * self.tileSize.height + self.tileSize.height / 2));
}

- (BOOL)isValidTileCoord:(CGPoint)coord
{
  return (coord.x >= 0 &&
          coord.y >= 0 &&
          coord.x < self.gridSize.width &&
          coord.y < self.gridSize.height);
}

- (CGPoint)coordForPoint:(CGPoint)point
{
  return CGPointMake((int)(point.x / self.tileSize.width),
                     (int)((point.y - self.layerSize.height) /
                           -self.tileSize.height));
}

- (CGPoint)pointForCoord:(CGPoint)coord
{
  return [self positionForRow:coord.y col:coord.x];
}

- (SKNode*)tileAtCoord:(CGPoint)coord
{
  return [self tileAtPoint:[self pointForCoord:coord]];
}

- (SKNode*)tileAtPoint:(CGPoint)point
{
  SKNode *n = [self nodeAtPoint:point];
  while (n && n != self && n.parent != self)
    n = n.parent;
  return n.parent == self ? n : nil;
}

@end
