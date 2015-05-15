//
//  ViewController_Ipad.m
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "ViewController_Ipad.h"
#import "SongsCell.h"
#import "CommonIpad.h"
 

@implementation ViewController_Ipad
    
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    network=[Network sharedInstance];
    network.delegate=self;
    audioPlayer = [AudioPlayer sharedInstance];
    [audioPlayer setDelegate:self];
    [self.view setBackgroundColor:[UIColor blackColor]   ];
 
    
    isOptionsVisible=YES;
    
    
    isVisualizerEnabled=NO;
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated{
     [self setupMediaView];
    
    
    //[self setupRightArtistView];
    //[self setupTitleLabel];
    

   
    [self setupSelectedArtistControl];
    [self setupBluetoothButton ];
    
    [self setupServerButton];
    [self setupBottomView];
    [self toggleOptions];

      }

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)setupMediaView
{
    frameHeight=self.view.bounds.size.height;
    framewidth=320;
    
    if(self.mediatView){
        [self.mediatView removeFromSuperview];
        self.mediatView =nil;
    }
    self.mediatView=[[MediaTableView_Ipad alloc] initWithFrame:CGRectMake(0,frameHeight-210  , 326 ,260 )];
    [self.view addSubview:self.mediatView];
    
    [self.mediatView setDelegate:self];
    
    
}
-(void)playLocalSongsWithUrl:(NSString *)temp atIndex:(int)i scrollPosition:(CGPoint )p
{
    isPlaying=YES;
    
    [audioPlayer setCurrentArtistIndex:currentSelectedArtistIndex];
    [audioPlayer setCurrentSongIndex:i];

    totalDuration= [[AudioPlayer sharedInstance] currentSongTotalDuration] ;
    [self setupCurrentSongView];
    [self setupCurrentSongAttributes];
    
            
            [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
                [self.mediatView setFrame:CGRectMake(0,frameHeight   , 320 ,254 )];
                
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
                    
                    
                    [selectedArtistView setAlpha:0];
                    [self.songsView setAlpha:0 ];
                    
                } completion:^(BOOL finished) {
                    
                    
                    [self setupAnalyzer];
                    
                    [self startTimer];
                    
                    NSURL *url=[NSURL URLWithString:[temp stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];;
                    
                    [audioPlayer play:url] ;
                    
                    [UIView animateWithDuration:0.2f
                                          delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         
                                         
                                         [currentSongView setFrame:                                        CGRectMake(0,170,self.view.bounds.size.width/2,self.view.bounds.size.height-80)]
                                          ;
                                         
                                         
                                     }
                     
                                     completion:^(BOOL finished){
                                         
                                         
                                     }]; }];}];
            
    
}
-(void)setupRightArtistView{
   

    artistCover = [[UIImageView alloc] initWithFrame: CGRectMake(1,1, 498, 498)];
    artistCover.image = [UIImage imageNamed:@"LOGO.png"];
    [artistCover setContentMode:UIViewContentModeScaleAspectFit];
 
 
    artistCover.clipsToBounds = YES;
 
    artistView=[[UIView alloc] initWithFrame:CGRectMake(505,135, 500, 500 )];
    artistView.layer.backgroundColor=[UIColor blackColor].CGColor;
  
    

    [artistView addSubview:artistCover];
    [self.view addSubview:artistView];
    
    


}

-(void)playSongsWithUrl:(MPMediaItem *)temp atIndex:(int)i scrollPosition:(CGPoint )p
{
    isPlaying=YES;
    [audioPlayer setCurrentArtist: [temp valueForProperty:MPMediaItemPropertyArtist]] ;
    MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
    [audioPlayer settduration:[[temp valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue]];
    [audioPlayer setCurrentArtwork: [artWork imageWithSize:CGSizeMake(150, 150)]];
 
    [audioPlayer setCurrentSongTotalDuration:[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]]];
    [[AudioPlayer sharedInstance] setCurrentSongTitle: [temp valueForProperty:MPMediaItemPropertyTitle]];
    totalDuration=[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    [audioPlayer setUpWithArtist:currentSelectedArtist];
    [audioPlayer setCurrentArtistIndex:currentSelectedArtistIndex];
    [audioPlayer setCurrentSongIndex:i];
   
    
    

         [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        [self.mediatView setFrame:CGRectMake(0,frameHeight   , 320 ,254 )];
        
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            
            
            
            [selectedArtistView setAlpha:0];
            [bottomButton setAlpha:0];
            [self.songsView setAlpha:0 ];
            [bluetoothButton setHidden:YES];
            [bluetoothView setHidden:YES];
            [serverButton setHidden:YES];
            [serverView setHidden:YES];

            
        } completion:^(BOOL finished) {
            
            
            [self setupAnalyzer];
            
            [self startTimer];
       
            [audioPlayer play:[temp valueForProperty:MPMediaItemPropertyAssetURL]] ;
            
            [self setupCurrentSongView];
            [self setupCurrentSongAttributes];
            [currentSongView setAlpha:0];
            [currentSongView setFrame:CGRectMake(0,170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
            
            [UIView animateWithDuration:0.2f
                                  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                               
                                 [currentSongView setAlpha:1];
                                 
                     
                             }
             
                             completion:^(BOOL finished){
                               
                               
                                 
                             }]; }];}];
    

    
            
    
    
}

