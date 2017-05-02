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


@interface YCViewController () <UITableViewDataSource,UITableViewDelegate>
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
    return indexPath.section == 1 ? 44 : kScreenWidth;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
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
