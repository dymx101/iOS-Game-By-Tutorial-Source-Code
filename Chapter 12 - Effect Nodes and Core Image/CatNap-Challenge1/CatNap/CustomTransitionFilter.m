//
//  CustomTransitionFilter.m
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "CustomTransitionFilter.h"

@implementation CustomTransitionFilter

- (CIImage *)outputImage
{
  //1
  CIFilter *color = 
    [CIFilter filterWithName:@"CIConstantColorGenerator"];
  [color setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0
                                  alpha:self.inputTime]
           forKey:@"inputColor"];
  //2
  CIFilter *blendWithMask = 
    [CIFilter filterWithName:@"CIBlendWithAlphaMask"];
  [blendWithMask setValue:color.outputImage
                   forKey:@"inputMaskImage"];
  [blendWithMask setValue:self.inputImage
                   forKey:@"inputBackgroundImage"];
  [blendWithMask setValue:self.inputTargetImage
                   forKey:@"inputImage"];
  //3
  CIFilter *spinFilter = 
    [CIFilter filterWithName:@"CIAffineTransform"];
  [spinFilter setValue:blendWithMask.outputImage 
                forKey:kCIInputImageKey];
  //4
  CGAffineTransform t =
    CGAffineTransformMakeRotation(self.inputTime * 3.14 * 4.0);
  NSValue *transformValue = 
    [NSValue valueWithCGAffineTransform:t];
  [spinFilter setValue:transformValue forKey:@"inputTransform"];
  //7
  return spinFilter.outputImage;
}

@end