- (void)audioPlayer:(AudioPlayer *)player didChangeStatus:(UInt32)status
{
    
    /*if(status==1){
     if (!positionTimer) {
     positionTimer = [NSTimer timerWithTimeInterval:1.00 target:self selector:@selector(updatePosition) userInfo:nil repeats:YES];
     [[NSRunLoop currentRunLoop] addTimer:positionTimer forMode:NSRunLoopCommonModes];
     }
     }
     if(status==0){
     if (positionTimer)
     {
     [positionTimer invalidate];
     positionTimer = NULL;
     [self.mediatView updateDurationLabel:0];
     }
     
     
     }
     
     */
	
}
-(void)changeTrack{

    artistCover.image = nil;
        [artistCover setNeedsDisplay];


}
-(void)setupAnalyzer{
    if(self.danceView)
    {[self.danceView cleanUp];
        [self.danceView removeFromSuperview];
        self.danceView=nil;
        
    }
    if(artistView)
    {
        [artistView removeFromSuperview];
        artistView=nil;
        
    }
    
    
    self.danceView = [[dance alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2+10,140,500,500) context:context];
    
     self.danceView .layer.borderColor=[UIColor blackColor].CGColor;

    
    self.danceView.layer.borderWidth=25;
    self.danceView.layer.cornerRadius=500/2;
    
    
    [self.view addSubview:self.danceView];
    
    [self.danceView setDandelegate:self ];

    isVisualizerEnabled=YES;
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupTitleLabel{
    UIView *topView=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,20)];
    topView.layer.backgroundColor=[UIColor blackColor].CGColor;
    
    
    subView=[[UIView alloc] initWithFrame:CGRectMake(0,20,self.view.bounds.size.width,50)];
    subView.layer.backgroundColor=[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0].CGColor;
        [self.view addSubview:topView];
    [self.view addSubview:subView];


    
    
        }
-(void)addSongsViewWithArtist:(NSString *)artist AtIndex:(int)i isLocal:(BOOL)s AndImage:(UIImage *)image
{
    [self setCellTitle:artist AndImage:image];
    currentSelectedArtist=artist;
    currentSelectedArtistIndex=i;
     [self.songsView removeFromSuperview];
    self.songsView =nil;
    //[self setupTitle:artist];
  
         self.songsView=[[SongsView_Ipad alloc] initWithFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,320,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET) ) ];
    self.songsView.layer.borderColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    self.songsView.layer.borderWidth=2;
     if(!s){
        [self.songsView setUpWithArtist:artist];
    }
    [self.view addSubview:self.songsView];
    //[self.songsView setCellTitle:artist];
    [self.songsView setDelegate:self];
    [self.songsView setIsLocalFile:s];
    
    [self.songsView setupTable];
    
 }

-(void)setCellTitle:(NSString*)title AndImage:(UIImage *)image
{
    if(image==nil)
    {
        
        image=[UIImage imageNamed: @"wave-white.png"];
        
    }
    
     selectedArtistLabel.text = title;
    [selectedArtistLabel setNeedsDisplay];
  selectedArtistCover.image = image;
    [selectedArtistCover setNeedsDisplay];
    title=nil;
    image=nil;
}

-(void)playNextTrack{
    [audioPlayer playNextTrack];
    
}
- (NSString *)convertTimeFromSeconds:(NSString *)seconds {
    
    // Return variable.
    NSString *result = @"";
    
    // Int variables for calculation.
    int secs = [seconds intValue];
    int tempHour    = 0;
    int tempMinute  = 0;
    int tempSecond  = 0;
    
    NSString *hour      = @"";
    NSString *minute    = @"";
    NSString *second    = @"";
    
    // Convert the seconds to hours, minutes and seconds.
    tempHour    = secs / 3600;
    tempMinute  = secs / 60 - tempHour * 60;
    tempSecond  = secs - (tempHour * 3600 + tempMinute * 60);
    
    hour    = [[NSNumber numberWithInt:tempHour] stringValue];
    minute  = [[NSNumber numberWithInt:tempMinute] stringValue];
    second  = [[NSNumber numberWithInt:tempSecond] stringValue];
    
    // Make time look like 00:00:00 and not 0:0:0
    if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    if (tempHour == 0) {
        
        result = [NSString stringWithFormat:@"%@:%@", minute, second];
        
    } else {
        
        
        result = [NSString stringWithFormat:@"%@:%@:%@",hour, minute, second];
        
    }
    
    return result;
    
}

