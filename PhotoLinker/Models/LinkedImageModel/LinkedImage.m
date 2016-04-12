//
//  LinkedImageModel.m
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "LinkedImage.h"

NSString *const kImageName = @"imageName";
NSString *const kx = @"x";
NSString *const ky = @"y";

static NSString *const kLinksTo = @"linksTo";
static NSString *const kLinksFrom = @"linksFrom";
static NSString *const kName = @"name";
static NSString *const kNo = @"no";

CGFloat const kTagViewWidth = 50.0;
CGFloat const kTagViewHeight = 50.0;
CGFloat const kTagViewToOriginX = 25.0;
CGFloat const kTagViewToOriginY = 25.0;

@interface LinkedImage ()

@property (strong, nonatomic) NSMutableArray *linksTo;
@property (strong, nonatomic) NSMutableArray *linksFrom;

@property (strong, nonatomic) LinkedImage *nextImage;
@property (strong, nonatomic) LinkedImage *prevImage;
@property (strong, nonatomic) LinkedImage *homeImage;

@end

@implementation LinkedImage

#pragma mark - AddNewLinkMethods

- (void)addNewLinkWithImage:(LinkedImage *)image atPoint:(CGPoint)point
{
    NSMutableDictionary *linkAtPoint = [NSMutableDictionary dictionaryWithDictionary:@{kImageName   :   image.name,
                                                                                       kx           :   [NSNumber numberWithFloat: point.x],
                                                                                       ky           :   [NSNumber numberWithFloat: point.y]
                                                                                       }];
    
    if (!self.linksTo) {
        self.linksTo = [NSMutableArray new];
    }
    
    [self.linksTo addObject:linkAtPoint];
}

- (void)addNewLinkFromImage:(LinkedImage *)image
{
    if (!self.linksFrom) {
        self.linksFrom = [NSMutableArray new];
    }
    
    [self.linksFrom addObject:image.name];
}

#pragma mark - ChangeLinkMethod

- (NSString*)getOldLinkByIndex:(NSInteger)index andChangeToNewImage:(LinkedImage *)newImage
{
    NSMutableDictionary *currentLink = [self.linksTo objectAtIndex:index];
    
    NSString *currentLinkedImageName = [currentLink valueForKey:kImageName];

    [newImage addNewLinkFromImage:self];
    [currentLink setObject:newImage.name forKey:kImageName];
    
    return currentLinkedImageName;
}

#pragma mark - RemoveLinkMethods

- (void)removeLinkWithImage:(LinkedImage *)destinationImage byIndex:(NSInteger)index
{
    [self.linksTo removeObjectAtIndex:index];
    [destinationImage removeLinkFromByName:self.name];
}

- (void)removeLinkWithImage:(LinkedImage *)destinationImage
{
    NSMutableArray *objectsToRemove = [NSMutableArray new];
    
    for (NSDictionary *linkTo in self.linksTo) {
        NSString *name = [linkTo valueForKey:kImageName];
        
        if ([name isEqualToString:destinationImage.name]) {
            [objectsToRemove addObject:linkTo];
        }
    }
    
    [self.linksTo removeObjectsInArray:objectsToRemove];
}

- (void)removeLinkFromByName:(NSString *)imageName
{
    [self.linksFrom removeObject:imageName];
}

#pragma mark - NavigationMethods

- (NSString *)imageToGo:(NSInteger)index
{
    NSDictionary *imageToGo = [self.linksTo objectAtIndex:index];
    
    return [imageToGo valueForKey:kImageName];
}

- (void)resetNavigationInfo
{
    self.nextImage = nil;
    self.prevImage = nil;
    self.homeImage = nil;
}

#pragma mark - SaveRestoreMethods

- (NSDictionary *)getImageObjectInfoForSave {
    NSDictionary *info = @{kName        :   self.name,
                           kLinksTo     :   self.linksTo && [self.linksTo count] ? self.linksTo : kNo,
                           kLinksFrom   :   self.linksFrom && [self.linksFrom count] ? self.linksFrom : kNo};
    
    return info;
}

- (void)restoreImageObjectFromSavedInfo:(NSDictionary *)info
{
    self.name = [info valueForKey:kName];
    
    id linksToValue = [info valueForKey:kLinksTo];
    id linksFromValue = [info valueForKey:kLinksFrom];
    
    if (linksToValue && [linksToValue isKindOfClass:[NSArray class]]) {
        self.linksTo = [[NSMutableArray alloc] initWithArray:linksToValue];
    } else {
        self.linksTo = [[NSMutableArray alloc] init];
    }
    
    if (linksFromValue && [linksFromValue isKindOfClass:[NSArray class]]) {
        self.linksFrom = [[NSMutableArray alloc] initWithArray:linksFromValue];
    } else {
        self.linksFrom = [[NSMutableArray alloc] init];
    }
}

#pragma mark - Accessors

- (LinkedImage *)getNext
{
    return self.nextImage;
}

- (LinkedImage *)getPrev
{
    return self.prevImage;
}

- (LinkedImage *)getHomeImage
{
    return self.homeImage;
}

- (NSMutableArray *)getLinksFrom
{
    return self.linksFrom;
}

- (NSMutableArray *)links
{
    return self.linksTo;
}

- (NSInteger)numberOfLinks
{
    return [self.linksTo count];
}

#pragma mark - Mutators

- (void)setNext:(LinkedImage *)nextImage
{
    self.nextImage = nextImage;
}

- (void)setPrev:(LinkedImage *)prevImage
{
    self.prevImage = prevImage;
}

- (void)setHome:(LinkedImage *)homeImage
{
    self.homeImage = homeImage;
}

- (void)copyHomeImageFromImage:(LinkedImage *)image
{
    self.homeImage = [image getHomeImage];
}

@end
