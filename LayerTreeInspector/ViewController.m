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
    
    CGPoint angle;

    NSArray *_titleArray;
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
    
    self.view.backgroundColor = [UIColor greenColor];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewTransform:)];
    [self.view addGestureRecognizer:panGesture];

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
    
    _titleArray = @[
                    @"找不到btn响应事件",
                    @"找不到vc中的方法",
                    @"向null对象发送length消息",
                    @"关闭UnrecognizedSel防护",
                    @"开启UnrecognizedSel防护"
                    ];
//    [self setupSubviews];
    
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

- (void)viewTransform:(UIPanGestureRecognizer *)sender{
    CGPoint point = [sender translationInView:self.view];//以手势在blueView的相对坐标为基准，但由于这个基准每次都变化，所以它也会变化。
    CGFloat angleX = angle.x + point.x/30.0;
    CGFloat angleY = angle.y - point.y/30.0;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/500.0;
    transform = CATransform3DRotate(transform, angleX, 0, 1, 0);
    transform = CATransform3DRotate(transform, angleY, 1, 0, 0);
    //    self.blueView.layer.transform = transform;//这是旋转layer，如果旋转的话，那么blueview的坐标系就会不断变化
    self.view.layer.sublayerTransform = transform;//这是旋转blueview的sublayer,这样blueview本身不会转动，但是子layer可以转动
    if (sender.state == UIGestureRecognizerStateEnded) {
        angle.x = angleX;
        angle.y = angleY;
    }
}


#pragma mark ======== Private Methods ========

- (void)btnClick:(UIButton *)btn{
    NSInteger btnTag = btn.tag;
    if (1000 == btnTag) {
    }else if (1001 == btnTag){
        //        [self performSelector:@selector(undefinedVCSelector)];
        
    }else if (1002 == btnTag){
        [[NSNull null]performSelector:@selector(length)];
    }else if (1003 == btnTag){
        //        [BayMaxProtector closeProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
    }else if (1004 == btnTag){
        //        [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
    }
}

- (CGFloat)getMaxLength{
    CGFloat maxLength = 0;
    for (int i = 0; i<_titleArray.count; i++) {
        CGFloat tempLength = [_titleArray[i] widthForFont:[UIFont systemFontOfSize:14]];
        if (tempLength>maxLength) {
            maxLength = tempLength;
        }
    }
    return maxLength;
}

- (void)setupSubviews{
    CGFloat btnWidth = ([self getMaxLength]+8)>(WIDTH/2-24)?(WIDTH/2-24):([self getMaxLength]+8);
    CGFloat btnHeight = 44;
    CGFloat borderSpace = 12;
    CGFloat btnSpace = (WIDTH - 2 * borderSpace - 2 * btnWidth);
    for (int i = 0; i<_titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1000+i;
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        btn.frame = CGRectMake(borderSpace + (btnSpace + btnWidth)*(i%2), 60+(btnHeight+borderSpace)*(i/2), btnWidth, btnHeight);
        if (i == 0) {
            CATransform3D diceTransform = CATransform3DIdentity;
//            diceTransform = CATransform3DRotate(CATransform3DIdentity, M_PI*0.3, 0, 1, 0);//y轴旋转
            diceTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 40);
            btn.layer.transform = diceTransform;

            UIView *btnSubview = [[UIView alloc]initWithFrame:CGRectMake(btn.frame.size.width-40, 12, 80, 40)];
            btnSubview.backgroundColor = [UIColor redColor];
            [btn addSubview:btnSubview];
            
            //change层级关系
            [btn convertRect:btnSubview.frame toView:self.view];
            [self.view addSubview:btnSubview];
            
            diceTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 80);
            btnSubview.layer.transform = diceTransform;

//            [btn addTarget:self action:@selector(undefinedBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }else{
//            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        btn.layer.cornerRadius = 5;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [self.view addSubview:btn];
    }
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 250, WIDTH-20, 150)];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor darkTextColor];
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"1、当未获取自动降级配置时，点击前三个按钮后，会拦阻异常，防止崩溃，但不会对该页面进行降级 \n 2、当获取自动降级配置后，再点击会跳转到该页面对应的H5页面，进行降级，展示掘金首页。\n 3、当关闭崩溃保护后，再次点击前三个按钮，会发生崩溃，可点击开启防护后，重新进行防护\n 4、如果有参数会获取参数。";
    [self.view addSubview:tipLabel];
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
