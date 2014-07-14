//
//  GameKitHelper.m
//  CircuitRacer
//
//  Created by Main Account on 9/23/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "GameKitHelper.h"

NSString *const PresentAuthenticationViewController =
  @"present_authentication_view_controller";

@interface GameKitHelper()<GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate>
@end

@implementation GameKitHelper {
  BOOL _enableGameCenter;
  BOOL _multiplayerMatchStarted;
  UIViewController *_presentingViewController;
}

+ (instancetype)sharedGameKitHelper
{
  static GameKitHelper *sharedGameKitHelper;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedGameKitHelper = [[GameKitHelper alloc] init];
  });
  return sharedGameKitHelper;
}

- (id)init
{
  self = [super init];
  if (self) {
    _enableGameCenter = YES;
  }
  return self;
}

- (void)authenticateLocalPlayer
{
  //1
  GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
  //2
  localPlayer.authenticateHandler  =
    ^(UIViewController *viewController, NSError *error) {
      //3
      [self setLastError:error];
      
      if(viewController != nil) {
        //4
        [self setAuthenticationViewController:viewController];
      } else if([GKLocalPlayer localPlayer].isAuthenticated) {
        //5
        _enableGameCenter = YES;
      } else {
        //6
        _enableGameCenter = NO;
      }
  };
}

- (void)setAuthenticationViewController:
  (UIViewController *)authenticationViewController
{
  if (authenticationViewController != nil) {
    _authenticationViewController = authenticationViewController;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:PresentAuthenticationViewController
     object:self];
  }
}

- (void)setLastError:(NSError *)error
{
  _lastError = [error copy];
  if (_lastError) {
    NSLog(@"GameKitHelper ERROR: %@",
          [[_lastError userInfo] description]);
  }
}

- (void)reportAchievements:(NSArray *)achievements
{
  if (!_enableGameCenter) {
    NSLog(@"Local play is not authenticated");
  }
  [GKAchievement reportAchievements:achievements
              withCompletionHandler:^(NSError *error ){
                [self setLastError:error];
              }];
}

- (void)showGKGameCenterViewController:
  (UIViewController *)viewController
{
  if (!_enableGameCenter) {
    NSLog(@"Local play is not authenticated");
  }
  //1
  GKGameCenterViewController *gameCenterViewController =
    [[GKGameCenterViewController alloc] init];
    
  //2
  gameCenterViewController.gameCenterDelegate = self;
    
  //3
  gameCenterViewController.viewState =
    GKGameCenterViewControllerStateDefault;
    
  //4
  [viewController presentViewController:gameCenterViewController
                               animated:YES
                             completion:nil];
}

- (void)gameCenterViewControllerDidFinish:
  (GKGameCenterViewController *)gameCenterViewController
{
  [gameCenterViewController dismissViewControllerAnimated:YES
                                               completion:nil];
}

- (void)reportScore:(int64_t)score
   forLeaderboardID:(NSString *)leaderboardID
{
  if (!_enableGameCenter) {
    NSLog(@"Local play is not authenticated");
  }
  //1
  GKScore *scoreReporter = 
    [[GKScore alloc] 
     initWithLeaderboardIdentifier:leaderboardID];
  scoreReporter.value = score;
  scoreReporter.context = 0;
    
  NSArray *scores = @[scoreReporter];
    
  //2
  [GKScore reportScores:scores
   withCompletionHandler:^(NSError *error) {
     [self setLastError:error];
   }];
}

- (void)lookupPlayersOfAMatch:(GKMatch*)match
{
  NSLog(@"Looking up %d players", match.playerIDs.count);
    
  [GKPlayer loadPlayersForIdentifiers:match.playerIDs
                withCompletionHandler:
    ^(NSArray *players, NSError *error){
      if (error) {
        NSLog(@"Error looking up players of multiplayer match:%@",
          error.localizedDescription);
        _multiplayerMatchStarted = NO;
        [_delegate matchEnded];
      } else {
        _playersDictionary =
          [NSMutableDictionary
            dictionaryWithCapacity:players.count + 1];
        for (GKPlayer *player in players) {
          NSLog(@"Found player: %@", player.alias);
          [_playersDictionary setObject:player
                                 forKey:player.playerID];
        }
        [_playersDictionary setObject:[GKLocalPlayer localPlayer] forKey:[GKLocalPlayer localPlayer].playerID];
        _multiplayerMatchStarted = YES;
        [_delegate matchStarted];
      }
  }];
}

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
       presentingViewController:(UIViewController*)viewController
                       delegate:(id<GameKitHelperDelegate>)delegate
{
  //1
  if (!_enableGameCenter) {
    NSLog(@"Local player is not authenticated");
    return;
  }
    
  //2
  _multiplayerMatchStarted = NO;
  _multiplayerMatch = nil;
  _delegate = delegate;
  _presentingViewController = viewController;
    
  //3
  GKMatchRequest *matchRequest = [[GKMatchRequest alloc] init];
  matchRequest.minPlayers = minPlayers;
  matchRequest.maxPlayers = maxPlayers;
    
  //4
  GKMatchmakerViewController *matchMakerViewController =
    [[GKMatchmakerViewController alloc]
     initWithMatchRequest:matchRequest];
  matchMakerViewController.matchmakerDelegate = self;
  [_presentingViewController
    presentViewController:matchMakerViewController
    animated:NO completion:nil];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID
{
  if (_multiplayerMatch != match)
    return;
    
  [_delegate match:match didReceiveData:data
        fromPlayer:playerID];
}

- (void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
  if (_multiplayerMatch != match)
    return;
    
  _multiplayerMatchStarted = NO;
  [_delegate matchEnded];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID
   didChangeState:(GKPlayerConnectionState)state
{
  if (_multiplayerMatch != match)
    return;
    
  switch (state) {
    case GKPlayerStateConnected:
      NSLog(@"Player connected");
      if (!_multiplayerMatchStarted &&
        _multiplayerMatch.expectedPlayerCount == 0) {
        [self lookupPlayersOfAMatch:_multiplayerMatch];
      }
      break;
    case GKPlayerStateDisconnected:
      NSLog(@"Player disconnected");
      _multiplayerMatchStarted = NO;
      [_delegate matchEnded];
      break;
  }
}

#pragma mark GKMatchMakerViewController delegate methods

- (void)matchmakerViewControllerWasCancelled:
   (GKMatchmakerViewController *)viewController
{
  [_presentingViewController dismissViewControllerAnimated:YES
                                                completion:nil];
  [_delegate matchEnded];
}

- (void)matchmakerViewController:
   (GKMatchmakerViewController *)viewController
                didFailWithError:(NSError *)error
{
  [_presentingViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
  NSLog(@"Error creating a match: %@",
    error.localizedDescription);
  [_delegate matchEnded];
}

- (void)matchmakerViewController:
   (GKMatchmakerViewController *)viewController
                    didFindMatch:(GKMatch *)match
{
  [_presentingViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
  _multiplayerMatch = match;
  _multiplayerMatch.delegate = self;
  if (!_multiplayerMatchStarted &&
    _multiplayerMatch.expectedPlayerCount == 0) {
    [self lookupPlayersOfAMatch:_multiplayerMatch];
  }
}

@end
