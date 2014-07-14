//
//  AISteering.h
//  XBlaster
//
//  Created by Mike Daley on 22/07/2013.
//  Copyright (c) 2013 www.raywenderlich.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Entity;

@interface AISteering : NSObject

#pragma -
#pragma Properties

@property (strong)  Entity          *entity;
@property (assign)  CGPoint         waypoint;

@property (assign)  CGPoint         currentPosition;
@property (assign)  CGPoint         currentDirection;

@property (assign)  float           maxVelocity;
@property (assign)  float           maxSteeringForce;

@property (assign)  float           waypointRadius;
@property (assign)  BOOL            waypointReached;

@property (assign)  BOOL            faceDirectionOfTravel;

#pragma mark -
#pragma mark Instance Methods

/**
 Used to create a new instance of the steering AI
 @param entity the entity to which this steering AI is attached
 @param waypoint the point towards which the entity should be steering
 @param target
 */
- (id)initWithEntity:(Entity *)entity waypoint:(CGPoint)waypoint;

/**
 Used to change the waypoint that the AI should be steering towards
 @param waypoint the position toward which the AI should be steering towards
 */
- (void)updateWaypoint:(CGPoint)waypoint;

/**
 Used to update th steering AI logic which calculates a new position fot the entity which moves it twards its current waypoint
 @param delta the time which has passed since the last update
 */
- (void)update:(CFTimeInterval)delta;

@end
