//
//  AudioUnit.m
//  AirDab
//
//  Created by YAZ on 8/21/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//
#import "AudioUnits.h"
#include <AudioUnit/AudioUnit.h>
#import "AudioToolbox/AudioToolbox.h"
#import "OutputNode.h"
#import <AVFoundation/AVFoundation.h>
#import "fft.h"
 #import "AudioPlayer.h"
#include "EncoderAACELD.h"
#include "DecoderAACELD.h"
#import "Network.h"
#import "BufferChain.h"
 
  static void*            g_tempMusicBuffer;
static AudioBuffer            g_inputBuffer;
static AudioBuffer            g_outputBuffer;
static UInt32                 g_outputBufferOffset  = 0;
static UInt32                 g_inputBufferOffset  = 0;
static UInt32                 g_frameSize      = 512;
static UInt32                 g_inputByteSize  = 0;
static UInt32                 g_outputByteSize = 0;
static EncoderAACELD         *g_encoder        = NULL;
static DecoderAACELD         *g_decoder        = NULL;

static MagicCookie            g_cookie;

static DMagicCookie            dg_cookie;

static BOOL           g_isEncoderinitialized    = NO;
static BOOL           g_isDecoderinitialized    = NO;
static void *               g_packetBuffer ;
void InitACEncoder()
{
    EncoderProperties p;
    p.samplingRate = 44100.0;
    p.inChannels   = 2;
    p.outChannels  = 1;
    p.frameSize    = 512;
    p.bitrate      = 32000;
    
    g_encoder = CreateEncoder();
    InitEncoder(g_encoder, p, &g_cookie);
}
void InitACDecoder()
{
    DecoderProperties dp;
    dp.samplingRate = 44100.0;
    dp.inChannels   = 1;
    dp.outChannels  = 1;
    dp.frameSize    =512;
    g_decoder = CreateDecoder();
    InitDecoder(g_decoder, dp, &dg_cookie );
}
void DestroyTranscoder()
{
    DestroyEncoder(g_encoder );
    DestroyDecoder(g_decoder);
}
@implementation AudioUnits



@synthesize  audioUnit,_graph, _outputNode, _mixerNode,_mixerNode2  ;




- (id)initWithController:(id)c
{
	self = [super init];
	if (self)
        
	{network=[Network sharedInstance];
       
        g_tempMusicBuffer= malloc(2048 );
        mixerUnit2=nil;
        outputUnit=nil;
        mixerUnit=nil;
        musicOutputNode=nil;
        
		outputController = c;
        isVOIPActive=NO;
        isLocalMusicPlayerActive=NO;
        isRemoteMusicPlayerActive=NO;
        isRecordingMessage=NO;
        isAudioSessionInitialized=NO;
        [self startMusicAudioSession];
        [self setupDataFormat];
        
		
	}
	
	return self;
}
-(void)initializeVoip{
    {
    if(!isVoipInitialized)
    InitACEncoder();
       isVoipInitialized=YES;
    tempBuffer = malloc(340 );
    g_packetBuffer=malloc(sizeof(UInt16));
    g_inputByteSize  = g_frameSize * 2  * sizeof(AudioSampleType);
    g_outputByteSize =g_frameSize * 1  * sizeof(AudioSampleType);
    
    
    /* Initialize the I/O buffers */
    g_inputBuffer.mNumberChannels = 2;
    g_inputBuffer.mDataByteSize   = g_inputByteSize;
    
    
    
    g_inputBuffer.mData           = malloc(sizeof(unsigned char)*g_inputByteSize);
    memset(g_inputBuffer.mData, 0, g_inputByteSize);
    
    g_outputBuffer.mNumberChannels = 1;
    
    g_outputBuffer.mData           = malloc(sizeof(unsigned char)*g_outputByteSize);
    memset(g_outputBuffer.mData, 0, g_outputByteSize);
    g_outputBuffer.mDataByteSize   = 0;
    
    
    
    voiceBuffer=[[CB alloc]initWithLength:100*10] ;
    
    }
    
    
}
-(void)destroyVoip{
    if(isVoipInitialized){
    free(g_packetBuffer);
    isVoipInitialized=NO;
    free(tempBuffer);
    free(g_inputBuffer.mData);
    free(g_outputBuffer.mData);
     [voiceBuffer release ];
    g_inputByteSize=0;
    g_outputByteSize=0;
    g_outputBufferOffset=0;
    g_inputBufferOffset=0;
    free(g_cookie.data);
    /* Initialize the I/O buffers */
    g_inputBuffer.mNumberChannels = 1;
    g_inputBuffer.mDataByteSize   = g_inputByteSize;
    
    
    
    NSLog(@"audioUnit VOIPDESTROYED");
    DestroyTranscoder();
    }
    
}
 


