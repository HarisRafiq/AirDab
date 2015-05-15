//
//  BufferChain.h
//  CogNew
//
//  Created by Vincent Spader on 1/4/06.
//  Copyright 2006 Vincent Spader. All rights reserved.
//



#import "InputNode.h"
 
#import "AudioPlayer.h"
#import "CoreAudioDecoder.h"
#import "OutputNode.h" 
@interface BufferChain : NSObject {
	InputNode *inputNode;
	 
 	 
	 
     
	id finalNode; 
	
	id controller;
}
- (id)initWithController:(id)c;
- (void)buildChain;

- (BOOL)open:(NSURL *)url withOutputFormat:(AudioStreamBasicDescription)outputFormat isLocal:(BOOL)s;

 
 - (void)seek:(double)time;

- (void)launchThreads;
 
  - (InputNode *)inputNode;
 - (id)finalNode;

- (void)setShouldContinue:(BOOL)s;

- (void)initialBufferFilled:(id)sender;
- (void)endOfInputPlayed;
 
- (BOOL)endOfInputReached;
- (BOOL)setTrack:(NSURL *)track;
 
@end
