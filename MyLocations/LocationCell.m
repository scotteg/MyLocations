//
//  LocationCell.m
//  MyLocations
//
//  Created by Scott Gardner on 3/10/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
