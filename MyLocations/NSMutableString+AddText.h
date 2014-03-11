//
//  NSMutableString+AddText.h
//  MyLocations
//
//  Created by Scott Gardner on 3/11/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator;

@end
