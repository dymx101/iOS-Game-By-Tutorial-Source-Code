//
//  AnimatingSprite.h
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(int32_t, PCFacingDirection)
{
  PCFacingForward,
  PCFacingBack,
  PCFacingRight,
  PCFacingLeft
};

@interface AnimatingSprite : SKSpriteNode

@property (strong,nonatomic) SKAction *facingForwardAnim;
@property (strong,nonatomic) SKAction *facingBackAnim;
@property (strong,nonatomic) SKAction *facingSideAnim;
@property (assign,nonatomic) PCFacingDirection facingDirection;

+ (SKAction*)createAnimWithPrefix:(NSString *)prefix
                           suffix:(NSString *)suffix;

@end
