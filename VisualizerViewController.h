//
//  VisualizerViewController.h
//  AirDab
//
//  Created by YAZ on 8/27/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import <GLKit/GLKit.h>
@protocol danceDelegate;

@interface VisualizerViewController : GLKViewController
{
    EAGLContext *_context;
    float utime;
    float magnitudes;
    float p_magnitudes;
    GLfloat current_points[360 *2];
    NSTimeInterval prev;
    GLuint _program;
    enum
    
    {UNIFORM_SC,
        UNIFORM_TIME,
        UNIFORM_RESOLUTION,
        UNIFORM_CENTER,
        UNIFORM_MODELVIEWPROJECTION_MATRIX,
        NUM_UNIFORMS
    };
    GLint uniforms[NUM_UNIFORMS];
    
    // Attribute index.
    enum
    {
        a_positon,
        
        NUM_ATTRIBUTES
    };
     GLKMatrix4 _modelViewProjectionMatrix;
    GLuint textureId;
    UIButton *leftButton;



}
@property(nonatomic, assign) id <danceDelegate> dandelegate;

@end
@protocol danceDelegate<NSObject>
-(void)back;


@end