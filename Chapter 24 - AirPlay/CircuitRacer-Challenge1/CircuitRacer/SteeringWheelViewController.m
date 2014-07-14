//
//  SteeringWheelViewController.m
//  CircuitRacer
//
//  Created by Main Account on 10/7/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "SteeringWheelViewController.h"

@interface SteeringWheelViewController ()

@end

@implementation SteeringWheelViewController {
  BOOL _allowedToNitro;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  _allowedToNitro = YES;
  UISwipeGestureRecognizer * swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
  [self.view addGestureRecognizer:swipeRecognizer];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
  [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
  [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (IBAction)actionHonk:(id)sender
{
  [self.scene playHorn];
}

- (void)handleSwipe:(UIGestureRecognizer *)recognizer {

  if (_allowedToNitro) {

    [self.scene nitro];
    _allowedToNitro = NO;
    [self performSelector:@selector(resetNitro) withObject:nil afterDelay:0.5];  
  }
  
}

- (void)resetNitro {
  _allowedToNitro = YES;
}


@end
