//
//  GalleryModel.m
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "Gallery.h"
#import "LinkedImage.h"

static NSString *const kName = @"name";
static NSString *const kItems = @"items";

@interface Gallery ()

@end

@implementation Gallery

- (NSDictionary *)getGalleryInfoForSave
{
    NSMutableArray *items = [NSMutableArray new];
    
    for (LinkedImage *image in self.linkedImages) {
        NSDictionary *imageInfo = [image getImageObjectInfoForSave];
        [items addObject:imageInfo];
    }
    
    NSDictionary *info = @{kName    :   self.galleryName,
                           kItems   :   items};
    
    return info;
}

- (void)setGalleryInfoFromSaved:(NSDictionary *)info
{
    self.linkedImages = [NSMutableArray new];
    self.galleryName = [info valueForKey:kName];
    
    NSArray *items = [info valueForKey:kItems];
    
    for (NSDictionary *itemInfo in items) {
        
        LinkedImage *image = [[LinkedImage alloc]init];
        
        [image restoreImageObjectFromSavedInfo:itemInfo];
        
        [self.linkedImages addObject:image];
    }
}

@end



