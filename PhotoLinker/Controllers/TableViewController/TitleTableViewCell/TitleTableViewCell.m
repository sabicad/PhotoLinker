//
//  TitleTableViewCell.m
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "TitleTableViewCell.h"

@interface TitleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TitleTableViewCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

@end
