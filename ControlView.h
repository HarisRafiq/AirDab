//
//  ControlView.h
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GameKit/GameKit.h>
#import "dance.h"

#import <UIKit/UIKit.h>
@protocol ControlViewDelegate;
@interface ControlView : UIView<  danceDelegate,GKSessionDelegate,GKPeerPickerControllerDelegate>
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
    CGFloat VISUALIZER_OFFSET;
    
    EAGLContext * context;
    
    UIImageView *myImageView;
  

    UIView *playingView;
    UIImageView *artistCover;
 UILabel *songTitle;
     UILabel *artistTitle;
}
@property (nonatomic, strong) UILabel *titleLabel;

-(void)setupAnalyzer;
-(void)cleanAnalyzer;
 @property (nonatomic, strong )  dance *danceView;
-(void)cleanUp;
-(void)setIsServerOn:(BOOL)s;
-(void)setIsBtOn:(BOOL)s;
-(void)setBtText:(NSString *)s;
@property(nonatomic, assign) id <ControlViewDelegate> delegate;
-(void)setServerAddress:(NSString *)s;
@end
@protocol ControlViewDelegate<NSObject>

-(void)serverSwitch;
-(void)btSwitch;
-(void)connectWithGKSession:(GKSession *)s;
-(void)nextSong;
-(void)prevSong;
-(void)playPause;
@end
