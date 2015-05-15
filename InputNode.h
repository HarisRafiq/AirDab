//
//  InputNode.h
//  Cog
//
//  Created by Vincent Spader on 8/2/05.
//  Copyright 2005 Vincent Spader. All rights reserved.
//



#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

#import "CoreAudioDecoder.h"
#import "Node.h"
 

@interface InputNode : Node  {
	CoreAudioDecoder *decoder;
    
    	UInt64 fileLength;
    UInt32 lengthread;
     void *tempBuffer;
	BOOL shouldSeek;
	CMTime seekFrame;
    BOOL isRemotePlayInitialized;
    long seekf;
}
 
-(AudioFilePacketTableInfo) srcPti;
- (BOOL)openWithUrl:(NSURL *)url isLocal:(BOOL)s;
 
- (void)process;
 - (void)seek:(long)frame;
-(int)totalFrames;
 
 

- (CoreAudioDecoder *) decoder;

 
@end
