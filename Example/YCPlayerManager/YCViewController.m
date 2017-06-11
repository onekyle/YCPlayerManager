//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCPlayerManager.h>
#import "YCNormalCellDataModel.h"
#import "YCNormalVideoCell.h"

CGFloat kTopMargin = 0;

@interface YCViewController () <UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isSuspendFlag;
}
@property (nonatomic, strong) YCPlayerManager *playerManager;
@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) NSMutableArray <NSArray *>*dataArray;

@end

@implementation YCViewController

- (void)dealloc
{
    NSLog(@"%@ dealloc", self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"normalcelldata.json" ofType:nil]];

    NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
    _dataArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NSArray *data = dict[@"data"];
        if ([data isKindOfClass:[NSArray class]]) {
            NSMutableArray *sectionModelArray = [NSMutableArray array];
            for (NSDictionary *modelDict in data) {
                YCNormalCellDataModel *model = [YCNormalCellDataModel modelWithDict:modelDict];
                [sectionModelArray addObject:model];
            }
            [_dataArray addObject:sectionModelArray];
        }
    }
    
    _playerManager = [YCPlayerManager shareManager];
    _playerManager.enableBackgroundPlay = YES;

    _contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _contentView.dataSource = self;
    _contentView.delegate = self;
    _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentView];

}

- (void)clickRight
{
    [self.contentView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_playerManager play];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    kTopMargin = self.navigationController.navigationBarHidden ? 0 : 64;
    [self.contentView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![self.navigationController.viewControllers containsObject:self]) {
        [_playerManager stop];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat limit = kScreenWidth - kTopMargin;
    if (offsetY >= limit) {
        [self showSuspendViewView];
    } else {
        [self resetToNormalPlayer];
    }
}


/** 显示悬浮窗口*/
- (void)showSuspendViewView
{
    if (_isSuspendFlag || _playerManager.isPaused) {
        return;
    }
    _isSuspendFlag = YES;
    CGFloat width = kScreenWidth / 3;
    [self suspendPlayerLayerWithSuperLayer:self.view.superview.layer frame:CGRectMake(kScreenWidth - width - 10, kTopMargin+ 10, width, width)]; // top and right margin plus 10
}

/** 播放器回复到正常尺寸*/
- (void)resetToNormalPlayer
{
    if (!_isSuspendFlag) {
        return;
    }
    _isSuspendFlag = NO;
    [self resetPlayerLayerFromSuspendWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
}


- (void)suspendPlayerLayerWithSuperLayer:(CALayer *)superLayer frame:(CGRect)frame
{
    AVPlayerLayer *playerLayer = _playerManager.player.currentLayer;
    [playerLayer removeFromSuperlayer];
    
    // 取消layer的隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    playerLayer.opacity = 0;
    [superLayer addSublayer:playerLayer];
    playerLayer.frame = frame;
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
    
    CABasicAnimation *easyAppearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    easyAppearAnimation.fromValue = @0.0f;
    easyAppearAnimation.toValue = @1.0f;
    easyAppearAnimation.duration = 0.3;        // 1 second
    easyAppearAnimation.autoreverses = NO;    // Back
    easyAppearAnimation.repeatCount = 1;       // Or whatever
    easyAppearAnimation.fillMode = kCAFillModeForwards;
    easyAppearAnimation.removedOnCompletion = NO;
    [playerLayer addAnimation:easyAppearAnimation forKey:@"flashAnimation"];
}

- (void)resetPlayerLayerFromSuspendWithFrame:(CGRect)frame
{
    AVPlayerLayer *playerLayer = _playerManager.player.currentLayer;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [playerLayer removeFromSuperlayer];
    [_playerManager.playerView.layer insertSublayer:playerLayer atIndex:0];
    playerLayer.frame = frame;
    playerLayer.opacity = 1.0;
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
}



#pragma mark - TableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? 44 : kScreenWidth;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        static NSString *footerID = @"video_footer";
        UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:footerID];
        if (!footerView) {
            footerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:footerID];
        }
        footerView.textLabel.text = @"Comment";
        return footerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    } else {
        return UITableViewAutomaticDimension;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    YCNormalCellDataModel *model = _dataArray[section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.reuseidentity];

    if (!cell) {
        if ([model.reuseidentity isEqualToString:@"video_cell"]) {
            cell = [[YCNormalVideoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:model.reuseidentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSString *mediaURLString = @"https://baobab.kaiyanapp.com/api/v1/playUrl?vid=20401&editionType=default&source=ucloud";
            _playerManager.playerView = ((YCNormalVideoCell *)cell).playerView;
            [_playerManager playWithMediaURLString:mediaURLString completionHandler:nil];
            cell.backgroundColor = [UIColor blackColor];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:model.reuseidentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    cell.textLabel.text = model.title;
    cell.detailTextLabel.text = model.detailTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YCNormalCellDataModel *model = _dataArray[indexPath.section][indexPath.row];
    if ([model.reuseidentity isEqualToString:@"video_cell"]) {
        return;
    }
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor orangeColor];
    vc.title = [NSString stringWithFormat:@"与%@的聊天",model.title];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
