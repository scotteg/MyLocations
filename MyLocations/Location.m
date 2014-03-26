//
//  Location.m
//  MyLocations
//
//  Created by Scott Gardner on 3/10/14.
//  Copyright (c) 2014 Optimac, Inc. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;
@dynamic photoId;

#pragma mark - MKAnnotation

+ (NSInteger)nextPhotoId
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSInteger photoId = [defaults integerForKey:@"PhotoID"];
  [defaults setInteger:photoId++ forKey:@"PhotoID"];
  [defaults synchronize];
  return photoId;
}

- (CLLocationCoordinate2D)coordinate
{
  return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
  if ([self.locationDescription length]) {
    return self.locationDescription;
  } else {
    return @"(No Description)";
  }
}

- (NSString *)subtitle
{
  return self.category;
}

- (BOOL)hasPhoto
{
  return (self.photoId && [self.photoId integerValue] != -1);
}

- (NSString *)documentsDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [[paths lastObject] stringByAppendingString:@"/"];
  return documentsDirectory;
}

- (NSString *)photoPath
{
  NSString *fileName = [NSString stringWithFormat:@"Photo-%d.jpg", [self.photoId integerValue]];
  return [[self documentsDirectory] stringByAppendingString:fileName];
}

- (UIImage *)photoImage
{
  NSAssert(self.photoId, @"No photo ID set");
  NSAssert([self.photoId integerValue] != -1, @"Photo ID is -1");
  return [UIImage imageWithContentsOfFile:[self photoPath]];
}

- (void)removePhotoFile
{
  NSString *path = [self photoPath];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if ([fileManager fileExistsAtPath:path]) {
    NSError *error;
    
    if (![fileManager removeItemAtPath:path error:&error]) {
      NSLog(@"Error removing file: %@", error);
    }
  }
}

@end