void  audio_session_interruption(void *userData,UInt32 interruptionState)
{
    AudioUnits *au = (AudioUnits *)userData;
    if(interruptionState == kAudioSessionBeginInterruption)
    {
        [au stopAudioSessions];
        [au stop];
        
    }
    else if(interruptionState == kAudioSessionEndInterruption)
    {
        
            [au startMusicAudioSession];
       
        [au start];
        
    }
}

-(void)start {
    
    
    
    if (_graph == NULL)
        
        return;
	
	Boolean isRunning = NO;
	AUGraphIsRunning(_graph, &isRunning);
	if (isRunning)
		return;
    
    
    
    if(!AUGraphStart(_graph))
        return;
    
    
    
}

-(void)stop {
    
    
    
    if (_graph == NULL)
        return;
    
	Boolean isRunning = NO;
	AUGraphIsRunning(_graph, &isRunning);
	
	if (!isRunning)
		return;
    
    
    
	 
    if(!AUGraphStop(_graph))
        return;
    

     }
-(AudioStreamBasicDescription) inputAudioDescription{return inputAudioDescription;}
-(AudioStreamBasicDescription) outputAudioDescription{return outputAudioDescription;}

-(BOOL)setupDataFormat
{
    
    if (_graph != NULL)
        [self teardownCoreAudio];
    
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
    
    
    AudioComponentDescription outputDescription;
	outputDescription.componentType = kAudioUnitType_Output;
#if TARGET_OS_IPHONE
	outputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
#else
    outputDescription.componentSubType = kAudioUnitSubType_DefaultOutput;
#endif
    outputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDescription.componentFlags = 0;
    outputDescription.componentFlagsMask = 0;
	
	// A description of the mixer unit
	AudioComponentDescription mixerDescription;
	mixerDescription.componentType = kAudioUnitType_Mixer;
	mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	mixerDescription.componentFlags = 0;
	mixerDescription.componentFlagsMask = 0;
	
    
    
    
	OSErr status = NewAUGraph(&_graph);
	if (status != noErr) {
        
        return NO;
    }
    
	status = AUGraphAddNode(_graph, &outputDescription, &_outputNode);
	if (status != noErr) {
        return NO;
    }
	
	
    
	status = AUGraphAddNode(_graph, &mixerDescription, &_mixerNode);
	if (status != noErr) {
        return NO;
    }
	
 	status = AUGraphAddNode(_graph, &mixerDescription, &_mixerNode2);
	if (status != noErr) {
        return NO;
    }
	
    AUGraphOpen(_graph);
	if (status != noErr) {
        return NO;
    }
   	status = AUGraphNodeInfo(_graph, _mixerNode, NULL, &mixerUnit);
	if (status != noErr) {
        return NO;
    }
    UInt32 maxFramesPerSlice = 4096;
    
	status = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
 	UInt32 numbuses = 1;
    
	status = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    
    
    
    
    
    AURenderCallbackStruct play_rcbs;
    play_rcbs.inputProc = playbackCallback;
    play_rcbs.inputProcRefCon = ( void *)(self);
    status = AUGraphSetNodeInputCallback(_graph, _mixerNode, 0, &play_rcbs);
   
    
    
    
    
    status = AUGraphNodeInfo(_graph, _mixerNode2, NULL, &mixerUnit2);
	if (status != noErr) {
        return NO;
    }
    status = AudioUnitSetProperty(mixerUnit2, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
    numbuses = 2;
    status = AudioUnitSetProperty(mixerUnit2, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    
    AURenderCallbackStruct network_rcbs;
    network_rcbs.inputProc = renderMsgCallback;
    network_rcbs.inputProcRefCon = ( void *)(self);
    
    
    // Set a callback for the specified node's specified input
    
    // equivalent to AudioUnitSetProperty(mMixer, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, i, &rcbs, sizeof(rcbs));
    
    status = AUGraphSetNodeInputCallback(_graph, _mixerNode2, 0, &network_rcbs);
    
    status = AUGraphNodeInfo(_graph, _outputNode, NULL, &outputUnit);
	if (status != noErr) {
        return NO;
    }
    AURenderCallbackStruct voice_rcbs;
    voice_rcbs.inputProc = voiceMsgCallback;
    voice_rcbs.inputProcRefCon = ( void *)(self);
    
    
    status = AUGraphSetNodeInputCallback(_graph, _mixerNode2, 1, &voice_rcbs);
    
    status = AUGraphNodeInfo(_graph, _outputNode, NULL, &outputUnit);
	if (status != noErr) {
        return NO;
    }
    
	UInt32 enable = 1;
    
    status=AudioUnitSetProperty(outputUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &enable, sizeof(UInt32));
    
    
    
    
    
    
    
	
	status = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, sizeof(maxFramesPerSlice));
	if (status != noErr) {
		return NO;
	}
    
	
    
    
    
    AudioStreamBasicDescription ioASBD;
	memset (&ioASBD, 0, sizeof (ioASBD));
	ioASBD.mSampleRate = 44100.0;
	ioASBD.mFormatID = kAudioFormatLinearPCM;
	ioASBD.mFormatFlags = kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked;
	ioASBD.mBytesPerPacket = 2;
	ioASBD.mFramesPerPacket = 1;
	ioASBD.mBytesPerFrame = 2;
	ioASBD.mChannelsPerFrame = 1;
	ioASBD.mBitsPerChannel = 16;
    inputAudioDescription=ioASBD;
    outputAudioDescription=outFormat;
    
    status = AudioUnitSetProperty(outputUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  1,
                                  &ioASBD,
                                  sizeof(ioASBD));
    
    status = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outFormat,
                                  sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &outFormat,
                                  sizeof(outFormat));
    status = AudioUnitSetProperty(outputUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outFormat,
                                  sizeof(outFormat));
 
    
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  0,
                                  &outFormat,
                                  sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  1,
                                  &outFormat,
                                  sizeof(outFormat));
    status = AudioUnitSetProperty(mixerUnit2,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  0,
                                  &outFormat,
                                  sizeof(outFormat));
    
    //status = AUGraphConnectNodeInput(_graph, _mixerNode, 0, _mixerNode2, 0);
    if (status != noErr) {
        
        NSLog(@"Error,%d",noErr);
        
        return NO;
    }
    
    status = AUGraphConnectNodeInput(_graph, _mixerNode2, 0, _outputNode, 0);
	if (status != noErr) {
        return NO;
    }
    
    CAShow(_graph);
    status = AUGraphInitialize(_graph);
	if (status != noErr) {
		return NO;
	}
    [self enableMixerInput:0 isOn:0];
    [self enableMixerInput:1 isOn:0];
    [self enableMixerInput2:1 isOn:0];
    [self enableMixerInput2:0 isOn:0];
         
    return YES;
    
    
    
}
///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////MIC CALLBACK///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