- (void)_timerAction:(id)timer
{
    
    [self updateTimeLabel];
    
}
- (void)audioPlayerDidStartPlayingNextTrackWithMPItem:(MPMediaItem *)item{
        totalDuration=[self convertTimeFromSeconds:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    
    
    
    
    [self setupCurrentSongAttributes];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{    [currentSongView setFrame:                                        CGRectMake(0,170,self.view.bounds.size.width/2,self.view.bounds.size.height-80)
];
                             [currentSongView setAlpha:1];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
    
}
- (void)audioPlayerDidStartPlayingPrevTrackWithMPItem:(MPMediaItem *)item{
    
    
    totalDuration=[self convertTimeFromSeconds:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    
    
    
    
    [self setupCurrentSongAttributes];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{    [currentSongView setFrame:CGRectMake(0, 170, 320,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                                                        [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
}
- (void)audioPlayerDidStartPlayingPrevTrackWithLocalSongs:(NSString *)songTitle{
    
 
    [self setupCurrentSongAttributes];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{    [currentSongView setFrame:CGRectMake(0, 170, 320,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                                                       [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 0, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
    
}
- (void)audioPlayerDidStartPlayingNextTrackWithLocalSongs:(NSString *)songTitle{
    
    
    
    
    
    
    
    [self setupCurrentSongAttributes];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{    [currentSongView setFrame:CGRectMake(0,170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                                                          [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 0, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             
                           
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 0, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
}
-(void)peerDisconnected:(NSString *)pid{ connectedPeer=nil;isBTOn=NO;
    [self stopTimer];
    [audioPlayer stopVoip];
    [self  setIsBtOn:isBTOn];
    
    [self setBtText:connectedPeer];
    [self swipeRightAction:nil];
    
    
    
}
-(void)peerConnected:(NSString *)pid{connectedPeer=pid; isBTOn=YES;
    [audioPlayer startVoip];
            [self  setIsBtOn:isBTOn];
        
        [self setBtText:connectedPeer];
        
     }

-(void)peerAvailable:(NSString *)pid{ }

-(void)updateTimeLabel{
    [currentSongDuration setText:[NSString stringWithFormat:@"%@/%@",[self convertTimeFromSeconds:[NSString stringWithFormat:@"%i",[audioPlayer currentTime]/44100  ] ],[audioPlayer currentSongTotalDuration]]] ;

        _captureDuration.value=([audioPlayer currentTime]/44100)/[audioPlayer tduration];
    
}
- (void)audioPlayerDidFinsihPlaying:(AudioPlayer *)player{
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];

                           
                             [currentSongView setFrame:CGRectMake(0, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             
                             [currentSongView setFrame:CGRectMake(0, frameHeight,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             
                             currentSongView.hidden=NO;
                             
                             [audioPlayer playNextTrack];
                             
                             
                         }];
    }
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];
                             [currentSongView setFrame:CGRectMake(0, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             currentSongView.hidden=NO;
                             
                             
                             
                             
                             [audioPlayer playNextTrack];
                             
                             
                         }];
        
        
        
        
        
    }
    
}
-(void)audioPlayerIsAlreadyPlayingFirstSong{   currentSongView.hidden=YES;
    if(isVisualizerEnabled){
      
         [currentSongView setFrame:CGRectMake(0, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             currentSongView.hidden=NO;
                             [currentSongView setAlpha:1];
                             [currentSongView setFrame:CGRectMake(0, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                        
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                         }];
    }
    
    else{
        [currentSongView setFrame:CGRectMake(0, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
        [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
        [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
       [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             currentSongView.hidden=NO;
                            [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];
                            
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
        
    }}
-(void)audioPlayerIsAlreadyPlayingLastSong{
    currentSongView.hidden=YES;
    if(isVisualizerEnabled){
               [currentSongView setFrame:CGRectMake(0, frameHeight,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];        [UIView animateWithDuration:0.3f
                                                                                                         delay:0.0 options:UIViewAnimationOptionTransitionNone
                                                                                                    animations:^{
                                                                                                        currentSongView.hidden=NO;
                                                                                                        
                                                 
                                                  [currentSongView setFrame:CGRectMake(0,50,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                                                                                                        
                                                                                                        [currentSongView setAlpha:1];
                                             
                                                                                                    }
                                                                                                    completion:^(BOOL finished){
                                                                                                        
                                                                                                        
                                                                                                        
                                                                                                    }];
    }
    
    else{
        [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-self.view.bounds.size.width/4, frameHeight, 320,self.view.bounds.size.height-80)];
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             currentSongView.hidden=NO;
                        
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [currentSongView setAlpha:1];

                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
        
    }}
-(void)startTimer{
    
    if(self.positionTimer)
    {
        [self.positionTimer invalidate];
        self.positionTimer=nil;
    }
    self.positionTimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    
}
-(void)setTotalDuration:(float)d{
    
    totalDuration= [self convertTimeFromSeconds:[NSString stringWithFormat:@"%f",d]] ;
}
-(void)setMPMediaTotalDuration:(NSString *)d{
    
    totalDuration= [self convertTimeFromSeconds:d]  ;
}
-(void)stopTimer{
    if(self.positionTimer){
        [self.positionTimer invalidate];
        self.positionTimer=nil;
    }
}
-(void)handleEnteredBackground:(id)s{
    
    [self stopTimer];
    if(isVisualizerEnabled)
    {
        [self.danceView cleanUp];
        self.danceView.dandelegate=nil;
        [self.danceView removeFromSuperview];
        self.danceView =nil;
        context=nil;
        
        isVisualizerEnabled=NO;
  
        [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
        [currentSongView setAlpha:1];

        [selectedArtistView setAlpha:1];
        
        [self.songsView reloadData];
        [self.songsView setAlpha:1 ];
        [self.mediatView setFrame:CGRectMake(0,frameHeight-210  , 326 ,260 )];
        
        
       
        
        
    }
}
-(void)setSongTitle{
    if(currentSongView){
        [self startTimer];
        [self setupCurrentSongAttributes ];
        
    }
}


-(void)setupPlayButton{
    
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(170,35, 50, 50)];
    
    playButton.layer.borderColor=[UIColor whiteColor].CGColor;
    playButton.layer.backgroundColor=[UIColor blackColor].CGColor;
    
    
    [playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPause" ofType:@"png"]]  forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    //[currentSongView addSubview:playButton];
    
    
}


-(void)setupBluetoothButton{
 
    
    bluetoothButton = [[UIButton alloc] initWithFrame:CGRectMake(330,45 , 75, 75)];
    btImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    
    [btImageView setContentMode:UIViewContentModeScaleAspectFit];
    btImageView.layer.borderWidth=2;
    [btImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    btImageView.layer.borderWidth=2;
    btImageView.layer.cornerRadius=70/2;
    btImageView.clipsToBounds = YES;
    
    
    bluetoothButton.layer.borderWidth=2;
    bluetoothButton.layer.cornerRadius=75/2;
    
    
    [bluetoothButton addTarget:self action:@selector(btSwitch) forControlEvents:UIControlEventTouchUpInside];
    [bluetoothButton addSubview:btImageView];
    
    
         [self.view addSubview:bluetoothButton];

    bluetoothView=[[UIView alloc] initWithFrame:CGRectMake(750,20,200,20)];
    bluetoothView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    bluetoothLabel =  [[UILabel alloc] initWithFrame:CGRectMake(5,0,195 ,60) ] ;
    
    [bluetoothLabel setBackgroundColor:[UIColor clearColor]]  ;
    
    bluetoothLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    bluetoothLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [bluetoothView addSubview:bluetoothLabel];
    [self.view addSubview:bluetoothView];
    [self setIsBtOn:isBTOn];


}
-(void)setupServerButton{
    
    serverButton = [[UIButton alloc] initWithFrame:CGRectMake(620,45, 75,75)];
    
    
    serverImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    [serverImageView setContentMode:UIViewContentModeScaleAspectFit];
    serverImageView.layer.borderWidth=2;
    
    serverImageView.layer.borderWidth=2;
    serverImageView.layer.cornerRadius=70/2;
    serverImageView.clipsToBounds = YES;
    
    serverButton.layer.borderWidth=2;
    serverButton.layer.cornerRadius=75/2;
    
    [serverButton addTarget:self action:@selector(serverSwitch) forControlEvents:UIControlEventTouchUpInside];
    [serverButton addSubview:serverImageView];
    [self.view addSubview:serverButton];

    serverView=[[UIView alloc] initWithFrame:CGRectMake(550,20,200,20)];
    serverView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    serverLabel =  [[UILabel alloc] initWithFrame:CGRectMake(5,0,195 ,20) ] ;
    
    [serverLabel setBackgroundColor:[UIColor clearColor]]  ;
    
    serverLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    serverLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    [serverView addSubview:serverLabel];
    [self.view addSubview:serverView];
    
    [self setIsServerOn:isServerOn];


    
}
-(void)setupCurrentSongAttributes{
 
    self.titleLabel.text=[[AudioPlayer sharedInstance] currentArtist];
    currentSongTitle.text=[[AudioPlayer sharedInstance] currentSongTitle];
    currentSongDuration.text=[[AudioPlayer sharedInstance] currentSongTotalDuration];
    rightArtistCover.image=[[AudioPlayer sharedInstance] currentArtwork];
    [sliderView setMinValue:0 maxValue:[[AudioPlayer sharedInstance] tduration] initialValue:0];
 

}
-(void)setupCurrentSongView{
    
    if(playButton!=nil)
    {
        [playButton removeFromSuperview];
        playButton=nil;
    }
    if(currentSongTimeElapsed!=nil)
    {
        [currentSongTimeElapsed removeFromSuperview];
        currentSongTimeElapsed=nil;
    }
         if(currentSongTitle!=nil)
    {
        [currentSongTitle removeFromSuperview];
        currentSongTitle=nil;
    
    
    }
    if(currentSongDuration!=nil)
    {
        [currentSongDuration removeFromSuperview];
        currentSongDuration=nil;
    }

    if( self.titleLabel!=nil)
    {
    
        [self.titleLabel removeFromSuperview];
        self.titleLabel=nil;
    
    
    }
    if(rightArtistCover!=nil){
        [rightArtistCover removeFromSuperview];
        rightArtistCover=nil;
    
    
    }
    if(currentSongView!=nil){
    [currentSongView removeFromSuperview];
    currentSongView =nil;
    }
    
 
 
    currentSongView=[[UIView alloc] initWithFrame:CGRectMake(320,50,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
    currentSongView.layer.backgroundColor=[UIColor clearColor].CGColor;
 
    currentSongTitle =  [[UILabel alloc] initWithFrame:CGRectMake(100, 20 , 250,60)];
    
    [currentSongTitle setBackgroundColor:[UIColor clearColor]];
    currentSongTitle.textColor = [UIColor whiteColor] ;
    currentSongTitle.lineBreakMode=NSLineBreakByTruncatingTail;
    currentSongTitle.numberOfLines=0;
    
    currentSongTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    currentSongTitle.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    [currentSongView addSubview:currentSongTitle];
    

    self.titleLabel =  [[UILabel alloc] initWithFrame:CGRectMake(100,0,250,20)   ] ;
    
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    self.titleLabel.textColor = [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] ;
    self.titleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    self.titleLabel.numberOfLines=1;
    
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    [currentSongView addSubview:self.titleLabel];
   artCoverView=[[UIView alloc] initWithFrame: CGRectMake(100,90 , 250, 250)];
    rightArtistCover = [[UIImageView alloc] initWithFrame: CGRectMake(0,0, 250, 250)];
    
    [rightArtistCover setContentMode:UIViewContentModeScaleAspectFit];
    rightArtistCover.layer.borderWidth=2;
    rightArtistCover.layer.borderColor=[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0].CGColor;
    rightArtistCover.clipsToBounds = YES;
    rightArtistCover.layer.cornerRadius=250/2;
    [artCoverView addSubview:rightArtistCover];
    
    [currentSongView addSubview:artCoverView];
 
    currentSongDuration =  [[UILabel alloc] initWithFrame:CGRectMake(165, 400, 120,20)];
    
    [currentSongDuration setBackgroundColor:[UIColor clearColor]];
    currentSongDuration.textColor =[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0];
    currentSongDuration.lineBreakMode=NSLineBreakByTruncatingTail;
    currentSongDuration.numberOfLines=1;
    
    currentSongDuration.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    currentSongDuration.textAlignment=NSTextAlignmentCenter;
 
    currentSongTimeElapsed =  [[UILabel alloc] initWithFrame:CGRectMake(35 , 10, 60,20)];
    
    [currentSongTimeElapsed setBackgroundColor:[UIColor clearColor]];
    currentSongTimeElapsed.textColor = [UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0] ;
    currentSongTimeElapsed.lineBreakMode=NSLineBreakByTruncatingTail;
    currentSongTimeElapsed.numberOfLines=1;
    
    currentSongTimeElapsed.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    currentSongTimeElapsed.textAlignment=NSTextAlignmentRight;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [currentSongView addSubview:currentSongDuration];
    //[currentSongView addSubview:currentSongTimeElapsed];

    _captureDuration = [[UISlider alloc] initWithFrame:CGRectMake(100, 360, 250, 30)];
    
  
        [currentSongView addSubview:_captureDuration];
      [_captureDuration setThumbTintColor:[UIColor redColor ]];
    
    //[_captureDuration setThumbImage:[UIImage imageNamed:@"circlebase.png"] forState: UIControlStateNormal ];
    [_captureDuration setMinimumTrackTintColor:[UIColor colorWithRed:0.66 green:0.019 blue:0.07 alpha:1.0]];
    [_captureDuration setMaximumTrackTintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [[AudioPlayer sharedInstance] enableScrubbingFromSlider:_captureDuration];

    [self.view addSubview:currentSongView];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [artCoverView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [artCoverView addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpAction:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUp.delegate = self;
    [artCoverView addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownAction:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDown.delegate = self;
    [artCoverView addGestureRecognizer:swipeDown];
    [self setupPlayButton];

}

-(void)setupSelectedArtistControl{
    
    selectedArtistView=[[UIView alloc] initWithFrame:CGRectMake(0,20,320,80)];
    selectedArtistView.layer.backgroundColor=[UIColor clearColor].CGColor;
   selectedArtistLabel =  [[UILabel alloc] initWithFrame:CGRectMake(85,25,235,25) ] ;
    selectedArtistView.layer.borderWidth=2;
    selectedArtistView.layer.borderColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    selectedArtistView.layer.backgroundColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0].CGColor;
    [selectedArtistLabel setBackgroundColor:[UIColor clearColor]];
   selectedArtistLabel.textColor = [UIColor whiteColor];
    selectedArtistLabel.lineBreakMode=NSLineBreakByTruncatingTail;
   selectedArtistLabel.numberOfLines=1;
    
    selectedArtistLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    selectedArtistLabel.textAlignment=NSTextAlignmentLeft;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    selectedArtistLabel.text=@"AIRSUGR";
    [selectedArtistView addSubview:selectedArtistLabel];
    selectedArtistCover = [[UIImageView alloc] initWithFrame: CGRectMake(10,3, 70, 70)];
    selectedArtistCover.layer.borderWidth=2;
    selectedArtistCover.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    

    [selectedArtistCover setContentMode:UIViewContentModeScaleAspectFit];
       [selectedArtistView addSubview:selectedArtistCover];
       [self.view addSubview:selectedArtistView];




}
- (void)swipeRightAction:(id)ignored
{
    
    if(isVisualizerEnabled){
        isVisualizerEnabled=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                          
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             [self.danceView setAlpha:0];
                         }
                         completion:^(BOOL finished){
                             
                             [self.danceView cleanUp];
                             self.danceView.dandelegate=nil;
                             [self.danceView removeFromSuperview];
                             self.danceView =nil;
                             context=nil;
                             [UIView animateWithDuration:0.3f
                                                   delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  
                                                  [selectedArtistView setAlpha:1];
                                                  [self.songsView reloadData];
                                                  [self.songsView setAlpha:1 ];
                                                  [self.mediatView setFrame:CGRectMake(0,frameHeight-210  , 326 ,260 )];
                                                  [bottomButton setAlpha:.5];

                                              }
                                              completion:^(BOOL finished){
                         
                                                  
                                              }];}];
    }
    else{
        [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
  
            [currentSongView setFrame:CGRectMake(self.view.bounds.size.width, 170, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
            
            
            
        }  completion:^(BOOL finished) {
                [audioPlayer stopMusicPlayer];
           
                [currentSongView removeFromSuperview];
                currentSongView= nil;
            }];
        
        
        
        
        
        
    }

}

- (void)swipeLeftAction:(id)ignored
{
        if(!isVisualizerEnabled){
            if([audioPlayer playStatus]==0)
            {
                [audioPlayer playPause];
            }
            
            isVisualizerEnabled=YES;
            [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
                [self.mediatView setFrame:CGRectMake(0, frameHeight , 320 ,254 )];
                [selectedArtistView setAlpha:0];
                [self.songsView setAlpha:0 ];
                
                 [bottomButton setAlpha:0];
                
            } completion:^(BOOL finished) {
                
                
                [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{

                    [currentSongView setFrame:CGRectMake(0,170,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                    
               } completion:^(BOOL finished) {
                    [self setupAnalyzer];
                    
                }];
            }];
        }
    
        else{
            [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
       
                [currentSongView setFrame:CGRectMake(-self.view.bounds.size.width/2, 170,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                
                
                
            } completion:^(BOOL finished) {
               
              

                [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
                    [self.danceView setAlpha:0];
                    [self.mediatView setFrame:CGRectMake(0, frameHeight-210 , 320 ,254 )];
                    [selectedArtistView setAlpha:1];
                    [self.songsView reloadData];
                    [self.songsView setAlpha:1 ];
 [bottomButton setAlpha:1];
                    
                } completion:^(BOOL finished) {
                     [audioPlayer stopMusicPlayer];
                    [self.danceView cleanUp];
                    self.danceView.dandelegate=nil;
                    [self.danceView removeFromSuperview];
                    self.danceView =nil;
                    context=nil;
                    [currentSongView removeFromSuperview];
                    currentSongView= nil;
                }];
            }];
        
        
        
        
        
        }

}
- (void)swipeUpAction:(id)ignored
{
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];

                           [currentSongView setFrame:CGRectMake(0, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             
                             [currentSongView setFrame:CGRectMake(0, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             currentSongView.hidden=NO;
                             
                             [audioPlayer playNextTrack];
                             
                             
                         }];
    }
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];

                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, -frameHeight,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             
                           [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, frameHeight,self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             currentSongView.hidden=NO;
                             
                             
                             
                             
                             [audioPlayer playNextTrack];
                             
                             
                         }];
        
        
        
        
        
    }
}

- (void)swipeDownAction:(id)ignored
{
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];

                             [currentSongView setFrame:CGRectMake(0, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             

                             [currentSongView setFrame:CGRectMake(0, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             currentSongView.hidden=NO;
                             
                             [audioPlayer playPrevTrack];
                             
                             
                         }];
    }
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [currentSongView setAlpha:0];
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                         }
                         completion:^(BOOL finished){
                             currentSongView.hidden=YES;
                             
                             
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, -frameHeight, self.view.bounds.size.width/2,self.view.bounds.size.height-80)];
                             currentSongView.hidden=NO;
                             
                             
                             
                             
                             [audioPlayer playPrevTrack];
                             
                             
                         }];
        
        
        
        
        
    }
    
}

- (void)tapAction:(id)ignored
{
 
    if(isVisualizerEnabled){
        isVisualizerEnabled=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [currentSongView setFrame:CGRectMake(self.view.bounds.size.width-450, self.view.bounds.size.width/2, 320,self.view.bounds.size.height-80)];
                             [self.danceView setAlpha:0];
                         }
                         completion:^(BOOL finished){
                             
                             [self.danceView cleanUp];
                             self.danceView.dandelegate=nil;
                             [self.danceView removeFromSuperview];
                             self.danceView =nil;
                             context=nil;
                             [UIView animateWithDuration:0.3f
                                                   delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  
                                                  [selectedArtistView setAlpha:1];
                                                  [self.songsView reloadData];
                                                  [self.songsView setAlpha:1 ];
                                                  [self.mediatView setFrame:CGRectMake(0,frameHeight-210  , 326 ,260 )];
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  
                                                  
                                              }];}];
    }
    
    [audioPlayer playPause];
    
}







-(void)setServerAddress:(NSString *)s{
    serverLabel.text=s;
    [serverLabel setNeedsDisplay];
    s=nil;
}
-(void)setBtText:(NSString *)s{
    bluetoothLabel.text=s;
    [bluetoothLabel setNeedsDisplay];
    s=nil;
}

-(void)setIsServerOn:(BOOL)s{
    
    isServerOn=s;
    if(isServerOn){
        serverLabel.textColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.07 alpha:1.0];
        serverImageView.layer.borderColor=[UIColor colorWithRed:1 green:1 blue:1.0 alpha:1.0].CGColor;
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/server.png"];
        serverImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        fullpath=nil;
        serverImageView.layer.backgroundColor=[UIColor colorWithRed:.8 green:0 blue:.07 alpha:1.0].CGColor;
        
        serverButton.layer.borderColor=[UIColor colorWithRed:.8 green:0.0 blue:0.07 alpha:1.0].CGColor;
        serverButton.layer.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor;
    }
    else {
        serverLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/server-black.png"];
        serverImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        serverImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        serverImageView.layer.borderColor=[UIColor blackColor].CGColor;
        fullpath=nil;
        serverImageView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1 blue:1 alpha:1.0].CGColor;
        
        serverButton.layer.borderColor=[UIColor whiteColor].CGColor;
        serverButton.layer.backgroundColor=[UIColor blackColor].CGColor;
        
    }
}-(void)setIsBtOn:(BOOL)s{
    isBTOn=s;
    if(isBTOn){
        bluetoothLabel.textColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.07 alpha:1.0];
        btImageView.layer.borderColor=[UIColor colorWithRed:1 green:1 blue:1.0 alpha:1.0].CGColor;
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bt.png"];
        btImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        fullpath=nil;
        btImageView.layer.backgroundColor=[UIColor colorWithRed:.8 green:0 blue:.07 alpha:1.0].CGColor;
        
        bluetoothButton.layer.borderColor=[UIColor colorWithRed:.8 green:0.0 blue:0.07 alpha:1.0].CGColor;
        bluetoothButton.layer.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor;
        
    }
    else { bluetoothLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        btImageView.layer.borderColor=[UIColor blackColor].CGColor;
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bt-black.png"];
        btImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        btImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        
        fullpath=nil;
        
        btImageView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1 blue:1 alpha:1.0].CGColor;
        
        bluetoothButton.layer.borderColor=[UIColor whiteColor].CGColor;
        bluetoothButton.layer.backgroundColor=[UIColor blackColor].CGColor;
        
        
        
    }
    
    
    
}


-(void)serverSwitch{
    
    
    if(serverAddress)
        serverAddress=nil;
    [network startHTTPServer];
    
}

-(void)btSwitch{
    if(connectedPeer)
        connectedPeer=nil;
    if(![network isBtConnected] ){
        
        [network startBT];
        
    }
    else [network endSession];
    
}
-(void)httpServerStartedOn:(NSString *)s
{
    isServerOn=YES;
    if(serverAddress)
        serverAddress=nil;
    
    serverAddress=s;
    
        [self setIsServerOn:YES];
        
        [self setServerAddress:s];
        
    
}
-(void)httpServerStopped{
    isServerOn=NO;
    if(serverAddress)
        serverAddress=nil;
    
    serverAddress=@"";
           [self setIsServerOn:NO];
        
        [self setServerAddress:serverAddress];
        
    
    
    
}
-(void)httpServerFailedToStart{
    isServerOn=NO;
    if(serverAddress)
        serverAddress=nil;
    
    serverAddress=@"Connection Failed";
    [self setIsServerOn:NO];
        
        [self setServerAddress:serverAddress];
        
    
    
}

-(void)switchServer{
    
    
    
    [self serverSwitch];
}
-(void)switchBt{
    if(![[Network sharedInstance] isBtConnected]){
        if(currentSession==nil)
        {
            currentSession = [[GKSession alloc] initWithSessionID:@"test" displayName:nil sessionMode:GKSessionModePeer];
        }
        if(connectionPicker==nil)
        {
            connectionPicker = [[GKPeerPickerController alloc] init];
            connectionPicker.delegate = self;
            //NOTE - GKPeerPickerConnectionTypeNearby is for Bluetooth connection, you can do the same thing over Wi-Fi with different type of connection
            connectionPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
        }
        
        [connectionPicker show];
        connectionPicker=nil;
        currentSession=nil;}
    else
        [[Network sharedInstance] endSession];
    
    
}
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    
    
    
    
    
    
    return currentSession;
    
    
    
}
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    
    
    
    
    connectionPicker.delegate=nil;
    currentSession.delegate=nil;
    currentSession=nil;
    picker.delegate = nil;
    [picker dismiss];
    picker=nil;
    session.delegate=nil;
    session.available=NO;
    [[Network sharedInstance] createSessionWithIdentifier:session];
    
    session=nil;
    session=nil;
    
}
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    connectionPicker.delegate=nil;
    currentSession.delegate=nil;
    connectionPicker.delegate=nil;
    connectionPicker=nil;
    picker.delegate = nil;
    
    picker=nil;
    
    
}
-(void)setUpScroll{
_captureDuration = [[UISlider alloc] initWithFrame:CGRectMake(500, 100, 170, 30)];
 
[_captureDuration setThumbTintColor:[UIColor blackColor]];
 
[self.view addSubview:_captureDuration];
}

-(void)setupBottomView{
    
    bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-50 ,self.view.bounds.size.height/2-55, 100 , 100 )];
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0,0, 100, 100)];
    [myImageView setContentMode:UIViewContentModeScaleAspectFit];
    myImageView.image = [UIImage imageNamed: @"iPad.png"];
 
    [bottomButton setImage:myImageView.image forState:UIControlStateNormal];
    [bottomButton addTarget:self action:@selector(toggleOptions) forControlEvents:UIControlEventTouchUpInside];
   
    [self.view addSubview:bottomButton];
    [bottomButton setAlpha:.5];
    myImageView=nil;
 
    
}

-(void)toggleOptions{

if(isOptionsVisible)
{
    [bottomButton setAlpha:.5];

    isOptionsVisible=NO;
    [bluetoothButton setHidden:YES];
    [bluetoothView setHidden:YES];
    [serverButton setHidden:YES];
    [serverView setHidden:YES];
    [self.songsView setAlpha:1.0 ];
    [self.mediatView setAlpha:1.0 ];
    [currentSongView setAlpha:1.0 ];
    [selectedArtistView setAlpha:1.0];

}
else {
    [bottomButton setAlpha:1];
[self.songsView setAlpha:.5 ];
    [self.mediatView setAlpha:.5 ];
    [currentSongView setAlpha:.5 ];
    [selectedArtistView setAlpha:.5];
    [bluetoothButton setHidden:NO];
    [bluetoothView setHidden:NO];
    [serverButton setHidden:NO];
    [serverView setHidden:NO];
    isOptionsVisible=YES;


}
    

}

@end