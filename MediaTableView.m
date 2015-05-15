//
//  MediaTableView.m
//  IMMedia
//
//  Created by YAZ on 4/16/13.
//  Copyright (c) 2013 IMPlayer. All rights reserved.
//
static NSString *CellIdentifier = @"Cell";

#import "MediaTableView.h"
#import "CircleCell.h"
#import "ViewController.h"
 #import "AudioPlayer.h"
#import "CustomFooterView.h"
 @implementation MediaTableView
 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
      [self setUp];
    return self;
}
 
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setUp{
    
   
    [self viewForFooterInSection:CGRectMake(self.bounds.origin.x+5  ,self.bounds.origin.y, self.bounds.size.width-10   ,self.bounds.size.height
                                            ) ];
     NSLog(@"height:%f,width:%f,originx:%f:originy:%f:",self.bounds.size.height,self.bounds.size.width, self.bounds.origin.x  , self.bounds.origin.y );
 
        // Create the shape layer and set its path
            // Set the newly created shape layer as the mask for the view's layer
    //[self.layer addSublayer:maskLayer];
          isVideoSessionActive=NO;
     tView=[[CircleTableView alloc] initWithFrame:CGRectMake(0,self.bounds.origin.x+5, self.bounds.size.height, self.bounds.size.width-10
                                                             )]; 
    tView.delegate=self;
    tView.dataSource=self;
    tView.separatorStyle = UITableViewCellSeparatorStyleNone;
   tView.opaque=YES;
    tView.showsHorizontalScrollIndicator=NO;
    tView.showsVerticalScrollIndicator=NO;
    CGAffineTransform rotateImage = CGAffineTransformMakeRotation(-M_PI_2);
    tView.transform = rotateImage;
    [tView setFrame:CGRectMake(self.bounds.origin.x+5 ,0, self.bounds.size.width-10  , self.bounds.size.height
                                    )];
    [tView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor] ];
 
    [self addSubview:tView];
    tView.scrollEnabled=YES;
    
    
    
     [self setupBottomView];
    [self setupLeftAndRightLabels];
     //[self setupLeftView];
 //[self setupTitleLabel];
    //[self setupDurationLabel];
   

   }
-(CircleTableView *)tView{
    return tView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        if(indexPath.row<[[AudioPlayer sharedInstance] artistsArray].count)
    {MPMediaItem *temp = [[[AudioPlayer sharedInstance] artistsArray] objectAtIndex:indexPath.row];
                 
        MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
        
        UIImage *finalImage=[artWork imageWithSize:CGSizeMake(5, 5)] ;
        [self.delegate addSongsViewWithArtist:[temp valueForProperty:MPMediaItemPropertyArtist] AtIndex:indexPath.row isLocal:NO AndImage:finalImage]  ;
         
    
    }
        else {
            [self.delegate addSongsViewWithArtist:@"LOCAL" AtIndex:indexPath.row isLocal:YES AndImage:nil]  ;
            
        
        
        }
    
}

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
  
    return  [[[AudioPlayer sharedInstance] artistsArray] count]+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        CircleCell *cell = (CircleCell*)[tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( !cell )
    {
        cell = [[CircleCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        //We grab the MPMediaItem at the nth indexPath.row corresponding to the current section (or letter/number)
       
        
    }
        if(indexPath.row>=[[AudioPlayer sharedInstance] artistsArray].count )
        {
            [cell setCellTitle:@"LOCAL"];
            UIImage *finalImage=[UIImage imageNamed:@"drive.png"];
           
            UIGraphicsBeginImageContext(finalImage.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
                trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, finalImage.size.height));
                CGContextConcatCTM(ctx, trnsfrm);
                CGContextBeginPath(ctx);
                CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, finalImage.size.width, finalImage.size.height));
                CGContextClip(ctx);
                CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, finalImage.size.width, finalImage.size.height), finalImage.CGImage);
                finalImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
 [cell setIcon:finalImage];
            finalImage=nil;
        }
        else{
            MPMediaItem *temp = [[[AudioPlayer sharedInstance] artistsArray] objectAtIndex:indexPath.row];
            //Title the current cell with the Album artist
            MPMediaItemArtwork *artWork = [temp valueForProperty:MPMediaItemPropertyArtwork];
          
            UIImage *finalImage=[artWork imageWithSize:CGSizeMake(5, 5)] ;
            if(finalImage==nil){
                
                finalImage=[UIImage imageNamed:@"wave-white.png"];
                
            }
            UIGraphicsBeginImageContext(finalImage.size);
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
                trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, finalImage.size.height));
                CGContextConcatCTM(ctx, trnsfrm);
                CGContextBeginPath(ctx);
                CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, finalImage.size.width, finalImage.size.height));
                CGContextClip(ctx);
                CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, finalImage.size.width, finalImage.size.height), finalImage.CGImage);
               
                finalImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            
            [cell setIcon:finalImage ]  ;
            [cell setCellTitle:[temp valueForProperty:MPMediaItemPropertyArtist]];
            finalImage=nil;
            temp=nil;
            artWork=nil;
        }
        return cell;
    
    
     }

 