static OSStatus micCallback(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList *ioData)
{
    
    if (g_isDecoderinitialized)
	{
       /* AudioUnits *self = (AudioUnits *)inRefCon;
        OSStatus renderErr=noErr;
        
        
        
        renderErr=AudioUnitRender( self->outputUnit,
                                  ioActionFlags,
                                  inTimeStamp,
                                  1,
                                  inNumberFrames,
                                  ioData);
        */
    }
    return noErr;
}



///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////// NETWORK CALLBACK///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////


static OSStatus renderMsgCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData){
 
    
    
    AudioUnits *self = (AudioUnits *)inRefCon;
    OSStatus renderErr=noErr;
   
  bzero(ioData->mBuffers[0].mData , inNumberFrames*4  );
    if(self->isLocalMusicPlayerActive)
    {
        if (![self->musicOutputNode shouldContinue] == NO)
        {
    renderErr=AudioUnitRender( self->mixerUnit,
                              ioActionFlags,
                              inTimeStamp,
                              0,
                              inNumberFrames,
                              ioData);
        }
    }
    if (g_isDecoderinitialized)
	{
        UInt16 *audioBuffer = (UInt16 *)(ioData->mBuffers[0].mData);
        UInt32 audioBufferSize = ioData->mBuffers[0].mDataByteSize;
        
        UInt16 *inputBuffer = (UInt16 *)(g_inputBuffer.mData +g_inputBufferOffset);
        UInt32 inputBufferSize = (g_inputBuffer.mDataByteSize -g_inputBufferOffset);
        __uint32_t numFrames = 0;
        
        do
        {
            
            
            numFrames++;
            *inputBuffer++=*audioBuffer++;
            *inputBuffer++=*audioBuffer++; // Move forward 1 frame (stereo, 32 bits)
            
            inputBufferSize -= 4;
            audioBufferSize -= 4;
        } while((inputBufferSize > 0) && (audioBufferSize > 0));
        
        if(inputBufferSize == 0)
        {
            
            EncodedAudioBuffer encodedAU;
            Encode(g_encoder, &g_inputBuffer, &encodedAU);
            
                        [self->network SendAudioData: encodedAU.data AndLength:encodedAU.mDataBytesSize] ;
             
                          //[self->voiceBuffer produceToBuffer:encodedAU.data ofLength:encodedAU.mDataBytesSize];
            
            
            
            
            g_inputBufferOffset=0;
        }
        
        else {
            
            UInt32 numBytesCopied = numFrames * 4;
            
            g_inputBufferOffset += numBytesCopied;
            
        }
        
        
        
        
        
                    }
  
    return noErr;
    
    
    
}
///////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////VOICE CALLBACK///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

