//
//  dance.h
//  HeartConnect
//
//  Created by YAZ on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@protocol danceDelegate;

@interface dance : GLKView
{
    CADisplayLink *_displayLink;
    NSThread *_displayLinkThread;
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
    EAGLContext *_context;
    GLKMatrix4 _modelViewProjectionMatrix;
    GLuint textureId;
    UIButton *leftButton;

}
-(void)cleanUp 
    ;
@property(nonatomic, assign) id <danceDelegate> dandelegate;
 @end
@protocol danceDelegate<NSObject>
-(void)back;
 

@end
