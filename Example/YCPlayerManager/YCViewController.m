//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCPlayerManager.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface YCViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) YCPlayerManager *playerManager;
@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _playerManager = [[YCPlayerManager alloc] init];
//    _playerManager.mediaURLString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
//    _playerManager.playerView.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth);
    
    _player = [AVPlayer playerWithURL:[NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"]];
    _contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _contentView.dataSource = self;
    _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentView];
//    [self.view addSubview:_playerManager.playerView];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    [rightBtn setTitle:@"click" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)clickRight
{
//    UIViewController *vc = [UIViewController new];
//    vc.view.backgroundColor = [UIColor redColor];
//    [self.navigationController pushViewController:vc animated:YES];
    [self.contentView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_player play];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contentView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 375;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"testCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"testCell"];
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_player];
//        [layer removeFromSuperlayer];
        layer.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
        [cell.layer addSublayer:layer];
        cell.backgroundColor = [UIColor grayColor];
        [_player play];
//        [cell.contentView addSubview:_playerManager.playerView];
    }
    return cell;
}

@end
