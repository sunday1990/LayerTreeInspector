//
//  LayerTreeDebugView.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeDebugView.h"
#import "LayerTreeInspector.h"
#import "LayerTreeViewDetailCell.h"
#import "LayerTreeGraphicsView.h"
#import "LayerTreeBreadcrumbsView.h"
#import "LayerTreeAffineTransFormView.h"
#import "LayerTreeBaseNode.h"
#import "LayerTreeAssistMacros.h"

typedef NS_ENUM(NSUInteger,LayerTreeStyle)
{
    LayerTreeStyleDefault = 0,      //默认的面包屑形式
    LayerTreeStyle3DTransForm = 1,  //3D变换形式
    LayerTreeStyleGraphics = 2      //🌲形式
    
};
@interface LayerTreeDebugView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *LTI_bubbleView;

@property (nonatomic, strong) UITableView *LTI_tableview;

@property (nonatomic, strong) LayerTreeBaseNode *LTI_currentNode;

@property (nonatomic, strong) NSMutableArray *LTI_selectNodes;

@property (nonatomic, strong) UIButton *LTI_headerView;

@property (nonatomic, strong) UIButton *LTI_dismissBtn;

@property (nonatomic, strong) UIButton *LTI_refreshBtn;

@property (nonatomic, strong) UIButton *LTI_changeTypeBtn;

@property (nonatomic, strong) UIView *LTI_typeView;

@property (nonatomic, strong) LayerTreeViewDetailModel *viewDetailModel;

@property (nonatomic, assign) LayerTreeStyle treeStyle;

@end

@implementation LayerTreeDebugView
{
    BOOL checkViewDetail;
    
    CGPoint angle;
    
    CATransform3D transForm;
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
        self.treeStyle = LayerTreeStyleDefault;
        self.frame = CGRectMake(12, 300, LTI_ScreenWidth-24,44*8);
        [self addSubview:self.LTI_tableview];
        [keyWindow addSubview:self];
        [keyWindow addSubview:self.LTI_bubbleView];
//        [keyWindow addSubview:self.LTI_tableview];
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
        return self.LTI_currentNode.subNodes.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        return 420;
    }else{
        return 60;
    }
}

