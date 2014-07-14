//
//  AppDelegate.m
//  PestControl
//
//  Created by Main Account on 9/1/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <SpriteKit/SpriteKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

  SKView *view = (SKView*)self.window.rootViewController.view;
  view.scene.paused = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
  //1
  SKView *view = (SKView*)self.window.rootViewController.view;
  SKScene *scene = view.scene;
  //2
  NSString *documentsDirectory = [AppDelegate getPrivateDocsDir];
  NSString *filePath =
  [documentsDirectory
   stringByAppendingPathComponent:@"autosaved-scene"];
  //3
  NSMutableData *data = [[NSMutableData alloc] init];
  NSKeyedArchiver *archiver =
  [[NSKeyedArchiver alloc]
   initForWritingWithMutableData:data];
  //4
  [archiver encodeObject:scene forKey:@"AppDelegateSceneKey"];
  [archiver finishEncoding];
  [data writeToFile:filePath atomically:YES];
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  
  SKView *view = (SKView*)self.window.rootViewController.view;
  NSString *dataPath =
  [[AppDelegate getPrivateDocsDir]
   stringByAppendingPathComponent:@"autosaved-scene"];
  NSData *codedData =
  [[NSData alloc] initWithContentsOfFile:dataPath];
  if (codedData != nil) {
    NSKeyedUnarchiver *unarchiver =
    [[NSKeyedUnarchiver alloc]
     initForReadingWithData:codedData];
    SKScene *scene =
    [unarchiver decodeObjectForKey:@"AppDelegateSceneKey"];
    [unarchiver finishDecoding];
    [view presentScene:scene];
  }
  view.scene.paused = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (NSString *)getPrivateDocsDir
{
  NSArray *paths =
  NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                      NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  documentsDirectory = [documentsDirectory
                        stringByAppendingPathComponent:@"Private Documents"];
  
  NSError *error;
  [[NSFileManager defaultManager]
   createDirectoryAtPath:documentsDirectory
   withIntermediateDirectories:YES attributes:nil error:&error];
  
  return documentsDirectory;
}

@end
