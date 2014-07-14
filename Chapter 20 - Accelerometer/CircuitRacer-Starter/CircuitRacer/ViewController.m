//
//  ViewController.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "AnalogControl.h"

@implementation ViewController {
  SKView *_skView;
  AnalogControl *_analogControl;
  MyScene *_scene;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  if (!_skView) {
    _skView =
     [[SKView alloc] initWithFrame:self.view.bounds];
    MyScene *scene = 
      [[MyScene alloc] initWithSize:_skView.bounds.size
                            carType:self.carType
                              level:self.levelType];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_skView presentScene:scene];
    [self.view addSubview:_skView];
    [self.view sendSubviewToBack:_skView];
    
    const float padSide = 128;
    const float padPadding = 10;

    _analogControl = 
      [[AnalogControl alloc] initWithFrame:
        CGRectMake(
          padPadding, _skView.frame.size.height-padPadding-padSide,
          padSide, padSide)];

    [self.view addSubview:_analogControl];
    
    [_analogControl addObserver:scene forKeyPath:@"relativePosition" 
                    options:NSKeyValueObservingOptionNew
                    context:nil];
    _scene = scene;
    
    __weak ViewController *weakSelf = self;
    _scene.gameOverBlock = ^(BOOL didWin){
      [weakSelf gameOverWithWin:didWin];
    };


  }
}

- (void)dealloc {
  [_analogControl removeObserver:_scene 
                      forKeyPath:@"relativePosition"];
}

- (void)gameOverWithWin:(BOOL)didWin
{
  UIAlertView *alert = 
    [[UIAlertView alloc] 
      initWithTitle:didWin ? @"You won!" : @"You lost"
      message:@"Game Over"
      delegate:nil
      cancelButtonTitle:nil
      otherButtonTitles:nil];
  [alert show];
  
  [self performSelector:@selector(goBack:) withObject:alert 
    afterDelay:3.0];
}

- (void)goBack:(UIAlertView*)alert
{
 [alert dismissWithClickedButtonIndex:0 animated:YES];
 [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)showInGameMenu:(id)sender {
  UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Game Menu" message:@"What would you like to do?" delegate:self cancelButtonTitle:@"Resume level" otherButtonTitles:@"Go to menu", nil];
  [alertView show];
  _scene.paused = YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  _scene.paused = NO;
  if (buttonIndex == alertView.firstOtherButtonIndex) {
    [self gameOverWithWin:NO];
  }
}

@end
