//
//  LinkedImageModel.h
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const kImageName;
extern NSString *const kx;
extern NSString *const ky;
extern CGFloat const kTagViewWidth;
extern CGFloat const kTagViewHeight;
extern CGFloat const kTagViewToOriginX;
extern CGFloat const kTagViewToOriginY;

@interface LinkedImage : NSObject

@property (strong, nonatomic) NSString *name;

- (void)addNewLinkWithImage:(LinkedImage *)image atPoint:(CGPoint)point;
- (void)addNewLinkFromImage:(LinkedImage *)image;

- (NSString*)getOldLinkByIndex:(NSInteger)index andChangeToNewImage:(LinkedImage *)newImage;

- (void)removeLinkWithImage:(LinkedImage *)destinationImage byIndex:(NSInteger)index;
- (void)removeLinkWithImage:(LinkedImage *)destinationImage;

- (void)removeLinkFromByName:(NSString *)imageName;

- (NSDictionary *)getImageObjectInfoForSave;
- (void)restoreImageObjectFromSavedInfo:(NSDictionary *)info;
- (NSInteger)numberOfLinks;
- (NSMutableArray *)links;
- (NSMutableArray *)getLinksFrom;
- (NSString *)imageToGo:(NSInteger)index;

- (LinkedImage *)getNext;
- (LinkedImage *)getPrev;
- (LinkedImage *)getHomeImage;
- (void)setNext:(LinkedImage *)nextImage;
- (void)setPrev:(LinkedImage *)prevImage;
- (void)setHome:(LinkedImage *)homeImage;
- (void)copyHomeImageFromImage:(LinkedImage *)image;
- (void)resetNavigationInfo;


@end
