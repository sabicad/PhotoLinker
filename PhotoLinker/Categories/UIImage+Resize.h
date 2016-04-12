//
//  UIImage+Resize.h
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)scaleImage:(UIImage *)originalImage toSize:(CGSize)size;

@end
