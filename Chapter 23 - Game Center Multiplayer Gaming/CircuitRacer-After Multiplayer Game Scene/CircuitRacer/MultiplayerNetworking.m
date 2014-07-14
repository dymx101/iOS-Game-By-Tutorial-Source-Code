//
//  MultiplayerNetworking.m
//  CircuitRacer
//
//  Created by Kauserali on 27/09/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MultiplayerNetworking.h"
#import "GameKitHelper.h"

@implementation MultiplayerNetworking

- (id)init
{
  if (self = [super init]) {
      
  }
  return self;
}


#pragma mark GameKitHelper

- (void)matchStarted
{
  NSLog(@"Match has started successfully");
}

- (void)matchEnded
{
  NSLog(@"Match has ended");
  [_delegate matchEnded];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerId
{
    
}
@end
