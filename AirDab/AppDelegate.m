//
//  AppDelegate.m
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewController_Ipad.h"
#import "AudioPlayer.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  /*  NSError *sessionError = nil;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    /* Pick any one of them */
    // 1. Overriding the output audio route
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    // 2. Changing the default output audio route
   /*  UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);*/
    
    self.audioPlayer= [AudioPlayer sharedInstance];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
        self.window.rootViewController = self.viewController;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.window makeKeyAndVisible];
    } else {
        self.viewController_IPAD = [[ViewController_Ipad alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        self.window.rootViewController = self.viewController_IPAD;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.window makeKeyAndVisible];
    }
   
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    [[AudioPlayer sharedInstance] setIsBackground:YES ];
    
    [self setNowPlayingInfo:0];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
     [[AudioPlayer sharedInstance] setIsBackground:NO ];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
[self.viewController setSongTitle ];
    
    else [self.viewController_IPAD setSongTitle ];
       
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
     [self.viewController setSongTitle ];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    if (event.type == UIEventTypeRemoteControl){
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                
                [[AudioPlayer sharedInstance] startMusicPlayer];
                
                break;
            case UIEventSubtypeRemoteControlPause:
                
                [[AudioPlayer sharedInstance] stopMusicPlayer];
                
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
               [[AudioPlayer sharedInstance] playPrevTrack];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[AudioPlayer sharedInstance] playNextTrack];

                break;
            default:
                break;
        }
    }
}

-(void)setNowPlayingInfo:(int)currentInx{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[[AudioPlayer sharedInstance] currentArtwork] ];
        
        [songInfo setObject:[[AudioPlayer sharedInstance] currentSongTitle] forKey:MPMediaItemPropertyTitle];
        [songInfo setObject:[[AudioPlayer sharedInstance] currentArtist]  forKey:MPMediaItemPropertyArtist];
 
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        
    }
    
}
@end
