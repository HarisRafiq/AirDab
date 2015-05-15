//
//  ControlView.m
//  AirDab
//
//  Created by YAZ on 10/1/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "ControlView.h"
#import "Network.h"
#import "CommonIpad.h"
@implementation ControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor blackColor]];
       
 
        if([[UIScreen mainScreen] bounds].size.height >= 568.0f)
            VISUALIZER_OFFSET=221 ;
        else VISUALIZER_OFFSET=144;
         
    }
    return self;
}

-(void)cleanAnalyzer{
    if(self.danceView)
    {[self.danceView cleanUp];
        [self.danceView removeFromSuperview];
        self.danceView=nil;
        
    }


}
-(void)setupAnalyzer{
    //we init our GLKView subclass with our newly created context
    if(self.danceView)
    {[self.danceView cleanUp];
        [self.danceView removeFromSuperview];
        self.danceView=nil;
        
    }
    if(myImageView)
    {
        [myImageView removeFromSuperview];
        myImageView=nil;
        
    }
    self.danceView = [[dance alloc] initWithFrame:CGRectMake(0,100, self.bounds.size.width ,self.bounds.size.height-200 ) context:context];
    
    
    
    
    [self insertSubview:self.danceView atIndex:0];
    
    [self.danceView setDandelegate:self ];
    
    
}
-(void)setupLogo{
     myImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0,50, self.bounds.size.width, self.bounds.size.height-100 )];
    [myImageView setContentMode:UIViewContentModeScaleAspectFit];
    myImageView.image = [UIImage imageNamed: @"LOGO.png"];
    myImageView.layer.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    [self insertSubview:myImageView atIndex:0];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setupSongView{
    playingView=[[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/4 , 100,self.bounds.size.width/2 ,80)];
    playingView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    songTitle =  [[UILabel alloc] initWithFrame:CGRectMake(80,5,self.bounds.size.width/2-80 ,20) ] ;
    
    [songTitle setBackgroundColor:[UIColor clearColor]]  ;
    
    songTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    songTitle.textAlignment=NSTextAlignmentLeft;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
       songTitle.textColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.07 alpha:1.0];
    songTitle.text=@"NOW PLAYING";
    
    artistCover = [[UIImageView alloc] initWithFrame: CGRectMake(0,0, 70, 70)];
    
    [artistCover setContentMode:UIViewContentModeScaleAspectFit];
    artistCover.layer.borderWidth=0;
    
    artistCover.clipsToBounds = YES;
    artistCover.image=[UIImage imageNamed: @"wave-white.png"];
    
    artistTitle =  [[UILabel alloc] initWithFrame:CGRectMake(80,25,self.bounds.size.width/2-80 ,20) ] ;
    
    [artistTitle setBackgroundColor:[UIColor clearColor]]  ;
    
    artistTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    artistTitle.textAlignment=NSTextAlignmentLeft;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    artistTitle.textColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.07 alpha:1.0];
    artistTitle.text=@"Now Playing";
    [playingView addSubview:artistCover];
    [playingView addSubview:songTitle];
     [playingView addSubview:artistTitle];
    [self addSubview:playingView];
    
    
}


-(void)setupServerView{
    serverView=[[UIView alloc] initWithFrame:CGRectMake(90, 90,165,20)];
    serverView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    serverLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0,0,165,20) ] ;
    
    [serverLabel setBackgroundColor:[UIColor clearColor]]  ;
    
    serverLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    serverLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
    [serverView addSubview:serverLabel];
    [self addSubview:serverView];
    
    
}

-(void)setupBluetoothView{
    bluetoothView=[[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-90, 90,165,20)];
    bluetoothView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    bluetoothLabel =  [[UILabel alloc] initWithFrame:CGRectMake(0,0,165,20) ] ;
    
    [bluetoothLabel setBackgroundColor:[UIColor clearColor]]  ;
    
    bluetoothLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    bluetoothLabel.textAlignment=NSTextAlignmentCenter;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    [bluetoothView addSubview:bluetoothLabel];
    [self addSubview:bluetoothView];
    
    
}

