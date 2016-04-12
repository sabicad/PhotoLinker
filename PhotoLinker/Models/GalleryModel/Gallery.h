//
//  GalleryModel.h
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gallery : NSObject

@property (strong, nonatomic) NSString *galleryName;
@property (strong, nonatomic) NSMutableArray *linkedImages;

- (NSDictionary *)getGalleryInfoForSave;
- (void)setGalleryInfoFromSaved:(NSDictionary *)info;

@end
