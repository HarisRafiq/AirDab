//
//  ViewController.h
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//
#import "MediaTableView.h"
#import "dance.h"
#import "ToggleTopView.h"
#import "SongsView.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Network.h"
#import "AudioPlayer.h"
#import "SongsCell.h"
#import "MainView.h"
 @interface ViewController : UIViewController<MediaTableViewDelegate,AudioPlayerDelegate,SongsViewDelegate, NetworkDelegate,danceDelegate,UIGestureRecognizerDelegate,MainViewDelegate>
{
     UIButton *playButton;
    BOOL isToggleView;
    ToggleTopView *toggleView;
     EAGLContext * context;
      Network *network;
    int frameHeight;
    int framewidth;
    AudioPlayer *audioPlayer;
    CGRect statusBar;
    CGPoint savedScrollPosition;
    SongsCell *songsCell;
    BOOL isVisualizerEnabled;
    NSString *totalDuration;
    BOOL isPlaying;
    UIView *subView;
    MainView *mainView;
    NSString *serverAddress;
    NSString *connectedPeer;
    CGRect songCellrect;
    BOOL isServerOn;
    BOOL isBTOn;
    int currentSelectedArtistIndex;
    NSString *currentSelectedArtist;
    UIImageView *artistCover;
    UIImage *currentArtistCover;
    CGFloat VISUALIZER_OFFSET;
}
-(void)setSongTitle;
- (void)swipeLeftAction:(id)ignored;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong )  dance *danceView;
@property (nonatomic, strong) NSTimer *positionTimer;
@property (nonatomic, strong) MediaTableView *mediatView;
@property (nonatomic, strong) SongsView *songsView;
 
 

@end