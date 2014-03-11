//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Scott Gardner on 3/5/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"
#import "NSMutableString+AddText.h"

@interface LocationDetailsViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation LocationDetailsViewController
{
  NSString *_descriptionText;
  NSString *_categoryName;
  NSDate *_date;
  UIImage *_image;
  UIActionSheet *_actionSheet;
  UIImagePickerController *_imagePicker;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    _descriptionText = @"";
    _categoryName = @"No Category";
    _date = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.tableView.backgroundColor = [UIColor blackColor];
  self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
  self.descriptionTextView.textColor = [UIColor whiteColor];
  self.descriptionTextView.backgroundColor = [UIColor blackColor];
  self.photoLabel.textColor = [UIColor whiteColor];
  self.photoLabel.highlightedTextColor = self.photoLabel.textColor;
  self.addressLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
  
  if (self.locationToEdit) {
    self.title = @"Edit Location";
    
    if ([self.locationToEdit hasPhoto]) {
      UIImage *existingImage = [self.locationToEdit photoImage];
      
      if (existingImage) {
        [self showImage:existingImage];
      }
    }
  }
  
  self.descriptionTextView.text = _descriptionText;
  self.categoryLabel.text = @"";
  self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.latitude];
  self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", self.coordinate.longitude];
  
  if (self.placemark) {
    self.addressLabel.text = [self stringFromPlacemark:self.placemark];
  } else {
    self.addressLabel.text = @"No Address Found";
  }
  
  self.dateLabel.text = [self formatDate:_date];
  
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
  tapGestureRecognizer.cancelsTouchesInView = NO;
  [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"PickCategory"]) {
    CategoryPickerViewController *controller = segue.destinationViewController;
    controller.selectedCategoryName = _categoryName;
  }
}