- (void)animate:(UIView *)view transform:(CATransform3D)trans{
    [UIView animateWithDuration:0.2 animations:^{
        NSLog(@"view:%@",view);
        view.layer.transform = trans;
        if (view.subviews.count>0 ) {
            for (UIView *subView in view.subviews) {
                [self animate:subView transform:trans];
            }
        }else{
            return;
        }
    }];
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        static NSString *CELL_ID = @"LayerTreeViewDetailCellID";
        LayerTreeViewDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (cell == nil) {
            cell = [[LayerTreeViewDetailCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
        }
        __weak typeof(self)weakSelf = self;
        cell.changeAttribute = ^(LayerTreeViewDetailModel * _Nonnull model) {
            if (weakSelf.treeStyle == LayerTreeStyleDefault) {
                model.associateView.frame = CGRectMake(model.x, model.y, model.w, model.h);
                model.associateView.backgroundColor = [UIColor colorWithRed:model.r green:model.g blue:model.b alpha:model.backGroundColoralpha];
                model.associateView.alpha = model.alpha;
            }else if (weakSelf.treeStyle == LayerTreeStyle3DTransForm){
                model.associateView.frame = CGRectMake(model.x, model.y, model.w, model.h);
                CATransform3D trans = CATransform3DIdentity;
                CATransform3D t = CATransform3DIdentity;
                t.m34 = -1.0/500.0;
                trans = CATransform3DConcat(CATransform3DMakeRotation(M_PI * model.r, 0, 1, 0), trans);
                trans = CATransform3DConcat(CATransform3DMakeRotation(M_PI * model.g, 1, 0, 0), trans);
                trans = CATransform3DConcat(CATransform3DMakeRotation(M_PI * model.b, 0, 0, 1), trans);

                trans = CATransform3DConcat(CATransform3DMakeScale(1+model.b, 1+model.b, 0),trans);
                trans = CATransform3DConcat(trans, t);
                [weakSelf animate:model.associateView transform:trans];
            }else if (weakSelf.treeStyle == LayerTreeStyleGraphics){
                
            }
        };
        
        [cell updateWithModel:self.viewDetailModel];
        return cell;
    
    }else{
        LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LTI_currentNode.subNodes[indexPath.row];
        static NSString *CELL_ID = @"LayTreeSubViewID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
            cell.userInteractionEnabled = YES;
            UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
            rightArrow.frame = CGRectMake(0, 0, 30, 30);
            [rightArrow setImage:[UIImage imageNamed:@"LTI_editIcon"] forState:UIControlStateNormal];
            [rightArrow addTarget:self action:@selector(checkCurrentSelectViewDetail:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = rightArrow;
        }
        if (node.subNodes.count>0) {
            cell.accessoryView.hidden = NO;
        }else{
            cell.accessoryView.hidden = YES;
        }
        if (node.LayerTreeNodeView) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",node.LayerTreeNodeView];
        }else{
            cell.accessoryView.hidden = YES;
            cell.textLabel.text = @"view已释放，无法查看，请返回上一级或点击刷新按钮";
        }
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.numberOfLines = 0;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (checkViewDetail) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LTI_currentNode.subNodes[indexPath.row];
    NSLog(@"nodelevel:%ld",node.nodeLevel);
    [_LTI_headerView setImage:[UIImage imageNamed:@"LTI__backIcon"] forState:UIControlStateNormal];
    if (node.subNodes.count>0) {
        LayerTreeBaseNode *firstSubNode = (LayerTreeBaseNode *)node.subNodes.firstObject;
        if (firstSubNode.LayerTreeNodeView) {
            node.expand = YES;
            checkViewDetail = NO;
            self.LTI_currentNode = node;
            [self.LTI_selectNodes addObject:node];
            [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }
    }else{
        if (node.LayerTreeNodeView) {
            self.LTI_currentNode = (LayerTreeBaseNode *)node.fatherNode;
            [self.LTI_selectNodes addObject:self.LTI_currentNode];
            LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.LayerTreeNodeView];
            checkViewDetail = YES;
            self.viewDetailModel = model;
            [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    LayerTreeBaseNode *lastNode = [self.LTI_selectNodes lastObject];
    if (self.LTI_selectNodes.count > 1) {
        [self.LTI_headerView setTitle:NSStringFromClass(lastNode.LayerTreeNodeView.class)?[NSString stringWithFormat:@"< %@",NSStringFromClass(lastNode.LayerTreeNodeView.class)]:@"view已释放，请点此返回或刷新" forState:UIControlStateNormal];
    }else{
        [self.LTI_headerView setTitle:NSStringFromClass(lastNode.LayerTreeNodeView.class)?NSStringFromClass(lastNode.LayerTreeNodeView.class):@"view已释放，请点此返回或刷新" forState:UIControlStateNormal];
    }
    return self.LTI_headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([touch.view isKindOfClass:NSClassFromString(@"UIButton")]) {//UITableViewCellContentView
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark =========== EventResponse ===========
- (void)viewPanTransform:(UIPanGestureRecognizer *)sender{
    CGPoint point = [sender translationInView:[UIApplication sharedApplication].keyWindow];//以手势在blueView的相对坐标为基准，但由于这个基准每次都变化，所以它也会变化。
    CGFloat angleX = angle.x + point.x/30.0;
    CGFloat angleY = angle.y - point.y/30.0;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0/500.0;
    transform = CATransform3DRotate(transform, angleX, 0, 1, 0);
    transform = CATransform3DRotate(transform, angleY, 1, 0, 0);
    [UIApplication sharedApplication].keyWindow.layer.sublayerTransform = transform;//这是旋转blueview的sublayer,这样blueview本身不会转动，但是子layer可以转动
    if (sender.state == UIGestureRecognizerStateEnded) {
        angle.x = angleX;
        angle.y = angleY;
    }
}

- (void)viewPinTransform:(UIPinchGestureRecognizer *)sender{
    NSLog(@"scale:%f",sender.scale);
    if (sender.state==UIGestureRecognizerStateBegan || sender.state==UIGestureRecognizerStateChanged){
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        CATransform3D transform = CATransform3DScale(CATransform3DIdentity, sender.scale, sender.scale, sender.scale);
        transform = CATransform3DRotate(transform, angle.x, 0, 1, 0);
        transform = CATransform3DRotate(transform, angle.y, 1, 0, 0);
        rootWindow.layer.sublayerTransform = transform;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
#warning 计算错误,需要更新angle
//        angle.x = sender.scale;
//        angle.y = sender.scale;
    }
}

- (void)checkCurrentSelectViewDetail:(UIButton *)btn{
    NSLog(@"check detail");
    UITableViewCell *cell = (UITableViewCell *)btn.superview;
    NSInteger index = [self.LTI_tableview.visibleCells indexOfObject:cell];
    NSLog(@"row:%ld",index);
    LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.LTI_currentNode.subNodes[index];
    [self.LTI_selectNodes addObject:self.LTI_currentNode];
    //展开这一行
    LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.LayerTreeNodeView];
    checkViewDetail = YES;
    self.viewDetailModel = model;
    [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];    
}

- (void)showDebugView{
    [self refreshDebugView];
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer{
    CGPoint translation = [recognizer translationInView:[self getWindow]];
    CGFloat centerX = recognizer.view.center.x + translation.x;
    CGFloat thecenter = 0;
    recognizer.view.center=CGPointMake(centerX,
                                       recognizer.view.center.y+ translation.y);
    [recognizer setTranslation:CGPointZero inView:[self getWindow]];
    if(recognizer.state==UIGestureRecognizerStateEnded || recognizer.state==UIGestureRecognizerStateCancelled) {
        if(centerX > LTI_ScreenWidth/2) {
            thecenter = LTI_ScreenWidth-recognizer.view.frame.size.width/2-12;
        }else{
            thecenter = recognizer.view.frame.size.width/2+12;
        }
        [UIView animateWithDuration:0.3 animations:^{
            recognizer.view.center=CGPointMake(thecenter,
                                               recognizer.view.center.y + translation.y);
        }];
    }
}

- (void)layerTreeBack:(UIButton *)btn{
    checkViewDetail = NO;
    if (self.LTI_selectNodes.count > 1) {
        [_LTI_headerView setImage:[UIImage imageNamed:@"LTI__backIcon"] forState:UIControlStateNormal];
        [self.LTI_selectNodes removeLastObject];
        self.LTI_currentNode = self.LTI_selectNodes.lastObject;
        [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [_LTI_headerView setImage:nil forState:UIControlStateNormal];
        if (self.LTI_selectNodes.count == 1) {
            self.LTI_currentNode = self.LTI_selectNodes[0];
            [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"无效点击");
        }
    }
}

- (void)dismissDebugView{
    checkViewDetail = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.LTI_tableview.alpha = 0;
    }completion:^(BOOL finished) {
        self.LTI_tableview.hidden = YES;
    }];
}

- (void)refreshDebugView{
    CABasicAnimation *lessAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    lessAnimation.toValue = [NSNumber numberWithFloat:0.3];
    
    CABasicAnimation *enlargeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    enlargeAnimation.toValue = [NSNumber numberWithFloat:1];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];//transform.rotation
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[lessAnimation,enlargeAnimation,rotateAnimation];
    animationGroup.duration = 0.4;
    [self.LTI_refreshBtn.layer addAnimation:animationGroup forKey:@"groupAnimation"];
    
    checkViewDetail = NO;
    self.LTI_tableview.hidden = NO;
    self.LTI_tableview.alpha = 1;
    [self.LTI_selectNodes removeAllObjects];
    [LayerTreeInspector layerTreeFindCurrentNodeAtTopviewWithCompletion:^(LayerTreeBaseNode *currentNode, NSArray<LayerTreeBaseNode *> *node) {
        self.LTI_currentNode = currentNode;
        [self.LTI_selectNodes addObjectsFromArray:node];
        [self.LTI_tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }];
}

- (void)showSelectTypeView:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.LTI_typeView.frame = CGRectMake(self.LTI_typeView.frame.origin.x, self.LTI_typeView.frame.origin.y, self.LTI_typeView.frame.size.width, 44*3);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.LTI_typeView.frame = CGRectMake(self.LTI_typeView.frame.origin.x, self.LTI_typeView.frame.origin.y, self.LTI_typeView.frame.size.width, 0);
        }];
    }
}

- (void)changeStyle:(UIButton *)btn{
    [self showSelectTypeView:self.LTI_changeTypeBtn];
    if (btn.tag == 100) {
        self.treeStyle = LayerTreeStyleDefault;
    }else if (btn.tag == 101) {//说明是3DTransform变换,此时需要对所有的view进行z轴的平移
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPanTransform:)];
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(viewPinTransform:)];
        pinGesture.delegate = self;
        UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
        [rootWindow addGestureRecognizer:pinGesture];
        [rootWindow addGestureRecognizer:panGesture];
        self.treeStyle = LayerTreeStyle3DTransForm;
        [LayerTreeInspector layerTreeRecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding:LTI_AffineTransformLevelPadding];
    }else if (btn.tag == 102){
        self.treeStyle = LayerTreeStyleGraphics;
    }
    [self.LTI_tableview reloadData];
}

