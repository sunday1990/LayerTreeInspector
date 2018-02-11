//
//  ViewController.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"
#import "AssistMicros.h"
#import "LayerTreeInspector.h"
#import "TestTableViewCell.h"
#import "TestDataItem.h"
#import "TestDetailViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *dataArray;
}
@property (nonatomic, strong) UITableView *tableview;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dataArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TestDatasource" ofType:@"plist"];
    NSArray *dics = [NSArray arrayWithContentsOfFile:filePath];
    for (NSDictionary *dic in dics) {
        TestDataItem *item = [[TestDataItem alloc]init];
        for (NSString *key in dic.allKeys) {
            [item setValue:[dic objectForKey:key] forKey:key];
        }
        [dataArray addObject:item];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableview];
}



#pragma mark ======== System Delegate ========

#pragma mark UITableViewDataSource && UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 124;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"TestTableViewCell";
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    TestDataItem *item = [dataArray objectAtIndex:indexPath.row];
    [cell updateCellWithItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TestDataItem *item = dataArray[indexPath.row];
    TestDetailViewController *detailVC = [[TestDetailViewController alloc]init];
    detailVC.item = item;
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma mark ======== Private Methods ========

- (void)btnClick:(UIButton *)btn{
}

#pragma mark ======== Setters && Getters ========

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.rowHeight = 44;
        _tableview.backgroundColor = [UIColor colorWithRed:0.79 green:0.94 blue:0.74 alpha:1];
        _tableview.tableFooterView = [[UIView alloc]init];
    }
    return _tableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
