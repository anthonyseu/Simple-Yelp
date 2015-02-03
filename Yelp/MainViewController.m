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
#import <GoogleMaps/GoogleMaps.h>

NSString * const kYelpConsumerKey = @"MsQLkzNGnLYvBguKVlqfjg";
NSString * const kYelpConsumerSecret = @"pqndfKbxKpSQf0wsUEtPlQmbJcg";
NSString * const kYelpToken = @"AQTVTZDs_79O3JD0sFabhreRmTXEhbFp";
NSString * const kYelpTokenSecret = @"m4lhCutcobTOtr8QElzkf7NkOZo";
NSString * const defaultSearchTerm = @"Restaurant";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *businessTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSDictionary *filters;
@property (nonatomic) BOOL showingMap;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;
@end


@implementation MainViewController
GMSMapView *mapView_;

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
    // search bar setting
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.tintColor = [UIColor blackColor];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.774866
                                                            longitude:-122.394556
                                                                 zoom:13];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
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

- (void)onMapButton
{
    if (self.showingMap) {
        // flip back to the list
        [UIView transitionFromView:self.mapView
                            toView:self.businessTableView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionShowHideTransitionViews
                        completion:nil];
        self.navigationItem.rightBarButtonItem.title = @"Map";
        self.showingMap = NO;
    } else {
        // flip to the map
        [self addMarker];
        [UIView transitionFromView:self.businessTableView
                            toView:self.mapView
                          duration:1.0
                           options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionShowHideTransitionViews
                        completion:nil];
        self.navigationItem.rightBarButtonItem.title = @"List";
        self.showingMap = YES;
    }
}

- (void)addMarker {
    for (Business *business in self.businesses) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(business.latitude, business.longitude);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = [UIImage imageNamed:@"flag_icon"];
        marker.map = self.mapView;
        marker.title = business.name;
    }
}

- (void)onFilterButton {
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
