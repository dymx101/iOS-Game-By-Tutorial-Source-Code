//
//  SelectLevelViewController.m
//  CircuitRacer
//
//  Created by Main Account on 9/19/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "SelectLevelViewController.h"
#import "ViewController.h"
#import "SKTAudio.h"

@interface SelectLevelViewController ()

@end

@implementation SelectLevelViewController

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

- (IBAction)backButtonPressed:(id)sender
{
  [[SKTAudio sharedInstance] 
    playSoundEffect:@"button_press.wav"];
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)levelButtonPressed:(UIButton*)sender
{
  [[SKTAudio sharedInstance] 
    playSoundEffect:@"button_press.wav"];
    
  ViewController *gameViewController = [self.storyboard
    instantiateViewControllerWithIdentifier:@"ViewController"];
  gameViewController.carType = _carType;
  gameViewController.levelType = sender.tag;
    
  [self.navigationController 
    pushViewController:gameViewController animated:YES];
}

@end