static OSStatus voiceMsgCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    if (g_isDecoderinitialized)
	{
        bzero(ioData->mBuffers[0].mData , ioData->mBuffers[0].mDataByteSize  );
        
        AudioUnits *output = (AudioUnits *)inRefCon;
        
        
        
        UInt16 *audioBuffer = (UInt16 *)(ioData->mBuffers[0].mData);
        UInt32 audioBufferSize = ioData->mBuffers[0].mDataByteSize;
        
        UInt16 *outputBuffer = (UInt16 *)(g_outputBuffer.mData +g_outputBufferOffset);
        UInt32 outputBufferSize = (g_outputBuffer.mDataByteSize - g_outputBufferOffset);
        if((outputBufferSize > 0)&&(audioBufferSize > 0))
        {
            
            do
            {
                // Copy mono outputBuffer into stereo audioBuffer by copying each sample from output
                // into both left and right sample of audio.
                
                *audioBuffer++ = *outputBuffer;
                *audioBuffer++ = *outputBuffer++;
                
                audioBufferSize -= 4;
                outputBufferSize -= 2;
                
            } while((outputBufferSize > 0) && (audioBufferSize > 0));
            
            if(outputBufferSize > 0)
            {
                // There's data leftover in the outputBuffer
                
                UInt32 numFramesRead = ioData->mBuffers[0].mDataByteSize / 4;
                UInt32 numBytesRead = numFramesRead * 2;
                
                g_outputBufferOffset += numBytesRead;
            }
            else
            {
                // We used up all the leftover data in the outputBuffer
                
                g_outputBufferOffset = 0;
            }        }
        
        while(audioBufferSize > 0)
        {
            UInt16 *read=0;
            
            
            
            NSUInteger availableData = [output->voiceBuffer  availableBytes];
            if(availableData>0){
                
                
                
                [output->voiceBuffer  consumeBytesTo:g_packetBuffer OfLength:sizeof(UInt16)];
                
                read=  (UInt16 *)g_packetBuffer;
                UInt16 amountToRead=*read;
                
                [output->voiceBuffer  consumeBytesTo:output->tempBuffer OfLength:amountToRead];
                if(amountToRead>availableData)
                    amountToRead=availableData;
                
                
                DecoderAudioBuffer decoderAU;
                decoderAU.mChannels=1;
                
                decoderAU.data=output->tempBuffer;
                
                
                decoderAU.mDataBytesSize= amountToRead;
                g_outputBuffer.mDataByteSize=g_outputByteSize;
                Decode(g_decoder, &decoderAU, &g_outputBuffer);
                
                
                
                g_outputBufferOffset = 0;
                
                outputBuffer = (UInt16 *)(g_outputBuffer.mData);
                outputBufferSize =g_outputBuffer.mDataByteSize;
                if(outputBufferSize> 0)
                {
                    do
                    {
                        
                        *audioBuffer++ = *outputBuffer;
                        *audioBuffer++ = *outputBuffer++;
                        
                        audioBufferSize -= 4;
                        outputBufferSize -= 2;
                    } while((outputBufferSize > 0) && (audioBufferSize > 0));
                    
                    if(outputBufferSize > 0)
                    {
                        // There's data leftover in the outputBuffer
                        
                        g_outputBufferOffset= g_outputBuffer.mDataByteSize-outputBufferSize;
                    }
                    else
                    {
                        // We used up all the leftover data in the outputBuffer
                        g_outputBuffer.mDataByteSize=0;
                        g_outputBufferOffset = 0;
                    }
                }
            } else {
                g_outputBuffer.mDataByteSize=0;
                g_outputBufferOffset = 0;
                break;
            }
        }
        
        
    }
    
    return noErr;
    
}
///////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////MUSIC CALLBACK///////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////