- (void)teardown
{
    for (UIView *subview in [tView subviews]){
        [subview removeFromSuperview];
    }
   
   bottomView=nil;
     bottomButton=nil;

    self.delegate=nil;
    tView=nil;
          
}

-(void)setupBottomView{
   
    bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-(75/2),self.bounds.size.height-140, 75 , 75 )];
    UIImageView *myImageView = [[UIImageView alloc] initWithFrame: CGRectMake(2.5,2.5, 70, 70)];
    [myImageView setContentMode:UIViewContentModeScaleAspectFit];
    myImageView.image = [UIImage imageNamed: @"logored.png"];
    myImageView.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
 
    bottomButton.layer.borderWidth=2;
    bottomButton.layer.cornerRadius=75/2;
     bottomButton.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    bottomButton.layer.backgroundColor=[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    [bottomButton addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomButton addSubview:myImageView];
    [self addSubview:bottomButton];
    myImageView=nil;
    bottomButton=nil;
    
}
 
-(void)reloadTableFromDelegate {
        
}
-(void)reloadTable {
    
    [tView reloadData];
    
    
}
 




-(void)nextTrack{
    [self.delegate playNextTrack];


}


-(void)callAction{
    
    
     [self.delegate call];
}
-(CGFloat) heightForFooterInSection:(NSInteger)section
{
    return self.bounds.size.width-(([[[AudioPlayer sharedInstance] artistsArray] count]+1)*tView.rowHeight);
}

- (void)  viewForFooterInSection:(CGRect)rect
{
     UIView* custom= [[CustomFooterView alloc] initWithFrame:rect];
    [self addSubview:custom];
    custom=nil;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
 [self setleftLabel:nil AndrightLabel:nil];

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self setleftLabel:nil AndrightLabel:nil];
}
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGPoint currentOffset = scrollView.contentOffset;
    if( [[AudioPlayer sharedInstance] artistsArray].count >  [[tView indexPathForCell:[tView.visibleCells lastObject]] row]   )
    {
        
        
        
        
        MPMediaItem *temp = [[[AudioPlayer sharedInstance] artistsArray] objectAtIndex:[[tView indexPathForCell:[tView.visibleCells firstObject]] row]];
        NSString *first=[temp valueForProperty:MPMediaItemPropertyArtist];
        temp=[[[AudioPlayer sharedInstance] artistsArray] objectAtIndex:[[tView indexPathForCell:[tView.visibleCells lastObject]] row]];
        NSString *last=[temp valueForProperty:MPMediaItemPropertyArtist];
        [self setleftLabel:first AndrightLabel:last];
        temp=nil;
        
    }
    
    if (currentOffset.y > self.lastContentOffset.y)
    {
        
    }
    else
    {
        
    }
    self.lastContentOffset = currentOffset;
}
-(void)setupLeftAndRightLabels{
    _leftLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-210,self.bounds.size.width/4,30)];
    _rightLabel=[[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.width/4, self.bounds.size.height-210,self.bounds.size.width/4,30)];
    _rightLabel.textColor=_leftLabel.textColor =  [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0] ;
    [_leftLabel setBackgroundColor:[UIColor clearColor]];
    [_rightLabel setBackgroundColor:[UIColor clearColor]];
    _leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    _leftLabel.textAlignment=NSTextAlignmentCenter;
    _rightLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    _rightLabel.textAlignment=NSTextAlignmentCenter;
    
    [self insertSubview:_rightLabel aboveSubview:tView];
    [self insertSubview:_leftLabel aboveSubview:tView];
    
}
-(void)setleftLabel:(NSString *)left AndrightLabel:(NSString *)right {
    
    
    if(![[left substringToIndex:1] isEqualToString:firstLetter]){
        firstLetter=[left substringToIndex:1];
        [_leftLabel setText:firstLetter ];
        
    }
    
    if(![[right substringToIndex:1] isEqualToString:lastLetter]){
        lastLetter=[right substringToIndex:1];
        [_rightLabel setText:lastLetter ];
        
        
        
    }
    left=nil;
    right=nil;
} @end
