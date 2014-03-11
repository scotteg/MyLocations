//
//  NSMutableString+AddText.m
//  MyLocations
//
//  Created by Scott Gardner on 3/11/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator
{
  if (text) {
    if ([self length]) {
      [self appendString:separator];
    }
    
    [self appendString:text];
  }
}

@end
