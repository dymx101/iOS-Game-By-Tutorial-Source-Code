//
//  TileMapLayer.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "TileMapLayer.h"

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
      break;
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

@end
