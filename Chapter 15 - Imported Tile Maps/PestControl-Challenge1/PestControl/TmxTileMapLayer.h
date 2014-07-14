//
//  TmxTileMapLayer.h
//  PestControl
//
//  Created by Main Account on 9/17/13.
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
