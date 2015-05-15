//
//  VisualizerViewController.m
//  AirDab
//
//  Created by YAZ on 8/27/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "VisualizerViewController.h"
#import "fft.h"
@interface VisualizerViewController ()

@end

@implementation VisualizerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!_context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    self.preferredFramesPerSecond = 60;
    prev=[NSDate timeIntervalSinceReferenceDate];
    
    for(int i = 0; i < 360*2; i+=2) {
        current_points[i+0]   =cosf(i ) *2;
        current_points[i+1] = sinf((i )) *2 ;
        
    }
    [self loadTexture:&textureId  fromFile: @"ball2.png"];
    glEnable(GL_TEXTURE_2D);
    
    [self loadShaders];
    [self setupLeftView];
    [[fft sharedInstance] setIsEnabled:YES];
    
    magnitudes=0;
    p_magnitudes=0;
    utime=0;


}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext:nil];
    }
    _context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)update
{
    magnitudes=[[fft sharedInstance ] fetchfrequency];
    magnitudes = sqrt((magnitudes- p_magnitudes)*(magnitudes- p_magnitudes));
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    NSTimeInterval current=[NSDate timeIntervalSinceReferenceDate ];
    
    
    prev=current;
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    utime= .1f;
    if(utime>=1.0f)
        utime=0;
    
    
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
    
    // Bind the texture
    glActiveTexture ( GL_TEXTURE0 );
    glBindTexture ( GL_TEXTURE_2D, textureId );
    glEnable ( GL_TEXTURE_2D );
    float  vec[2];
    vec[0]=self.view.bounds.size.width;
    vec[1]=self.view.bounds.size.height;
    glUniform2fv (uniforms[ UNIFORM_RESOLUTION],1,  vec);
    glUniform1f (uniforms[ UNIFORM_TIME],  utime );
    glUniform1f (uniforms[ UNIFORM_SC],  magnitudes );
    
    glDrawArrays(GL_TRIANGLE_FAN,0,360);
    p_magnitudes=magnitudes;
}




-(void)setupLeftView{
    leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(self.view.bounds.size.width-32,5, 31, 20);
    
    leftButton.backgroundColor=[UIColor clearColor];
    
    [leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    
    [leftButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [self.view addSubview:leftButton];
    
    
}
-(void)back
{
    
    [self.dandelegate back];
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
    [EAGLContext setCurrentContext:_context];
         glDeleteProgram(_program);
  
    glDeleteTextures(1, &textureId);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    [leftButton  removeFromSuperview ];
    [[fft sharedInstance] setIsEnabled:NO];
     
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
