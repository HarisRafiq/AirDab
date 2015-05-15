//
//  Network.h
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "HTTPServer.h"
#import "MYHTTPConnection.h"
@protocol NetworkDelegate;
@protocol NetworkDelegate <NSObject>
-(void)peerDisconnected:(NSString *)pid;
-(void)peerConnected:(NSString *)pid;
-(void)peerConnecting:(NSString *)pid;
-(void)peerConnectionFailed:(NSString *)pid;
-(void)peerAvailable:(NSString *)pid;
-(void)httpServerStartedOn:(NSString *)s;
-(void)httpServerFailedToStart;
-(void)httpServerStopped;
 
@end

@interface Network : NSObject<  GKSessionDelegate>
{
    MYHTTPConnection *connection;
     UInt32 sendSequence;
    UInt32 expectedSequence;
    int state;
    dispatch_queue_t myQueue;
 dispatch_queue_t receiveQueue;
    HTTPServer *httpServer;
	NSMutableArray *fileList;
    BOOL isHTTPRunning;
    BOOL isBtConnected;
    GKSession *currentSession;
    
}
-(GKPeerPickerController *)connectionPicker;
@property (nonatomic, retain) id<NetworkDelegate> delegate;
-(void)startBT;
+ (Network *)sharedInstance;
-(GKSession *)session;
-(void)createSessionWithIdentifier:(GKSession *)sid;
-(void)startHTTPServer;
-(void)stopHTTPServer;
-(void)endSession;
 -(BOOL) isBtConnected;
- (void) SendCookieData:(NSData *) data;
- (void) SendAudioData:(void *)data AndLength:(int)l;
-(NSArray *)fileList;
- (NSInteger)numberOfFiles;

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index;

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename;

- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath;

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName;

@end

