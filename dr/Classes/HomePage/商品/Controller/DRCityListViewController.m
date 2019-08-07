//
//  DRCityListViewController.m
//  dr
//
//  Created by 毛文豪 on 2018/8/29.
//  Copyright © 2018年 JG. All rights reserved.
//

#import "DRCityListViewController.h"
#import "DRCityModel.h"
#import "UITableView+DRNoData.h"

@interface DRCityListViewController ()<UITableViewDelegate,UITableViewDataSource, UISearchControllerDelegate,  UISearchResultsUpdating, NSXMLParserDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray * cityArray;
@property (nonatomic, strong) NSMutableArray * titleArray;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray *searchList;//满足搜索条件的数组
@property (nonatomic, copy) NSString *currentElement;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *keyWord;

@end

@implementation DRCityListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"选择城市";
    [self setupChilds];
    [self getData];
}

#pragma mark - 解析数据
- (void)getData
{
    NSBundle *b = [NSBundle mainBundle];
    NSString *path = [b pathForResource:@"string_city" ofType:@".xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSXMLParser *par = [[NSXMLParser alloc]initWithData:data];
    par.delegate = self;
    [par parse];
}
    
#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    self.currentElement = elementName;
}
    
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([self.currentElement isEqualToString:@"item"]) {
        self.cityName = string;
    }
}
    
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    if ([elementName isEqualToString:@"item"]) {
        if (!DRStringIsEmpty(self.cityName)) {
            DRCityModel * cityModel = [[DRCityModel alloc] init];
            cityModel.cityName = self.cityName;
            NSMutableString *cityName_mu = [[NSMutableString alloc] initWithString:self.cityName];
            CFStringTransform((__bridge CFMutableStringRef)cityName_mu, 0, kCFStringTransformMandarinLatin, NO);
            CFStringTransform((__bridge CFMutableStringRef)cityName_mu, 0, kCFStringTransformStripDiacritics, NO);
            // bigStr 拼音转成大写
            NSString *bigStr = [cityName_mu uppercaseString];
            if (bigStr.length > 0) {
                cityModel.initial = [bigStr substringToIndex:1];
            }
            [self.cityArray addObject:cityModel];
        }
    }
}
    
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    [self.cityArray removeAllObjects];
}
    
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [self dealData];
}

#pragma mark - 处理数据
- (void)dealData
{
    [self.titleArray removeAllObjects];
    [self.dataArray removeAllObjects];
    
    if (!self.searchController.active || self.searchList.count == self.cityArray.count) {
        if (!DRStringIsEmpty(self.currentCityName)) {
            [self.titleArray addObject:@"当"];
            [self.dataArray addObject:@[self.currentCityName]];
        }
        [self.titleArray addObject:@"热"];
        [self.dataArray addObject:@[@"北京", @"上海", @"广州", @"深圳"]];
    }
    
    for (int i = 'A'; i <='Z'; i++) {
        NSMutableArray *subGroupArray = [NSMutableArray array];
        NSString *AZStirng = [NSString stringWithFormat:@"%c",i];
        [self.titleArray addObject:AZStirng];
        [self.dataArray addObject:subGroupArray];
    }
    
    NSMutableArray * cityNameArray = [NSMutableArray array];
    if (self.searchController.active) {
        cityNameArray = [NSMutableArray arrayWithArray:self.searchList];
    }else
    {
        cityNameArray = [NSMutableArray arrayWithArray:self.cityArray];
    }
    for (int i = 0; i < cityNameArray.count; i++) {
        DRCityModel * cityModel = cityNameArray[i];
        NSString *initial = cityModel.initial;
        if ([self.titleArray containsObject:initial]) {
            NSInteger index = [self.titleArray indexOfObject:initial];
            NSMutableArray *subGroupArray = self.dataArray[index];
            [subGroupArray addObject:cityModel.cityName];
        }
    }
    
    NSMutableIndexSet * emptySet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.dataArray.count; i++) {
        NSArray *subGroupArray = self.dataArray[i];
        if (subGroupArray.count == 0) {
            [emptySet addIndex:i];
        }
    }
    [self.dataArray removeObjectsAtIndexes:emptySet];
    [self.titleArray removeObjectsAtIndexes:emptySet];
    [self.tableView reloadData];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableView
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH - [DRTool getSafeAreaBottom])];
    self.tableView = tableView;
    tableView.backgroundColor = DRBackgroundColor;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 44;
    tableView.tableFooterView = [UIView new];
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
    
    //创建UISearchController
    UISearchController *searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController = searchController;
    searchController.searchResultsUpdater = self;
    searchController.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.obscuresBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    UITextField * searchTextField = [[[searchController.searchBar.subviews firstObject] subviews] lastObject];
    searchTextField.font = [UIFont systemFontOfSize:DRGetFontSize(30)];
    searchController.searchBar.placeholder = @"请输入城市名";
    searchController.searchBar.tintColor = DRDefaultColor;
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    } else {
        self.tableView.tableHeaderView = searchController.searchBar;
    }
}

