//
//  AudioUnit.h
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#include <AudioUnit/AudioUnit.h>
#import "AudioToolbox/AudioToolbox.h"


#import <mach/mach.h>
#import "CB.h"
#import "Network.h"
#include <Block.h>
@class OutputNode;
@interface AudioUnits : NSObject{
    id outputController;
    OutputNode * musicOutputNode;
    
    CB *voiceBuffer;
    
    AudioUnit outputUnit;
    AudioUnit mixerUnit;
    AudioUnit mixerUnit2;
    AUGraph _graph;
    AUNode _mixerNode;
    AUNode _mixerNode2;
    AUNode _outputNode;
    void *tempBuffer;
    
    
    AudioStreamBasicDescription inputAudioDescription;
    AudioStreamBasicDescription outputAudioDescription;
    BOOL isVOIPActive;
    BOOL isLocalMusicPlayerActive;
    BOOL isRemoteMusicPlayerActive;
    BOOL isStreaming;
    BOOL isRecordingMessage;
    BOOL isAudioSessionInitialized;
    BOOL isVoipInitialized;
    BOOL isRemotePlayInitialized;
    int playedFrames;
    Network *network;
 }
-(void)setPlayedFrames:(int)frames;
-(AudioStreamBasicDescription) inputAudioDescription;
-(AudioStreamBasicDescription ) outputAudioDescription;
@property (nonatomic, readonly) NSUInteger currentTime;
@property (nonatomic) AudioUnit audioUnit;
@property (nonatomic) AUGraph _graph;
@property (nonatomic) AUNode _outputNode;
@property (nonatomic) AUNode _mixerNode2;
@property (nonatomic) AUNode _mixerNode;
- (id)initWithController:(id)c;
- (void)_resetTiming;
-(void)setMusicOutputNode:(OutputNode *)c;
-(void)stopLocalMusicPlayer;
-(void)startLocalMusicPlayer;
-(void)stopRemoteMusicPlayer;
-(void)startRemoteMusicPlayer;
-(void)stopVOIP;
-(void)startVOIP;
-(void)setIsStreaming:(BOOL)s;
-(int)playedFrames;
-(void)setCookie:(NSData *)cookie;
-(NSData *)requestCookie;

 

 
-(void) didProducePackets:(NSData *)packetData;
@end
