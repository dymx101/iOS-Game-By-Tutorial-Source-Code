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

@implementation SteeringWheelViewController

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


@end
