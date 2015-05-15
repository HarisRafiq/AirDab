//
//  CB.m
//  HeartConnect
//
//  Created by YAZ on 13-02-08.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CB.h"

@implementation CB
{
    unsigned int gBufferLength;
    unsigned int gAvailableBytes;
    unsigned int gHead;
    unsigned int gTail;
    void *gBuffer;
}

// Init instance with a certain length and alloc the space
-(id)initWithLength:(int)length
{
    self = [super init];
    
    if (self != nil)
    {
        gBufferLength = length;
        gBuffer = malloc(length);
        memset(gBuffer, 0, length);
        
        gAvailableBytes = 0;
        gHead = 0;
        gTail = 0;
    }
    
    return self;
}

// return the number of bytes stored in the buffer
-(int) availableBytes
{
    return gAvailableBytes;
}

-(void) produceToBuffer:(const void*)data ofLength:(int)length
{
    // if the number of bytes to add to the buffer will go past the end.
    // copy enough to fill to the end
    // go back to the start
    // fill the remaining
    if((gHead + length) > gBufferLength-1)
    {
        int remainder = ((gBufferLength-1) - gHead);
        memcpy(gBuffer + gHead, data, remainder);
        gHead = 0;
        memcpy(gBuffer + gHead, data + remainder, (length - remainder));
        gHead += (length - remainder);
        gAvailableBytes += length;
    }
    // if there is room in the buffer for these bytes add them
    else if((gAvailableBytes + length) <= gBufferLength-1)
    {
        memcpy(gBuffer + gHead, data, length);
        gAvailableBytes += length;
        gHead += length;
    }
    else
    {
        //NSLog(@"--- Discarded ---");
    }
}

-(void) consumeBytesTo:(void *)buf OfLength:(int)length
{
    // if the tail is at a point where there is not enough between it and the end to fill the buffer.
    // copy out whats left
    // move back to the start
    // copy out the rest
    if((gTail + length) > gBufferLength-1 && length <= gAvailableBytes)
    {
        int remainder = ((gBufferLength-1) - gTail);
        memcpy(buf, gBuffer + gTail, remainder);
        gTail = 0;
        memcpy(buf + remainder, gBuffer, (length -remainder));
        gAvailableBytes-=length;
        gTail += (length -remainder);
    }
    // if there is enough bytes in the buffer
    else if(length <= gAvailableBytes)
    {
        memcpy(buf, gBuffer + gTail, length);
        gAvailableBytes-=length;
        gTail+=length;
    }
    // else play silence
    else
    {
        memset(buf, 0, length);
    }
}

-(void)dealloc{
    
    
    free(gBuffer);
    [super dealloc];

}
@end
