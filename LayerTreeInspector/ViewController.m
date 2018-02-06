//
//  ViewController.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"
#import "TestAutoDegradeVC.h"
#import "TestManaulDegradeVC.h"
#import "WebViewController.h"
#import "AssistMicros.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArray;
    
    NSArray<NSString *> *_vcNames;
    NSArray<NSArray<NSDictionary *> *> *_params;
    NSArray<NSString *> *_urls;
    NSArray<NSString *> *_initiativeVCS;
}
/**
 tableView
 */
@property (nonatomic, strong) UITableView *tableview;
/**
 获取自动降级配置的按钮
 */
@property (nonatomic, strong) UIButton *autoDegradeBtn;
/**
 获取手动降级配置的按钮
 */
@property (nonatomic, strong) UIButton *manaulDegradeBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    titleArray = @[
                   @{
                       @"title":@"UnrecognizedSelector || AutoDegrade",
                       @"class":@"TestUnrecognizedSelVC"
                       },
                   @{
                       @"title":@"UnrecognizedSelector-ViewDidLoad",
                       @"class":@"TestViewDidloadUnrecognizedSelVC"
                       },
                   @{
                       @"title":@"TimerError",
                       @"class":@"TestTimerErrorVC"
                       },
                   @{
                       @"title":@"KVOError",
                       @"class":@"TestKVOErrorVC"
                       },
                   @{
                       @"title":@"NotificationError",
                       @"class":@"TestNotificationErrorVC"
                       },
                   @{
                       @"title":@"ManaulDegrade",
                       @"class":@"TestManaulDegradeVC"
                       }
                   ];
    [self.view addSubview:self.tableview];
    [self.view addSubview:self.autoDegradeBtn];
    [self.view addSubview:self.manaulDegradeBtn];
}

#pragma mark ======== System Delegate ========

#pragma mark UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID = @"mainCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    cell.textLabel.text = [titleArray[indexPath.row]objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item =  titleArray[indexPath.row];
    Class cls = NSClassFromString([item objectForKey:@"class"]);
    if ([[item objectForKey:@"class"] isEqualToString:@"TestUnrecognizedSelVC"]) {
        UIViewController *vc = [[cls alloc]init];
        [vc setValue:@"someOne" forKey:@"userName"];
        [vc setValue:@"00001" forKey:@"userID"];
        [self presentViewController:vc animated:YES completion:nil];
        return;//
    }else if ([[item objectForKey:@"class"] isEqualToString:@"TestManaulDegradeVC"]){
        UIViewController *vc = [[cls alloc]init];
        [vc setValue:@"100000" forKey:@"uid"];
        [vc setValue:@"type001" forKey:@"type"];
        [self presentViewController:vc animated:YES completion:nil];
        return;//
    }
    [self presentViewController:[[cls alloc]init] animated:YES completion:nil];
}



#pragma mark ======== Private Methods ========


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
