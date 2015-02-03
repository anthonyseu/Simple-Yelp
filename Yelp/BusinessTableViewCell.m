//
//  BusinessTableViewCell.m
//  Yelp
//
//  Created by Li Jiao on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "BusinessTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface BusinessTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@end

@implementation BusinessTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.thumbImageView.layer.cornerRadius = 3;
    self.thumbImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(Business *)business {
    _business = business;
    
    [self.thumbImageView setImageWithURL:[NSURL URLWithString:_business.imageUrl]];
    self.nameLabel.text = _business.name;
    [self.ratingImageView setImageWithURL:[NSURL URLWithString:_business.ratingImageUrl]];
    self.ratingLabel.text = [NSString stringWithFormat:@"%ld Reviews", _business.numReviews];
    self.addressLabel.text = _business.address;
    self.categoryLabel.text = _business.categories;
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", _business.distance];
    //    self.distanceLabel.text = [NSString stringWithFormat:@"%@mi", _business.distance];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}

@end
