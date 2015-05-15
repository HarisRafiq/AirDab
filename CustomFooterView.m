//
//  CustomFooterView.m
//  AirDab
//
//  Created by YAZ on 9/15/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#import "CustomFooterView.h"
static inline double radians (double degrees) { return degrees * M_PI/180; }
CGMutablePathRef createArcPathFromBottomOfRect(CGRect rect, CGFloat arcHeight);
@implementation CustomFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
        
          }
    return self;
}


 - (void)drawRect:(CGRect)rect
{
    

     CGContextRef context = UIGraphicsGetCurrentContext();
     
 
     
          CGRect paperRect = CGRectMake(self.bounds.origin.x , self.bounds.origin.y, self.bounds.size.width ,  self.bounds.size.height);
   
     CGRect arcRect = paperRect;
     //arcRect.size.height = paperRect.size.height;
    CGContextSetStrokeColorWithColor(context,[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 2.0);
    
     CGMutablePathRef arcPath = createArcPathFromBottomOfRect(arcRect, arcRect.size.height/1.45);
     CGContextAddPath(context, arcPath);
        CGContextStrokePath(context);
     //drawLinearGradient(context, paperRect, whiteColor.CGColor, whiteColor.CGColor );
    
    
    
    
     CFRelease(arcPath);
    
    
    

 }
void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, color);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
    CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
}
CGMutablePathRef createArcPathFromBottomOfRect(CGRect rect, CGFloat arcHeight)
{
    CGRect arcRect = CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - arcHeight, rect.size.width, arcHeight);
    
    CGFloat arcRadius = (arcRect.size.height/2) + (pow(arcRect.size.width, 2) / (8*arcRect.size.height));
    CGPoint arcCenter = CGPointMake(arcRect.origin.x + arcRect.size.width/2, arcRect.origin.y + arcRadius);
    
    CGFloat angle = acos(arcRect.size.width / (2*arcRadius));
    CGFloat startAngle = radians(180) + angle;
    CGFloat endAngle = radians(360) - angle;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, arcCenter.x, arcCenter.y, arcRadius, startAngle, endAngle, 0);
 
    
    return path;
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
@end
