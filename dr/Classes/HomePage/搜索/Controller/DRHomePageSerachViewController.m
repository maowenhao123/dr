//
//  DRHomePageSerachViewController.m
//  dr
//
//  Created by 毛文豪 on 2017/5/25.
//  Copyright © 2017年 JG. All rights reserved.
//

#import "DRHomePageSerachViewController.h"
#import "DRGoodListViewController.h"
#import "DRShopListViewController.h"
#import "DRCollectionTextView.h"
#import "DRMenuView.h"
#import "UIButton+DR.h"
#import "DRSearchTool.h"

@interface DRHomePageSerachViewController ()<UISearchBarDelegate, CollectionTextViewDelegate, MenuViewDelegate>

@property (nonatomic,weak) UIView *searchView;
@property (nonatomic, weak) UISearchBar * searchBar;
@property (nonatomic,strong) UIButton * sortbutton;
@property (nonatomic,weak) DRCollectionTextView * hotTextView;//热搜
@property (nonatomic,weak) UIView * historyView;
@property (nonatomic,weak) DRCollectionTextView * historyTextView;
@property (nonatomic,assign) NSInteger type;//1 商品 2 店铺

@end

@implementation DRHomePageSerachViewController

#pragma mark - 控制器的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.type = 1;//默认宝贝　
    [self getHotData];
    [self setupChildViews];
}

- (void)getHotData
{
    //type 1 商品 2 店铺
    NSDictionary *bodyDic = @{
                              @"type":@(self.type),
                              };
    
    NSDictionary *headDic = @{
                              @"cmd":@"P14",
                              };
    [[DRHttpTool shareInstance] postWithHeadDic:headDic bodyDic:bodyDic success:^(id json) {
        DRLog(@"%@",json);
        if (SUCCESS) {
            self.hotTextView.texts = json[@"list"];
            self.hotTextView.height = [self.hotTextView getViewHeight];
            self.historyView.y = CGRectGetMaxY(self.hotTextView.frame) + 15;
        }
    } failure:^(NSError *error) {
        DRLog(@"error:%@",error);
    }];
}
- (void)setupChildViews
{
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, statusBarH, 40, navBarH);
    [backButton setImage:[UIImage imageNamed:@"black_back_bar"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backButton.frame), statusBarH + 5, screenWidth - CGRectGetMaxX(backButton.frame), 34)];
    self.searchBar = searchBar;
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
    searchBar.placeholder = @"多肉、店铺";
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
    
    //分类按钮
    UIButton * sortbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sortbutton = sortbutton;
    if (!iOS13) {
        sortbutton.frame = CGRectMake(0, 0, 50, searchBar.height);
        UITextField * searchTextField = [searchBar valueForKey:@"_searchField"];
        searchTextField.leftView = sortbutton;
        searchTextField.leftViewMode = UITextFieldViewModeAlways;
    }else
    {
         sortbutton.frame = CGRectMake(12, 0, 40, searchBar.height);
         [searchBar setPositionAdjustment:UIOffsetMake(CGRectGetMaxX(sortbutton.frame) + 3, 0) forSearchBarIcon:UISearchBarIconSearch];
         [searchBar addSubview:sortbutton];
    }
    [sortbutton setTitle:@"宝贝" forState:UIControlStateNormal];
    [sortbutton setTitleColor:DRBlackTextColor forState:UIControlStateNormal];
    sortbutton.titleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(26)];
    [sortbutton setImage:[UIImage imageNamed:@"search_sort_triangle"] forState:UIControlStateNormal];
    [sortbutton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentRight imgTextDistance:3];
    [sortbutton addTarget:self action:@selector(sortButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBar];
    
    //搜索页面
    UIView * searchView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarH + navBarH, screenWidth, screenHeight - statusBarH - navBarH)];
    self.searchView = searchView;
    [self.view addSubview:searchView];
    
    //热搜
    UILabel * hotTopTitleLabel = [[UILabel alloc] init];
    hotTopTitleLabel.text = @"大家都在搜";
    hotTopTitleLabel.font = [UIFont systemFontOfSize:DRGetFontSize(28)];
    hotTopTitleLabel.textColor = DRBlackTextColor;
    CGSize hotTopTitleLabelSize = [hotTopTitleLabel.text sizeWithLabelFont:hotTopTitleLabel.font];
    hotTopTitleLabel.frame = CGRectMake(DRMargin, 10, hotTopTitleLabelSize.width, hotTopTitleLabelSize.height);
    [searchView addSubview:hotTopTitleLabel];
    
    DRCollectionTextView * hotTextView = [[DRCollectionTextView alloc] init];
    self.hotTextView = hotTextView;
    hotTextView.textFont = [UIFont systemFontOfSize:DRGetFontSize(26)];
    hotTextView.delegate = self;
    hotTextView.frame = CGRectMake(0, CGRectGetMaxY(hotTopTitleLabel.frame) + 15, screenWidth, [hotTextView getViewHeight]);
    [searchView addSubview:hotTextView];
    
    //历史搜索
    UIView * historyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hotTextView.frame) + 15, screenWidth, 30)];
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
    historyTextView.texts = [DRSearchTool getGoodHistoryData];
    historyTextView.frame = CGRectMake(0, CGRectGetMaxY(historyTitleLabel.frame) + 15, screenWidth, [historyTextView getViewHeight]);
    [historyView addSubview:historyTextView];
    
    historyView.height = CGRectGetMaxX(historyTextView.frame);
    
    if (!DRStringIsEmpty(self.keyWord)) {
        searchBar.text = self.keyWord;
        [self searchWithKeyword:searchBar.text];
    }
}

