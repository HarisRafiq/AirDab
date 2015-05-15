//
//  MainView.h
//  AirDab
//
//  Created by YAZ on 9/6/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//
#import <GameKit/GameKit.h>

#import <UIKit/UIKit.h>
@protocol MainViewDelegate;
@interface MainView : UIView<  GKSessionDelegate,GKPeerPickerControllerDelegate>
{GKPeerPickerController *connectionPicker;
    GKSession *currentSession;
    UILabel *bluetoothLabel;
    UILabel *serverLabel;
    UIView *serverView;
    UIView *bluetoothView;
 UIView *bottomView;
     UIButton *bottomButton;
    UIButton *btButton;
    UIButton *serverButton;
    BOOL isServerOn;
    BOOL isBtOn;
    UIImageView *serverImageView;
    UIImageView *btImageView;
}
-(void)cleanUp;
-(void)setIsServerOn:(BOOL)s;
-(void)setIsBtOn:(BOOL)s;
-(void)setBtText:(NSString *)s;
@property(nonatomic, assign) id <MainViewDelegate> delegate;
-(void)setServerAddress:(NSString *)s;
@end
@protocol MainViewDelegate<NSObject>
-(void)changeView;
 -(void)serverSwitch;
-(void)btSwitch;
-(void)connectWithGKSession:(GKSession *)s;

@end
