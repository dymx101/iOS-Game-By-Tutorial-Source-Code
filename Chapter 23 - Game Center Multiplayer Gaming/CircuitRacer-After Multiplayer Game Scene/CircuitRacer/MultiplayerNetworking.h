//
//  MultiplayerNetworking.h
//  CircuitRacer
//
//  Created by Kauserali on 27/09/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "GameKitHelper.h"

@protocol MultiplayerProtocol <NSObject>
- (void) matchEnded;
@end

@interface MultiplayerNetworking : NSObject<GameKitHelperDelegate>
@property (nonatomic, assign) id<MultiplayerProtocol> delegate;
@property (nonatomic) NSUInteger noOfLaps;
@end
