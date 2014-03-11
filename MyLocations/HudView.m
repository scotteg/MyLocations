//
//  HudView.m
//  MyLocations
//
//  Created by Scott Gardner on 3/6/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "HudView.h"

@implementation HudView

+ (instancetype)hudInView:(UIView *)view animated:(BOOL)animated
{
  HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
  hudView.opaque = NO;
  [view addSubview:hudView];
  view.userInteractionEnabled = NO;
//  hudView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f];
  [hudView showAnimated:animated];
  return hudView;
}

- (void)drawRect:(CGRect)rect
{
  const CGFloat boxWidth = 96.0f;
  const CGFloat boxHeight = 96.0f;
  CGFloat midX = CGRectGetMidX(self.frame);
  CGFloat midY = CGRectGetMidY(self.frame);
  
//  CGRect boxRect = CGRectMake(
//                roundf(self.bounds.size.width - boxWidth) / 2.0f,
//                roundf(self.bounds.size.height - boxHeight) / 2.0f,
//                boxWidth,
//                boxHeight);
  
  CGRect boxRect = CGRectMake(
                midX - boxWidth / 2.0f,
                midY - boxHeight / 2.0f,
                boxWidth,
                boxHeight);
  
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:10.0f];
  [[UIColor colorWithWhite:0.3f alpha:0.8f] setFill];
  [roundedRect fill];
  
  UIImage *image = [UIImage imageNamed:@"Checkmark"];
  CGPoint imagePoint = CGPointMake(midX - roundf(image.size.width / 2.0f),
                   midY - roundf(image.size.height / 2.0f) - boxHeight / 8.0f);
  [image drawAtPoint:imagePoint];
  
  NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:16.0f],
                 NSForegroundColorAttributeName : [UIColor whiteColor]};
  CGSize textSize = [self.text sizeWithAttributes:attributes];
  CGPoint textPoint = CGPointMake(midX - roundf(textSize.width / 2.0f),
                  midY - roundf(textSize.height / 2.0f) + boxHeight / 4.0f);
  [self.text drawAtPoint:textPoint withAttributes:attributes];
}

- (void)showAnimated:(BOOL)animated
{
  if (animated) {
    self.alpha = 0.0f;
    self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
    [UIView animateWithDuration:0.3 animations:^{
      self.alpha = 1.0f;
      self.transform = CGAffineTransformIdentity;
    }];
  }
}

@end
