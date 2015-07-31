//
//  PersistencyManager.m
//  Instagram
//
//  Created by MS on 7/30/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//

#define PLIST_DIR @"/Library/Caches/UserID.plist"

#import "PersistencyManager.h"
#import <Foundation/Foundation.h>
#import "Photo.h"
#import "Constants.h"
#import "Errors.h"

@interface PersistencyManager ()
@property (nonatomic) NSInteger currentUserOffset;
@property (strong, nonatomic) NSString *currentUserID;

@end

@implementation PersistencyManager

- (id)init
{
    self = [super init];
    if (self) {
        self.currentUserOffset = 0;
        self.currentUserID = @"";
        
    }
    return self;
}

//if user changed, make offset equal zero
- (void)setCurrentUserID:(NSString *)currentUserID
{
    if (_currentUserID != currentUserID) {
        self.currentUserOffset = 0;
        _currentUserID = currentUserID;
    }
}

- (void)getNextPortionOfImageAndCommentsOfUserID: (NSString *)userID
                                       onSuccess: (void (^) (NSArray *result)) success //array of model
                                       onFailure: (void (^) (NSError *error)) failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *filename = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@.bin", userID];
        NSData *photosData = [NSData dataWithContentsOfFile:filename];
        NSMutableArray *existingPhotos = [[NSKeyedUnarchiver unarchiveObjectWithData:photosData] mutableCopy];
        
        NSMutableArray *portion = [NSMutableArray array];
        for (int i = self.currentUserOffset; (i < [existingPhotos count]) && (i < self.currentUserOffset + PORTION); i++) {
            [portion addObject:existingPhotos[i]];
        }
        
        
        self.currentUserOffset += [portion count];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([portion count] == 0) {
                NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSNoMorePhotos userInfo:nil];
                failure(error);
                
            } else {
                success(portion);
            }
        });
    });
    
        
    

}

- (void)savePhotos: (NSArray *)photos ofUserID: (NSString *)userID
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *filename = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@.bin", userID];
        NSError *error = nil;
        NSData *existingPhotosData = [NSData dataWithContentsOfFile:filename options:0 error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        NSMutableArray *existingPhotos = [[NSKeyedUnarchiver unarchiveObjectWithData:existingPhotosData] mutableCopy];
        if (existingPhotos == nil) {
            existingPhotos = [NSMutableArray array];
        }
        NSArray *mergedArray = [self mergeArray:existingPhotos withArray: photos];
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:mergedArray];
        [newData writeToFile:filename atomically:YES];
    });
}

- (NSArray *)mergeArray:(NSArray *)arr1 withArray: (NSArray *)arr2
{
    NSMutableArray *newArray = [NSMutableArray array];
    NSMutableArray *arr1arr2 = [NSMutableArray arrayWithArray:arr1];
    [arr1arr2 addObjectsFromArray:arr2];
    
    for (Photo *photo in arr1arr2) {
        NSUInteger index = [newArray indexOfObject:photo
                                     inSortedRange:(NSRange){0, [newArray count]}
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^NSComparisonResult(id obj1, id obj2) {
            Photo *photo1 = (Photo *)obj1;
            Photo *photo2 = (Photo *)obj2;
            if (photo1.creationTime > photo2.creationTime) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (photo1.creationTime < photo2.creationTime) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        
        [newArray insertObject:photo atIndex:index];
    }

    //remove duplicates
    NSMutableArray* uniqueValues = [[NSMutableArray alloc] init];
    for(Photo *photo in newArray)
    {
        BOOL add = YES;
        for (Photo *uniquePhoto in uniqueValues) {
            if ([photo.photoId isEqualToString:uniquePhoto.photoId]) {
                add = NO;
                break;
            }
        }
        if (add) {
            [uniqueValues addObject:photo];
        }
    }
    return uniqueValues;
}


- (void)saveImage:(UIImage*)image filename:(NSString*)filename
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fullPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@", filename];
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:fullPath atomically:YES];
    });
}

- (void)getImageByFilename: (NSString *)filename
                 onSuccess: (void (^) (UIImage *image)) success
                 onFailure: (void (^) (NSError *error)) failure;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *fullPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/%@", filename];
        NSData *data = [NSData dataWithContentsOfFile:fullPath];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!image) {
                NSError *error = [NSError errorWithDomain:MSErrorDomain code:MSImageNotFound userInfo:nil];
                failure(error);
            } else {
                success(image);
            }
        });
    });
}

- (NSString *)getUserIDOfLogin: (NSString *)login
{
    NSString *plistFile = [NSHomeDirectory() stringByAppendingString:PLIST_DIR];
    NSDictionary *usersDict = [NSDictionary dictionaryWithContentsOfFile:plistFile];
    NSString *userId = nil;
    if (login) {
        userId = [usersDict objectForKey:login];
    }
    
    return userId;
}

- (void)saveUserID:(NSString *)userID ofLogin:(NSString *)login
{
    NSString *plistFile = [NSHomeDirectory() stringByAppendingString:PLIST_DIR];
    NSMutableDictionary *usersDict = [[NSDictionary dictionaryWithContentsOfFile:plistFile] mutableCopy];
    if (usersDict == nil) {
        usersDict = [NSMutableDictionary dictionary];
    }
    if (login) {
        [usersDict setObject:userID forKey:login];
    }
    [usersDict writeToFile:plistFile atomically:YES];
}

@end
