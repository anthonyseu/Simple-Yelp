//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessTableViewCell.h"
#import "FiltersViewController.h"
#import "MBProgressHUD.h"

NSString * const kYelpConsumerKey = @"MsQLkzNGnLYvBguKVlqfjg";
NSString * const kYelpConsumerSecret = @"pqndfKbxKpSQf0wsUEtPlQmbJcg";
NSString * const kYelpToken = @"AQTVTZDs_79O3JD0sFabhreRmTXEhbFp";
NSString * const kYelpTokenSecret = @"m4lhCutcobTOtr8QElzkf7NkOZo";
NSString * const defaultSearchTerm = @"Restaurant";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSDictionary *filters;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
@end


@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self fetchBusinessesWithQuery:defaultSearchTerm params:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // table view setting
    self.businessTableView.dataSource = self;
    self.businessTableView.delegate = self;
    [self.businessTableView registerNib:[UINib nibWithNibName:@"BusinessTableViewCell" bundle:nil] forCellReuseIdentifier:@"BusinessTableViewCell"];
    self.businessTableView.rowHeight = UITableViewAutomaticDimension;
    
    // filter button setting
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    // search bar setting
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = [UIColor blackColor];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Searchbar methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // hide keyboard
    [searchBar resignFirstResponder];
    NSString *query = searchBar.text;
    [self fetchBusinessesWithQuery:query params:self.filters];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""] || searchText==nil){
        [self fetchBusinessesWithQuery:defaultSearchTerm params:self.filters];
        return;
    }
}

#pragma mark - table view methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.businessTableView deselectRowAtIndexPath:indexPath animated:YES];
    BusinessTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessTableViewCell"];
    cell.business = self.businesses[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark - private methods
- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    self.filters = filters;
    [self fetchBusinessesWithQuery:defaultSearchTerm params:filters];
}

- (void)onFilterButton
{
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    if (self.filters) {
        vc.filters = self.filters;
    }
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        self.businesses = [Business businessesDictionaries:businessDictionaries];
        [self.businessTableView reloadData];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}
@end
