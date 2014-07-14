//
//  CircuitRacerNavigationController.m
//  CircuitRacer
//
//  Created by Main Account on 9/23/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "CircuitRacerNavigationController.h"
#import "GameKitHelper.h"

@implementation CircuitRacerNavigationController

- (void)viewDidLoad {
  [super viewDidLoad];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(showAuthenticationViewController)
      name:PresentAuthenticationViewController
      object:nil];
    
  [[GameKitHelper sharedGameKitHelper]
    authenticateLocalPlayer];
}

- (void)showAuthenticationViewController
{
  GameKitHelper *gameKitHelper =
    [GameKitHelper sharedGameKitHelper];
  
  [self.topViewController presentViewController:
     gameKitHelper.authenticationViewController
                                       animated:YES
                                     completion:nil];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
