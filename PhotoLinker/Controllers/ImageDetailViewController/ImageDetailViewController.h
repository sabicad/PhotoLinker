//
//  ImageDetailViewController.h
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinkedImage.h"

typedef NS_ENUM(NSInteger, ImageState) {
    ImageStateView,
    ImageStateEdit
};

@protocol ImageDetailViewControllerProtocol <NSObject>

- (void)imageDetailViewControllerWillGoBack;
- (void)imageDetailViewControllerSaveActionAndCGPoint:(CGPoint)point;
- (LinkedImage *)getLinkedImageModelByName:(NSString *)name;
- (void)imageDetailViewControllerChangedImageTo:(LinkedImage *)image;
- (void)imageDetailViewControllerChangeLinkOfImage:(LinkedImage *)image andViewTag:(NSInteger)tag;
- (void)imageDetailViewControllerResetNavigationInfo;

@end

@interface ImageDetailViewController : UIViewController

@property (strong, nonatomic) id<ImageDetailViewControllerProtocol> delegate;
@property (strong, nonatomic) LinkedImage *linkedImage;
@property (assign, nonatomic) ImageState imageState;
@property (assign, nonatomic) CGPoint currentPosition;

@end
