//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Scott Gardner on 3/5/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

@class Location;

@interface LocationDetailsViewController : UITableViewController

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) CLPlacemark *placemark;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Location *locationToEdit;

@end