static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    AudioUnits *output = (AudioUnits *)inRefCon;
    
    if(output->isLocalMusicPlayerActive&&output->musicOutputNode)
    {
        if (![output->musicOutputNode shouldContinue] == NO)
        {
            OSStatus err = noErr;
            void *readPointer = g_tempMusicBuffer;
            
            int amountToRead, amountRead;
            
            
            
            
            
            
            
            amountToRead = inNumberFrames*4;
            amountRead = [output->musicOutputNode readData:(readPointer) amount:amountToRead];
            
            ioData->mBuffers[0].mData=g_tempMusicBuffer;
            if ((amountRead < amountToRead) && [output->musicOutputNode endOfStream] == NO) //Try
            {
                bzero(ioData->mBuffers[0].mData + amountRead, ioData->mBuffers[0].mDataByteSize - amountRead);
                 
                return noErr;
            }
            [output setPlayedFrames:inNumberFrames];
 
            ioData->mBuffers[0].mDataByteSize = amountRead;
            ioData->mBuffers[0].mNumberChannels = 2;
       
            [[fft sharedInstance] doFFTReal:inNumberFrames/sizeof(int16_t) :(int16_t *)g_tempMusicBuffer  ] ;
            
            return err;
        }
               
    }
    
    
    return noErr;
}



-(void)teardownCoreAudio {
    if (_graph == NULL)
        return;
    AUGraphUninitialize(_graph);
	DisposeAUGraph(_graph);
	
	_graph = NULL;
	outputUnit = NULL;
	mixerUnit = NULL;
    [self destroyVoip];
    musicOutputNode=nil;
    
    
}

