//
//  YCTableViewController.m
//  YCPlayerManager
//
//  Created by Durand on 23/3/17.
//  Copyright © 2017年 ych.wang@outlook.com. All rights reserved.
//

#import "YCTableViewController.h"
#import "YCVideoPlayerCell.h"

@interface YCTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation YCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; ++i) {
        [_dataArray addObject:[NSString stringWithFormat:@"placeholder_%d",i]];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    CAShapeLayer *separatorLiner = [CAShapeLayer layer];
//    separatorLiner.backgroundColor = [UIColor orangeColor].CGColor;
//    separatorLiner.frame = CGRectMake(0, kScreenHeight - 64, kScreenWidth, 1);
//    [self.view.layer addSublayer:separatorLiner];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, (kScreenHeight - 64) / 2, kScreenWidth, 1)];
    separatorView.backgroundColor = [UIColor orangeColor];
    [self.view.window addSubview:separatorView];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenWidth;
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
        cell.backgroundColor = [self randomColor];
    }
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
