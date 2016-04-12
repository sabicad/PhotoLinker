//
//  GalleryViewController.h
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GalleryViewControllerProtocol <NSObject>

- (void)galleryViewControllerWillGoBack:(NSArray *)array;
- (void)galleryViewControllerUpdatedArray:(NSArray *)array;

@end

typedef NS_ENUM(NSInteger, GalleryState) {
    GalleryStateSelect,
    GalleryStateView,
    GalleryStateEdit,
    GalleryStateChange,
    GalleryStateBackToImage
};

@interface GalleryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) id<GalleryViewControllerProtocol> delegate;
@property (strong, nonatomic) NSMutableArray *linkedImages;
@property (assign, nonatomic) GalleryState galleryState;
@property (assign, nonatomic) NSInteger galeryIndex;

@end
