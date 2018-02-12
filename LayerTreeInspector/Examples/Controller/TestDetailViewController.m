//
//  TestDetailViewController.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/11.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestDetailViewController.h"
#import "AssistMicros.h"

@interface TestDetailViewController ()
{
    UIImageView *headerImgView;
    UILabel *contentLabel;
    UIButton *backButton;
    
}
@end

@implementation TestDetailViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:245/255.0 alpha:1];
    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========
- (void)back:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ======== Private Methods ========
- (void)setupSubviews{
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(12, 12, 40, 40);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    headerImgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 60, WIDTH-40, 260)];
    headerImgView.image = [UIImage imageNamed:self.item.img];
    headerImgView.layer.cornerRadius = 5;
    headerImgView.layer.masksToBounds = YES;
    [self.view addSubview:headerImgView];
    
    contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(headerImgView.frame), CGRectGetMaxY(headerImgView.frame)+10, headerImgView.frame.size.width, HEIGHT-CGRectGetMaxY(headerImgView.frame))];
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.textColor = [UIColor darkTextColor];
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.text = @"《如果有一天我变得很有钱》\n --毛不易 \n 如果有一天我变得很有钱 \n 我的第一选择不是去环游世界\n,躺在世界上最大最软的沙发里\n吃了就睡醒了再吃先过一年\n，如果有一天我变得很有钱\n我就可以把所有人都留在我身边\n每天快快乐乐吃吃喝喝聊聊天\n不用担心关于明天和离别\n变有钱 我变有钱\n多少人没日没夜地浪费时间\n变有钱 我变有钱\n然后故作谦虚说金钱不是一切\n变有钱 我变有钱\n所有烦恼都被留在天边\n变有钱 我变有钱\n然后发自内心地说金钱它不是一切";
    [self.view addSubview:contentLabel];
}

#pragma mark ======== Setters && Getters ========

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