- (void)back
{
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)sortButtonDidClick
{
    DRMenuView * menuView = [[DRMenuView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) titleArray:@[@"宝贝", @"店铺"] left:YES];
    menuView.delegate = self;
    menuView.menuViewX = 40 + 15;
    [self.tabBarController.view addSubview:menuView];
}

- (void)menuViewButtonDidClick:(UIButton *)button
{
    self.type = button.tag + 1;
    [self.sortbutton setTitle:button.currentTitle forState:UIControlStateNormal];
    [self.sortbutton setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentRight imgTextDistance:3];
    
    [self getHotData];
}
- (void)deleteButtonDidClick
{
    [DRSearchTool deleteGoodHistoryData];
    self.historyTextView.texts = [DRSearchTool getGoodHistoryData];
    self.historyTextView.height = [self.historyTextView getViewHeight];
    self.historyView.height = CGRectGetMaxX(self.historyTextView.frame);
}
- (void)collectionTextViewButtonDidClick:(UIButton *)button
{
    [self searchWithKeyword:button.currentTitle];
    self.searchBar.text = button.currentTitle;
    [self.searchBar resignFirstResponder];
}
- (void)searchWithKeyword:(NSString *)keyword
{
    if (DRStringIsEmpty(keyword)) {
        return;
    }

    //储存搜索关键字
    [DRSearchTool addGoodKeyWord:keyword];
    self.historyTextView.texts = [DRSearchTool getGoodHistoryData];
    self.historyTextView.height = [self.historyTextView getViewHeight];
    self.historyView.height = CGRectGetMaxX(self.historyTextView.frame);
    if (self.type == 1) {//宝贝
        DRGoodListViewController * goodListVC = [[DRGoodListViewController alloc] init];
        goodListVC.likeName = keyword;
        [self.navigationController pushViewController:goodListVC animated:NO];
    }else if (self.type == 2)//店铺
    {
        DRShopListViewController * shopListVC = [[DRShopListViewController alloc] init];
        shopListVC.likeName = keyword;
        [self.navigationController pushViewController:shopListVC animated:NO];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchWithKeyword:searchBar.text];
}

@end
