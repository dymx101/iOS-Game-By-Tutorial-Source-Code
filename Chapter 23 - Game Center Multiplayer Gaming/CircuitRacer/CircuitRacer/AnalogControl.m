//
//  AnalogControl.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AnalogControl.h"
#import "SKTUtils.h"

@implementation AnalogControl
{
  UIImageView *_knobImageView;
  CGPoint _baseCenter;
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // 1
    [self setUserInteractionEnabled:YES];

    // 2
    UIImageView *baseImageView =
      [[UIImageView alloc] initWithFrame:self.bounds];
    baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    baseImageView.image = 
      [UIImage imageNamed:@"base.png"];
    [self addSubview:baseImageView];

    // 3
    _baseCenter = CGPointMake(frame.size.width/2,
                              frame.size.height/2);

    // 4
    _knobImageView = 
      [[UIImageView alloc] initWithImage:
        [UIImage imageNamed:@"knob.png"]];
    _knobImageView.center = _baseCenter;
    [self addSubview:_knobImageView];
    // 5
    NSAssert(CGRectContainsRect(self.bounds, _knobImageView.bounds),
      @"Analog control size should be greater than the knob size");

  }
  return self;
}

- (void)updateKnobWithPosition:(CGPoint)position
{
  // 1
  CGPoint positionToCenter =
    CGPointSubtract(position, _baseCenter);
  CGPoint direction;
  if (CGPointEqualToPoint(positionToCenter, CGPointZero)) {
    direction = CGPointZero;
  } else {
    direction = CGPointNormalize(positionToCenter);
  }
  
  // 2
  float radius = self.frame.size.width/2;
  float length = CGPointLength(positionToCenter);

  // 3
  if (length > radius) {
    length = radius;
    positionToCenter = CGPointMultiplyScalar(direction, radius);
  }
  
  CGPoint relativePosition =
    CGPointMake(direction.x * length/radius,
                direction.y * length/radius);
  
  _knobImageView.center = CGPointAdd(_baseCenter, positionToCenter);
  self.relativePosition = relativePosition;
  
  NSLog(@"%@", NSStringFromCGPoint(relativePosition));
  
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  CGPoint touchLocation = 
    [[touches anyObject] locationInView:self];
  [self updateKnobWithPosition:touchLocation];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  CGPoint touchLocation = 
    [[touches anyObject] locationInView:self];
  [self updateKnobWithPosition:touchLocation];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  [self updateKnobWithPosition:_baseCenter];
}

- (void)touchesCancelled:(NSSet*)touches
              withEvent:(UIEvent*)event {
  [self updateKnobWithPosition:_baseCenter];
}

@end
