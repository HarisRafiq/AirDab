//
//  OutputNode.h
//  Cog
//
//  Created by Vincent Spader on 8/2/05.
//  Copyright 2005 Vincent Spader. All rights reserved.
//


#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
 

#import "Node.h"

 
 
@interface OutputNode : Node {
	AudioStreamBasicDescription format;
	 
	unsigned long long amountPlayed;
	
     
}

- (double)amountPlayed;
 
- (void)setup;
- (void)process;
- (void)close;
- (void)seek:(double)time;

- (int)readData:(void *)ptr amount:(int)amount;

- (void)setFormat:(AudioStreamBasicDescription *)f;
- (AudioStreamBasicDescription) format;
 - (void)setShouldContinue:(BOOL)s;

 
@end
