//
//  BufferChain.m
//  CogNew
//
//  Created by Vincent Spader on 1/4/06.
//  Copyright 2006 Vincent Spader. All rights reserved.
//

#import "BufferChain.h"
 
#import "CoreAudioUtils.h"

@implementation BufferChain

- (id)initWithController:(id)c
{
	self = [super init];
	if (self)
	{
		controller = c;
		 
        
 		inputNode = nil;
		 
	}
	
	return self;
}
 

- (void)buildChain
{
    if(inputNode){
        [inputNode setShouldContinue:NO];
	[inputNode release];
        inputNode=nil;
        
    }
 
        inputNode = [[InputNode alloc] initWithController:self previous:nil];
  
	finalNode = inputNode;
}

- (BOOL)open:(NSURL *)url withOutputFormat:(AudioStreamBasicDescription)outputFormat isLocal:(BOOL)s
{	
 
	[self buildChain];
	
 
	if (![inputNode openWithUrl:url isLocal:s])
		return NO;
        
    [self setShouldContinue:YES];
	return YES;}

 

- (void)launchThreads
{
	         [inputNode launchThread];
    
   
     
	
}
 
 

- (void)dealloc
{
    
    
	[[controller audiounits] _resetTiming];
	
    if(inputNode){
        [inputNode setShouldContinue:NO];
        [inputNode release];
        inputNode=nil;
        
    }
 
	NSLog(@"Bufferchain dealloc");
	
	[super dealloc];
}

- (void)seek:(double)time
{
	long frame = time * [[[inputNode properties] objectForKey:@"sampleRate"] floatValue];

	[inputNode seek:frame];
}

- (BOOL)endOfInputReached
{
	return [controller endOfInputReached:self];
}
- (void)endOfInputPlayed
{
     
    [controller endOfInputPlayed];

}
- (BOOL)setTrack: (NSURL *)track
{
	return [inputNode setTrack:track];
}

- (void)initialBufferFilled:(id)sender
{
	NSLog(@"INITIAL BUFFER FILLED");
    [[controller outputNode] setShouldContinue:YES];
    }
 


- (InputNode *)inputNode
{
	return inputNode;
}
 

- (id)finalNode
{
	return finalNode;
}


- (void)setShouldContinue:(BOOL)s
{
    
    
	[inputNode setShouldContinue:s];
	  
   
}
 



@end
