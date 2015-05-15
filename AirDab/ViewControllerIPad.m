//
//  ViewControllerIPad.m
//  AirDab
//
//  Created by YAZ on 9/20/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "ViewControllerIPad.h"
//
//  ViewController.m
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//


#import "SongsCell.h"
#import "CommonIpad.h"

@implementation ViewControllerIPad


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
    [self.view setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] ];
    
    
    
    
    
    isVisualizerEnabled=NO;
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [self setupMediaView];
    [self setupTitleLabel];
}

-(void)setupMediaView
{
    frameHeight=self.view.bounds.size.height;
    framewidth=320;
    
    if(self.mediatView){
        [self.mediatView removeFromSuperview];
        self.mediatView =nil;
    }
    self.mediatView=[[MediaTableView alloc] initWithFrame:CGRectMake(0,frameHeight-200  , 320 ,254 )];
    [self.view addSubview:self.mediatView];
    
    
    [self.mediatView setDelegate:self];
    
    
}
-(void)playLocalSongsWithUrl:(NSString *)temp atIndex:(int)i scrollPosition:(CGPoint )p
{
    isPlaying=YES;
    
    totalDuration= songsCell.duration.text ;
    [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [self.mediatView setAlpha:0];
        [self.songsView setAlpha:0 ];
        
        [self.view setBackgroundColor:[UIColor blackColor]];
        [songsCell setBackgroundColor:[UIColor blackColor]];
        [self.songsView setBackgroundColor:[UIColor blackColor] ];
    } completion:^(BOOL finished) {
        
        [self setupAnalyzer];
        [audioPlayer setCurrentArtistIndex:currentSelectedArtistIndex];
        [audioPlayer setCurrentSongIndex:i];
        
        
        
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, framewidth, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, framewidth, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             [self startTimer];
                             NSURL *url=[NSURL URLWithString:[temp stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];;
                             
                             [audioPlayer play:url] ;
                             [songsCell setSelected:YES];
                         }]; }];
    
    
}


-(void)playSongsWithUrl:(MPMediaItem *)temp atIndex:(int)i scrollPosition:(CGPoint )p
{
    isPlaying=YES;
    
    [[AudioPlayer sharedInstance] setCurrentSongTitle:[temp valueForProperty:MPMediaItemPropertyTitle]];
    totalDuration=[self convertTimeFromSeconds:[temp valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    
    
    [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
        [self.mediatView setAlpha:0];
        [self.songsView setAlpha:0 ];
        
        
    } completion:^(BOOL finished) {
        
        [self setupAnalyzer];
        
        
        
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view setBackgroundColor:[UIColor blackColor]];
                             [songsCell setBackgroundColor:[UIColor blackColor]];
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, framewidth, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, framewidth, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             [self startTimer];
                             [audioPlayer setUpWithArtist:currentSelectedArtist];
                             [audioPlayer setCurrentArtistIndex:currentSelectedArtistIndex];
                             [audioPlayer setCurrentSongIndex:i];
                             [audioPlayer play:[temp valueForProperty:MPMediaItemPropertyAssetURL]] ;
                             [songsCell setSelected:YES];
                             
                         }]; }];
    
    
    
}
-(void)addSelectedSongView:(SongsCell *)c{
    
    
    if(songsCell){
        [songsCell removeFromSuperview];
        songsCell= nil;
    }
    songsCell=c;
    [songsCell setPlayer:YES];
    [songsCell setSelected:NO];
    
    [songsCell setFrame:CGRectMake(c.frame.origin.x, c.frame.origin.y+SONGS_VIEW_OFFSET, c.frame.size.width, c.frame.size.height)];
    [self.view addSubview:songsCell];
	UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [songsCell addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [songsCell addGestureRecognizer:swipeLeft];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpAction:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUp.delegate = self;
    [songsCell addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDownAction:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDown.delegate = self;
    [songsCell addGestureRecognizer:swipeDown];
    [self.view bringSubviewToFront:songsCell];
    
}



-(void)updatePosition{
    double pos = [audioPlayer amountPlayed];
	
	[self.mediatView updateDurationLabel:pos];
    
    
}

- (void)swipeRightAction:(id)ignored
{
    [songsCell setSelected:YES];
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(self.view.bounds.size.width, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             self.danceView.hidden=YES;
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(-self.view.bounds.size.width, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             songsCell.hidden=NO;
                             self.danceView.hidden=NO;
                             
                             
                             [songsCell setSelected:YES];
                             [audioPlayer playPrevTrack];
                             
                             
                         }];
    }
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             songsCell.hidden=NO;
                             
                             
                             
                             [songsCell setSelected:NO];
                             [audioPlayer playPrevTrack];
                             
                             
                         }];
        
        
        
        
        
    }
}

