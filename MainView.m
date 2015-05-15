//
//  MainView.m
//  AirDab
//
//  Created by YAZ on 9/6/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "MainView.h"
#import "Network.h"
@implementation MainView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
        [self setBackgroundColor:[UIColor blackColor]];
        [self setupBottomView];
        [self setupServerView];
        [self setupBluetoothView];
        [self setupBTButton];
        [self setupServerButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setupServerView{
    serverView=[[UIView alloc] initWithFrame:CGRectMake(90,55,self.bounds.size.width-90,60)];
    serverView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
   
    
    serverLabel =  [[UILabel alloc] initWithFrame:CGRectMake(5,0,self.bounds.size.width-100 ,60) ] ;
    
    [serverLabel setBackgroundColor:[UIColor clearColor]]  ;
 
    serverLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    serverLabel.textAlignment=NSTextAlignmentLeft;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
   
    [serverView addSubview:serverLabel];
    [self addSubview:serverView];
   
    
}

-(void)setupBluetoothView{
    bluetoothView=[[UIView alloc] initWithFrame:CGRectMake(90,145,self.bounds.size.width-90,60)];
    bluetoothView.layer.backgroundColor=[UIColor clearColor].CGColor;
    
    
    
    bluetoothLabel =  [[UILabel alloc] initWithFrame:CGRectMake(5,0,self.bounds.size.width-100 ,60) ] ;
    
    [bluetoothLabel setBackgroundColor:[UIColor clearColor]]  ;
   
    bluetoothLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    bluetoothLabel.textAlignment=NSTextAlignmentLeft;
    //[self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
         [bluetoothView addSubview:bluetoothLabel];
    [self addSubview:bluetoothView];
  
    
}
-(void)setupBTButton{
    
    btButton = [[UIButton alloc] initWithFrame:CGRectMake(5,140 , 75, 75)];
    btImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];

        [btImageView setContentMode:UIViewContentModeScaleAspectFit];
        btImageView.layer.borderWidth=2;
    [btImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    btImageView.layer.borderWidth=2;
    btImageView.layer.cornerRadius=70/2;
 btImageView.clipsToBounds = YES; 
    
    
    btButton.layer.borderWidth=2;
    btButton.layer.cornerRadius=75/2;
    
  
    [btButton addTarget:self action:@selector(switchBt) forControlEvents:UIControlEventTouchUpInside];
    [btButton addSubview:btImageView];
    [self addSubview:btButton];
    
    
}
-(void)setupServerButton{
    
    serverButton = [[UIButton alloc] initWithFrame:CGRectMake(5,50, 75, 75)];
    serverImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    [serverImageView setContentMode:UIViewContentModeScaleAspectFit];
        serverImageView.layer.borderWidth=2;
  
    serverImageView.layer.borderWidth=2;
    serverImageView.layer.cornerRadius=70/2;
 serverImageView.clipsToBounds = YES; 
   
    serverButton.layer.borderWidth=2;
    serverButton.layer.cornerRadius=72/2;
     
    [serverButton addTarget:self action:@selector(switchServer) forControlEvents:UIControlEventTouchUpInside];
    [serverButton addSubview:serverImageView];
    [self addSubview:serverButton];
    
    
}
-(void)setupBottomView{
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];

    bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-(75/2),self.bounds.size.height-85, 75, 75)];
     [myImageView setContentMode:UIViewContentModeScaleAspectFit];
    myImageView.image = [UIImage imageNamed: @"wave-black.png"];
    myImageView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1 blue:1 alpha:1.0].CGColor;
    myImageView.layer.borderWidth=2;
    myImageView.layer.borderColor=[UIColor blackColor].CGColor;
    myImageView.layer.borderWidth=2;
    myImageView.layer.cornerRadius=70/2;
    myImageView.clipsToBounds = YES; 
    bottomButton.layer.borderWidth=2;
    bottomButton.layer.cornerRadius=75/2;
    bottomButton.layer.borderColor=[UIColor blackColor].CGColor;

    bottomButton.layer.backgroundColor=[UIColor blackColor].CGColor;
    [bottomButton addTarget:self action:@selector(viewChange) forControlEvents:UIControlEventTouchUpInside];
    [bottomButton addSubview:myImageView];
    [self addSubview:bottomButton];

    
    
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
-(void)viewChange{
    
    
    [self.delegate changeView];
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
        
        btImageView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1 blue:1 alpha:1.0].CGColor;
        
        btButton.layer.borderColor=[UIColor whiteColor].CGColor;
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
