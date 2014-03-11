//
//  MapViewController.m
//  MyLocations
//
//  Created by Scott Gardner on 3/10/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "LocationDetailsViewController.h"

@interface MapViewController () <MKMapViewDelegate, UIBarPositioningDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController
{
  NSArray *_locations;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:self.managedObjectContext];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self updateLocations];
  
  if ([_locations count]) {
    [self showLocations:nil];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;
    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    UIButton *button = (UIButton *)sender;
    Location *location = _locations[button.tag];
    controller.locationToEdit = location;
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)showLocations:(id)sender
{
  MKCoordinateRegion region = [self regionForAnnotations:_locations];
  [self.mapView setRegion:region animated:YES];
}

- (IBAction)showUser:(id)sender
{
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000.0, 1000.0);
  [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations
{
  MKCoordinateRegion region;
  
  if ([annotations count] == 0) {
    region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000.0, 1000.0);
  } else if ([annotations count] == 1) {
    id <MKAnnotation> annotation = [annotations lastObject];
    region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000.0, 1000.0);
  } else {
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90.0;
    topLeftCoord.longitude = 180.0;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90.0;
    bottomRightCoord.longitude = -180.0;
    
    for (id <MKAnnotation> annotation in annotations) {
      topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
      topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
      bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
      bottomRightCoord.longitude = fmax(topLeftCoord.longitude, annotation.coordinate.longitude);
    }
    
    const double extraSpace = 1.1;
    
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2.0;
    region.center.longitude = topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2.0;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace;
    region.span.longitudeDelta = fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace;
  }
  
  return [self.mapView regionThatFits:region];
}

- (void)updateLocations
{
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [NSFetchRequest new];
  [fetchRequest setEntity:entity];
  
  // Could use NSFetchedResultsController instead of fetching manually
  NSError *error;
  NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  if (!foundObjects) {
    FATAL_CORE_DATA_ERROR(error);
    return;
  }
  
  if (_locations) {
    [self.mapView removeAnnotations:_locations];
  }
  
  _locations = foundObjects;
  [self.mapView addAnnotations:_locations];
}

- (void)showLocationDetails:(UIButton *)button
{
  [self performSegueWithIdentifier:@"EditLocation" sender:button];
}

- (void)contextDidChange:(NSNotification *)notification
{
  if ([self isViewLoaded]) {
//    [self updateLocations];
    
    id <MKAnnotation> annotation;
    
    if ([self.managedObjectContext.insertedObjects count]) {
      annotation = [self.managedObjectContext.insertedObjects anyObject];
    } else if ([self.managedObjectContext.updatedObjects count]) {
      annotation = [self.managedObjectContext.updatedObjects anyObject];
    }
    
    [self.mapView removeAnnotation:annotation];
    [self.mapView addAnnotation:annotation];
    
    if ([self.managedObjectContext.deletedObjects count]) {
      annotation = [self.managedObjectContext.deletedObjects anyObject];
      [self.mapView removeAnnotation:annotation];
    }
  }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  if ([annotation isKindOfClass:[Location class]]) {
    static NSString *identifier = @"Location";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
      annotationView.enabled = YES;
      annotationView.canShowCallout = YES;
      annotationView.animatesDrop = NO;
      annotationView.pinColor = MKPinAnnotationColorGreen;
      annotationView.tintColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
      UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
      [rightButton addTarget:self action:@selector(showLocationDetails:) forControlEvents:UIControlEventTouchUpInside];
      annotationView.rightCalloutAccessoryView = rightButton;
    } else {
      annotationView.annotation = annotation;
    }
    
    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    button.tag = [_locations indexOfObject:(Location *)annotation];
    return annotationView;
  }
  
  return nil;
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
  return UIBarPositionTopAttached;
}

@end
