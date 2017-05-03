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

CGFloat kTopMargin = 0;

@interface YCViewController () <UITableViewDataSource,UITableViewDelegate>
{
    BOOL _isSuspendFlag;
}
@property (nonatomic, strong) YCPlayerManager *playerManager;
@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSMutableArray <NSArray *>*dataArray;
@end

@implementation YCViewController

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
    
    _playerManager = [[YCPlayerManager alloc] init];
    _playerManager.enableBackgroundPlay = YES;
    _playerManager.mediaURLString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    _playerManager.playerView.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth);
    _playerLayer = _playerManager.player.currentLayer;
    _playerLayer.backgroundColor = [UIColor blackColor].CGColor;

    _contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _contentView.dataSource = self;
    _contentView.delegate = self;
    _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentView];
    
//    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    [rightBtn setTitle:@"click" forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
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
    easyAppearAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    easyAppearAnimation.toValue = [NSNumber numberWithFloat:1.0];
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
    
    
    //    CABasicAnimation *easyDisppearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    //    easyDisppearAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    //    easyDisppearAnimation.toValue = [NSNumber numberWithFloat:0.0];
    //    easyDisppearAnimation.duration = 0.3;        // 1 second
    //    easyDisppearAnimation.autoreverses = NO;    // Back
    //    easyDisppearAnimation.repeatCount = 1;       // Or whatever
    //    easyDisppearAnimation.fillMode = kCAFillModeForwards;
    ////    easyDisppearAnimation.removedOnCompletion = NO;
    //    [playerLayer addAnimation:easyDisppearAnimation forKey:@"flashAnimation"];
    //
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 取消layer的隐式动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [playerLayer removeFromSuperlayer];
    [_playerManager.playerView.layer insertSublayer:playerLayer atIndex:0];
    playerLayer.frame = frame;
    playerLayer.opacity = 1.0;
    [CATransaction setDisableActions:NO];
    [CATransaction commit];
    
    //    });
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
    if (section == 0) {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:model.reuseidentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
            [cell.contentView.layer addSublayer:_playerLayer];
            cell.backgroundColor = [UIColor blackColor];
            [cell.contentView addSubview:_playerManager.playerView];
            _playerManager.playerView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
            //        [_player play];
            [_playerManager play];
        }
    } else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:model.reuseidentity];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = model.title;
        cell.detailTextLabel.text = model.detailTitle;
    }
    return cell;
}
@end
