//
//  Network.m
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "Network.h"
#import "AudioPlayer.h"
#import "IMPackets.h"
#import "MYHTTPConnection.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
static NSTimeInterval const kConnectionTimeout = 5.0;
static NSTimeInterval const kDisconnectTimeout = 5.0;
#define STATE_INIT                          0
 #define STATE_MAGIC_COOKIE_RECEIVED                  1
 #define STATE_ESTABLISHED                  2
#define SEQUENCE_SEND_MAGIC_COOKIE                     -11

#if TARGET_IPHONE_SIMULATOR
NSString *const WifiInterfaceName = @"en1";
#else
NSString *const WifiInterfaceName = @"en0";
#endif
@implementation Network
 static Network *sharedInstance;
 + (void)initialize
{
	static BOOL initialized = NO;
	if(!initialized)
	{
		initialized = YES;
		sharedInstance = [[Network alloc] init];
        
	}
}
+ (Network *)sharedInstance
{
	return sharedInstance;
}



- (id)init {
    self = [super init];
	if (self)
	{
        myQueue = dispatch_queue_create("com.IMPLAYR.voipqueue", DISPATCH_QUEUE_SERIAL);
        receiveQueue=dispatch_queue_create("com.IMPLAYR.receivequeue", DISPATCH_QUEUE_SERIAL);
         state=STATE_INIT;
        fileList = [[NSMutableArray alloc] init];
        [self loadFileList];
      
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(loadFileList)
                                                     name: @"FileDidUpload"
                                                   object: nil];
        
       

        //NOTE - GKPeerPickerConnectionTypeNearby is for Bluetooth connection, you can do the same thing over Wi-Fi with different type of connection
       
          }
	
	return self;
}
-(void)createSessionWithIdentifier:(GKSession *)sid
{
    if(!isBtConnected)
    {
        isBtConnected=YES;
    currentSession=[sid retain];
    currentSession.available = YES;
    currentSession.delegate = self;

     [currentSession setDataReceiveHandler:self withContext:nil];
 dispatch_async(dispatch_get_main_queue(), ^{
        [self startBySendingMagicCookie];
 });
        
    }
    
    
    else [self endSession];
    
}


- (void) SendCookieData:(NSData *) data
{ dispatch_sync(myQueue,^{
    if (isBtConnected )
        [currentSession sendDataToAllPeers:data
                                   withDataMode:GKSendDataReliable
                                          error:nil];
});

}

- (void) SendAudioData:(void *)datas AndLength:(int)l
{
    
    if (isBtConnected&&currentSession){
        
        sendSequence++;
        
            NSData *data=[[NSData alloc ] initWithBytes:datas length:l];
        
        IMPackets *packet=   [[IMPackets alloc] init]     ;
        [packet setSequence:sendSequence];
        [packet setData:data];
    
        @autoreleasepool {
            
        [currentSession sendDataToAllPeers:[packet packetData]
                                   withDataMode:GKSendDataUnreliable
         
                                          error:nil];
        }
            
            [data release];
          
         [packet release];
        
         }
    
   
    }
-(void)startBySendingMagicCookie{
    IMPackets *packet=  [[IMPackets alloc] init]   ;
    [packet setSequence:SEQUENCE_SEND_MAGIC_COOKIE];
    
    
    NSData *data=[[[AudioPlayer sharedInstance] audiounits] requestCookie];
    [packet setData:data];
            @autoreleasepool {
    [self SendCookieData:[packet packetData]];
            }
    [packet release];
    
}


-(void) receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)session
            context:(void *)context {
    
    IMPackets *packetData=  [[IMPackets alloc] initWithData:data]     ;
    
    if([packetData packetDataSize]==[data length])
    {
        if(state==STATE_INIT){
            if( ([packetData sequence]==SEQUENCE_SEND_MAGIC_COOKIE)){
                [[[AudioPlayer sharedInstance ]audiounits] setCookie:[packetData data]];
    
                state=STATE_ESTABLISHED;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate peerConnected:nil];
                 
                    
                });
                [packetData release];
                return;
    }
            
        
        
        }
        if(state==STATE_ESTABLISHED){
            if([packetData sequence]>=expectedSequence)
            {
                
                [[[AudioPlayer sharedInstance ]audiounits] didProducePackets:[packetData data]];
expectedSequence=[packetData sequence];
            }
        
        
        
        }
 
    }
          
    [packetData release];
    
         return;

}
-(void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSString* name = [session displayNameForPeer:peerID];
    NSLog(@"Received Request to Connect To... %@", name);
 }

