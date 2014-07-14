//
//  AchievementsHelper.h
//  CircuitRacer
//
//  Created by Main Account on 9/23/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface AchievementsHelper : NSObject

+ (GKAchievement *)collisionAchievement:
  (NSUInteger)noOfCollisions;
+ (GKAchievement *)achievementForLevel:(CRLevelType)levelType;
+ (GKAchievement *)racingAddictAchievement:
  (NSUInteger)noOfPlays;
  
@end
