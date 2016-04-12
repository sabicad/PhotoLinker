//
//  GalleryCollectionViewCell.m
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "GalleryCollectionViewCell.h"

@interface GalleryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GalleryCollectionViewCell

- (void)prepareForReuse
{
    self.imageView.image = [UIImage imageNamed:@"plus"];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

@end
