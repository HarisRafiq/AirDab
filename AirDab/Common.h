//
//  Header.h
//  AirDab
//
//  Created by YAZ on 8/31/13.
//  Copyright (c) 2013 AirDab. All rights reserved.
//

#ifndef AirDab_Header_h
#define AirDab_Header_h



#endif
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height >= 568.0f)

 #define VISUALIZER_OFFSET_y 144
#define SONGS_VIEW_OFFSET 73
#define SONGS_VIEW_HEIGHT_OFFSET 252
#define SONGS_CELL_Y_OFFSET 242
#define circleTableViewHeight 254
#define circleTableViewWidth 310
#define circleTableViewYOffset 20
#define circleTableViewXOffset 5