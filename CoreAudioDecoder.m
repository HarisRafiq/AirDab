
#include <unistd.h>

#import "CoreAudioDecoder.h"
 #import "BufferChain.h"
 
AVAssetReader* CreateAssetReaderFromSong(AVURLAsset* songURL) {
    
    if([songURL.tracks count] <= 0)
        return NULL;
    
    
    AVAssetTrack* songTrack = [songURL.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                              [NSNumber numberWithInt:44100],AVSampleRateKey,  /*Not Supported*/
                                        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,   /*Not Supported*/
                                        
                                        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        
                                        nil];
    
    
    NSError* error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:songURL error:&error];
    
    {
        AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
        [reader addOutput:output];
        [output release];
    }
    [outputSettingsDict
      release];
    return reader;
}

@implementation CoreAudioDecoder
-(id)initWithLocalUrl:(NSURL *)urls Delegate:(id<CoreDelegate>)adelegate
{
    self = [super init];
  if(self){
      
        delegate=adelegate;
      OSStatus						err;
       ref=(CFURLRef)urls;
             err = ExtAudioFileOpenURL(ref, &_in);
     
      if(noErr != err) {
          err = ExtAudioFileDispose(_in);
          NSLog(@"Error opening file: %li",  err);
          return self
          ;      }

      [self readInfoFromExtAudioFileRef];
   }
return self;
}
  - (BOOL) readInfoFromExtAudioFileRef
{
    	OSStatus						err;
	UInt32							size;
	AudioStreamBasicDescription		asbd;
    
	
	// Get input file information
	size	= sizeof(asbd);
	err		= ExtAudioFileGetProperty(_in, kExtAudioFileProperty_FileDataFormat, &size, &asbd);
	if(err != noErr) {
		err = ExtAudioFileDispose(_in);
        NSLog(@"Error opening file: %li",  err);

        return NO;
	}
	
	SInt64 total;
	size	= sizeof(total);
	err		= ExtAudioFileGetProperty(_in, kExtAudioFileProperty_FileLengthFrames, &size, &total);
	if(err != noErr) {
		err = ExtAudioFileDispose(_in);
        NSLog(@"Error opening file: %li",  err);

		return NO;
	}
	totalFrames = total;
	
	//Is there a way to get bitrate with extAudioFile?
	bitrate				= 0;
	
	// Set our properties
	bitsPerSample		= asbd.mBitsPerChannel;
	channels			= asbd.mChannelsPerFrame;
	frequency			= asbd.mSampleRate;
	
	// mBitsPerChannel will only be set for lpcm formats
	if(0 == bitsPerSample) {
		bitsPerSample = 16;
	}
	
	// Set output format
    
    AudioStreamBasicDescription outFormat;
    memset(&outFormat, 0, sizeof(AudioStreamBasicDescription));
    outFormat.mFormatID = kAudioFormatLinearPCM;
    outFormat.mFormatFlags =kAudioFormatFlagsCanonical;
    outFormat.mBitsPerChannel = 16;
    outFormat.mFramesPerPacket = 1;
    outFormat.mChannelsPerFrame = 2;
    outFormat.mBytesPerPacket =2 * outFormat.mChannelsPerFrame;
    outFormat.mBytesPerFrame =2 * outFormat.mChannelsPerFrame;
    outFormat.mSampleRate=44100.0;

	AudioStreamBasicDescription		result;
	
	bzero(&result, sizeof(AudioStreamBasicDescription));
	
	result.mFormatID			= kAudioFormatLinearPCM;
	result.mFormatFlags			= kAudioFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsBigEndian;
	
	result.mSampleRate			= frequency;
	result.mChannelsPerFrame	= channels;
	result.mBitsPerChannel		= bitsPerSample;
	
	result.mBytesPerPacket		= channels * (bitsPerSample / 8);
	result.mFramesPerPacket		= 1;
	result.mBytesPerFrame		= channels * (bitsPerSample / 8);
   err = ExtAudioFileSetProperty(_in, kExtAudioFileProperty_ClientDataFormat, sizeof(outFormat), &outFormat);
	if(noErr != err) {
		err = ExtAudioFileDispose(_in);
        NSLog(@"Error opening file: %li",  err);

		return NO;
	}
	
	 	
	return YES;
}
-(id)initWithUrl:(NSURL *)urls Delegate:(id<CoreDelegate>)adelegate


{
self = [super init];
    if(self){
        url=urls;
      
         
        AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:urls
                                                    options:nil];
        asset_reader= (CreateAssetReaderFromSong(songAsset))  ;
    [asset_reader startReading];
    delegate=adelegate;
    }
return self;

}
- (long) seekLocal:(long)frame
{
	OSStatus			err;
	
	err = ExtAudioFileSeek(_in, frame);
	if(noErr != err) {
		return -1;
	}
	
	return frame;
}
-(BOOL)seek:(CMTime)time{

    CMTimeRange timeRange = CMTimeRangeMake(time, kCMTimePositiveInfinity);
    
    [asset_reader cancelReading];
    asset_reader=nil;
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url
                                                options:nil];
    asset_reader= (CreateAssetReaderFromSong(songAsset))  ;
    
    asset_reader.timeRange = timeRange;

    
return [asset_reader startReading];
}
 

- (int) readAudio:(void *)buf frames:(UInt32)amount 
{
    if(!isLocal){
    if(asset_reader.status==AVAssetReaderStatusReading)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    CMSampleBufferRef nextBuffer = [asset_reader.outputs[0] copyNextSampleBuffer];
        UInt64 size = CMSampleBufferGetTotalSampleSize(nextBuffer);
        if(size>0)
        {
        AudioBufferList abl;
        CMBlockBufferRef blockBuffer;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(nextBuffer, NULL, &abl, sizeof(abl), NULL, NULL, kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment, &blockBuffer);
        
        
        memcpy(buf, abl.mBuffers[0].mData, size);
                           CFRelease(nextBuffer);
            
    CFRelease(blockBuffer);
        
             
        }
        else {size=0;
        }
        [pool release];
        return size;

    }
            return 0;
	}
    
    else {
        
                 OSStatus				err;
        AudioBufferList			bufferList;
        UInt32					frameCount;
        
        // Set up the AudioBufferList
        bufferList.mNumberBuffers				= 1;
        bufferList.mBuffers[0].mNumberChannels	= 2;
        bufferList.mBuffers[0].mData			= buf;
        bufferList.mBuffers[0].mDataByteSize	= amount * 4;
;
        
        // Read a chunk of PCM input (converted from whatever format)
        frameCount	= amount;
        err			= ExtAudioFileRead(_in, &frameCount, &bufferList);
        
        if(err != noErr) {
           
            return 0;
        }
        
        return frameCount;

    
    
    }
}
 
-(void)dealloc{
    if(!isLocal&&asset_reader){
        
        [asset_reader release];
     }
        else  {
            [self close];
      }
    
     
    delegate=nil;
        [super dealloc];
}
 
- (void) close
{
	OSStatus			err;
	if(_in){
       
	err = ExtAudioFileDispose(_in);
        
	if(noErr != err) {
		NSLog(@"Error closing ExtAudioFile");
	}
    }
}
-(BOOL) isLocal{return isLocal;}

-(void)setIsLocal:(BOOL)s;
{

    isLocal=s;
}

-(int)bytesPerFrame{return 4;}
-(int)totalFrames{

    return totalFrames/frequency;
}
-(int)frequency{
    
    return frequency;
}
@end
 
 
