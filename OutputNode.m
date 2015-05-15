//
//  OutputNode.m
//  Cog
//
//  Created by Vincent Spader on 8/2/05.
//  Copyright 2005 Vincent Spader. All rights reserved.
//

#import "OutputNode.h"
 
 
#import "BufferChain.h"
 
@implementation OutputNode

- (void)setup
{
	amountPlayed = 0;
    endOfStream=NO; 
}
 
- (void)seek:(double)time
{
//	[output pause];

	amountPlayed = time*format.mBytesPerFrame*(format.mSampleRate);
}

- (void)process
{
 
}
 

 
- (int)readData:(void *)ptr amount:(int)amount
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	int n;
	[self setPreviousNode: [[controller musicBufferChain]  finalNode]] ;
	
	n = [super readData:ptr amount:amount];
	if (endOfStream == YES)
	{
		amountPlayed = 0;
        [controller endOfInputPlayed];
		 	}

/*	if (n == 0) {
		NSLog(@"Output Buffer dry!");
	}
*/	
	amountPlayed += n;

	[pool release];
	
	return n;
}
 

- (double)amountPlayed
{
	return (amountPlayed/format.mBytesPerFrame)/(format.mSampleRate);
}

- (AudioStreamBasicDescription) format
{
	return format;
}

- (void)setFormat:(AudioStreamBasicDescription *)f
{
	format = *f;
}

- (void)close
{
    
    
	 }

- (void)dealloc
{
     NSLog(@"OUTPUTNODE dealloc");
	[super dealloc];
}

- (void)setVolume:(double) v
{
	 
}

- (void)setShouldContinue:(BOOL)s
{
	[super setShouldContinue:s];
	
//	if (s == NO)
//		[output stop];
}
@end