- (void)cityListViewControllerChooseAddress:(NSString *)address
{
    if (_delegate && [_delegate respondsToSelector:@selector(cityListViewControllerChooseAddress:)]) {
        [_delegate cityListViewControllerChooseAddress:address];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchResultsUpdating
//每输入一个字符都会执行一次
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.keyWord = searchController.searchBar.text;
    if (!DRStringIsEmpty(self.keyWord)) {
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"cityName CONTAINS[c] %@", self.keyWord];
        self.searchList = [NSMutableArray arrayWithArray:[self.cityArray filteredArrayUsingPredicate:preicate]];
    }else
    {
        self.searchList = [NSMutableArray arrayWithArray:self.cityArray];
    }
    [self dealData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [tableView showNoDataWithTitle:@"" description:@"未搜到该城市" rowCount:self.dataArray.count];
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * subGroupArray = self.dataArray[section];
    return subGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CitySearchCellId"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CitySearchCellId"];
    }
    NSArray * subGroupArray = self.dataArray[indexPath.section];
    NSString * cityName = subGroupArray[indexPath.row];
    cell.textLabel.textColor = DRBlackTextColor;
    cell.textLabel.font = [UIFont systemFontOfSize:DRGetFontSize(31)];
    cell.textLabel.numberOfLines = 0;
    NSMutableAttributedString * cityNameAttStr = [[NSMutableAttributedString alloc] initWithString:cityName];
    if (!DRStringIsEmpty(self.keyWord) && self.searchController.active) {
        [cityNameAttStr addAttribute:NSForegroundColorAttributeName value:DRDefaultColor range:[cityName rangeOfString:self.keyWord]];
    }
    cell.textLabel.attributedText = cityNameAttStr;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenWidth - 20, 35)];
    titleLabel.font = [UIFont boldSystemFontOfSize:DRGetFontSize(34)];
    titleLabel.backgroundColor = DRBackgroundColor;
    titleLabel.textColor = DRBlackTextColor;
    NSString * title = self.titleArray[section];
    if ([title isEqualToString:@"当"]) {
        title = @"当前城市";
    }else if ([title isEqualToString:@"热"])
    {
        title = @"热门城市";
    }
    titleLabel.text = [NSString stringWithFormat:@"   %@", title];
    return titleLabel;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.titleArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(cityListViewControllerChooseAddress:)]) {
        NSArray * subGroupArray = self.dataArray[indexPath.section];
        NSString * cityName = subGroupArray[indexPath.row];
        [_delegate cityListViewControllerChooseAddress:cityName];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 初始化
- (NSMutableArray *)cityArray
{
    if (!_cityArray) {
        _cityArray = [NSMutableArray array];
    }
    return _cityArray;
}

- (NSMutableArray *)titleArray
{
    if (!_titleArray) {
        _titleArray = [NSMutableArray array];
    }
    return _titleArray;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)searchList
{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

@end