- (void)swipeLeftAction:(id)ignored
{
    
    [songsCell setSelected:YES];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(-self.view.bounds.size.width, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             self.danceView.hidden=YES;
                             
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(self.view.bounds.size.width, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             songsCell.hidden=NO;
                             self.danceView.hidden=NO;
                             [songsCell setSelected:YES];
                             [audioPlayer playNextTrack];
                             
                             
                             
                             
                         }];
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             
                             
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             
                             songsCell.hidden=NO;
                             
                             [songsCell setSelected:NO];
                             [audioPlayer playNextTrack];
                             
                             
                             
                             
                         }];
        
        
        
    }
    
}
- (void)swipeUpAction:(id)ignored
{
    
    
    
    [songsCell setSelected:NO];
    
    
    if(isVisualizerEnabled){
        isPlaying=NO;
        isVisualizerEnabled=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view setBackgroundColor:[UIColor whiteColor]];
                             [songsCell setBackgroundColor:[UIColor whiteColor]];
                             
                             [songsCell setFrame:CGRectMake(0, -100, self.view.bounds.size.width, 60)];
                             
                             
                             [self.danceView setFrame:CGRectMake(0,  frameHeight , self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             [songsCell removeFromSuperview];
                             songsCell= nil;
                             [self.songsView setFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET) )];
                             [self.songsView layoutSubviews];
                             [self.songsView reloadData];
                             [self setCellTitle:currentSelectedArtist AndImage:currentArtistCover];
                             
                             [audioPlayer stopMusicPlayer];
                             [self.danceView cleanUp];
                             self.danceView.dandelegate=nil;
                             [self.danceView removeFromSuperview];
                             self.danceView =nil;
                             context=nil;
                             
                             
                             [UIView animateWithDuration:0.3f
                                                   delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  
                                                  [self.mediatView setAlpha:1];
                                                  [self.songsView setAlpha:1 ];
                                                  
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  
                                                  [songsCell setSelected:NO];
                                                  
                                                  
                                              }];
                         }];
    }
    else {
        isVisualizerEnabled=YES;
        [UIView animateWithDuration:0.2f delay:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            [self.mediatView setAlpha:0];
            [self.songsView setAlpha:0 ];
            [self.view setBackgroundColor:[UIColor blackColor]];
            [songsCell setBackgroundColor:[UIColor blackColor]];
            
        } completion:^(BOOL finished) {
            
            [self setupAnalyzer];
            
            
            
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                                 [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 [songsCell setSelected:YES];
                             }];
            
        }];
    }
    
}
- (void)swipeDownAction:(id)ignored
{[songsCell setSelected:NO];
    [self.songsView setFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET)-60 )];
    [self.songsView layoutSubviews];
    [self.songsView reloadData];
    [self setCellTitle:currentSelectedArtist AndImage:currentArtistCover];
    if(isVisualizerEnabled){
        isVisualizerEnabled=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view setBackgroundColor:[UIColor whiteColor]];
                             [songsCell setBackgroundColor:[UIColor whiteColor]];
                             [songsCell setFrame:CGRectMake(0,(frameHeight-242) , self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0,  self.view.bounds.size.height , self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             
                             
                             
                         }
                         completion:^(BOOL finished){
                             [self.danceView cleanUp];
                             self.danceView.dandelegate=nil;
                             [self.danceView removeFromSuperview];
                             self.danceView =nil;
                             context=nil;
                             
                             
                             [UIView animateWithDuration:0.3f
                                                   delay:0.1 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  
                                                  [self.mediatView setAlpha:1];
                                                  [self.songsView setAlpha:1 ];
                                                  
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  [self.view bringSubviewToFront:songsCell];
                                                  [songsCell setSelected:NO];
                                                  
                                                  
                                              }];
                         }];
    }
    else{
        [audioPlayer stopMusicPlayer];
        isPlaying=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 60)];
                             
                             if(self.songsView)
                             {
                                 [self.songsView setFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET) )];
                                 [self.songsView layoutSubviews];
                             }
                             
                             
                         }
                         completion:^(BOOL finished){
                             songsCell =nil;
                         }];
        
    }
    
    
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

