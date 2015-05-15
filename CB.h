//
//  CB.h
//  HeartConnect
//
//  Created by YAZ on 13-02-08.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CB : NSObject
-(int) availableBytes;
-(id) initWithLength:(int)length;
-(void) produceToBuffer:(const void*)data ofLength:(int)length;
-(void) consumeBytesTo:(void *)buf OfLength:(int)length;

@end
