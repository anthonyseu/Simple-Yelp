//
//  SwitchCell.h
//  Yelp
//
//  Created by Li Jiao on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwitchCell;
 
@protocol SwitchCellDelegate <NSObject>

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value;

@end

@interface SwitchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) id<SwitchCellDelegate> delegate;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) NSString *codeLabel;

-(void)setOn:(BOOL)on animated:(BOOL)animated;
@end
