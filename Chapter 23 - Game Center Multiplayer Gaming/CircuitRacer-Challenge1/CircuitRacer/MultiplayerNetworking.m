//
//  MultiplayerNetworking.m
//  CircuitRacer
//
//  Created by Kauserali on 27/09/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "MultiplayerNetworking.h"
#import "GameKitHelper.h"

typedef NS_ENUM(NSInteger, GameState) {
  kGameStateWaitingForMatch = 0,
  kGameStateWaitingForRandomNumber,
  kGameStateWaitingForStart,
  kGameStatePlaying,
  kGameStateDone
};

typedef NS_ENUM(NSInteger, MessageType) {
  kMessageTypeRandomNumber,
  kMessageTypeGameBegin,
  kMessageTypeMove,
  kMessageTypeLapComplete,
  kMessageTypeGameOver
};

typedef struct {
  MessageType messageType;
} Message;

typedef struct {
  Message message;
  uint32_t randomNumber;
} MessageRandomNumber;

typedef struct {
  Message message;
} MessageGameBegin;

typedef struct {
  Message message;
  float dx, dy, rotate;
} MessageMove;

typedef struct {
  Message message;
} MessageLapComplete;

typedef struct {
  Message message;
} MessageGameOver;

#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"

@implementation MultiplayerNetworking {
  uint32_t _ourRandomNumber;
  GameState _gameState;
  BOOL _isPlayer1, _receivedAllRandomNumbers;
    
  NSMutableArray *_orderOfPlayers;
  NSMutableDictionary *_lapCompleteInformation;
}

