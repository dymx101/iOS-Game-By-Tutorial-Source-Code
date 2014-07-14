//
//  TileMapLayer.h
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TileMapLayer : SKNode

@property (readonly,nonatomic) CGSize tileSize;
@property (readonly,nonatomic) CGSize gridSize;
@property (readonly,nonatomic) CGSize layerSize;

- (instancetype)initWithAtlasNamed:(NSString *)atlasName
                          tileSize:(CGSize)tileSize
                              grid:(NSArray *)tileCodes;
- (BOOL)isValidTileCoord:(CGPoint)coord;
- (CGPoint)pointForCoord:(CGPoint)coord;
- (CGPoint)coordForPoint:(CGPoint)point;
- (SKNode*)tileAtCoord:(CGPoint)coord;
- (SKNode*)tileAtPoint:(CGPoint)point;

@end