-(void)setupBTButton{
    
    btButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-160, 10, 75, 75)];
    btImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    
    [btImageView setContentMode:UIViewContentModeScaleAspectFit];
    btImageView.layer.borderWidth=2;
    [btImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    btImageView.layer.borderWidth=2;
     btImageView.clipsToBounds = YES;
    
    
    btButton.layer.borderWidth=2;
    
    
    [btButton addTarget:self action:@selector(switchBt) forControlEvents:UIControlEventTouchUpInside];
    [btButton addSubview:btImageView];
    [self addSubview:btButton];
    
    
}
-(void)setupServerButton{
    
    serverButton = [[UIButton alloc] initWithFrame:CGRectMake(90,  10, 75, 75)];
    serverImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    [serverImageView setContentMode:UIViewContentModeScaleAspectFit];
    serverImageView.layer.borderWidth=2;
    
    serverImageView.layer.borderWidth=2;
     serverImageView.clipsToBounds = YES;
    
    serverButton.layer.borderWidth=2;
    
    [serverButton addTarget:self action:@selector(switchServer) forControlEvents:UIControlEventTouchUpInside];
    [serverButton addSubview:serverImageView];
    [self addSubview:serverButton];
    
    
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
        serverButton.layer.backgroundColor=[UIColor colorWithRed:.1 green:1 blue:1 alpha:1.0].CGColor;
    }
    else {
        serverLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/server-black.png"];
        serverImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        serverImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        serverImageView.layer.borderColor=[UIColor blackColor].CGColor;
        fullpath=nil;
        serverImageView.layer.backgroundColor=[UIColor colorWithRed:.12 green:.12 blue:.12 alpha:1.0].CGColor;
        
        serverButton.layer.borderColor=[UIColor colorWithRed:.12 green:.12 blue:.12 alpha:1.0].CGColor;
        serverButton.layer.backgroundColor=[UIColor blackColor].CGColor;
        
    }
}
-(void)setIsBtOn:(BOOL)s{
    isBtOn=s;
    if(isBtOn){
        bluetoothLabel.textColor = [UIColor colorWithRed:0.9 green:0.0 blue:0.07 alpha:1.0];
        btImageView.layer.borderColor=[UIColor colorWithRed:1 green:1 blue:1.0 alpha:1.0].CGColor;
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bt.png"];
        btImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        fullpath=nil;
        btImageView.layer.backgroundColor=[UIColor colorWithRed:.8 green:0 blue:.07 alpha:1.0].CGColor;
        
        btButton.layer.borderColor=[UIColor colorWithRed:.8 green:0.0 blue:0.07 alpha:1.0].CGColor;
        btButton.layer.backgroundColor=[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor;
        
    }
    else { bluetoothLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        btImageView.layer.borderColor=[UIColor blackColor].CGColor;
        NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/bt-black.png"];
        btImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        btImageView.image = [UIImage imageWithContentsOfFile:fullpath];
        
        fullpath=nil;
        
        btImageView.layer.backgroundColor=[UIColor colorWithRed:.12 green:.12 blue:.12 alpha:1.0].CGColor;
        
        btButton.layer.borderColor=[UIColor colorWithRed:.12 green:.12 blue:.12 alpha:1.0].CGColor;
        btButton.layer.backgroundColor=[UIColor blackColor].CGColor;
        
        
        
    }
    
    
    
}
-(void)switchServer{
    
    
    
    [self.delegate serverSwitch];
}
-(void)switchBt{
    if(![[Network sharedInstance] isBtConnected]){
        if(currentSession==nil)
        {
            currentSession = [[GKSession alloc] initWithSessionID:nil displayName:nil sessionMode:GKSessionModePeer];
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
-(void)cleanUp{
    [btButton removeFromSuperview];
    [serverButton removeFromSuperview];
    [btImageView removeFromSuperview];
    [serverImageView removeFromSuperview];
    [bluetoothLabel removeFromSuperview];
    [serverLabel removeFromSuperview];
    [serverView removeFromSuperview];
    [bluetoothView removeFromSuperview];
    [bottomButton removeFromSuperview];
    [bottomView removeFromSuperview];
    bluetoothLabel=nil;
    serverView=nil;
    bluetoothView=nil;
    serverButton=nil;
    bottomView=nil;
    bottomButton=nil;
    btButton=nil;
    
    btImageView=nil;
    serverImageView=nil;
    
    
    
}

@end
