//
//  BBCell.m
//  CircleView
//
//  Created by Bharath Booshan on 6/8/12.
//  Copyright (c) 2012 Bharath Booshan Inc. All rights reserved.
//

#import "CircleCell.h"

@implementation CircleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGAffineTransform rotateImage = CGAffineTransformMakeRotation(M_PI);
        self.transform = rotateImage;
    
                 self.selectionStyle = UITableViewCellSelectionStyleNone;
        //add the image layer
        [self setBackgroundColor:[UIColor clearColor]];
                       self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView setOpaque:YES];
        [self.backgroundView setOpaque:YES];
                mImageLayer =[CALayer layer];
        //mImageLayer.cornerRadius = 16.0;
        mImageLayer.opaque=YES;
                self.contentView.layer.masksToBounds=YES;
        // Performance improvement here depends on the size of your view
     mImageLayer.shouldRasterize = YES;
      mImageLayer.rasterizationScale=[[UIScreen mainScreen] scale];
        //mImageLayer.backgroundColor = [UIColor greenColor].CGColor;
                [self.contentView.layer addSublayer:mImageLayer];
        mImageLayer.borderWidth=2.0;
        [mImageLayer setBackgroundColor:[UIColor whiteColor].CGColor];

                      mCellTtleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x+44, self.contentView.bounds.origin.y, self.contentView.bounds.size.width - 44.0, 21.0)];
        mCellTtleLabel.font =[UIFont fontWithName:@"Helvetica-Bold" size:12];
        
                 mCellTtleLabel.lineBreakMode=NSLineBreakByTruncatingTail;
         mCellTtleLabel.numberOfLines=0;
         mCellTtleLabel.textAlignment=NSTextAlignmentCenter;
        CGAffineTransform rotate= CGAffineTransformMakeRotation(-M_PI_2);
        mCellTtleLabel.transform = rotate;
        mImageLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0.0, 0.0, 1.0);
        [mCellTtleLabel setBackgroundColor:[UIColor clearColor]];
               [self.contentView addSubview:mCellTtleLabel];
        
    }
    return self;
}



-(void)layoutSubviews
{
    
    [super layoutSubviews];
    float imageY = 2.0;
    float heightOfImageLayer  = self.bounds.size.height - imageY ;
    heightOfImageLayer = floorf(heightOfImageLayer);
  
 
  mCellTtleLabel.frame = CGRectMake(0, 0,self.contentView.bounds.size.width/3 -self.contentView.bounds.size.height- imageY*2.0  ,self.bounds.size.height);
     
     mImageLayer.cornerRadius = heightOfImageLayer/2.0f;
    mImageLayer.frame = CGRectMake(self.contentView.bounds.size.width/3 -self.contentView.bounds.size.height- imageY*2.0   , imageY , heightOfImageLayer, heightOfImageLayer );
 
 }

-(void)setCellTitle:(NSString*)title
{
    mCellTtleLabel.text = title;
    title=nil;
}

-(void)setIcon:(UIImage*)image
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    mImageLayer.contents = (id)image.CGImage;
    [CATransaction commit];
    image=nil;
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    mImageLayer.hidden = selected ? YES:NO ;
    mImageLayer.borderColor = selected ? [UIColor colorWithRed:0.8 green:.0 blue:.0 alpha:1.0].CGColor:[UIColor colorWithRed:.0 green:.0 blue:.0 alpha:1.0].CGColor ;
    mCellTtleLabel.textColor = selected ?  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] :[UIColor colorWithRed:.0 green:.0 blue:.0 alpha:1.0] ;
    
     }

@end
