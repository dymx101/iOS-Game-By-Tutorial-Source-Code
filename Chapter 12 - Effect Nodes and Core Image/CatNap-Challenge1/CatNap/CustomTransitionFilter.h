//
//  CustomTransitionFilter.h
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface CustomTransitionFilter : CIFilter

@property (strong,nonatomic) CIImage *inputImage;
@property (strong,nonatomic) CIImage *inputTargetImage;
@property (assign,nonatomic) NSTimeInterval inputTime;

@end
