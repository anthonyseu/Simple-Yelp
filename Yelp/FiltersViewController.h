//
//  FiltersViewController.h
//  Yelp
//
//  Created by Li Jiao on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchCell.h"

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>
-(void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters;
@end

@interface FiltersViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, SwitchCellDelegate>
@property (nonatomic, weak) id<FiltersViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *filters;
@end
