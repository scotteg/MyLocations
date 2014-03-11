//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Scott Gardner on 3/10/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "LocationDetailsViewController.h"
#import "UIImage+Resize.h"
#import "NSMutableString+AddText.h"

@interface LocationsViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation LocationsViewController
//{
//  NSFetchedResultsController *_fetchedResultsController;
//}

- (NSFetchedResultsController *)fetchedResultsController
{
  if (!_fetchedResultsController) {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
    
    [fetchRequest setFetchBatchSize:20];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"Locations"];
    _fetchedResultsController.delegate = self;
  }
  
  return _fetchedResultsController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
  
  // Handle iOS 7 bug
  [NSFetchedResultsController deleteCacheWithName:@"Locations"];
  
  [self performFetch];
}

- (void)dealloc
{
  _fetchedResultsController.delegate = nil;
}

- (void)performFetch
{
  NSError *error;
  
  if (![self.fetchedResultsController performFetch:&error]) {
    FATAL_CORE_DATA_ERROR(error);
    return;
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  LocationCell *locationCell = (LocationCell *)cell;
  Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  locationCell.descriptionLabel.text = [location.locationDescription length] ? location.locationDescription : @"(No Description)";
  
  if (location.placemark) {
    NSMutableString *string = [NSMutableString stringWithCapacity:100];
    [string addText:location.placemark.subThoroughfare withSeparator:@""];
    [string addText:location.placemark.thoroughfare withSeparator:@" "];
    [string addText:location.placemark.locality withSeparator:@", "];
    
    locationCell.addressLabel.text = string;
  } else {
    locationCell.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f, Long: %.8f", [location.latitude doubleValue], [location.longitude doubleValue]];
  }
  
  UIImage *image;
  
  if (([location hasPhoto])) {
    image = [location photoImage];
    if (image) {
      image = [image resizedImageWithBounds:CGSizeMake(52.0f, 52.0f)];
    }
  } else {
    image = [UIImage imageNamed:@"No Photo"];
  }
  
  locationCell.photoImageView.image = image;
  locationCell.backgroundColor = [UIColor blackColor];
  locationCell.descriptionLabel.textColor = [UIColor whiteColor];
  locationCell.descriptionLabel.highlightedTextColor = locationCell.descriptionLabel.textColor;
  locationCell.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  locationCell.addressLabel.highlightedTextColor = locationCell.addressLabel.textColor;
  
  // Because there is no selectionColor property
  UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
  selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
  locationCell.selectedBackgroundView = selectionView;
  
  locationCell.photoImageView.layer.cornerRadius = CGRectGetWidth(locationCell.photoImageView.bounds) / 2.0f;
  locationCell.photoImageView.clipsToBounds = YES;
  locationCell.separatorInset = UIEdgeInsetsMake(0.0f, 82.0f, 0.0f, 0.0f);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;
    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    controller.locationToEdit = location;
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [[[self.fetchedResultsController sections][section] name] uppercaseString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [location removePhotoFile];
    [self.managedObjectContext deleteObject:location];
    NSError *error;
    
    if (![self.managedObjectContext save:&error]) {
      FATAL_CORE_DATA_ERROR(error);
      return;
    }
  }
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 14.0f, 300.0f, 14.0f)];
  label.font = [UIFont boldSystemFontOfSize:11.0f];
  label.text = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
  label.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  label.backgroundColor = [UIColor clearColor];
  
  UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(15.0f, tableView.sectionHeaderHeight - 0.5f, CGRectGetWidth(tableView.bounds) - 15.0f, 0.5f)];
  separator.backgroundColor = tableView.separatorColor;
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), tableView.sectionHeaderHeight)];
  view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.85f];
  [view addSubview:label];
  [view addSubview:separator];
  
  return view;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  NSLog(@"*** %s", __PRETTY_FUNCTION__);
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
  switch (type) {
    case NSFetchedResultsChangeInsert:
      NSLog(@"*** NSFetchedResultsChangeInsert (object)");
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      NSLog(@"*** NSFetchedResultsChangeDelete (object)");
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeMove:
      NSLog(@"*** NSFetchedResultsChangeMove (object)");
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:
      NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
      [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  switch (type) {
    case NSFetchedResultsChangeInsert:
      NSLog(@"*** NSFetchedResultsChangeInsert (section)");
      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      NSLog(@"*** NSFetchedResultsChangeInsert (section)");
      [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  NSLog(@"*** %s", __PRETTY_FUNCTION__);
  [self.tableView endUpdates];
}

@end
