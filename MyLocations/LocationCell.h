//
//  LocationCell.h
//  MyLocations
//
//  Created by Scott Gardner on 3/10/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end
