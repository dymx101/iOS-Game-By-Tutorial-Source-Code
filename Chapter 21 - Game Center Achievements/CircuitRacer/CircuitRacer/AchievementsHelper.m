//
//  AchievementsHelper.m
//  CircuitRacer
//
//  Created by Main Account on 9/23/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AchievementsHelper.h"

static NSString* const
  kDestructionHeroAchievementId = @"com.razeware.circuitracer3.destructionhero";
static NSString* const
  kAmatuerAchievementId = @"com.razeware.circuitracer3.amateurracer";
static NSString* const
  kIntermediateAchievementId = @"com.razeware.circuitracer3.intermediateracer";
static NSString* const
  kProfessionalAchievementId = @"com.razeware.circuitracer3.professionalracer";

static const NSInteger kMaxCollisions = 20;

@implementation AchievementsHelper

+ (GKAchievement *)collisionAchievement:
  (NSUInteger)noOfCollisions
{
  //1
  CGFloat percent = (noOfCollisions/kMaxCollisions) * 100;
  
  //2
  GKAchievement *collisionAchievement =
    [[GKAchievement alloc] initWithIdentifier:
     kDestructionHeroAchievementId];
  
  //3
  collisionAchievement.percentComplete = percent;
  collisionAchievement.showsCompletionBanner = YES;
  return collisionAchievement;
}

+ (GKAchievement *)achievementForLevel:(CRLevelType)levelType
{
  NSString *achievementId = kAmatuerAchievementId;
  if (levelType == CRLevelMedium) {
    achievementId = kIntermediateAchievementId;
  } else if(levelType == CRLevelHard) {
    achievementId = kProfessionalAchievementId;
  }
  
  GKAchievement *levelAchievement = 
    [[GKAchievement alloc] initWithIdentifier:achievementId];
  
  levelAchievement.percentComplete = 100;
  levelAchievement.showsCompletionBanner = YES;
  return levelAchievement;
}

@end
