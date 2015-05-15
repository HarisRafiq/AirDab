//
//  EncoderAACELD.h
//  IMMedia
//
//  Created by YAZ on 6/4/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#ifndef AACELD_ENCODER_H
#define AACELD_ENCODER_H
#ifdef __cplusplus
extern "C" {
#endif
    
    
    typedef struct  EncoderAACELD_  EncoderAACELD;
    
    /* Structure to keep the encoder configuration */
    typedef struct EncoderProperties_
    {
        Float64 samplingRate;
        UInt32  inChannels;
        UInt32  outChannels;
        UInt32  frameSize;
        UInt32  bitrate;
    } EncoderProperties;
    
    /* Structure to keep the magic cookie */
    
    
    /* Structure to keep one encoded AU */
    typedef struct EncodedAudioBuffer_
    {
        UInt32 mChannels;
        UInt32 mDataBytesSize;
        void *data;
    } EncodedAudioBuffer;
    typedef struct MagicCookie_
    {
        void *data;
        int byteSize;
    } MagicCookie;
    /* Create a new AAC-ELD encoder */
    EncoderAACELD* CreateEncoder();
    /* Initialize the encoder and get the magic cookie */
    int  InitEncoder(EncoderAACELD* encoder, EncoderProperties props,MagicCookie *outCookie);
    /* Encode one LPCM frame (512 samples) to one AAC-ELD AU */
    int  Encode(EncoderAACELD* encoder, AudioBuffer *inSamples, EncodedAudioBuffer *outData);
    /* Destroy the encoder and free associated memory */
    void DestroyEncoder(EncoderAACELD *encoder);
#ifdef __cplusplus
}
#endif
#endif