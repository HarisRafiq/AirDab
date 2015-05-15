//
//  AudioPlayer.h
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <mach/mach.h>
#import "AudioUnits.h"
#import "Network.h"
#import <MediaPlayer/MediaPlayer.h>
#import "OutputNode.h"
 @class BufferChain;
@class OutputNode;
@protocol AudioPlayerDelegate;
@interface AudioPlayer : NSObject  {
	id<AudioPlayerDelegate> delegate;
    BufferChain *musicBufferChain;
    OutputNode *outputNode;
    Network *network;
    BOOL endOfInputReached;
    NSMutableArray *artistsArray;
    NSMutableArray *currentArtistSongs;
        int currentArtistIndex;
    int nextArtistIndex;
    int prevArtistIndex;
     int nextSongIndex;
    int prevSongIndex;
    int currentSongIndex;
    AudioUnits *audiounits;
    int playstatus;
    dispatch_queue_t audioQueue;
    BOOL isPrevLocal;
    BOOL isNextLocal;
    BOOL isFirstChange;
    BOOL isBackground;
    NSString *currentSongTitle;
    NSString *currentSongTotalDuration;
    NSString *currentArtist;
    UIImage *currentArtwork;
    double tduration;
}
-(double)tduration;
-(void)settduration:(double)s;
-(void)playPause;
-(void)setCurrentSongIndex:(int)i;
-(void)setCurrentArtistIndex:(int)i;

@property (nonatomic, retain) id<AudioPlayerDelegate> delegate;
-(NSMutableArray *)currentArtistSongs;
-(NSMutableArray *)artistsArray;
 
- (void)stop;
- (void)setUpWithArtist:(NSString *)artist;
-(double)amountPlayed;
- (int)currentTime;
-(NSArray *)fileListArray;

- (OutputNode *)outputNode;

-(AudioUnits *)audiounits;
-(void)stopMusicPlayer;
-(void)startMusicPlayer;
- (void)startVoip;
- (void)stopVoip;
- (int)playStatus;
- (BufferChain *) musicBufferChain;
+(AudioPlayer *)sharedInstance;
- (void)setPlaybackStatus:(int)s;


- (void)play:(NSURL *)url;
- (BOOL)endOfInputReached:(BufferChain *)sender;
-(void)talkEnabled;
-(void)talkDisabled;
- (double)amountPlayed;
- (void)endOfInputPlayed;
-(int)currentSongIndex;
-(void)setIsBackground:(BOOL)s;
-(void)playNextTrack;
-(void)playPrevTrack;
-(NSString *)currentSongTitle;
-(void)setCurrentSongTitle:(NSString *)s;
-(void)setCurrentSongTotalDuration:(NSString *)s;
-(void)setCurrentArtist:(NSString *)s;
-(void)setCurrentArtwork:(UIImage *)s;
-(NSString *)currentSongTotalDuration;
-(NSString *)currentArtist;
-(void)seek:(float)frames;
-(UIImage *)currentArtwork;
- (void)enableScrubbingFromSlider:(UISlider *)slider;

@end

@protocol AudioPlayerDelegate<NSObject>
-(void)setTotalDuration:(float)d;

- (void)audioPlayerDidStartPlayingPrevTrackWithLocalSongs:(NSString *)songTitle;
- (void)audioPlayerDidStartPlayingNextTrackWithLocalSongs:(NSString *)songTitle;
- (void)audioPlayerDidFinsihPlaying:(AudioPlayer *)player ;
- (void)audioPlayerDidStartPlayingNextTrackWithMPItem:(MPMediaItem *)item;
- (void)audioPlayerDidStartPlayingPrevTrackWithMPItem:(MPMediaItem *)item;
- (void)audioPlayer:(AudioPlayer *)player didChangeStatus:(UInt32)status;
-(void)audioPlayerIsAlreadyPlayingFirstSong;
-(void)audioPlayerIsAlreadyPlayingLastSong;
-(void)setMPMediaTotalDuration:(NSString *)d;
@end