-(void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    
  
    
    session.disconnectTimeout=.00001;
    [session disconnectFromAllPeers];
    
    
    session.available=NO;
 
}

-(void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
  
    session.disconnectTimeout=.00001;
    [session disconnectFromAllPeers];
    
    
    session.available=NO;
    
   
    
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)states
{
    NSString* name = [session displayNameForPeer:peerID];
    switch (states)
    {
        case GKPeerStateConnecting:
        {
            
            NSLog(@"Connecting to ... %@", name);
            break;
        }
        case GKPeerStateUnavailable:
        {
                       NSLog(@"UNAVAILABLE to ... %@", name);
            break;
        }
        case GKPeerStateConnected:
        {
            NSLog(@"CONNECTED: %@", name);
            isBtConnected=YES;
           
            
            break;
        }
        case GKPeerStateDisconnected:
        {
            NSLog(@"DISCONNECTED: %@", name);
            
            session.disconnectTimeout=.00001;
            [session disconnectFromAllPeers];
            
            
            session.available=NO;
            
            session=nil;
            [session release];
            dispatch_async(dispatch_get_main_queue(), ^{
            [self endSession];
            });
            break;
        }
            case GKPeerStateAvailable:
        {
            
            NSLog(@"AVAILABLE to ... %@", name);
            break;
        }
        default:
            break;
    }
}
-(void)endSession{
     isBtConnected=NO;
    if(currentSession)
    {

        
        [currentSession disconnectFromAllPeers];
     
       
        currentSession.available=NO;
        
        
        currentSession=nil;
        [currentSession release];
       NSLog(@"SESSION,%i",[currentSession retainCount]);

    
        
     
        
    
       

        [self.delegate peerDisconnected:nil];
     }
    state=STATE_INIT;

    expectedSequence=0;
    sendSequence=0;
    
}
-(NSString *)serverAddress{
    
        NSString *address = @"";
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = getifaddrs(&interfaces);
        if (success == 0) {
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    if([@(temp_addr->ifa_name) isEqualToString:WifiInterfaceName])
                        address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
        // Free memory
        freeifaddrs(interfaces);
        return address;
    



}
-(void)startHTTPServer{

    if(!isHTTPRunning){
        if(httpServer)
        {
            [httpServer release];
            httpServer=nil;
        
        }
        
        httpServer = [[[HTTPServer alloc] init] retain];
        [httpServer setType:@"_http._tcp."];
        [httpServer setPort:8080];
        [httpServer setName:@"AIIRX"];
         NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] stringByDeletingLastPathComponent];
        [httpServer setDocumentRoot: docRoot   
         ];
        [httpServer setConnectionClass:[MYHTTPConnection class]];
        [httpServer setController:self];
        if([httpServer start:nil]){
        
        isHTTPRunning=YES;
        [self.delegate httpServerStartedOn:[NSString stringWithFormat:@"%@:%i",[self serverAddress],[httpServer listeningPort]]];
        
        }
        else {
            [self.delegate httpServerFailedToStart];
        
        }
        }
        else
        {
            [httpServer stop];
            [httpServer release];
            httpServer=nil;
            isHTTPRunning=NO;
            [self.delegate httpServerStopped];
        }
        }
 
- (void)loadFileList
{
	[fileList removeAllObjects];
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
									  enumeratorAtPath:docDir];
	NSString *pname;
	while (pname = [direnum nextObject])
	{
		[fileList addObject:pname];
	}
}
-(NSArray *)fileList{

    return fileList;
}
 
#pragma mark WebFileResourceDelegate
// number of the files
- (NSInteger)numberOfFiles
{
	return [fileList count];
}

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index
{
	return [fileList objectAtIndex:index];
}

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename
{
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

 
- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath
{
	if (name == nil || tmpPath == nil)
		return;
	NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
	NSString *path = [NSString stringWithFormat:@"%@/%@", docDir, name];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if (![fm moveItemAtPath:tmpPath toPath:path error:&error])
	{
		NSLog(@"can not move %@ to %@ because: %@", tmpPath, path, error );
	}
    
	[self loadFileList];
	
}

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName
{
	NSString *path = [self filePathForFileName:fileName];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error;
	if(![fm removeItemAtPath:path error:&error])
	{
		NSLog(@"%@ can not be removed because:%@", path, error);
	}
	[self loadFileList];
}
-(BOOL) isBtConnected{

    return isBtConnected;
 }


@end