- (id)init
{
  if (self = [super init]) {
    _ourRandomNumber = arc4random();
    _gameState = kGameStateWaitingForMatch;
    _orderOfPlayers = [NSMutableArray array];
    [_orderOfPlayers addObject:@{playerIdKey : [GKLocalPlayer localPlayer].playerID,
                             randomNumberKey : @(_ourRandomNumber)}];
    _lapCompleteInformation = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark networking code

- (void)sendData:(NSData*)data
{
  NSError *error;
  GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
    
  BOOL success = [gameKitHelper.multiplayerMatch
                   sendDataToAllPlayers:data
                   withDataMode:GKMatchSendDataReliable
                   error:&error];
  if (!success) {
    NSLog(@"Error sending data:%@", error.localizedDescription);
    [self matchEnded];
  }
}

- (void)sendRandomNumber
{
  MessageRandomNumber message;
  message.message.messageType = kMessageTypeRandomNumber;
  message.randomNumber = _ourRandomNumber;
  NSData *data =
    [NSData dataWithBytes:&message
                   length:sizeof(MessageRandomNumber)];
  [self sendData:data];
}

- (void)sendBeginGame
{
  MessageGameBegin message;
  message.message.messageType = kMessageTypeGameBegin;
  NSData *data =
    [NSData dataWithBytes:&message
                   length:sizeof(MessageGameBegin)];
  [self sendData:data];
  [self retrieveAllPlayerAliases];
  [self retrieveAllPlayerPhotos];
}

- (void)sendMove:(float)dx yPosition:(float)dy
        rotation:(float)rotation
{
  MessageMove messageMove;
  messageMove.dx = dx;
  messageMove.dy = dy;
  messageMove.rotate = rotation;
  messageMove.message.messageType = kMessageTypeMove;
  NSData *data = [NSData dataWithBytes:&messageMove
                                length:sizeof(MessageMove)];
  [self sendData:data];
}

- (void)sendGameOverMessage
{
  MessageGameOver gameOverMessage;
  gameOverMessage.message.messageType = kMessageTypeGameOver;
  NSData *data = [NSData dataWithBytes:&gameOverMessage
                                length:sizeof(MessageGameOver)];
  [self sendData:data];
}

- (void)sendLapComplete
{
  MessageLapComplete lapCompleteMessage;
  lapCompleteMessage.message.messageType = kMessageTypeLapComplete;
  NSData *data =
    [NSData dataWithBytes:&lapCompleteMessage
                   length:sizeof(MessageLapComplete)];
  [self sendData:data];
  [self reduceNoOfLapsForPlayer:[GKLocalPlayer localPlayer].playerID];
    
  if ([self isGameOver] && _isPlayer1) {
    [self sendGameOverMessage];
    [self.delegate gameOver:[self hasLocalPlayerWon]];
  }
}

#pragma mark Helper methods

- (void)tryStartGame
{
  if (_isPlayer1 && _gameState == kGameStateWaitingForStart) {
    _gameState = kGameStatePlaying;
    [self sendBeginGame];
        
    //first player
    [self.delegate setCurrentPlayerIndex:0];
  }
}

- (void)reduceNoOfLapsForPlayer:(NSString*)playerId
{
  NSNumber *laps = _lapCompleteInformation[playerId];
  laps = [NSNumber numberWithUnsignedInteger:laps.integerValue - 1];
  _lapCompleteInformation[playerId] = laps;
}

- (void)setupLapCompleteInformation
{
  NSArray *array = [GameKitHelper sharedGameKitHelper].multiplayerMatch.playerIDs;
    
  for (NSString *playerId in array) {
    [_lapCompleteInformation setObject:@(_noOfLaps) forKey:playerId];
  }
  _lapCompleteInformation[[GKLocalPlayer localPlayer].playerID] = @(_noOfLaps);
}

- (void)processReceivedRandomNumber:(NSDictionary*)randomNumberDetails
{
  if([_orderOfPlayers containsObject:randomNumberDetails]) {
    [_orderOfPlayers removeObjectAtIndex:[_orderOfPlayers indexOfObject:randomNumberDetails]];
  }
  [_orderOfPlayers addObject:randomNumberDetails];
    
  NSSortDescriptor *sortByRandomNumber = [NSSortDescriptor sortDescriptorWithKey:randomNumberKey ascending:NO];
  NSArray *sortDescriptors = @[sortByRandomNumber];
  [_orderOfPlayers sortUsingDescriptors:sortDescriptors];
    
  if ([self allRandomNumbersAreReceived]) {
    _receivedAllRandomNumbers = YES;
  }
}

- (BOOL)allRandomNumbersAreReceived
{
  NSMutableArray *receivedRandomNumbers = [NSMutableArray array];
  for (NSDictionary *dict in _orderOfPlayers) {
   [receivedRandomNumbers addObject:dict[randomNumberKey]];
  }
  NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
  if (arrayOfUniqueRandomNumbers.count == [GameKitHelper sharedGameKitHelper].multiplayerMatch.playerIDs.count + 1) {
    return YES;
  }
  return NO;
}

- (NSUInteger)indexForLocalPlayer
{
  NSString *playerId = [GKLocalPlayer localPlayer].playerID;
    
  return [self indexForPlayerWithId:playerId];
}

- (NSUInteger)indexForPlayerWithId:(NSString*)playerId
{
  __block NSUInteger index = -1;
  [_orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop){
    NSString *pId = obj[playerIdKey];
    if ([pId isEqualToString:playerId]) {
      index = idx;
      *stop = YES;
    }
  }];
  return index;
}

- (BOOL)isLocalPlayerPlayer1
{
  NSDictionary *dictionary = _orderOfPlayers[0];
  if ([dictionary[playerIdKey] isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
    NSLog(@"I'm player 1");
    return YES;
  }
  return NO;
}

- (BOOL)hasLocalPlayerWon
{
  NSUInteger winningIndex = [self indexForWinningPlayer];
  NSDictionary *dict = _orderOfPlayers[winningIndex];
    
  if ([dict[playerIdKey] isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
    return YES;
  }
  return NO;
}

- (NSUInteger)indexForWinningPlayer
{
  NSArray *playerIds = [_lapCompleteInformation allKeys];
    
  NSString *winningPlayerId;
  for (NSString *key in playerIds) {
    NSNumber *laps = _lapCompleteInformation[key];
    if (laps.unsignedIntegerValue == 0) {
      winningPlayerId = key;
      break;
    }
  }
    
  return [self indexForPlayerWithId:winningPlayerId];
}

- (BOOL)isGameOver
{
  NSArray *playerIds = [_lapCompleteInformation allKeys];
    
  for (NSString *key in playerIds) {
    NSNumber *laps = _lapCompleteInformation[key];
    if (laps.unsignedIntegerValue == 0) {
      return YES;
    }
  }
  return NO;
}

- (void)retrieveAllPlayerAliases
{
  NSMutableArray *playerAliases = [NSMutableArray arrayWithCapacity:_orderOfPlayers.count];
    
  for (NSDictionary *playerDetails in _orderOfPlayers) {
    NSString *playerId = playerDetails[playerIdKey];
    GKPlayer *player = [GameKitHelper sharedGameKitHelper].playersDictionary[playerId];
    [playerAliases addObject:player.alias];
  }
  [self.delegate setPlayerLabelsInOrder:[NSArray arrayWithArray:playerAliases]];
}

/*Multiplayer challenge 1*/
- (void)retrieveAllPlayerPhotos
{
  if (_gameState == kGameStatePlaying) {
        
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:_orderOfPlayers.count];
        
    for (NSDictionary *playerDetails in _orderOfPlayers) {
      NSString *playerId = playerDetails[playerIdKey];
      GKPlayer *player = [GameKitHelper sharedGameKitHelper].playersDictionary[playerId];
      [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        [photos addObject:photo];
                
        if (photos.count == [GameKitHelper sharedGameKitHelper].multiplayerMatch.playerIDs.count + 1) {
          //invoke delegate method
          [self.delegate setPlayerPhotosInOrder:photos];
        }
      }];
    }
  }
}
/*Multiplayer challenge 1*/

#pragma mark GameKitHelper

- (void)matchStarted
{
  NSLog(@"Match has started successfully");
    if (_receivedAllRandomNumbers) {
        _gameState = kGameStateWaitingForStart;
    } else {
        _gameState = kGameStateWaitingForRandomNumber;
    }
  [self sendRandomNumber];
  [self tryStartGame];
  [self setupLapCompleteInformation];
}

- (void)matchEnded
{
  NSLog(@"Match has ended");
  [[GameKitHelper sharedGameKitHelper].multiplayerMatch disconnect];
  [_delegate matchEnded];
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerId
{
  //1
  Message *message = (Message*)[data bytes];
  if (message->messageType == kMessageTypeRandomNumber) {
    MessageRandomNumber *messageRandomNumber = (MessageRandomNumber*)[data bytes];
        
    NSLog(@"Received random number:%d",messageRandomNumber->randomNumber);

    BOOL tie = NO;
    if (messageRandomNumber->randomNumber == _ourRandomNumber) {
      //2
      NSLog(@"Tie");
      tie = YES;
      _ourRandomNumber = arc4random();
      [self sendRandomNumber];
    } else {
      //3
      NSDictionary *dictionary = @{playerIdKey : playerId,
                                    randomNumberKey :
                                      @(messageRandomNumber->randomNumber)};
      [self processReceivedRandomNumber:dictionary];
    }
    //4
    if (_receivedAllRandomNumbers) {
      _isPlayer1 = [self isLocalPlayerPlayer1];
    }
        
    if (!tie && _receivedAllRandomNumbers) {
      //5
      if (_gameState == kGameStateWaitingForRandomNumber) {
        _gameState = kGameStateWaitingForStart;
      }
      [self tryStartGame];
    }
  } else if (message->messageType == kMessageTypeGameBegin) {
    _gameState = kGameStatePlaying;
    [self.delegate setCurrentPlayerIndex:[self indexForLocalPlayer]];
    [self retrieveAllPlayerAliases];
    [self retrieveAllPlayerPhotos];
  } else if (message->messageType == kMessageTypeMove) {
    MessageMove *messageMove = (MessageMove*)[data bytes];
        
    NSLog(@"dX:%f dY:%f Rotation:%f", messageMove->dx,
              messageMove->dy, messageMove->rotate);
        
    [self.delegate setPositionOfCarAtIndex:[self indexForPlayerWithId:playerId]
                                        dx:messageMove->dx
                                        dy:messageMove->dy
                                  rotation:messageMove->rotate];
  } else if (message->messageType == kMessageTypeLapComplete) {
    [self reduceNoOfLapsForPlayer:playerId];
    if ([self isGameOver] && _isPlayer1) {
      [self sendGameOverMessage];
      [self.delegate gameOver:[self hasLocalPlayerWon]];
    }
  } else if(message->messageType == kMessageTypeGameOver) {
    [self.delegate gameOver:[self hasLocalPlayerWon]];
  }
}
@end