-(void)setMusicOutputNode:(OutputNode *)c{
    musicOutputNode=c;
    
    
    
    
    
}

- (void)setVolumemixer2:(AudioUnitParameterValue)vol forBus:(UInt32)busNumber
{
    
    AudioUnitSetParameter(mixerUnit2, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, busNumber, vol*vol*vol, 0);
}
- (void)setVolume:(AudioUnitParameterValue)vol forBus:(UInt32)busNumber
{
    AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, busNumber, vol*vol*vol, 0);
    
}

- (float)getVolumeForBus:(UInt32)busNumber
{
    float floatVolume;
    AudioUnitGetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, busNumber, &floatVolume);
    
    return floatVolume;
}

- (BOOL)busNumberIsMuted:(int)busNumber
{
    float enabled;
    AudioUnitGetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, busNumber, &enabled);
    
    return !(BOOL)enabled;
}

- (void)unmuteBusNumber:(int)busNumber
{
    float enabled = 1;
    AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, busNumber, enabled, 0);
}

- (void)muteBusNumber:(int)busNumber
{
    float enabled = 0;
    AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, busNumber, enabled, 0);
}


-(NSData *)requestCookie{
    
    if(!isVoipInitialized){
        [self initializeVoip];
    }
    
    NSData *data=[NSData dataWithBytes:g_cookie.data length:g_cookie.byteSize]
    ;
    return data;
}
-(void)setCookie:(NSData *)cookie{
    dg_cookie.data=(void *)[cookie bytes];
    dg_cookie.byteSize=[cookie length];
    
    InitACDecoder();
    
    
}

-(void)startVOIP{
    if(isVOIPActive==NO){
    if(isLocalMusicPlayerActive==YES)
    {
        [self stopLocalMusicPlayer];
        
    }
     [self startMusicAudioSession];
    [self start];
    
    g_isDecoderinitialized=YES;
    g_isEncoderinitialized=YES;
    isVOIPActive=YES;
 
    [self enableMixerInput2:0 isOn:1];
    [self setVolumemixer2:1.0 forBus:0];
    [self enableMixerInput2:1 isOn:1];
    [self setVolumemixer2:1.0 forBus:1];
    }
}
-(void)stopVOIP{
     if(isVOIPActive){
         isLocalMusicPlayerActive=NO;
    g_isDecoderinitialized=NO;
    g_isEncoderinitialized=NO;
    isVOIPActive=NO;
    [self destroyVoip];
         [self stopAudioSessions];
         [self stop];
     
    [self setVolumemixer2:0.0 forBus:1];
    [self enableMixerInput2:1 isOn:0];
    [self setVolume:0.0 forBus:0];
    [self enableMixerInput:0 isOn:0];
    [self setVolumemixer2:0.0 forBus:0];
    [self enableMixerInput2:0 isOn:0];
       
   
    }
}
-(void)startLocalMusicPlayer{
    
    if(isLocalMusicPlayerActive==YES)
        return;
   
    isLocalMusicPlayerActive=YES;
    [self startMusicAudioSession];
    [self start];
    
        

        [self enableMixerInput:0 isOn:1];
        [self setVolume:1.0 forBus:0];
        
        
        [self enableMixerInput2:0 isOn:1];
        [self setVolumemixer2:1.0 forBus:0];
    [self setVolumemixer2: 0.0 forBus:1];
        [self enableMixerInput2:1 isOn:0];
    
    
    
                return;
        
    
}
-(void)stopLocalMusicPlayer{
    if(isLocalMusicPlayerActive){
    isLocalMusicPlayerActive=NO;
    if(isVOIPActive==NO){
        [self stopAudioSessions];
        [self stop];
        
        [self setVolume:0.0 forBus:0];
         [self setVolumemixer2:0.0 forBus:0];
        [self setVolumemixer2:0.0 forBus:1];
         [self enableMixerInput:0 isOn:0];
        [self enableMixerInput2:1 isOn:0];
        [self enableMixerInput2:0 isOn:0];
        
        
    }
    else {
        
        [self setVolume:0.0 forBus:0];
        [self enableMixerInput:0 isOn:0];
        
        [self setVolumemixer2:0.0 forBus:0];
        [self enableMixerInput2:0 isOn:0];
        [self enableMixerInput2:1 isOn:1];
        [self setVolumemixer2:1.0 forBus:1];
        
        
        
    }
    
     
    }
    
    
}
-(void)setIsStreaming:(BOOL)s{
    
    isStreaming=YES;
    
}
- (void) didProducePackets:(NSData *)packetData
{
    
    
    
    NSUInteger availableData = [voiceBuffer  availableBytes];
    if((availableData+[packetData length]+sizeof(UInt16))>=100*9)
    {
        NSLog (@"AVAILABLE %d", (int) availableData );
        
    }
    else {
        
        UInt16 len= [packetData length] ;
        [voiceBuffer produceToBuffer:&len ofLength:sizeof(len)];
        
        [voiceBuffer produceToBuffer:(void *)[packetData bytes] ofLength:[packetData length]];
        
        
        
    }
    
}