#pragma mark =========== Setters && Getters ===========

- (UIWindow *)getWindow{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    return keyWindow;
}

- (UIButton *)LTI_bubbleView{
    if (!_LTI_bubbleView) {
        _LTI_bubbleView = [UIButton buttonWithType:UIButtonTypeCustom];
        _LTI_bubbleView.frame = CGRectMake(LTI_ScreenWidth-12- 50, 30, 50, 50);
        _LTI_bubbleView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_LTI_bubbleView setTitle:@"Debug" forState:UIControlStateNormal];
        [_LTI_bubbleView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _LTI_bubbleView.layer.cornerRadius = 10;
        _LTI_bubbleView.backgroundColor = LTI_BackGroundColor;
        [_LTI_bubbleView addTarget:self action:@selector(showDebugView) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_LTI_bubbleView addGestureRecognizer:pan];
    }
    return _LTI_bubbleView;
}

- (UITableView *)LTI_tableview{
    if (!_LTI_tableview) {
        _LTI_tableview = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _LTI_tableview.delegate = self;
        _LTI_tableview.hidden = YES;
        _LTI_tableview.dataSource = self;
        _LTI_tableview.layer.shadowColor = [UIColor blackColor].CGColor;
        _LTI_tableview.layer.borderWidth = 1;
        _LTI_tableview.layer.borderColor = LTI_BackGroundColor.CGColor;
        _LTI_tableview.layer.cornerRadius = 10;
        _LTI_tableview.tableFooterView = [[UIView alloc]init];
        _LTI_tableview.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
        [_LTI_tableview addSubview:self.LTI_typeView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [_LTI_tableview addGestureRecognizer:pan];
    }
    return _LTI_tableview;
}

- (UIButton *)LTI_headerView{
    if (!_LTI_headerView) {
        _LTI_headerView = [UIButton buttonWithType:UIButtonTypeCustom];
        _LTI_headerView.frame = CGRectMake(0, 0, self.LTI_tableview.frame.size.width, 44);
        _LTI_headerView.titleLabel.font = [UIFont systemFontOfSize:12];
        _LTI_headerView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _LTI_headerView.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_LTI_headerView setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _LTI_headerView.backgroundColor = LTI_BackGroundColor;
        [_LTI_headerView addTarget:self action:@selector(layerTreeBack:) forControlEvents:UIControlEventTouchUpInside];
        [_LTI_headerView addSubview:self.LTI_dismissBtn];
        [_LTI_headerView addSubview:self.LTI_refreshBtn];
        [_LTI_headerView addSubview:self.LTI_changeTypeBtn];
    }
    return _LTI_headerView;
}

- (UIButton *)LTI_dismissBtn{
    if (!_LTI_dismissBtn) {
        _LTI_dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _LTI_dismissBtn.frame = CGRectMake(_LTI_headerView.frame.size.width-50, 0, 44, 44);
        [_LTI_dismissBtn setImage:[UIImage imageNamed:@"LTI_deleteIcon"] forState:UIControlStateNormal];
        _LTI_dismissBtn.backgroundColor = LTI_BackGroundColor;
        [_LTI_dismissBtn addTarget:self action:@selector(dismissDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _LTI_dismissBtn;
}

- (UIButton *)LTI_refreshBtn{
    if (!_LTI_refreshBtn) {
        _LTI_refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _LTI_refreshBtn.frame = CGRectMake(_LTI_headerView.frame.size.width-50-56, 44/2-30/2, 30, 30);
        [_LTI_refreshBtn setImage:[UIImage imageNamed:@"LTI_refreshIcon"] forState:UIControlStateNormal];
        _LTI_refreshBtn.backgroundColor = LTI_BackGroundColor;
        [_LTI_refreshBtn addTarget:self action:@selector(refreshDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _LTI_refreshBtn;
}

- (UIButton *)LTI_changeTypeBtn{
    if (!_LTI_changeTypeBtn) {
        _LTI_changeTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _LTI_changeTypeBtn.frame = CGRectMake(CGRectGetMinX(self.LTI_refreshBtn.frame)-56, 0, 44, 44);
        [_LTI_changeTypeBtn setImage:[UIImage imageNamed:@"LTI_arrowdownIcon"] forState:UIControlStateNormal];
        [_LTI_changeTypeBtn setImage:[UIImage imageNamed:@"LTI_arrowupIcon"] forState:UIControlStateSelected];
        _LTI_changeTypeBtn.backgroundColor = LTI_BackGroundColor;
        [_LTI_changeTypeBtn addTarget:self action:@selector(showSelectTypeView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _LTI_changeTypeBtn;
}

- (UIView *)LTI_typeView{
    if (!_LTI_typeView) {
        _LTI_typeView = [[UIView alloc]initWithFrame:CGRectMake(_LTI_tableview.frame.size.width - 60-80-88, 44, 80+88, 0)];
        _LTI_typeView.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
        _LTI_typeView.layer.masksToBounds = YES;
        NSArray *title = @[@"DefaultBreadStyle",
                           @"3DTransFormStyle",
                           @"GraphicsTreeStyle(Pending)"
                           ];
        for (int i = 0; i<3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            btn.frame = CGRectMake(0, 44*i, _LTI_typeView.frame.size.width, 44);
            [btn setTitle:title[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn addTarget:self action:@selector(changeStyle:) forControlEvents:UIControlEventTouchUpInside];
            [_LTI_typeView addSubview:btn];
        }
    }
    return _LTI_typeView;
}

- (NSMutableArray *)LTI_selectNodes{
    if (!_LTI_selectNodes) {
        _LTI_selectNodes = [NSMutableArray array];
    }
    return _LTI_selectNodes;
}

@end
