/*
 *  $Id$
 *
 *  Copyright (C) 2006 Stephen F. Booth <me@sbooth.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */



#import <AudioToolbox/AudioToolbox.h>
 #import <CoreAudio/CoreAudioTypes.h>
  #import "Node.h"
#import <AVFoundation/AVFoundation.h>
 

@protocol CoreDelegate;
@interface CoreAudioDecoder:NSObject
{
    
    ExtAudioFileRef  _in;
 	int bitrate;
	int bitsPerSample;
	int channels;
	float frequency;
	long totalFrames;
    BOOL isLocal;
    id<CoreDelegate> delegate;
 
          AVAssetReader *asset_reader;
    BOOL shouldBecomeNode;
    BOOL initialBufferFilled;
    CFURLRef ref;
    NSURL *url;
}
-(int)frequency;
- (long) seekLocal:(long)frame;
-(BOOL)seek:(CMTime)time;
-(int)totalFrames;
-(int)bytesPerFrame;
-(BOOL) isLocal;
- (void) close;
-(void)setIsLocal:(BOOL)s;
 -(id)initWithUrl:(NSURL *)url Delegate:(id<CoreDelegate>)adelegate;
 -(id)initWithLocalUrl:(NSURL *)url Delegate:(id<CoreDelegate>)adelegate;
 - (int)readAudio:(void *)buf frames:(UInt32)amount ;
- (BOOL) readInfoFromExtAudioFileRef;
 - (NSMutableArray *)array;
- (void)addObject:(NSMutableArray *)newArray;
 
-(void)setNodeToConverter;
@end
@protocol CoreDelegate<NSObject>
- (void)ASPD:(UInt32)aspdDelegate ;


@end