-(void)setupAnalyzer{
    //we init our GLKView subclass with our newly created context
    if(self.danceView)
    {[self.danceView cleanUp];
        [self.danceView removeFromSuperview];
        self.danceView=nil;
        
    }
    self.danceView = [[dance alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height-VISUALIZER_OFFSET, self.view.bounds.size.width  ,self.view.bounds.size.height-VISUALIZER_OFFSET ) context:context];
    
    
    
    
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
    
    subView=[[UIView alloc] initWithFrame:CGRectMake(0,21,self.view.bounds.size.width ,52)];
    subView.layer.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    artistCover = [[UIImageView alloc] initWithFrame: CGRectMake(5,1, 50, 50)];
    
    [artistCover setContentMode:UIViewContentModeScaleAspectFit];
    artistCover.layer.borderWidth=0;
    
    artistCover.clipsToBounds = YES;
    
    
    
    self.titleLabel =  [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width+10  ) /4,0,(self.view.bounds.size.width-10  )/2   ,52) ] ;
    
    [self.titleLabel setBackgroundColor:[UIColor clearColor]]  ;
    self.titleLabel.textColor = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1.0] ;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    self.titleLabel.text=@"AIRSUGR";
    [subView addSubview:self.titleLabel];
    [subView addSubview:artistCover];
    [self.view addSubview:topView];
    [self.view addSubview:subView];
    
    topView=nil ;
    subView=nil;
}
-(void)addSongsViewWithArtist:(NSString *)artist AtIndex:(int)i isLocal:(BOOL)s AndImage:(UIImage *)image
{
    [self setCellTitle:artist AndImage:image];
    currentSelectedArtist=artist;
    currentSelectedArtistIndex=i;
    currentArtistCover=image;
    [self.songsView removeFromSuperview];
    self.songsView =nil;
    //[self setupTitle:artist];
    
    if(isPlaying){
        self.songsView=[[SongsView alloc] initWithFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET)-60  ) ];
        [self.view bringSubviewToFront:songsCell];
    }
    
    else {
        self.songsView=[[SongsView alloc] initWithFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET) ) ];
        
        
    }
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
    
    artistCover.image = image;
    self.titleLabel.text = title;
    [self.titleLabel setNeedsDisplay];
    [artistCover setNeedsDisplay];
    title=nil;
    image=nil;
}
-(void)call{
    
    
    
    //[network startHTTPServer];
    [self setupMainView];
    
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
    NSString *songTitle = [item valueForProperty: MPMediaItemPropertyTitle];
    
    
    totalDuration=[self convertTimeFromSeconds:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    
    
    
    
    [songsCell.title setText:songTitle];
    [songsCell.duration setText:totalDuration];
    [songsCell setNeedsDisplay];
    [super.view layoutSubviews];
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             MPMediaItemArtwork *artWork = [item valueForProperty:MPMediaItemPropertyArtwork];
                             UIImage *finalImage=[artWork imageWithSize:CGSizeMake(5, 5)] ;
                             [self setCellTitle:[item valueForProperty: MPMediaItemPropertyArtist] AndImage:finalImage];
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0,  (frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
    
}
- (void)audioPlayerDidStartPlayingPrevTrackWithMPItem:(MPMediaItem *)item{
    
    
    NSString *songTitle = [item valueForProperty: MPMediaItemPropertyTitle];
    totalDuration=[self convertTimeFromSeconds:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]];
    
    
    
    
    [songsCell.title setText:songTitle];
    [songsCell.duration setText:totalDuration];
    [songsCell setNeedsDisplay];
    [super.view layoutSubviews];
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             MPMediaItemArtwork *artWork = [item valueForProperty:MPMediaItemPropertyArtwork];
                             UIImage *finalImage=[artWork imageWithSize:CGSizeMake(5, 5)] ;
                             [self setCellTitle:[item valueForProperty: MPMediaItemPropertyArtist] AndImage:finalImage];
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
    }
    
    else{
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0,  (frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    
}
- (void)audioPlayerDidStartPlayingPrevTrackWithLocalSongs:(NSString *)songTitle{
    
    
    [songsCell.title setText:songTitle];
    [songsCell.duration setText:totalDuration];
    [songsCell setNeedsDisplay];
    [super.view layoutSubviews];
    if(isVisualizerEnabled){
        [self setCellTitle:@"DRIVE MUSIC" AndImage:nil] ;
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             [UIView animateWithDuration:0.3f
                                                   delay:0.0 options:UIViewAnimationOptionTransitionNone
                                              animations:^{
                                                  
                                                  [songsCell setFrame:CGRectMake(0,  SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                                                  
                                              }
                                              completion:^(BOOL finished){
                                                  
                                                  
                                                  
                                                  
                                              }];
                             
                             
                             
                         }];
        
        
        
        
    }
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0,  (frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
        
    }
    
}
- (void)audioPlayerDidStartPlayingNextTrackWithLocalSongs:(NSString *)songTitle{
    
    
    
    
    
    
    
    [songsCell.title setText:songTitle];
    [songsCell.duration setText:totalDuration];
    [songsCell setNeedsDisplay];
    [super.view layoutSubviews];
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [self setCellTitle:@"DRIVE MUSIC" AndImage:nil] ;
                             
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
    }
    else{
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0,(frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
        
    }
}
-(void)peerDisconnected:(NSString *)pid{ connectedPeer=nil;isBTOn=NO;
    [self stopTimer];
    [audioPlayer stopVoip];
    if(mainView!=nil)
    {
        [mainView setIsBtOn:isBTOn];
        
        [mainView setBtText:@"Bluetooth is off"];
        
        
    }
    if(songsCell!=nil)
        [songsCell setFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 60)];
    if(isVisualizerEnabled)
    {isVisualizerEnabled=NO;
        [self.danceView cleanUp];
        [self.danceView removeFromSuperview];
        self.danceView=nil;
        [self.mediatView setAlpha:1];
        [self.songsView setAlpha:1 ];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.mediatView setBackgroundColor:[UIColor whiteColor]];
        [self.songsView setBackgroundColor:[UIColor whiteColor]];
        if(self.songsView!=nil)
        {
            
            
            [self.songsView setFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET) )];
            [self.songsView layoutSubviews];
            [self.songsView reloadData];
            
        }
    }
    
    
    
}
-(void)peerConnected:(NSString *)pid{connectedPeer=pid; isBTOn=YES;
    
    if(mainView!=nil)
    {
        [mainView setIsBtOn:isBTOn];
        
        [mainView setBtText:connectedPeer];
        
    }}

