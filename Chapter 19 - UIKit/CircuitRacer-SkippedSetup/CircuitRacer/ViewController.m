//
//  ViewController.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  SKView *skView = (SKView *)self.view;
  if (!skView.scene) {
    MyScene *scene =
      [[MyScene alloc] initWithSize:skView.bounds.size
                            carType:CRYellowCar
                              level:CRLevelEasy];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
  }
}

@end
