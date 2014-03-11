//
//  MyTabBarController.m
//  MyLocations
//
//  Created by Scott Gardner on 3/11/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
  return nil;
}

@end
