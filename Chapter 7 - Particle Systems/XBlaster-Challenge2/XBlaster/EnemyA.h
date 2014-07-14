//
//  EnemyA.h
//  XBlaster
//
//  Created by Mike Daley on 21/07/2013.
//  Copyright (c) 2013 www.raywenderlich.com. All rights reserved.
//

#import "Entity.h"

@class AISteering;

@interface EnemyA : Entity {
  int         _score;
  int         _damageTakenPerShot;
  NSString    *_healthMeterText;
}

@property (strong,nonatomic) AISteering *aiSteering;

@end
