//
//  SelectCarViewController.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "SelectCarViewController.h"
#import "SelectLevelViewController.h"
#import "SKTAudio.h"

@interface SelectCarViewController ()

@end

@implementation SelectCarViewController

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
    [[SKTAudio sharedInstance] playBackgroundMusic:@"circuitracer.mp3"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)carButtonPressed:(UIButton*)sender
{
  [[SKTAudio sharedInstance] 
    playSoundEffect:@"button_press.wav"];
    
  SelectLevelViewController *levelViewController =   
    [self.storyboard instantiateViewControllerWithIdentifier:
     @"SelectLevelViewController"];
  levelViewController.carType = sender.tag;

  [self.navigationController 
    pushViewController:levelViewController animated:YES];
}




@end