-(void)peerAvailable:(NSString *)pid{ }

-(void)updateTimeLabel{
    [songsCell.duration setText:[NSString stringWithFormat:@"%@/%@",[self convertTimeFromSeconds:[NSString stringWithFormat:@"%i",[audioPlayer currentTime]/44100  ] ],totalDuration]];
    [songsCell setNeedsDisplay];
    
    
}
- (void)audioPlayerDidFinsihPlaying:(AudioPlayer *)player{
    
    if(isVisualizerEnabled){
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(-self.view.bounds.size.width,VISUALIZER_OFFSET, self.view.bounds.size.width,self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             [super.view layoutSubviews];
                             
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             self.danceView.hidden=YES;
                             
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(self.view.bounds.size.width, VISUALIZER_OFFSET, self.view.bounds.size.width, self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             songsCell.hidden=NO;
                             self.danceView.hidden=NO;
                             
                             [super.view layoutSubviews];
                             
                             [self playNextTrack];
                             
                             
                         }];
    }
    
    else{
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(-self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             songsCell.hidden=YES;
                             [songsCell setFrame:CGRectMake(self.view.bounds.size.width,(frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
                             songsCell.hidden=NO;
                             
                             [self playNextTrack];
                             
                             
                         }];
        
        
        
    }
    
}
-(void)audioPlayerIsAlreadyPlayingFirstSong{   songsCell.hidden=YES;
    if(isVisualizerEnabled){
        
        [songsCell setFrame:CGRectMake(self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
        [self.danceView setFrame:CGRectMake(self.view.bounds.size.width,VISUALIZER_OFFSET, self.view.bounds.size.width,self.view.bounds.size.height-VISUALIZER_OFFSET)];
        [super.view layoutSubviews];
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             songsCell.hidden=NO;
                             
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0,VISUALIZER_OFFSET, self.view.bounds.size.width,self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                         }];
    }
    
    else{
        [songsCell setFrame:CGRectMake(self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
        
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             songsCell.hidden=NO;
                             [songsCell setFrame:CGRectMake(0,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                             
                         }];
        
        
        
    }}
-(void)audioPlayerIsAlreadyPlayingLastSong{
    songsCell.hidden=YES;
    if(isVisualizerEnabled){
        
        [songsCell setFrame:CGRectMake(-self.view.bounds.size.width, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
        [self.danceView setFrame:CGRectMake(-self.view.bounds.size.width,VISUALIZER_OFFSET, self.view.bounds.size.width,self.view.bounds.size.height-VISUALIZER_OFFSET)];
        [super.view layoutSubviews];
        songsCell.hidden=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             [songsCell setFrame:CGRectMake(0, SONGS_VIEW_OFFSET, self.view.bounds.size.width, 60)];
                             [self.danceView setFrame:CGRectMake(0,VISUALIZER_OFFSET, self.view.bounds.size.width,self.view.bounds.size.height-VISUALIZER_OFFSET)];
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             
                         }];
    }
    
    else{
        [songsCell setFrame:CGRectMake(-self.view.bounds.size.width,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
        songsCell.hidden=NO;
        [UIView animateWithDuration:0.3f
                              delay:0.0 options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             [songsCell setFrame:CGRectMake(0,  (frameHeight-SONGS_CELL_Y_OFFSET) , self.view.bounds.size.width, 60)];
                             
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

-(void)stopTimer{
    if(self.positionTimer){
        [self.positionTimer invalidate];
        self.positionTimer=nil;
    }
}
-(void)handleEnteredBackground:(id)s{
    
    
    if(isVisualizerEnabled)
    {
        isVisualizerEnabled=NO;
        [songsCell setFrame:CGRectMake(0, (frameHeight-SONGS_CELL_Y_OFFSET), self.view.bounds.size.width, 60)];
        [songsCell setSelected:NO];
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [songsCell setBackgroundColor:[UIColor whiteColor]];
        [self.view setAlpha:1];
        [self.mediatView setBackgroundColor:[UIColor whiteColor]];
        [self.mediatView setAlpha:1];
        [self.songsView setAlpha:1];
        [self.songsView setBackgroundColor:[UIColor whiteColor]];
        [self.songsView setFrame:CGRectMake(0,SONGS_VIEW_OFFSET ,self.view.bounds.size.width,(frameHeight-SONGS_VIEW_HEIGHT_OFFSET)-60 )];
        [self.songsView layoutSubviews];
        [self.songsView reloadData];
        
        [self.danceView cleanUp];
        self.danceView.dandelegate=nil;
        [self.danceView removeFromSuperview];
        self.danceView =nil;
        context=nil;
        
        
        
        
    }
}
-(void)setSongTitle{
    if(songsCell){
        [[songsCell title] setText:[[AudioPlayer sharedInstance] currentSongTitle]];
        [songsCell setNeedsDisplay];
        [super.view layoutSubviews];
        [self.view bringSubviewToFront:songsCell];
    }
}

-(void)setupMainView{
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    if(mainView!=nil){
        [mainView removeFromSuperview];
        mainView =nil;
    }
    mainView=[[MainView alloc] initWithFrame:CGRectMake(0,SONGS_VIEW_OFFSET  , self.view.bounds.size.width  ,self.view.bounds.size.height-SONGS_VIEW_OFFSET)];
    
    
    
    [mainView setIsServerOn:isServerOn];
    [mainView setIsBtOn:isBTOn];
    if(isServerOn)
    {
        [mainView setServerAddress:serverAddress];
    }
    else {[mainView setServerAddress:@"Server is off"];}
    if(isBTOn)
    {
        [mainView setBtText:connectedPeer];
        
    }
    else  {
        [mainView setBtText:@"Bluetooth is off"];
    }
    [self.view addSubview:mainView];
    [mainView setDelegate:self];
    
}
-(void)changeView{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [mainView cleanUp];
    [mainView removeFromSuperview];
    mainView =nil;
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
    if(mainView)
    {
        [mainView setIsServerOn:YES];
        
        [mainView setServerAddress:s];
        
    }
}
-(void)httpServerStopped{
    isServerOn=NO;
    if(serverAddress)
        serverAddress=nil;
    
    serverAddress=@"Server is off";
    if(mainView)
    {
        [mainView setIsServerOn:NO];
        
        [mainView setServerAddress:serverAddress];
        
    }
    
    
}
-(void)httpServerFailedToStart{
    isServerOn=NO;
    if(serverAddress)
        serverAddress=nil;
    
    serverAddress=@"Server failed to start";
    if(mainView)
    {
        [mainView setIsServerOn:NO];
        
        [mainView setServerAddress:serverAddress];
        
    }
    
    
}



@end
