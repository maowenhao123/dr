//
//  DRGrouponSearchViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/10/24.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRGrouponSearchViewController.h"
#import "DRCollectionTextView.h"
#import "DRSearchTool.h"
#import "DRTitleView.h"
#import "DRGrouponSearchView.h"

@interface DRGrouponSearchViewController ()<UISearchBarDelegate, CollectionTextViewDelegate>

@property (nonatomic,weak) UISearchBar * searchBar;
@property (nonatomic,weak) UIView * searchView;
@property (nonatomic,weak) DRCollectionTextView * hotTextView;
@property (nonatomic,weak) UIView * historyView;
@property (nonatomic,weak) DRCollectionTextView * historyTextView;
@property (nonatomic,weak) DRGrouponSearchView *grouponSearchView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation DRGrouponSearchViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 取出appearance对象
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setShadowImage:[UIImage new]];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.searchBar.isFirstResponder) {
        [self.searchBar becomeFirstResponder];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 取出appearance对象
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setShadowImage:nil];
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChildViews];
}

- (void)setupChildViews
{
    //search
    DRTitleView *titleView = [[DRTitleView alloc] init];
    titleView.x = 40;
    titleView.width = screenWidth - 60;
    titleView.height = 33;
    titleView.y = (navBarH - titleView.height) / 2;
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:titleView.bounds];
    self.searchBar = searchBar;
    searchBar.backgroundImage = [UIImage ImageFromColor:[UIColor clearColor] WithRect:searchBar.bounds ];
    searchBar.delegate = self;
    searchBar.placeholder = @"商品名称";
    searchBar.tintColor = DRDefaultColor;
    searchBar.backgroundImage = [UIImage new];
    UITextField * searchTextField = nil;
    if (iOS13) {
        searchTextField = (UITextField *)[DRTool findViewWithClassName:@"UITextField" inView:_searchBar];
    }else
    {
        searchTextField = [_searchBar valueForKey:@"_searchField"];
    }
    if (!DRObjectIsEmpty(searchTextField)) {
        searchTextField.backgroundColor = DRColor(242, 242, 242, 1);
        searchTextField.textColor = DRBlackTextColor;
        searchTextField.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    }
    [titleView addSubview:searchBar];
    self.navigationItem.titleView = titleView;
    
    //搜索页面
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.searchView = searchView;
    [self.view addSubview:searchView];
    
    //历史搜索
    UIView * historyView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, screenWidth, 30)];
    self.historyView = historyView;
    [searchView addSubview:historyView];
    
    UILabel * historyTitleLabel = [[UILabel alloc] init];
    historyTitleLabel.text = @"我搜过";
    historyTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    historyTitleLabel.textColor = DRBlackTextColor;
    CGSize historyTitleLabelSize = [historyTitleLabel.text sizeWithLabelFont:historyTitleLabel.font];
    historyTitleLabel.frame = CGRectMake(DRMargin, 0, historyTitleLabelSize.width, historyTitleLabelSize.height);
    [historyView addSubview:historyTitleLabel];
    
    CGFloat deleteButtonWH = 18;
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(screenWidth - DRMargin - deleteButtonWH, 0, deleteButtonWH, deleteButtonWH);
    deleteButton.centerY = historyTitleLabel.centerY;
    [deleteButton setImage:[UIImage imageNamed:@"delete_search_history_icon"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [historyView addSubview:deleteButton];
    
    DRCollectionTextView * historyTextView = [[DRCollectionTextView alloc] init];
    self.historyTextView = historyTextView;
    historyTextView.delegate = self;
    historyTextView.textFont = [UIFont systemFontOfSize:DRGetFontSize(26)];
    historyTextView.texts = [DRSearchTool getGroupHistoryData];
    historyTextView.frame = CGRectMake(0, CGRectGetMaxY(historyTitleLabel.frame) + 15, screenWidth, [historyTextView getViewHeight]);
    [historyView addSubview:historyTextView];
    
    historyView.height = CGRectGetMaxX(historyTextView.frame);
    
    //团购搜索
    DRGrouponSearchView * grouponSearchView = [[DRGrouponSearchView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.grouponSearchView = grouponSearchView;
    grouponSearchView.hidden = YES;
    [self.view addSubview:grouponSearchView];
    
    [self addSetDeadlineTimer];
}
- (void)deleteButtonDidClick
{
    [DRSearchTool deleteGroupHistoryData];
    self.historyTextView.texts = [DRSearchTool getGroupHistoryData];
    self.historyTextView.height = [self.historyTextView getViewHeight];
    self.historyView.height = CGRectGetMaxX(self.historyTextView.frame);
}
- (void)collectionTextViewButtonDidClick:(UIButton *)button
{
    [self searchWithKeyword:button.currentTitle];
    self.searchBar.text = button.currentTitle;
    [self.searchBar resignFirstResponder];
}

#pragma mark - 倒计时
- (void)addSetDeadlineTimer
{
    if(self.timer == nil)//空才创建
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)setTimeLabelText
{
    [self.grouponSearchView.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchView.hidden = NO;
    self.grouponSearchView.hidden = YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchWithKeyword:searchBar.text];
}
- (void)searchWithKeyword:(NSString *)keyword
{
    if (DRStringIsEmpty(keyword)) {
        return;
    }
    
    //储存搜索关键字
    [DRSearchTool addGroupKeyWord:keyword];
    self.historyTextView.texts = [DRSearchTool getGroupHistoryData];
    self.historyTextView.height = [self.historyTextView getViewHeight];
    self.historyView.height = CGRectGetMaxX(self.historyTextView.frame);
    
    self.searchView.hidden = YES;
    self.grouponSearchView.hidden = NO;
    [self.grouponSearchView searchGrouponWithKeyword:keyword];
}

@end
