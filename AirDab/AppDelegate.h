//
//  AppDelegate.h
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "ViewController_Ipad.h"
#import "AudioPlayer.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (retain, nonatomic) AudioPlayer *audioPlayer;
@property (strong, nonatomic) UIWindow *window;
    
@property (strong, nonatomic) ViewController *viewController;
    @property (strong, nonatomic) ViewController_Ipad *viewController_IPAD;
@end
