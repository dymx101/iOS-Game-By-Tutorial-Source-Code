//
//  OldTimeyFilter.h
//  CatNap
//
//  Created by Main Account on 8/30/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>

@interface OldTimeyFilter : CIFilter

@property (strong, nonatomic) CIImage *inputImage;

@end
