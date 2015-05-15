//
//  DecoderAACELD.m
//  IMMedia
//
//  Created by YAZ on 6/4/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#import "DecoderAACELD.h"
typedef struct DecoderAACELD_ {
    AudioStreamBasicDescription  sourceFormat;
    AudioStreamBasicDescription  destinationFormat;
    AudioConverterRef            audioConverter;
    
    UInt32                       bytesToDecode;
    void                        *decodeBuffer;
    AudioStreamPacketDescription packetDesc[1];
    
    Float64                      samplingRate;
    UInt32                       inChannels;
    UInt32                       outChannels;
    UInt32                       frameSize;
    UInt32                       maxOutputPacketSize;
} DecoderiLBC;

DecoderAACELD* CreateDecoder()
{
    /* Create and initialize a new decoder */
    DecoderAACELD *decoder = (DecoderAACELD*) malloc(sizeof(DecoderAACELD));
    memset(&(decoder->sourceFormat), 0, sizeof(AudioStreamBasicDescription));
    memset(&(decoder->destinationFormat), 0, sizeof(AudioStreamBasicDescription));
    
    decoder->bytesToDecode       = 0;
    decoder->decodeBuffer        = NULL;
    decoder->samplingRate        = 0;
    decoder->inChannels          = 0;
    decoder->outChannels         = 0;
    decoder->frameSize           = 0;
    decoder->maxOutputPacketSize = 0;
    
    return decoder;
}

void DestroyDecoder(DecoderAACELD* decoder)
{
     AudioConverterDispose(decoder->audioConverter);
    free(decoder); /* free the allocated decoder memory */
    NSLog(@"DECODER dealloc");
    
}

int InitDecoder(DecoderAACELD* decoder, DecoderProperties props, const DMagicCookie *cookie)
{
    /* Copy the provided decoder properties */
    decoder->inChannels   = props.inChannels;
    decoder->outChannels  = props.outChannels;
    decoder->samplingRate = props.samplingRate;
    decoder->frameSize    = props.frameSize;
    AudioStreamBasicDescription ioASBD;
	memset (&ioASBD, 0, sizeof (ioASBD));
	ioASBD.mSampleRate = props.samplingRate;
	ioASBD.mFormatID = kAudioFormatLinearPCM;
	ioASBD.mFormatFlags =kAudioFormatFlagsCanonical;
	ioASBD.mBytesPerPacket = props.outChannels*2;
	ioASBD.mFramesPerPacket = 1;
	ioASBD.mBytesPerFrame = props.outChannels*2;
	ioASBD.mChannelsPerFrame = props.outChannels;
	ioASBD.mBitsPerChannel = 16;
    decoder->destinationFormat=ioASBD;
    
    
    /* from AAC-ELD, having the same sampling rate, but possibly a different channel configuration */
    decoder->sourceFormat.mFormatID         = kAudioFormatMPEG4AAC_ELD;
    decoder->sourceFormat.mChannelsPerFrame = decoder->inChannels;
    decoder->sourceFormat.mSampleRate       = decoder->samplingRate;    UInt32 dataSize = sizeof(decoder->sourceFormat);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                           0,
                           NULL,
                           &dataSize,
                           &(decoder->sourceFormat));
    
    /* Create a new AudioConverter instance for the conversion AAC-ELD -> LPCM */
    AudioConverterNew(&(decoder->sourceFormat),
                      &(decoder->destinationFormat),
                      &(decoder->audioConverter));
    
    if (!decoder->audioConverter)
    {
        return -1;
    }
    
    /* Check for variable output packet size */
    if (decoder->destinationFormat.mBytesPerPacket == 0)
    {
        UInt32 maxOutputSizePerPacket = 0;
        dataSize = sizeof(maxOutputSizePerPacket);
        AudioConverterGetProperty(decoder->audioConverter,
                                  kAudioConverterPropertyMaximumOutputPacketSize,
                                  &dataSize,
                                  &maxOutputSizePerPacket);
        decoder->maxOutputPacketSize = maxOutputSizePerPacket;
    }
    else
    {
        decoder->maxOutputPacketSize = decoder->destinationFormat.mBytesPerPacket;
    }
    
    AudioConverterSetProperty(decoder->audioConverter,
                              kAudioConverterDecompressionMagicCookie,
                              cookie->byteSize,
                              cookie->data);

    return 0;
}

static OSStatus decodeProc(AudioConverterRef inAudioConverter,
                           UInt32 *ioNumberDataPackets,
                           AudioBufferList *ioData,
                           AudioStreamPacketDescription **outDataPacketDescription,
                           void *inUserData)
{
    /* Get the current decoder state from the inUserData parameter */
    DecoderAACELD *decoder = (DecoderAACELD*)inUserData;
    
    UInt32 maxPackets = decoder->bytesToDecode / decoder->maxOutputPacketSize;
    
    if (*ioNumberDataPackets > maxPackets)
    {
        /* If requested number of packets is bigger, adjust */
        *ioNumberDataPackets = maxPackets;
    }
    
    /* If there is data to be decoded, set it accordingly */
    if (decoder->bytesToDecode)
    {
        ioData->mBuffers[0].mData           = decoder->decodeBuffer;
        ioData->mBuffers[0].mDataByteSize   = decoder->bytesToDecode;
        ioData->mBuffers[0].mNumberChannels = decoder->inChannels;
    }
    
    /* And set the packet description */
    if (outDataPacketDescription)
    {
        decoder->packetDesc[0].mStartOffset            = 0;
        decoder->packetDesc[0].mVariableFramesInPacket = 0;
        decoder->packetDesc[0].mDataByteSize           = decoder->bytesToDecode;
        
        (*outDataPacketDescription) = decoder->packetDesc;
    }
    
    if (decoder->bytesToDecode == 0)
    {
        // We are currently out of data but want to keep on processing
        // See Apple Technical Q&A QA1317
        return 1;
    }
    
    decoder->bytesToDecode = 0;
    
    return noErr;
}

int Decode(DecoderAACELD* decoder, DecoderAudioBuffer *inData, AudioBuffer *outSamples)
{
    OSStatus status = noErr;
    
    decoder->decodeBuffer  = inData->data;
    decoder->bytesToDecode = inData->mDataBytesSize;
    
    UInt32 outBufferMaxSizeBytes = decoder->frameSize * decoder->outChannels * sizeof(AudioSampleType);
    
     
    UInt32 numOutputDataPackets = outBufferMaxSizeBytes / decoder->maxOutputPacketSize;
    
    /* Output packet stream are 512 LPCM samples */
    AudioStreamPacketDescription outputPacketDesc[512];
    
    /* Create the output buffer list */
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers = 1;
    outBufferList.mBuffers[0].mNumberChannels = decoder->outChannels;
    outBufferList.mBuffers[0].mDataByteSize   = outSamples->mDataByteSize;
    outBufferList.mBuffers[0].mData           = outSamples->mData;
    status = AudioConverterFillComplexBuffer(decoder->audioConverter,
                                             decodeProc,
                                             decoder,
                                             &numOutputDataPackets,
                                             &outBufferList,
                                             outputPacketDesc);
    outSamples->mDataByteSize=outBufferList.mBuffers[0].mDataByteSize;
   
    if(numOutputDataPackets==0)
            if (noErr != status)
    {
        return -1;
        NSLog(@"DECODE BYTES %i",(unsigned int)outBufferList.mBuffers[0].mDataByteSize);

    
    }
   
    return 0;
}

