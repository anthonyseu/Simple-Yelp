//
//  FiltersViewController.m
//  Yelp
//
//  Created by Li Jiao on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController ()
@property (strong, nonatomic) IBOutlet UITableView *filtersTableView;
@end

@implementation FiltersViewController
NSArray *categoryOptions;
NSArray *distanceOptions;
NSArray *sortByOptions;

NSDictionary *categoryOptionsMap;
NSDictionary *distanceOptionsMap;
NSDictionary *sortByOptionsMap;

NSMutableSet *selectedCategories;
NSMutableArray *selectedDistanceOption;
NSMutableArray *selectedSortByOption;

BOOL categorySectionIsExpanded;
BOOL distanceSectionIsExpanded;
BOOL sortSectionIsExpanded;
BOOL dealSelected;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    
    self.filtersTableView.dataSource =self;
    self.filtersTableView.delegate = self;
    self.filtersTableView.rowHeight = UITableViewAutomaticDimension;
    
    UINib *movieCellNib = [UINib nibWithNibName:@"SwitchCell" bundle:nil];
    [self.filtersTableView registerNib:movieCellNib forCellReuseIdentifier:@"SwitchCell"];
    
    
    [self initCategories];
    [self initDistances];
    [self initSort];
    self.title = @"Filters";
    selectedCategories = [[NSMutableSet alloc] init];
    [self populateSelectedFilters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - switchcell methods
-(void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    if ([[cell.titleLabel text] isEqualToString:@"Deals"]) {
        dealSelected = value;
    } else {
        if (value && cell.codeLabel) {
            [selectedCategories addObject:cell.codeLabel];
        } else {
            [selectedCategories removeObject:cell.codeLabel];
        }
    }
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        if (distanceSectionIsExpanded) {
            return [distanceOptions count];
        } else {
            return [selectedDistanceOption count];
        }

    } else if (section == 2) {
        if (sortSectionIsExpanded) {
            return [sortByOptions count];
        } else {
            return [selectedSortByOption count];
        }
    } else if (section == 3) {
        if (categorySectionIsExpanded) {
            return [categoryOptions count];
        } else {
            return 4;
        }
    }
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 0;
    }
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *string;
    if (section == 0) {
        string = @"Deals";
    } else if (section == 1) {
        string = @"Distance";
    } else if (section == 2) {
        string = @"Sort By";
    } else {
        string = @"Categories";
    }
    return string;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (distanceSectionIsExpanded) {
            selectedDistanceOption[0] = [distanceOptions[indexPath.row] mutableCopy];
        }
        distanceSectionIsExpanded = !distanceSectionIsExpanded;
        [self.filtersTableView reloadData];
    } else if (indexPath.section == 2) {
        if (sortSectionIsExpanded) {
            selectedSortByOption[0] = [sortByOptions[indexPath.row] mutableCopy];
        }
        sortSectionIsExpanded = ! sortSectionIsExpanded;
        [self.filtersTableView reloadData];
    } else if (indexPath.section == 3) {
        if (!categorySectionIsExpanded && indexPath.row == 3) {
            categorySectionIsExpanded = YES;
            [self.filtersTableView reloadData];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        cell.titleLabel.text = @"Deals";
        cell.delegate = self;
        [cell setOn:dealSelected animated:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        if (distanceSectionIsExpanded) {
            cell.textLabel.text = distanceOptions[indexPath.row][@"name"];
        } else {
            cell.textLabel.text = selectedDistanceOption[indexPath.row][@"name"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        if (sortSectionIsExpanded) {
            cell.textLabel.text = sortByOptions[indexPath.row][@"name"];
        } else {
            cell.textLabel.text = selectedSortByOption[indexPath.row][@"name"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 3) {
        if (categorySectionIsExpanded || indexPath.row <3) {
            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
            cell.titleLabel.text = categoryOptions[indexPath.row][@"name"];
            NSString *codeString = categoryOptions[indexPath.row][@"code"];
            BOOL on = [selectedCategories containsObject:codeString];
            [cell setOn:on animated:YES];
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.codeLabel = codeString;
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.text = @"See more";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - private methods
- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    self.filters = [self collectSelectedFilters];
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)collectSelectedFilters {
    NSMutableDictionary *filters = [[NSMutableDictionary alloc] init];
    if (selectedCategories.count > 0) {
        NSMutableArray *codeStringArray = [[selectedCategories allObjects] mutableCopy];
        NSString *categoryFilter = [codeStringArray componentsJoinedByString:@","];
        [filters setValue:categoryFilter forKey:@"category_filter"];
    }
    if (selectedDistanceOption.count > 0) {
        [filters setValue:selectedDistanceOption[0][@"code"] forKey:@"radius_filter"];
    }
    if (selectedSortByOption.count > 0) {
        [filters setValue:selectedSortByOption[0][@"code"] forKey:@"sort"];
    }
    if (dealSelected) {
        [filters setValue: @"true" forKey:@"deal"];
    } else {
        [filters setValue: @"false" forKey:@"deal"];
    }
    return filters;
}

- (void) populateSelectedFilters {
    if ([self.filters valueForKey:@"deal"]) {
        NSString *deal = [self.filters valueForKey:@"deal"];
        if ([deal isEqualToString:@"true"]) {
            dealSelected = YES;
        } else {
            dealSelected = NO;
        }
    }
    
    if ([self.filters valueForKey:@"category_filter"]) {
        NSString *temp = [self.filters valueForKey:@"category_filter"];
        NSArray *temp2 = [temp componentsSeparatedByString:@","];
        selectedCategories = [NSMutableSet setWithArray:temp2];
    }
    
    if ([self.filters valueForKey:@"sort"]) {
        NSString *codeString = [self.filters valueForKey:@"sort"];
        NSString *name = sortByOptionsMap[codeString];
        selectedSortByOption[0] = @{@"name": name,
                                    @"code": codeString
                                    };
    }
    
    if ([self.filters valueForKey:@"radius_filter"]) {
        NSString *codeString = [self.filters valueForKey:@"radius_filter"];
        NSString *name = distanceOptionsMap[codeString];
        selectedDistanceOption[0] = @{@"name": name,
                                      @"code": codeString};
    }
}

- (void)initSort
{
    selectedSortByOption = [@[@{@"name" : @"Best matched", @"code": @"0"}] mutableCopy];
    sortByOptions = @[
              @{@"name" : @"Best matched", @"code": @"0"},
              @{@"name" : @"Distance", @"code": @"1"},
              @{@"name" : @"Highest Rated", @"code": @"2"},
              ];
    sortByOptionsMap = @{@"0": @"Best matched",
                           @"1" : @"Distance",
                           @"2" : @"Highest Rated"
                           };
    
}
- (void)initDistances
{
    selectedDistanceOption = [@[@{@"name" : @"Auto", @"code": @"1000"}] mutableCopy];
    distanceOptions = @[@{@"name" : @"Auto", @"code": @"1000"},
                   @{@"name" : @"0.3 miles", @"code": @"300" },
                   @{@"name" : @"0.6 miles", @"code": @"600" },
                   @{@"name" : @"1 mile", @"code": @"1000" },
                   @{@"name" : @"5 miles", @"code": @"5000" },
                   @{@"name" : @"10 miles", @"code": @"10000" },
                   ];
    distanceOptionsMap = @{@"1000": @"Auto",
                           @"300" : @"0.3 miles",
                           @"600" : @"0.6 miles",
                           @"1000" : @"1 mile",
                           @"5000" : @"5 miles",
                           @"10000" : @"10 miles",
                           };
}

- (void)initCategories
{
    categoryOptions = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                        @{@"name" : @"African", @"code": @"african" },
                        @{@"name" : @"American, New", @"code": @"newamerican" },
                        @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                        @{@"name" : @"Arabian", @"code": @"arabian" },
                        @{@"name" : @"Argentine", @"code": @"argentine" },
                        @{@"name" : @"Armenian", @"code": @"armenian" },
                        @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                        @{@"name" : @"Asturian", @"code": @"asturian" },
                        @{@"name" : @"Australian", @"code": @"australian" },
                        @{@"name" : @"Austrian", @"code": @"austrian" },
                        @{@"name" : @"Baguettes", @"code": @"baguettes" },
                        @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                        @{@"name" : @"Barbeque", @"code": @"bbq" },
                        @{@"name" : @"Basque", @"code": @"basque" },
                        @{@"name" : @"Bavarian", @"code": @"bavarian" },
                        @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                        @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                        @{@"name" : @"Beisl", @"code": @"beisl" },
                        @{@"name" : @"Belgian", @"code": @"belgian" },
                        @{@"name" : @"Bistros", @"code": @"bistros" },
                        @{@"name" : @"Black Sea", @"code": @"blacksea" },
                        @{@"name" : @"Brasseries", @"code": @"brasseries" },
                        @{@"name" : @"Brazilian", @"code": @"brazilian" },
                        @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                        @{@"name" : @"British", @"code": @"british" },
                        @{@"name" : @"Buffets", @"code": @"buffets" },
                        @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                        @{@"name" : @"Burgers", @"code": @"burgers" },
                        @{@"name" : @"Burmese", @"code": @"burmese" },
                        @{@"name" : @"Cafes", @"code": @"cafes" },
                        @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                        @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                        @{@"name" : @"Cambodian", @"code": @"cambodian" },
                        @{@"name" : @"Canadian", @"code": @"New)" },
                        @{@"name" : @"Canteen", @"code": @"canteen" },
                        @{@"name" : @"Caribbean", @"code": @"caribbean" },
                        @{@"name" : @"Catalan", @"code": @"catalan" },
                        @{@"name" : @"Chech", @"code": @"chech" },
                        @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                        @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                        @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                        @{@"name" : @"Chilean", @"code": @"chilean" },
                        @{@"name" : @"Chinese", @"code": @"chinese" },
                        @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                        @{@"name" : @"Corsican", @"code": @"corsican" },
                        @{@"name" : @"Creperies", @"code": @"creperies" },
                        @{@"name" : @"Cuban", @"code": @"cuban" },
                        @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                        @{@"name" : @"Cypriot", @"code": @"cypriot" },
                        @{@"name" : @"Czech", @"code": @"czech" },
                        @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                        @{@"name" : @"Danish", @"code": @"danish" },
                        @{@"name" : @"Delis", @"code": @"delis" },
                        @{@"name" : @"Diners", @"code": @"diners" },
                        @{@"name" : @"Dumplings", @"code": @"dumplings" },
                        @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                        @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                        @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                        @{@"name" : @"Filipino", @"code": @"filipino" },
                        @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                        @{@"name" : @"Fondue", @"code": @"fondue" },
                        @{@"name" : @"Food Court", @"code": @"food_court" },
                        @{@"name" : @"Food Stands", @"code": @"foodstands" },
                        @{@"name" : @"French", @"code": @"french" },
                        @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                        @{@"name" : @"Galician", @"code": @"galician" },
                        @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                        @{@"name" : @"Georgian", @"code": @"georgian" },
                        @{@"name" : @"German", @"code": @"german" },
                        @{@"name" : @"Giblets", @"code": @"giblets" },
                        @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                        @{@"name" : @"Greek", @"code": @"greek" },
                        @{@"name" : @"Halal", @"code": @"halal" },
                        @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                        @{@"name" : @"Heuriger", @"code": @"heuriger" },
                        @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                        @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                        @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                        @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                        @{@"name" : @"Hungarian", @"code": @"hungarian" },
                        @{@"name" : @"Iberian", @"code": @"iberian" },
                        @{@"name" : @"Indian", @"code": @"indpak" },
                        @{@"name" : @"Indonesian", @"code": @"indonesian" },
                        @{@"name" : @"International", @"code": @"international" },
                        @{@"name" : @"Irish", @"code": @"irish" },
                        @{@"name" : @"Island Pub", @"code": @"island_pub" },
                        @{@"name" : @"Israeli", @"code": @"israeli" },
                        @{@"name" : @"Italian", @"code": @"italian" },
                        @{@"name" : @"Japanese", @"code": @"japanese" },
                        @{@"name" : @"Jewish", @"code": @"jewish" },
                        @{@"name" : @"Kebab", @"code": @"kebab" },
                        @{@"name" : @"Korean", @"code": @"korean" },
                        @{@"name" : @"Kosher", @"code": @"kosher" },
                        @{@"name" : @"Kurdish", @"code": @"kurdish" },
                        @{@"name" : @"Laos", @"code": @"laos" },
                        @{@"name" : @"Laotian", @"code": @"laotian" },
                        @{@"name" : @"Latin American", @"code": @"latin" },
                        @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                        @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                        @{@"name" : @"Malaysian", @"code": @"malaysian" },
                        @{@"name" : @"Meatballs", @"code": @"meatballs" },
                        @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                        @{@"name" : @"Mexican", @"code": @"mexican" },
                        @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                        @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                        @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                        @{@"name" : @"Modern European", @"code": @"modern_european" },
                        @{@"name" : @"Mongolian", @"code": @"mongolian" },
                        @{@"name" : @"Moroccan", @"code": @"moroccan" },
                        @{@"name" : @"New Zealand", @"code": @"newzealand" },
                        @{@"name" : @"Night Food", @"code": @"nightfood" },
                        @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                        @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                        @{@"name" : @"Oriental", @"code": @"oriental" },
                        @{@"name" : @"Pakistani", @"code": @"pakistani" },
                        @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                        @{@"name" : @"Parma", @"code": @"parma" },
                        @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                        @{@"name" : @"Peruvian", @"code": @"peruvian" },
                        @{@"name" : @"Pita", @"code": @"pita" },
                        @{@"name" : @"Pizza", @"code": @"pizza" },
                        @{@"name" : @"Polish", @"code": @"polish" },
                        @{@"name" : @"Portuguese", @"code": @"portuguese" },
                        @{@"name" : @"Potatoes", @"code": @"potatoes" },
                        @{@"name" : @"Poutineries", @"code": @"poutineries" },
                        @{@"name" : @"Pub Food", @"code": @"pubfood" },
                        @{@"name" : @"Rice", @"code": @"riceshop" },
                        @{@"name" : @"Romanian", @"code": @"romanian" },
                        @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                        @{@"name" : @"Rumanian", @"code": @"rumanian" },
                        @{@"name" : @"Russian", @"code": @"russian" },
                        @{@"name" : @"Salad", @"code": @"salad" },
                        @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                        @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                        @{@"name" : @"Scottish", @"code": @"scottish" },
                        @{@"name" : @"Seafood", @"code": @"seafood" },
                        @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                        @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                        @{@"name" : @"Singaporean", @"code": @"singaporean" },
                        @{@"name" : @"Slovakian", @"code": @"slovakian" },
                        @{@"name" : @"Soul Food", @"code": @"soulfood" },
                        @{@"name" : @"Soup", @"code": @"soup" },
                        @{@"name" : @"Southern", @"code": @"southern" },
                        @{@"name" : @"Spanish", @"code": @"spanish" },
                        @{@"name" : @"Steakhouses", @"code": @"steak" },
                        @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                        @{@"name" : @"Swabian", @"code": @"swabian" },
                        @{@"name" : @"Swedish", @"code": @"swedish" },
                        @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                        @{@"name" : @"Tabernas", @"code": @"tabernas" },
                        @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                        @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                        @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                        @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                        @{@"name" : @"Thai", @"code": @"thai" },
                        @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                        @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                        @{@"name" : @"Trattorie", @"code": @"trattorie" },
                        @{@"name" : @"Turkish", @"code": @"turkish" },
                        @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                        @{@"name" : @"Uzbek", @"code": @"uzbek" },
                        @{@"name" : @"Vegan", @"code": @"vegan" },
                        @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                        @{@"name" : @"Venison", @"code": @"venison" },
                        @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                        @{@"name" : @"Wok", @"code": @"wok" },
                        @{@"name" : @"Wraps", @"code": @"wraps" },
                        @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
    
}

@end
