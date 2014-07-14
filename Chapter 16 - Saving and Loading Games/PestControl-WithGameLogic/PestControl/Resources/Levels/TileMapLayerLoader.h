//
//  TileMapLayerLoader.h
//  PestControl
//
//  Created by Christopher LaPollo on 7/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "TileMapLayer.h"

@interface TileMapLayerLoader : NSObject

+ (TileMapLayer *)tileMapLayerFromFileNamed:(NSString *)fileName;

@end
