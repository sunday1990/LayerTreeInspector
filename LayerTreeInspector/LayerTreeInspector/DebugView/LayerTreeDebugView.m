//
//  LayerTreeDebugView.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeDebugView.h"
#import "LayerTreeBaseNode.h"
#import "LayerTreeAssistMacros.h"
#import "LayerTreeInspector.h"
#import "LayerTreeViewDetailCell.h"

@interface LayerTreeDebugView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton *LYT_bubbleView;

@property (nonatomic, strong) UITableView *LYT_tableview;

@property (nonatomic, strong) LayerTreeBaseNode *LYT_currentNode;

@property (nonatomic, strong) NSMutableArray *LYT_selectNodes;

@property (nonatomic, strong) UIButton *LYT_headerView;

@property (nonatomic, strong) UIButton *LYT_dismissBtn;

@property (nonatomic, strong) LayerTreeViewDetailModel *viewDetailModel;

@end

@implementation LayerTreeDebugView
{
    BOOL checkViewDetail;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static LayerTreeDebugView *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)sharedDebugView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        UIWindow *keyWindow = [self getWindow];
        [keyWindow addSubview:self.LYT_bubbleView];
        [keyWindow addSubview:self.LYT_tableview];
    }
    return self;
}

#pragma mark =========== System Delegate =========== 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (checkViewDetail) {
        return 1;
    }else{
        return self.LYT_currentNode.subNodes.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        return 420;
    }else{
        return 60;
    }
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        static NSString *CELL_ID = @"LayerTreeViewDetailCellID";
        LayerTreeViewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (cell == nil) {
            cell = [[LayerTreeViewDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
        }
        cell.changeAttribute = ^(LayerTreeViewDetailModel * _Nonnull model) {
            model.associateView.frame = CGRectMake(model.x, model.y, model.w, model.h);
            model.associateView.backgroundColor = [UIColor colorWithRed:model.r green:model.g blue:model.b alpha:model.backGroundColoralpha];
            model.associateView.alpha = model.alpha;
        };
        
        [cell updateWithModel:self.viewDetailModel];
        return cell;
    
    }else{
        LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LYT_currentNode.subNodes[indexPath.row];
        static NSString *CELL_ID = @"LayTreeSubViewID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
            cell.userInteractionEnabled = YES;
            UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
            rightArrow.frame = CGRectMake(0, 0, 30, 30);
            [rightArrow setImage:[UIImage imageNamed:@"LYT_editIcon"] forState:UIControlStateNormal];
            [rightArrow addTarget:self action:@selector(checkCurrentSelectViewDetail:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = rightArrow;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@",node.LayerTreeNodeView];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.numberOfLines = 0;
        if (node.subNodes.count>0) {
            cell.accessoryView.hidden = NO;
        }else{
            cell.accessoryView.hidden = YES;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LYT_currentNode.subNodes[indexPath.row];
    if (node.subNodes.count>0) {
        node.expand = YES;
        checkViewDetail = NO;
        self.LYT_currentNode = node;
        [self.LYT_selectNodes addObject:node];
        [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        self.LYT_currentNode = (LayerTreeBaseNode *)node.fatherNode;
        [self.LYT_selectNodes addObject:self.LYT_currentNode];
        LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.LayerTreeNodeView];
        checkViewDetail = YES;
        self.viewDetailModel = model;
        [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    LayerTreeBaseNode *lastNode = [self.LYT_selectNodes lastObject];
    [self.LYT_headerView setTitle:NSStringFromClass(lastNode.LayerTreeNodeView.class) forState:UIControlStateNormal];
    return self.LYT_headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

#pragma mark =========== EventResponse ===========
- (void)checkCurrentSelectViewDetail:(UIButton *)btn{
    NSLog(@"check detail");
    UITableViewCell *cell = (UITableViewCell *)btn.superview;
    NSInteger index = [self.LYT_tableview.visibleCells indexOfObject:cell];
    NSLog(@"row:%ld",index);
    LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LYT_currentNode.subNodes[index];
    [self.LYT_selectNodes addObject:self.LYT_currentNode];
    //展开这一行
    LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.LayerTreeNodeView];
    checkViewDetail = YES;
    self.viewDetailModel = model;
    [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];    
}

- (void)showDebugView{
    self.LYT_tableview.hidden = NO;
    self.LYT_tableview.alpha = 1;
    [self.LYT_selectNodes removeAllObjects];
    [LayerTreeInspector layerTreeFindCurrentNodeAtTopviewWithCompletion:^(LayerTreeBaseNode *currentNode, NSArray<LayerTreeBaseNode *> *node) {
        self.LYT_currentNode = currentNode;
        [self.LYT_selectNodes addObjectsFromArray:node];
        [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer{
    CGPoint translation = [recognizer translationInView:[self getWindow]];
    CGFloat centerX = recognizer.view.center.x + translation.x;
    CGFloat thecenter = 0;
    recognizer.view.center=CGPointMake(centerX,
                                       recognizer.view.center.y+ translation.y);
    [recognizer setTranslation:CGPointZero inView:[self getWindow]];
    if(recognizer.state==UIGestureRecognizerStateEnded || recognizer.state==UIGestureRecognizerStateCancelled) {
        if(centerX > LYT_ScreenWidth/2) {
            thecenter = LYT_ScreenWidth-recognizer.view.frame.size.width/2-12;
        }else{
            thecenter = recognizer.view.frame.size.width/2+12;
        }
        [UIView animateWithDuration:0.3 animations:^{
            recognizer.view.center=CGPointMake(thecenter,
                                               recognizer.view.center.y + translation.y);
        }];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap{
    
    NSLog(@"tap.view:%@",tap.view);
}

- (void)layerTreeBack:(UIButton *)btn{
    checkViewDetail = NO;
    if (self.LYT_selectNodes.count > 1) {
        [self.LYT_selectNodes removeLastObject];
        self.LYT_currentNode = self.LYT_selectNodes.lastObject;
        [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        if (self.LYT_selectNodes.count == 1) {
            self.LYT_currentNode = self.LYT_selectNodes[0];
            [self.LYT_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"无效点击");
        }
    }
}

- (void)dismissDebugView{
    checkViewDetail = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.LYT_tableview.alpha = 0;
    }completion:^(BOOL finished) {
        self.LYT_tableview.hidden = YES;
    }];
}

#pragma mark =========== Setters && Getters ===========

- (UIWindow *)getWindow{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    return keyWindow;
}

- (UIButton *)LYT_bubbleView{
    if (!_LYT_bubbleView) {
        _LYT_bubbleView = [UIButton buttonWithType:UIButtonTypeCustom];
        _LYT_bubbleView.frame = CGRectMake(LYT_ScreenWidth-12- 50, 30, 50, 50);
        _LYT_bubbleView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_LYT_bubbleView setTitle:@"Debug" forState:UIControlStateNormal];
        [_LYT_bubbleView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _LYT_bubbleView.layer.cornerRadius = 10;
        _LYT_bubbleView.backgroundColor = LYT_BackGroundColor;
        [_LYT_bubbleView addTarget:self action:@selector(showDebugView) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_LYT_bubbleView addGestureRecognizer:pan];
    }
    return _LYT_bubbleView;
}

- (UITableView *)LYT_tableview{
    if (!_LYT_tableview) {
        _LYT_tableview = [[UITableView alloc]initWithFrame:CGRectMake(12, 300, LYT_ScreenWidth-24,44*8 ) style:UITableViewStylePlain];
        _LYT_tableview.delegate = self;
        _LYT_tableview.hidden = YES;
        _LYT_tableview.dataSource = self;
        _LYT_tableview.layer.shadowColor = [UIColor blackColor].CGColor;
        _LYT_tableview.layer.borderWidth = 1;
        _LYT_tableview.layer.borderColor = LYT_BackGroundColor.CGColor;
        _LYT_tableview.layer.cornerRadius = 10;
        _LYT_tableview.tableFooterView = [[UIView alloc]init];
        _LYT_tableview.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    }
    return _LYT_tableview;
}

- (UIButton *)LYT_headerView{
    if (!_LYT_headerView) {
        _LYT_headerView = [UIButton buttonWithType:UIButtonTypeCustom];
        _LYT_headerView.frame = CGRectMake(0, 0, self.LYT_tableview.frame.size.width, 44);
        _LYT_headerView.titleLabel.font = [UIFont systemFontOfSize:12];
        _LYT_headerView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _LYT_headerView.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_LYT_headerView setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _LYT_headerView.backgroundColor = LYT_BackGroundColor;
        [_LYT_headerView addTarget:self action:@selector(layerTreeBack:) forControlEvents:UIControlEventTouchUpInside];
        [_LYT_headerView addSubview:self.LYT_dismissBtn];
    }
    return _LYT_headerView;
}

- (UIButton *)LYT_dismissBtn{
    if (!_LYT_dismissBtn) {
        _LYT_dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _LYT_dismissBtn.frame = CGRectMake(_LYT_headerView.frame.size.width-50, 0, 44, 44);
        [_LYT_dismissBtn setTitle:@"取消" forState:UIControlStateNormal];
        _LYT_dismissBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _LYT_dismissBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _LYT_dismissBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_LYT_dismissBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _LYT_dismissBtn.backgroundColor = LYT_BackGroundColor;
        [_LYT_dismissBtn addTarget:self action:@selector(dismissDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _LYT_dismissBtn;
}

- (NSMutableArray *)LYT_selectNodes{
    if (!_LYT_selectNodes) {
        _LYT_selectNodes = [NSMutableArray array];
    }
    return _LYT_selectNodes;
}

@end