- (void) enableMixerInput: (UInt32) inputBus isOn: (AudioUnitParameterValue) isOnValue {
    
    NSLog (@"Bus %d now %@", (int) inputBus, isOnValue ? @"on" : @"off");
    
    OSStatus result = AudioUnitSetParameter (
                                             mixerUnit,
                                             kMultiChannelMixerParam_Enable,
                                             kAudioUnitScope_Input,
                                             inputBus,
                                             isOnValue,
                                             0
                                             );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (enable the mixer unit)" withStatus: result];
    }
}
- (void) enableMixerInput2: (UInt32) inputBus isOn: (AudioUnitParameterValue) isOnValue {
    
    NSLog (@"Bus %d now %@", (int) inputBus, isOnValue ? @"on" : @"off");
    
    OSStatus result = AudioUnitSetParameter (
                                             mixerUnit2,
                                             kMultiChannelMixerParam_Enable,
                                             kAudioUnitScope_Input,
                                             inputBus,
                                             isOnValue,
                                             0
                                             );
    
    if (noErr != result) {[self printErrorMessage: @"AudioUnitSetParameter (enable the mixer unit)" withStatus: result];
    }
}
-(void)printErrorMessage: (NSString *) errorString withStatus: (OSStatus) result {
    
    
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(result);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)result);
    
    //	fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    
    NSLog (
           @"*** %@ error: %s\n",
           errorString,
           str
           );
}
-(void)startVOIPAudioSession{
 NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error: &error];
         [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    Float32 preferredBufferTime = 512.0 / 44100.0;
    [audioSession
     setPreferredIOBufferDuration: preferredBufferTime
     error: &error];
    Float64 hwSampleRate = 44100.0;
    [audioSession
     setPreferredSampleRate:hwSampleRate error:&error]
    ;
    [audioSession setActive:YES error: &error];

}
-(void)startMusicAudioSession{
    if(isAudioSessionInitialized)
        return;
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    Float32 preferredBufferTime = 512.0 / 44100.0;
    [audioSession
     setPreferredIOBufferDuration: preferredBufferTime
     error: &error];
    Float64 hwSampleRate = 44100.0;
    [audioSession
     setPreferredSampleRate:hwSampleRate error:&error]
    ;

    [audioSession setActive:YES error: &error];
    isAudioSessionInitialized=YES;
}
-(void)stopAudioSessions{
 
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO error: &error];
    isAudioSessionInitialized=NO;

}
-(void)setPlayedFrames:(int)frames{


    playedFrames+=frames;
}
-(int)playedFrames{

    return playedFrames;
}
- (void)_resetTiming
{
    playedFrames=0;
}
 
@end

 