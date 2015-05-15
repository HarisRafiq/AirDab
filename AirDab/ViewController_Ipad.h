//
//  ViewController_Ipad.h
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaTableView_Ipad.h"
#import "dance.h"
#import "ControlView.h"
#import "SongsView_Ipad.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Network.h"
#import "AudioPlayer.h"
#import "SongsCell.h"
#import "MainView.h"
#import "CircularSliderView.h"

@interface ViewController_Ipad: UIViewController<MediaTableView_IpadDelegate,AudioPlayerDelegate,SongsView_IpadDelegate, NetworkDelegate,danceDelegate,UIGestureRecognizerDelegate,ControlViewDelegate,GKSessionDelegate,GKPeerPickerControllerDelegate>
    {
        CircularSliderView *sliderView;
        UISlider*                   _captureDuration;
        GKPeerPickerController *connectionPicker;
        GKSession *currentSession;

        UILabel *bluetoothLabel;
        UILabel *serverLabel;
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
        ControlView *mainView;
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
        UIView *rightSubView;
        UIImageView *rightArtistCover;
        UIView *topSubView;
UIView *separatorSubView;
        UIImageView *serverImageView;
        UIImageView *btImageView;
        UIView *artistView;
        UIButton *playButton;
        UIButton *prevButton;
        UIButton *nextButton;
        UIButton *bluetoothButton;
        UIButton *serverButton;
        UILabel *currentSongTitle;
        UILabel *currentSongDuration;
        UILabel *currentSongTimeElapsed;
        UIView *currentSongView;
        UIView *artCoverView;
        UILabel *selectedArtistLabel;
        UIView *selectedArtistView;
  UIImageView *selectedArtistCover;
        UIView *serverView;
        UIView *bluetoothView;
 
        UIButton *bottomButton;
        BOOL isOptionsVisible;
        
    }
-(void)setSongTitle;
- (void)swipeLeftAction:(id)ignored;
    @property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;

    @property (nonatomic, strong )  dance *danceView;
     @property (nonatomic, strong) NSTimer *positionTimer;
    @property (nonatomic, strong) MediaTableView_Ipad *mediatView;
    @property (nonatomic, strong) SongsView_Ipad *songsView;
    
    
    
    @end

