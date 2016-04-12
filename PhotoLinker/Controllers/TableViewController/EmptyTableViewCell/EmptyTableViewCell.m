//
//  EmptyTableViewCell.m
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "EmptyTableViewCell.h"

@implementation EmptyTableViewCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.layer.masksToBounds = NO;
    self.separatorInset = UIEdgeInsetsMake(0.f, self.bounds.size.width, 0.f, 0.f);
}


@end
