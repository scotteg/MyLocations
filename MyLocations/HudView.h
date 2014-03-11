//
//  HudView.h
//  MyLocations
//
//  Created by Scott Gardner on 3/6/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated;

@property (strong, nonatomic) NSString *text;

@end
