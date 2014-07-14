//
//  GameKitHelper.h
//  CircuitRacer
//
//  Created by Main Account on 9/23/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <GameKit/GameKit.h>

extern NSString *const PresentAuthenticationViewController;

@protocol GameKitHelperDelegate <NSObject>
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerId;
@end

@interface GameKitHelper : NSObject

@property (nonatomic, readonly) 
  UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

@property (nonatomic,assign) id<GameKitHelperDelegate> delegate;
@property (nonatomic,strong) GKMatch *multiplayerMatch;

@property (nonatomic, strong) NSMutableDictionary *playersDictionary;

+ (instancetype)sharedGameKitHelper;
- (void)authenticateLocalPlayer;
- (void)reportAchievements:(NSArray *)achievements;
- (void)showGKGameCenterViewController:
  (UIViewController *)viewController;
- (void)reportScore:(int64_t)score
   forLeaderboardID:(NSString*)leaderboardID;

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
       presentingViewController:(UIViewController *)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate;
@end
