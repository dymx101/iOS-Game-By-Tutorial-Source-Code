//
//  MyScene.h
//  CatNap
//

//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ImageCaptureDelegate
- (void)requestImagePicker;
@end

@interface MyScene : SKScene

@property (nonatomic, assign) id <ImageCaptureDelegate> delegate;
-(void)setPhotoTexture:(SKTexture *)texture;
- (instancetype)initWithSize:(CGSize)size
  andLevelNumber:(int)currentLevel;
  
@end
