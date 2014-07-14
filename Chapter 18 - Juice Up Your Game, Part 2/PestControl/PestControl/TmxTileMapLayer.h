//
//  TmxTileMapLayer.h
//  PestControl
//
//  Created by Christopher LaPollo on 9/2/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "TileMapLayer.h"
#import "JSTileMap.h"

@interface TmxTileMapLayer : TileMapLayer

- (instancetype)initWithTmxLayer:(TMXLayer*)layer;
- (instancetype)initWithTmxObjectGroup:(TMXObjectGroup *)group
                              tileSize:(CGSize)tileize
                              gridSize:(CGSize)gridSize;
@end
