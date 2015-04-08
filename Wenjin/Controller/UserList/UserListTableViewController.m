//
//  UserListTableViewController.m
//  Wenjin
//
//  Created by 秦昱博 on 15/4/8.
//  Copyright (c) 2015年 TWT Studio. All rights reserved.
//

#import "UserListTableViewController.h"
#import "UserListTableViewCell.h"
#import "SVPullToRefresh.h"
#import "UserDataManager.h"
#import "MsgDisplay.h"
#import "UserViewController.h"

@interface UserListTableViewController ()

@end

@implementation UserListTableViewController {
    NSMutableArray *rowsData;
    NSMutableArray *dataInTable;
    NSInteger currentPage;
    NSInteger totalRows;
}

@synthesize userType;
@synthesize userId;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
    self.title = @"关注";
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.top = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
    }

    rowsData = [[NSMutableArray alloc]init];
    dataInTable = [[NSMutableArray alloc]init];
    currentPage = 1;
    
    __weak UserListTableViewController *weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refreshContent];
    }];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf nextPage];
    }];
    [self.tableView triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getListData {
    [UserDataManager getFollowUserListWithOperation:userType userID:userId andPage:currentPage success:^(NSUInteger _totalRows, NSArray *_rowsData) {
        
        totalRows = _totalRows;

        if (currentPage == 1) {
            rowsData = [[NSMutableArray alloc]initWithArray:_rowsData];
        } else {
            [rowsData addObjectsFromArray:_rowsData];
        }
        dataInTable = rowsData;
        
        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
        
    } failure:^(NSString *errStr) {
        [MsgDisplay showErrorMsg:errStr];
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
}

- (void)refreshContent {
    currentPage = 1;
    rowsData = [[NSMutableArray alloc]init];
    [self getListData];
}

- (void)nextPage {
    if ([dataInTable count] == totalRows) {
        [MsgDisplay showErrorMsg:@"已经到最后一页了哦~"];
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    }
    if ([dataInTable count] < totalRows) {
        currentPage ++;
        [self getListData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [dataInTable count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"reuseIdentifier";
    UserListTableViewCell *cell = (UserListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserListTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSUInteger row = [indexPath row];
    NSDictionary *tmp = dataInTable[row];
    cell.userNameLabel.text = tmp[@"user_name"];
    cell.userSigLabel.text = (tmp[@"signature"] == [NSNull null]) ? @"" : tmp[@"signature"];
    [cell loadImageWithApartURL:tmp[@"avatar_file"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    NSDictionary *tmp = dataInTable[row];
    UserViewController *uVC = [[UserViewController alloc]initWithNibName:@"UserViewController" bundle:nil];
    uVC.userId = tmp[@"uid"];
    [self.navigationController pushViewController:uVC animated:YES];
}

@end
