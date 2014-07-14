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
- (void) setCurrentPlayerIndex:(NSUInteger)index;
- (void) setPositionOfCarAtIndex:(NSUInteger)index dx:(CGFloat)dx dy:(CGFloat)dy rotation:(CGFloat)rotation;
- (void) gameOver:(BOOL)didLocalPlayerWin;
- (void) setPlayerLabelsInOrder:(NSArray*)playerAliases;

/*Multiplayer challenge 1*/
- (void)setPlayerPhotosInOrder:(NSArray*)playerPhotos;
@end

@interface MultiplayerNetworking : NSObject<GameKitHelperDelegate>
@property (nonatomic, assign) id<MultiplayerProtocol> delegate;
@property (nonatomic) NSUInteger noOfLaps;

- (void)sendMove:(float)dx yPosition:(float)dy
        rotation:(float)rotation;
- (void)sendLapComplete;
@end
