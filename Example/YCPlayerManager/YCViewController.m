//
//  YCViewController.m
//  YCPlayerManager
//
//  Created by ych.wang@outlook.com on 02/24/2017.
//  Copyright (c) 2017 ych.wang@outlook.com. All rights reserved.
//

#import "YCViewController.h"
#import <YCPlayerManager/YCPlayerManager.h>



@interface YCViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) YCPlayerManager *playerManager;
@property (nonatomic, strong) UITableView *contentView;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _playerManager = [[YCPlayerManager alloc] init];
    _playerManager.enableBackgroundPlay = YES;
    _playerManager.mediaURLString = @"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4";
    _playerManager.playerView.frame = CGRectMake(0, 20, kScreenWidth, kScreenWidth);
    _playerLayer = _playerManager.mediaPlayer.currentLayer;

    _contentView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _contentView.dataSource = self;
    _contentView.delegate = self;
    _contentView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_contentView];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [rightBtn setTitle:@"click" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(clickRight) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
}

- (void)clickRight
{
    [self.contentView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [_playerManager play];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contentView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kScreenWidth;
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
    return cell;
}

@end
