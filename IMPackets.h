//
//  IMPackets.h
//  IMMedia
//
//  Created by YAZ on 5/22/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMPackets : NSObject
{
	UInt32 sequence;
    UInt32 packetDataSize;
 	
	NSData *data;
	
	 
}

- (id)initWithData:(NSData *)udpData;
- (id)init;
- (UInt32)packetDataSize;
- (void)setpacketDataSize:(UInt32)num;
- (UInt32)sequence;
- (void)setSequence:(UInt32)num;
 - (NSData *)data;
- (void)setData:(NSData *)payload;

- (NSData *)packetData;
 
@end
