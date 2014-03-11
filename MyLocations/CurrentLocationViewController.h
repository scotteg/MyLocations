//
//  CurrentLocationViewController.h
//  MyLocations
//
//  Created by Scott Gardner on 3/3/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
