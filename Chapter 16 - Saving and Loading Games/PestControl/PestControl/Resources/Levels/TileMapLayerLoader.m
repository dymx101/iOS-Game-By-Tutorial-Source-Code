//
//  TileMapLayerLoader.m
//  PestControl
//
//  Created by Christopher LaPollo on 7/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "TileMapLayerLoader.h"

@implementation TileMapLayerLoader

+ (TileMapLayer *)tileMapLayerFromFileNamed:(NSString *)fileName
{
  // file must be in bundle
  NSString *path = [[NSBundle mainBundle] pathForResource:fileName
                                                   ofType:nil];
  NSError *error;
  NSString *fileContents = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
  // if there was an error, there is nothing to be done.
  // Should never happen in properly configured system.
  if (fileContents == nil && error) {
    NSLog(@"Error reading file: %@", error.localizedDescription);
    return nil;
  }

  // get the contents of the file, separated into lines
  NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
  
  // first line contains the atlas name for this layer's tiles
  NSString *atlasName = lines[0];

  // second line contains tile size, in form width x height
  NSArray *tileSizeComps = [lines[1] componentsSeparatedByString:@"x"];
  
  CGSize tileSize = CGSizeMake([tileSizeComps.firstObject floatValue],
                               [tileSizeComps.lastObject floatValue]);

  // remaining lines are the grid. It's assumed that all rows are same length
  NSArray *grid = [lines subarrayWithRange:NSMakeRange(2, lines.count-2)];

  return [[TileMapLayer alloc] initWithAtlasNamed:atlasName
                                         tileSize:tileSize
                                             grid:grid];
}

@end
