//
//  InputNode.m
//  Cog
//
//  Created by Vincent Spader on 8/2/05.
//  Copyright 2005 Vincent Spader. All rights reserved.
//
 
#import "InputNode.h"
#import "BufferChain.h"
 #import "CoreAudioUtils.h"
 
@implementation InputNode

- (BOOL)openWithUrl:(NSURL *)url isLocal:(BOOL)s
{
    if(!s){
	decoder = [[CoreAudioDecoder alloc] initWithUrl:url Delegate:nil];
    }
    else {decoder=[[CoreAudioDecoder alloc] initWithLocalUrl:url Delegate:nil];
     
    }
    [decoder setIsLocal:s];
	 	  
	
	 
 
	shouldContinue = YES;
	shouldSeek = NO;

	return YES;
}

 
 
- (void)process
{
    
    if( ![decoder isLocal] ){
	int amountInBuffer = 0;
 
	void *inputBuffer = (void *)malloc(66000);
    int amountRead=1;
	 
	int il=0;

    
    
     
    
     	while ([self shouldContinue] == YES && [self endOfStream] == NO)
	{
        
        if (shouldSeek == YES)
		{
			NSLog(@"SEEKING!");
			[decoder seek:seekFrame];
			shouldSeek = NO;
			NSLog(@"Seeked! Resetting Buffer");
			
			[self resetBuffer];
			
			NSLog(@"Reset buffer!");
			initialBufferFilled = NO;
		}
        
        if(amountRead!=0)
        {
         
            amountRead= [decoder readAudio: inputBuffer   frames: 0 ];
            
            

            if (amountRead <= 0)
			{
				 
				 
				endOfStream = YES;
                [controller endOfInputReached];
				break;
			}
         

            
            
            
		 		       int amountwritten=  [self writeData:inputBuffer amount:amountRead];
        amountInBuffer+=amountwritten;
            
            
            
        }
            if(il== 0&&amountInBuffer>=CHUNK_SIZE/2)
    {
        
        il++;
        [controller initialBufferFilled:self];
    
    }
        
    }
	 
	 	free(inputBuffer);
        return;
        
    }
    else {
       
        
        
        int amountInBuffer = 0;
        void *inputBuffer = (void *)malloc(CHUNK_SIZE);
        
         [decoder readInfoFromExtAudioFileRef];
        while ([self shouldContinue] == YES && [self endOfStream] == NO)
        {
            if (shouldSeek == YES)
            {
                NSLog(@"SEEKING!");
                [decoder seekLocal:seekf];
                shouldSeek = NO;
                NSLog(@"Seeked! Resetting Buffer");
                
                [self resetBuffer];
                
                NSLog(@"Reset buffer!");
                initialBufferFilled = NO;
            }
            
            if (amountInBuffer < CHUNK_SIZE) {
                int framesToRead = (CHUNK_SIZE - amountInBuffer)/[decoder bytesPerFrame];
                int framesRead = [decoder readAudio:((char *)inputBuffer) + amountInBuffer frames:framesToRead];
                amountInBuffer += (framesRead *[decoder bytesPerFrame]);
                
                if (framesRead <= 0)
                {
                                                        endOfStream = YES;
                     
                    [controller endOfInputReached];
                     
                    break;
                }
                
                [self writeData:inputBuffer amount:amountInBuffer];
                amountInBuffer = 0;
            }
        }
        
        
        free(inputBuffer);}
}

- (void)seek:(long)frame
{
    if( ![decoder isLocal]){
    seekFrame=CMTimeMake(frame, 1);
    }
    else seekf=frame*[decoder frequency];
    
	shouldSeek = YES;
	NSLog(@"Should seek!");
	[semaphore signal];
}
 


- (void)dealloc
{
	NSLog(@"Input Node dealloc");

 if(decoder)
	[decoder release];
	 	[super dealloc];
}

 

- (CoreAudioDecoder *) decoder
{
	return decoder;
}
-(int)totalFrames{

   return [decoder totalFrames];
}
@end
