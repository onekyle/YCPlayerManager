//
//  YCTableViewController.m
//  YCPlayerManager
//
//  Created by Durand on 23/3/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCTableViewController.h"
#import "YCVideoPlayerCell.h"
#import "YCVideoCellDataModel.h"

@interface YCTableViewController ()
{
    BOOL _isFirstLoadFlag;
}
@property (nonatomic, strong) NSMutableArray <YCVideoCellDataModel *>*dataArray;
@property (nonatomic, assign) CGPoint centerPoint;
//@property (nonatomic,strong) UIView *separatorView;
@property (nonatomic, weak) YCVideoPlayerCell *scrollInCell;
@end

@implementation YCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirstLoadFlag = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
    _centerPoint = CGPointMake(0, (kScreenHeight - 64) / 2);
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"videocelldata.json" ofType:nil]];
    
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
    
    NSArray *videoDataArray = dataDict[@"itemList"];
    _dataArray = [NSMutableArray arrayWithCapacity:videoDataArray.count];
    for (NSDictionary *dict in videoDataArray) {
        if (![dict[@"type"] hasPrefix:@"video"]) {
            continue;
        }
        NSDictionary *data = dict[@"data"];
        if (![data isKindOfClass:[NSDictionary class]]) {
            return;
        }
        YCVideoCellDataModel *model = [YCVideoCellDataModel modelWithDict:data];
        if (model) {
            NSLog(@"%@",model);
            [_dataArray addObject:model];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isFirstLoadFlag) {
//        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - 64) / 2, kScreenWidth, 1)];
//        separatorView.backgroundColor = [UIColor orangeColor];
//        [self.view.superview addSubview:separatorView];
//        _separatorView = separatorView;
        
        // loaded first time
        if (self.tableView.contentOffset.y < 0.1) {
            UITableViewCell *firstCell = self.tableView.visibleCells.firstObject;
            [self changeVisibleCellsShowStatusForTableView:self.tableView withConditionBlock:^BOOL(__kindof UITableViewCell *cell) {
                return cell == firstCell;
            }];
            [_scrollInCell playVideo];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _isFirstLoadFlag = NO;
    if (![self.navigationController.viewControllers containsObject:self]) {
        [[DemoManager shareManager] stop];
    }
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UITableView *)tableView
{
//    if (!tableView.isDragging) {
//        return;
//    }
    CGFloat offsetY = tableView.contentOffset.y;
    if (offsetY < 0.1) {
        UITableViewCell *firstCell = tableView.visibleCells.firstObject;
        [self changeVisibleCellsShowStatusForTableView:tableView withConditionBlock:^BOOL(__kindof UITableViewCell *cell) {
            return cell == firstCell;
        }];
    } else if (tableView.contentSize.height -  offsetY - tableView.bounds.size.height < 0.1) {
        UITableViewCell *lastCell = tableView.visibleCells.lastObject;
        [self changeVisibleCellsShowStatusForTableView:tableView withConditionBlock:^BOOL(__kindof UITableViewCell *cell) {
            return cell == lastCell;
        }];
    } else {
        [self changeVisibleCellsShowStatusForTableView:tableView withConditionBlock:^BOOL(__kindof UITableViewCell *cell) {
            CGRect cellFrame = [cell convertRect:cell.bounds toView:self.view.window];
            return CGRectContainsPoint(cellFrame, _centerPoint);
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [_scrollInCell playVideo];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_scrollInCell playVideo];
}

- (void)changeVisibleCellsShowStatusForTableView:(UITableView *)tableView withConditionBlock:(BOOL(^)(__kindof UITableViewCell *cell))conditionBlock
{
    if (!conditionBlock) {
        return;
    }
    for (YCVideoPlayerCell *cell in tableView.visibleCells) {
        if (conditionBlock(cell)) {
            cell.show = YES;
            _scrollInCell = cell;
        } else {
            cell.show = NO;
        }
    }
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [YCVideoPlayerCell cellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

NSString *const kYCTabelViewCellID = @"kYCTabelViewCellID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YCVideoPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kYCTabelViewCellID];
    if (!cell) {
        cell = [[YCVideoPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kYCTabelViewCellID];
        cell.backgroundColor = [UIColor blackColor];
    }
    cell.data = _dataArray[indexPath.row];
    return cell;
}

- (UIColor *)randomColor
{
    CGFloat r  = (arc4random() % 256) / 255.0;
    CGFloat g = (arc4random() % 256) / 255.0;
    CGFloat b = (arc4random() % 256) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}


@end
