//
//  IMPackets.m
//  IMMedia
//
//  Created by YAZ on 5/22/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import "IMPackets.h"
#import "DDNumber.h"
@implementation IMPackets

- (id)initWithData:(NSData *)udpData
{
	if((self = [super init]))
	{
		if([udpData length] >1)
		{
			sequence         = [NSNumber extractUInt32FromData:udpData atOffset: 0 andConvertFromNetworkOrder:YES];
			 	 					
            
            
            packetDataSize=[NSNumber extractUInt32FromData:udpData atOffset: 4 andConvertFromNetworkOrder:YES];
            void *dataBytes = (void *)([udpData bytes] + 8);
					data =  [NSData dataWithBytesNoCopy:dataBytes length:([udpData length] - 8) freeWhenDone:NO];
            
        }
    }
            return self;
}

- (id)init
{
	if((self = [super init]))
	{
        packetDataSize=0;
		sequence         = 0;
		 	}
	return self;
}

- (UInt32)sequence {
	return sequence;
}
- (void)setSequence:(UInt32)num {
	sequence = num;
}
- (UInt32)packetDataSize{
	return packetDataSize;
}

- (void)setpacketDataSize:(UInt32)num{
	packetDataSize = num;
}

- (NSData *)packetData
{
 
	UInt16 dataLength = [data length];
	 
	
	UInt32 packetSize = sizeof(packetDataSize)+sizeof(sequence) + dataLength;
	void *byteBuffer = malloc(packetSize);
	
	UInt32 seq = htonl(sequence);
	memcpy(byteBuffer+0, &seq, sizeof(seq));
    UInt32 packsize = htonl(packetSize);
	memcpy(byteBuffer+4, &packsize, sizeof(packsize));
	 		if(data)
		{
			memcpy(byteBuffer+8, [data bytes], dataLength);
		}
    
    NSData  *result= [NSData dataWithBytesNoCopy:byteBuffer length:packetSize freeWhenDone:YES]   ;
    
    return  result;
    
    
}
- (NSData *)data {
	return data;
}
- (void)setData:(NSData *)payload
{
	 
		 
		data =  payload ;
    
}
- (void)dealloc
{
    
    data=nil;
         [super dealloc];
     
}

@end
