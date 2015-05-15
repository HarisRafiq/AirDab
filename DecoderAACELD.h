//
//  DecoderAACELD.h
//  IMMedia
//
//  Created by YAZ on 6/4/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//
#include <AudioToolbox/AudioToolbox.h>
#ifndef AACELD_DECODER_H
#define AACELD_DECODER_H
#ifdef __cplusplus
extern "C" {
#endif
    
    
    
    typedef struct DecoderAACELD_ DecoderAACELD;
    
    /* Structure to keep the decoder configuration */
    typedef struct DecoderProperties_
    {
        Float64 samplingRate;
        UInt32  inChannels;
        UInt32  outChannels;
        UInt32  frameSize;
    } DecoderProperties;
    typedef struct DecoderAudioBuffer_
    {
        UInt32 mChannels;
        UInt32 mDataBytesSize;
        void *data;
    } DecoderAudioBuffer;
    typedef struct DMagicCookie_
    {
        void *data;
        int byteSize;
    } DMagicCookie;
    
    /* Create a new AAC-ELD decoder */
    DecoderAACELD* CreateDecoder();
    /* Initialize the decoder and set the magic cookie */
    int  InitDecoder(DecoderAACELD* decoder, DecoderProperties props,const DMagicCookie *cookie) ;
    /* Decode one AAC-ELD AU to one LPCM frame (512 samples) */
    int  Decode(DecoderAACELD* decoder, DecoderAudioBuffer *inData, AudioBuffer *outSamples);
    /* Destroy the decoder and free associated memory */
    void DestroyDecoder(DecoderAACELD* decoder);
#ifdef __cplusplus
}
#endif
#endif