- (void)applicationDidEnterBackground
{
  if (_imagePicker) {
    [self dismissViewControllerAnimated:NO completion:nil];
    _imagePicker = nil;
  }
  
  if (_actionSheet) {
    [_actionSheet dismissWithClickedButtonIndex:_actionSheet.cancelButtonIndex animated:NO];
    _actionSheet = nil;
  }
  
  [self.descriptionTextView resignFirstResponder];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setLocationToEdit:(Location *)locationToEdit
{
  if (_locationToEdit != locationToEdit) {
    _locationToEdit = locationToEdit;
    _descriptionText = locationToEdit.locationDescription;
    _categoryName = locationToEdit.category;
    _date = locationToEdit.date;
    self.coordinate = CLLocationCoordinate2DMake([locationToEdit.latitude doubleValue], [locationToEdit.longitude doubleValue]);
    self.placemark = locationToEdit.placemark;
  }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
  NSMutableString *line = [NSMutableString stringWithCapacity:100];
  
  [line addText:placemark.subThoroughfare withSeparator:@""];
  [line addText:placemark.thoroughfare withSeparator:@" "];
  [line addText:placemark.locality withSeparator:@", "];
  [line addText:placemark.administrativeArea withSeparator:@", "];
  [line addText:placemark.postalCode withSeparator:@", "];
  
  return line;
}

- (void)addText:(NSString *)text toLine:(NSMutableString *)line withSeparator:(NSString *)separator
{
  if (text) {
    if ([line length]) {
      [line appendString:separator];
    }
    
    [line appendString:text];
  }
}

- (NSString *)formatDate:(NSDate *)date
{
  static NSDateFormatter *formatter;
  
  if (!formatter) {
    formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
  }
  
  return [formatter stringFromDate:date];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tapGestureRecognizer
{
//  [self.view endEditing:YES];
  
  CGPoint point = [tapGestureRecognizer locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
  
  if (indexPath && indexPath.section == 0 && indexPath.row == 0) {
    return;
  }
  
  [self.descriptionTextView resignFirstResponder];
}

- (IBAction)done:(id)sender
{
  HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
  
  Location *location;
  
  if (self.locationToEdit) {
    hudView.text = @"Updated";
    location = self.locationToEdit;
  } else {
    hudView.text = @"Tagged";
    location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    location.photoId = @(-1);
  }
  
  location.locationDescription = _descriptionText;
  location.category = _categoryName;
  location.latitude = @(self.coordinate.latitude);
  location.longitude = @(self.coordinate.longitude);
  location.date = _date;
  location.placemark = self.placemark;
  
  if (_image) {
    if (![location hasPhoto]) {
      location.photoId = @([Location nextPhotoId]);
    }
    
    NSData *data = UIImageJPEGRepresentation(_image, 0.5f);
    NSError *error;
    
    if (![data writeToFile:[location photoPath] options:NSDataWritingAtomic error:&error]) {
      NSLog(@"Error writing file: %@", error);
    }
  }
  
  NSError *error;
  
  if (![self.managedObjectContext save:&error]) {
    FATAL_CORE_DATA_ERROR(error);
    return;
  }
  
  [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}

- (IBAction)cancel:(id)sender
{
  [self closeScreen];
}

- (void)closeScreen
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue
{
  CategoryPickerViewController *controller = segue.sourceViewController;
  _categoryName = controller.selectedCategoryName;
  self.categoryLabel.text = _categoryName;
}

- (void)takePhoto
{
  _imagePicker = [UIImagePickerController new];
  _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
  _imagePicker.delegate = self;
  _imagePicker.allowsEditing = YES;
  _imagePicker.view.tintColor = self.view.tintColor;
  [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary
{
  _imagePicker = [UIImagePickerController new];
  _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  _imagePicker.delegate = self;
  _imagePicker.allowsEditing = YES;
  _imagePicker.view.tintColor = self.view.tintColor;
  [self presentViewController:_imagePicker animated:YES completion:nil];
}

- (void)showPhotoMenu
{
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    [_actionSheet showInView:self.view];
  } else {
    [self choosePhotoFromLibrary];
  }
}

- (void)showImage:(UIImage *)image
{
  self.imageView.image = image;
  self.imageView.hidden = NO;
  CGFloat adjustedHeight = image.size.height * ((CGRectGetWidth(self.tableView.frame) - 50.0f) / image.size.width);
  self.imageView.frame = CGRectMake(10.0f, 10.0f, 260.0f, adjustedHeight);
  self.photoLabel.hidden = YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
    return 88.0f;
  } else if (indexPath.section == 1) {
    if (self.imageView.hidden || !self.imageView.image) {
      return 44.0f;
    } else {
//      return 280.0f;
      return CGRectGetHeight(self.imageView.frame) + 20.0f;
    }
  } else if (indexPath.section == 2 && indexPath.row == 2) {
    CGRect rect = CGRectMake(100.0f, 10.0f, 205.0f, 10000.0f);
    self.addressLabel.frame = rect;
    [self.addressLabel sizeToFit];
    rect.size.height = self.addressLabel.frame.size.height;
    self.addressLabel.frame = rect;
    return  self.addressLabel.frame.size.height + 20.0f;
  } else {
    return 44.0f;
  }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 || indexPath.section == 1) {
    return indexPath;
  } else {
    return nil;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0) {
    [self.descriptionTextView becomeFirstResponder];
  } else if (indexPath.section == 1 && indexPath.row == 0) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showPhotoMenu];
  }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
  _descriptionText = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
  _descriptionText = [textView.text stringByReplacingCharactersInRange:range withString:text];
  return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  cell.backgroundColor = [UIColor blackColor];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
  cell.detailTextLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
  cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
  UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
  selectionView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
  cell.selectedBackgroundView = selectionView;
  
  if (indexPath.row == 2) {
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:100];
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.highlightedTextColor = addressLabel.textColor;
  }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  _image = info[UIImagePickerControllerEditedImage];
  [self showImage:_image];
  [self.tableView reloadData];
  [self dismissViewControllerAnimated:YES completion:nil];
  _imagePicker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:nil];
  _imagePicker = nil;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 0) {
    [self takePhoto];
  } else if (buttonIndex == 1) {
    [self choosePhotoFromLibrary];
  }
  
  _actionSheet = nil;
}

@end
