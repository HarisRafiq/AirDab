//
//  dance.m
//  HeartConnect
//
//  Created by YAZ on 3/28/13.
//
//

#import "dance.h"
#import "fft.h"
@implementation dance

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    _context=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self = [super initWithFrame:frame context:_context];
    if (self) {
         [EAGLContext setCurrentContext:_context];
         glEnable(GL_DEPTH_TEST);
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
        prev=[NSDate timeIntervalSinceReferenceDate];
      
                      for(int i = 0; i < 360*2; i+=2) {
                          current_points[i+0]   =cosf(i ) *2;
                          current_points[i+1] = sinf((i )) *2 ;
                                     
        }
        //[self loadTexture:&textureId  fromFile: @"ball2.png"];
       // glEnable(GL_TEXTURE_2D);
 
        [self loadShaders];
        
         [[fft sharedInstance] setIsEnabled:YES];
        [self _setupDisplayLink];
         
    }
    return self;
}
 
-(void)back
{

    [self.dandelegate back];
}
- (void)_setupDisplayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(_displayLinkCallback:)];
    [_displayLink setPaused:NO];
    [_displayLink setFrameInterval:1];
    
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                       forMode:NSRunLoopCommonModes];
}
- (void)_displayLinkCallback:(CADisplayLink *)displayLink
{
       [self setNeedsDisplay];
    
}
- (void)loadTexture:(GLuint *)newTextureName fromFile:(NSString *)fileName {
    // Load image from file and get reference
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil]];
    CGImageRef imageRef = [image CGImage];
    
    if(imageRef) {
        // get width and height
        size_t imageWidth = CGImageGetWidth(imageRef);
        size_t imageHeight = CGImageGetHeight(imageRef);
        
        GLubyte *imageData = (GLubyte *)malloc(imageWidth * imageHeight * 4);
        memset(imageData, 0, (imageWidth * imageHeight * 4));
        
        CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth * 4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
        
        // Make CG system interpret OpenGL style texture coordinates properly by inverting Y axis
        CGContextTranslateCTM(imageContextRef, 0, imageHeight);
        CGContextScaleCTM(imageContextRef, 1.0, -1.0);
        
        CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
        
        CGContextRelease(imageContextRef);
        
        glGenTextures(1, newTextureName);
        
        glBindTexture(GL_TEXTURE_2D, *newTextureName);
        
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
        glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        
        
    }
    
    
}

 

- (void)drawRect:(CGRect)rect
{
    [EAGLContext setCurrentContext:_context];
    magnitudes=[[fft sharedInstance ] fetchfrequency];
    
    NSTimeInterval current=[NSDate timeIntervalSinceReferenceDate ];
         
    prev=current;
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    utime+= .09f;
    
    if(utime>=1.0f)
        utime=.09f;
        
    //magnitudes =  (magnitudes-p_magnitudes)  *utime ;
    
         _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
      glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
   
    // Use the program object
    glUseProgram (_program);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
   
     
    float color[4];
    
    
    // Random color
    color[0] =  1.0f;
    color[1] =  0.0f;
    color[2] =  0.0f;
    color[3] =  1.0f;
    
    
    
    glVertexAttribPointer(a_positon,2, GL_FLOAT, 0, 0, current_points);
    glEnableVertexAttribArray(a_positon);
    
    
 
    glEnable ( GL_BLEND );
    glBlendFunc ( GL_SRC_ALPHA, GL_ONE );
    
   
    float  vec[2];
    vec[0]=self.bounds.size.width;
    vec[1]=self.bounds.size.height;
 glUniform2fv (uniforms[ UNIFORM_RESOLUTION],1,  vec);
    glUniform1f (uniforms[ UNIFORM_TIME],  p_magnitudes );
    glUniform1f (uniforms[ UNIFORM_SC],  magnitudes );
    
    glDrawArrays(GL_TRIANGLE_FAN,0,360);
     p_magnitudes=magnitudes;
    
}


- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    glBindAttribLocation(_program,a_positon, "a_position");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    uniforms[UNIFORM_TIME] = glGetUniformLocation (_program, "u_time" );
    uniforms[UNIFORM_SC] = glGetUniformLocation (_program, "u_sc" );
    uniforms[UNIFORM_RESOLUTION] = glGetUniformLocation (_program, "resolution" );

       // Get the uniform locations
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "mvp_matrix");
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
-(void)cleanUp{
    [[fft sharedInstance] setIsEnabled:NO];

    [EAGLContext setCurrentContext:_context];
    [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
 [_displayLink invalidate];
     _displayLink =nil;
glDeleteProgram(_program);
    glDeleteBuffers(1, &textureId);
    glDeleteTextures(1, &textureId);
     
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
     
    [leftButton  removeFromSuperview ];
       [EAGLContext setCurrentContext:nil];
     
}
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
