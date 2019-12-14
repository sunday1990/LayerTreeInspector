//
//  LayerTreeInspectionView.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeInspectionView.h"
#import "LayerTreeWindow.h"
#import "LayerTreeDefaultCell.h"
#import "LayerTree3DCell.h"
#import "LayerTreeImageView.h"
#import "LayerTreeMacros.h"
#import "LayerTreeBaseNode.h"

@interface LayerTreeInspectionView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
//代理
@property (nonatomic, weak) id<LayerTreeInspectionViewDelegate>delegate;
//part0
@property (nonatomic, strong) LayerTreeWindow *debugBtnContainerWindow;
@property (nonatomic, strong) UIButton *debugBtn;
//part1
@property (nonatomic, strong) LayerTreeWindow *tableViewContainerWindow;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *headerView;
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) UIButton *refreshBtn;
@property (nonatomic, strong) UIButton *changeTypeBtn;
@property (nonatomic, strong) UIView *typeView;
//part3
@property (nonatomic, strong) LayerTreeBaseNode *currentNode;
@property (nonatomic, strong) NSMutableArray *selectNodes;
@property (nonatomic, strong) LayerTreeViewDetailModel *viewDetailModel;
@property (nonatomic, strong) LayerTreeBaseNode *view3DDetailModel;
@property (nonatomic, assign) LayerTreeStyle treeStyle;

@end

@implementation LayerTreeInspectionView
{
    BOOL checkViewDetail;
    UIPanGestureRecognizer *_panGesture;
    UIPinchGestureRecognizer *_pinGesture;
    CATransform3D _initialTransForm;
    LayerTreeImageView *_currentSelect3DView;
    UIWindow * _rootWindow;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static float rotateX;static float rotateY;static float dist;

static inline float degreesToRadians(d){
    return ((d) * M_PI / 180);
}

+ (nonnull instancetype)sharedInspectionView{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _rootWindow = [UIApplication sharedApplication].keyWindow;
        self.treeStyle = LayerTreeStyleDefault;
        UIWindow *keyWindow = [self getWindow];
        [keyWindow addSubview:self.debugBtn];
    }
    return self;
}

- (void)registerDelegate:(id<LayerTreeInspectionViewDelegate>)delegate{
    self.delegate = delegate;
}

- (void)updateSelectNodeView:( LayerTreeImageView * _Nonnull )nodeView{
    if (nodeView == _currentSelect3DView) {
        return;
    }
    if (_currentSelect3DView) {
        _currentSelect3DView.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;;
    }
    _currentSelect3DView = nodeView;
    nodeView.layer.backgroundColor = LTI_BackGroundColor.CGColor;
    self.view3DDetailModel = nodeView.viewNode;
    [self.tableview reloadData];
}

#pragma mark =========== System Delegate =========== 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.treeStyle == LayerTreeStyleDefault||self.treeStyle == LayerTreeStyleGraphics) {
        if (checkViewDetail) {
            return 1;
        }else{
            return self.currentNode.subNodes.count;
        }
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.treeStyle == LayerTreeStyleDefault || self.treeStyle == LayerTreeStyleGraphics) {
        if (checkViewDetail) {
            return 420;
        }else{
            return 60;
        }
    }else{
        return 300;
    }
   
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.treeStyle == LayerTreeStyleDefault||self.treeStyle == LayerTreeStyleGraphics) {
        if (checkViewDetail) {
            static NSString *CELL_ID = @"LayerTreeDefaultCellID";
            LayerTreeDefaultCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
            if (cell == nil) {
                cell = [[LayerTreeDefaultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
            }
            __weak typeof(self)weakSelf = self;
            cell.changeAttribute = ^(LayerTreeViewDetailModel * _Nonnull model) {
                if (weakSelf.treeStyle == LayerTreeStyleDefault||weakSelf.treeStyle == LayerTreeStyle3DTransForm) {
                    model.associateView.frame = CGRectMake(model.x, model.y, model.w, model.h);
                    model.associateView.backgroundColor = [UIColor colorWithRed:model.r green:model.g blue:model.b alpha:model.backGroundColoralpha];
                    model.associateView.alpha = model.alpha;
                }else{
                    
                }
            };
            [cell updateWithModel:self.viewDetailModel];
            return cell;
        }else{
            LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.currentNode.subNodes[indexPath.row];
            static NSString *CELL_ID = @"LayTreeSubViewID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
                cell.userInteractionEnabled = YES;
                UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
                rightArrow.frame = CGRectMake(0, 0, 30, 30);
                //editIcon
                [rightArrow setImage:LTI_Image(@"editIcon") forState:UIControlStateNormal];
                [rightArrow addTarget:self action:@selector(checkCurrentSelectViewDetail:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = rightArrow;
            }
            if (node.subNodes.count>0) {
                cell.accessoryView.hidden = NO;
            }else{
                cell.accessoryView.hidden = YES;
            }
            if (node.treeNodeView) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@",node.treeNodeView];
            }else{
                cell.accessoryView.hidden = YES;
                cell.textLabel.text = @"view已释放，无法查看，请返回上一级或点击刷新按钮";
            }
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.numberOfLines = 0;
            return cell;
        }
    }else{
        static NSString *CELL_ID = @"LayerTree3DCellID";
        LayerTree3DCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (cell == nil) {
            cell = [[LayerTree3DCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID];
        }
        [cell updateWithNode:self.view3DDetailModel];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.treeStyle == LayerTreeStyleDefault || self.treeStyle == LayerTreeStyleGraphics) {
        if (checkViewDetail) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            return;
        }
        LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.currentNode.subNodes[indexPath.row];
        [_headerView setImage:LTI_Image(@"_backIcon") forState:UIControlStateNormal];
        if (node.subNodes.count>0) {
            LayerTreeBaseNode *firstSubNode = (LayerTreeBaseNode *)node.subNodes.firstObject;
            if (firstSubNode.treeNodeView) {
                node.expand = YES;
                checkViewDetail = NO;
                self.currentNode = node;
                [self.selectNodes addObject:node];
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
            }
        }else{
            if (node.treeNodeView) {
                self.currentNode = (LayerTreeBaseNode *)node.fatherNode;
                [self.selectNodes addObject:self.currentNode];
                LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.treeNodeView];
                checkViewDetail = YES;
                self.viewDetailModel = model;
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }else{

    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.treeStyle == LayerTreeStyleDefault || self.treeStyle == LayerTreeStyleGraphics) {
        LayerTreeBaseNode *lastNode = [self.selectNodes lastObject];
        if (self.selectNodes.count > 1) {
            [self.headerView setTitle:NSStringFromClass(lastNode.treeNodeView.class)?[NSString stringWithFormat:@"< %@",NSStringFromClass(lastNode.treeNodeView.class)]:@"view已释放，请点此返回或刷新" forState:UIControlStateNormal];
        }else{
            [self.headerView setTitle:NSStringFromClass(lastNode.treeNodeView.class)?NSStringFromClass(lastNode.treeNodeView.class):@"view已释放，请点此返回或刷新" forState:UIControlStateNormal];
        }
    }else{
        [self.headerView setTitle:@"3D视角" forState:UIControlStateNormal];
    }
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([touch.view isKindOfClass:NSClassFromString(@"UIButton")]) {//UITableViewCellContentView  ???
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
//- (void)tapInspectionView:(UITapGestureRecognizer *)tap{
//    if (tap.view == _currentSelect3DView) {
//        return;
//    }
//    if (_currentSelect3DView) {
//        _currentSelect3DView.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;;
//    }
//    LayerTreeImageView *subImgView = (LayerTreeImageView *)tap.view;
//    _currentSelect3DView = subImgView;
//    subImgView.layer.backgroundColor = LTI_BackGroundColor.CGColor;
//    self.view3DDetailModel = subImgView.viewNode;
//    [self.tableview reloadData];
//}

/**
偷了个懒，以下的pan:、pinch:、anime来自YY大佬的 YYViewHierarchy3D

 @param gestureRecognizer gestureRecognizer
 */
- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer {
    static CGPoint oldPan;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        oldPan = CGPointMake(rotateY, -rotateX);
    }
    CGPoint change = [gestureRecognizer translationInView:self];
    rotateY =  oldPan.x + change.x;
    rotateX = -oldPan.y - change.y;
    [self anime:0.1];
}

- (void)pinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    static float oldDist;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        oldDist = dist;
    }
    dist = oldDist + (gestureRecognizer.scale - 1);
    dist = dist < -5 ? -5 : dist > 0.5 ? 0.5 : dist;
    [self anime:0.1];
}

- (void)anime:(float)time {
    CATransform3D trans = CATransform3DIdentity;
    CATransform3D t = CATransform3DIdentity;
    t.m34 = -0.001;
    trans = CATransform3DMakeTranslation(0, 0, dist * 1000);
    trans = CATransform3DConcat(CATransform3DMakeRotation(degreesToRadians(rotateX), 1, 0, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(degreesToRadians(rotateY), 0, 1, 0), trans);
    trans = CATransform3DConcat(CATransform3DMakeRotation(degreesToRadians(0), 0, 0, 1), trans);
    trans = CATransform3DConcat(trans, t);
    [self getWindow].layer.sublayerTransform = trans;
}

- (void)checkCurrentSelectViewDetail:(UIButton *)btn{
    UITableViewCell *cell = (UITableViewCell *)btn.superview;
    NSInteger index = [self.tableview.visibleCells indexOfObject:cell];
    LayerTreeBaseNode *node = (LayerTreeBaseNode *)self.currentNode.subNodes[index];
    [self.selectNodes addObject:self.currentNode];
    LayerTreeViewDetailModel *model = [LayerTreeViewDetailModel modelWithView:node.treeNodeView];
    checkViewDetail = YES;
    self.viewDetailModel = model;
    [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showDebugView{
    if (!self.tableViewContainerWindow) {
        LayerTreeWindow *tableViewContainerWindow = [LayerTreeWindow window];
        tableViewContainerWindow.frame = CGRectMake(12, LTI_ScreenWidth - 44*7, LTI_ScreenWidth-24,44*6);
        tableViewContainerWindow.windowLevel = 1000;
        tableViewContainerWindow.backgroundColor = [UIColor clearColor];
        self.tableViewContainerWindow = tableViewContainerWindow;
        [self.tableViewContainerWindow addSubview:self.tableview];
        [self.tableViewContainerWindow makeKeyAndVisible];
    }
    if (!self.debugBtnContainerWindow) {
        LayerTreeWindow *bubbleContainerWindow = [LayerTreeWindow window];
        bubbleContainerWindow.frame = self.debugBtn.frame;
        self.debugBtn.frame = bubbleContainerWindow.bounds;
        bubbleContainerWindow.windowLevel = 1001;
        bubbleContainerWindow.backgroundColor = [UIColor clearColor];
        self.debugBtnContainerWindow = bubbleContainerWindow;
        [self.debugBtnContainerWindow addSubview:self.debugBtn];
        [self.debugBtnContainerWindow makeKeyAndVisible];
    }
    [self refreshDebugView];
}

#pragma mark 这个方法需要进行简化
- (void)handlePan:(UIPanGestureRecognizer*) recognizer{
    UIWindow *window = recognizer.view.window;
    if ([window isMemberOfClass:[LayerTreeWindow class]]) {
        CGPoint translation = [recognizer translationInView:[self getWindow]];//
        CGFloat centerX = recognizer.view.window.center.x + translation.x;
        CGFloat thecenter = 0;
        recognizer.view.window.center=CGPointMake(centerX,
                                           recognizer.view.window.center.y+ translation.y);
        [recognizer setTranslation:CGPointZero inView:[self getWindow]];
        if(recognizer.state==UIGestureRecognizerStateEnded || recognizer.state==UIGestureRecognizerStateCancelled) {
            if(centerX > LTI_ScreenWidth/2) {
                thecenter = LTI_ScreenWidth-recognizer.view.window.frame.size.width/2-12;
            }else{
                thecenter = recognizer.view.window.frame.size.width/2+12;
            }
            [UIView animateWithDuration:0.3 animations:^{
                recognizer.view.window.center=CGPointMake(thecenter,
                                                   recognizer.view.window.center.y + translation.y);
            }];
        }
    }else{
        CGPoint translation = [recognizer translationInView:[self getWindow]];//
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
}

- (void)layerTreeBack:(UIButton *)btn{
    checkViewDetail = NO;
    if (self.selectNodes.count > 1) {
        [_headerView setImage:LTI_Image(@"_backIcon") forState:UIControlStateNormal];
        [self.selectNodes removeLastObject];
        self.currentNode = self.selectNodes.lastObject;
        [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [_headerView setImage:nil forState:UIControlStateNormal];
        if (self.selectNodes.count == 1) {
            self.currentNode = self.selectNodes[0];
            [self.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSLog(@"无效点击");
        }
    }
}

- (void)dismissDebugView{
    checkViewDetail = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableview.alpha = 0;
    }completion:^(BOOL finished) {
        self.tableViewContainerWindow.hidden = YES;        
        id delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(layerTreeInspectionViewDidDismiss)] ) {
            [delegate layerTreeInspectionViewDidDismiss];
        }
    }];
}

- (void)refreshDebugView{
    CABasicAnimation *lessAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    lessAnimation.toValue = [NSNumber numberWithFloat:0.3];
    CABasicAnimation *enlargeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    enlargeAnimation.toValue = [NSNumber numberWithFloat:1];
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI*2];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[lessAnimation,enlargeAnimation,rotateAnimation];
    animationGroup.duration = 0.4;
    [_refreshBtn.layer addAnimation:animationGroup forKey:@"groupAnimation"];
    checkViewDetail = NO;
    self.tableViewContainerWindow.hidden = NO;
    self.tableview.alpha = 1;
    [self.selectNodes removeAllObjects];
    if (self.tableViewContainerWindow.frame.origin.y<(self.headerView.frame.size.height+44)||self.tableViewContainerWindow.frame.origin.y > (LTI_ScreenHeight - self.headerView.frame.size.height-44)) {
        [UIView animateWithDuration:0.5 animations:^{
           self.tableViewContainerWindow.frame = CGRectMake(12, LTI_ScreenHeight - 44*7, LTI_ScreenWidth-24,44*6);
        }];
    }
    if (LayerTreeStyleDefault == self.treeStyle) {
        id delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(layerTreeShouldRefreshCurrentNodeAtTopviewWithCompletion:)]) {
            __weak typeof(self)weakself = self;
            [self.delegate layerTreeShouldRefreshCurrentNodeAtTopviewWithCompletion:^(LayerTreeBaseNode * _Nullable currentNode, NSArray<LayerTreeBaseNode *> * _Nullable node) {
                weakself.currentNode = currentNode;
                [weakself.selectNodes addObjectsFromArray:node];
                [weakself.tableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:UITableViewRowAnimationFade];
            }];
        }
    }
}

- (void)showSelectTypeView:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.typeView.frame = CGRectMake(self.typeView.frame.origin.x, self.typeView.frame.origin.y, self.typeView.frame.size.width, 44*3);
        }completion:^(BOOL finished) {
            [self.tableview scrollsToTop];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.typeView.frame = CGRectMake(self.typeView.frame.origin.x, self.typeView.frame.origin.y, self.typeView.frame.size.width, 0);
        }];
    }
}

- (void)changeStyle:(UIButton *)btn{
    [self showSelectTypeView:self.changeTypeBtn];
    if (btn.tag == 100) {
        self.refreshBtn.userInteractionEnabled = YES;
        if (self.treeStyle == LayerTreeStyle3DTransForm) {
            self.treeStyle = LayerTreeStyleDefault;
            [self resetLayerTree:nil];
        }else if (self.treeStyle == LayerTreeStyleGraphics){
            self.treeStyle = LayerTreeStyleDefault;
            /*
             Codes:here
             
             */
        }
    }else if (btn.tag == 101) {
        self.treeStyle = LayerTreeStyle3DTransForm;
        self.refreshBtn.userInteractionEnabled = NO;
        self.resetButton.hidden = NO;
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
        _pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
        _pinGesture.delegate = self;
        UIWindow *rootWindow = [self getWindow];
        [rootWindow addGestureRecognizer:_pinGesture];
        [rootWindow addGestureRecognizer:_panGesture];
        _initialTransForm = rootWindow.layer.sublayerTransform;
        id delegate = self.delegate;
        if (delegate && [delegate respondsToSelector:@selector(layerTreeShould3DTransformWitPadding:)]) {
            [delegate layerTreeShould3DTransformWitPadding:LTI_AffineTransformLevelPadding];
        }
    }else if (btn.tag == 102){
        self.refreshBtn.userInteractionEnabled = YES;
        self.treeStyle = LayerTreeStyleGraphics;
        /*
         Codes here:
         */
    }
    [self.tableview reloadData];
}

- (void)resetBtnEvent:(UIButton *)btn{
    self.treeStyle = LayerTreeStyleDefault;
    self.refreshBtn.userInteractionEnabled = YES;
    [self resetLayerTree:btn];
}

- (void)resetLayerTree:(UIButton *)btn{
    NSLog(@"start revert 3D to plannar");
    _resetButton.hidden = YES;
    [self getWindow].layer.sublayerTransform = CATransform3DIdentity;
    [[self getWindow] removeGestureRecognizer:_pinGesture];
    [[self getWindow] removeGestureRecognizer:_panGesture];
    id delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(layerTreeShouldResetToIniaialFrom3DTransform:)]) {
        __weak typeof(self)weakself = self;
        [delegate layerTreeShouldResetToIniaialFrom3DTransform:^(BOOL isFinished) {
            if (isFinished) {
               NSLog(@"finish revert 3D to plannar");
                rotateX = rotateY = dist = 0;
               [weakself.tableview reloadData];
            }
        }];
    }
}

#pragma mark =========== Setters && Getters ===========

- (UIWindow *)getWindow{
    return _rootWindow;
}

- (UIButton *)debugBtn{
    if (!_debugBtn) {
        _debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _debugBtn.frame = CGRectMake(LTI_ScreenWidth-12- 50, 100, 50, 50);
        _debugBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_debugBtn setTitle:@"Tree" forState:UIControlStateNormal];
        [_debugBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _debugBtn.layer.cornerRadius = 10;
        _debugBtn.backgroundColor = LTI_BackGroundColor;
        [_debugBtn addTarget:self action:@selector(showDebugView) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_debugBtn addGestureRecognizer:pan];
    }
    return _debugBtn;
}

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:self.tableViewContainerWindow.bounds style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.layer.shadowColor = [UIColor blackColor].CGColor;
        _tableview.layer.borderWidth = 1;
        _tableview.layer.borderColor = LTI_BackGroundColor.CGColor;
        _tableview.layer.cornerRadius = 10;
        _tableview.tableFooterView = [[UIView alloc]init];
        _tableview.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        [_tableview addGestureRecognizer:pan];
    }
    return _tableview;
}

- (UIButton *)headerView{
    if (!_headerView) {
        _headerView = [UIButton buttonWithType:UIButtonTypeCustom];
        _headerView.frame = CGRectMake(0, 0, self.tableview.frame.size.width, 44);
        _headerView.titleLabel.font = [UIFont systemFontOfSize:12];
        _headerView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _headerView.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [_headerView setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _headerView.backgroundColor = LTI_BackGroundColor;
        [_headerView addTarget:self action:@selector(layerTreeBack:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:self.dismissBtn];
        [_headerView addSubview:self.refreshBtn];
        [_headerView addSubview:self.changeTypeBtn];
        [_headerView addSubview:self.resetButton];
    }
    return _headerView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(_headerView.frame.size.width-50, 0, 44, 44);
        [_dismissBtn setImage:LTI_Image(@"deleteIcon") forState:UIControlStateNormal];
        _dismissBtn.backgroundColor = LTI_BackGroundColor;
        [_dismissBtn addTarget:self action:@selector(dismissDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UIButton *)refreshBtn{
    if (!_refreshBtn) {
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refreshBtn.frame = CGRectMake(_headerView.frame.size.width-50-56, 44/2-30/2, 30, 30);
        [_refreshBtn setImage:LTI_Image(@"refreshIcon") forState:UIControlStateNormal];
        _refreshBtn.backgroundColor = LTI_BackGroundColor;
        _refreshBtn.showsTouchWhenHighlighted = YES;
        [_refreshBtn addTarget:self action:@selector(refreshDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _refreshBtn;
}

- (UIButton *)changeTypeBtn{
    if (!_changeTypeBtn) {
        _changeTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeTypeBtn.frame = CGRectMake(CGRectGetMinX(self.refreshBtn.frame)-56, 0, 44, 44);
        [_changeTypeBtn setImage:LTI_Image(@"arrowdownIcon") forState:UIControlStateNormal];
        [_changeTypeBtn setImage:LTI_Image(@"arrowupIcon") forState:UIControlStateSelected];
        _changeTypeBtn.backgroundColor = LTI_BackGroundColor;
        [_changeTypeBtn addTarget:self action:@selector(showSelectTypeView:) forControlEvents:UIControlEventTouchUpInside];
        _changeTypeBtn.showsTouchWhenHighlighted = YES;
    }
    return _changeTypeBtn;
}

- (UIButton *)resetButton{
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.frame = CGRectMake(CGRectGetMinX(self.changeTypeBtn.frame)-56, 0, 44, 44);
        _resetButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_resetButton setTitle:@"复原" forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _resetButton.showsTouchWhenHighlighted = YES;
        _resetButton.layer.cornerRadius = 10;
        _resetButton.hidden = YES;
        _resetButton.backgroundColor = LTI_BackGroundColor;
        [_resetButton addTarget:self action:@selector(resetBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIView *)typeView{
    if (!_typeView) {
        _typeView = [[UIView alloc]initWithFrame:CGRectMake(self.tableViewContainerWindow.frame.size.width - 60-80-88, 44, 80+88, 0)];
        _typeView.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
        _typeView.layer.masksToBounds = YES;
        NSArray *title = @[
                           @"DefaultBreadStyle",
                           @"3DTransFormStyle",
                           @"GraphicsTreeStyle(Pending)"
                           ];
        for (int i = 0; i<3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            btn.frame = CGRectMake(0, 44*i, _typeView.frame.size.width, 44);
            [btn setTitle:title[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor colorWithRed:0.89 green:0.96 blue:0.95 alpha:1];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn addTarget:self action:@selector(changeStyle:) forControlEvents:UIControlEventTouchUpInside];
            [_typeView addSubview:btn];
        }
        [_tableViewContainerWindow addSubview:self.typeView];
    }
    return _typeView;
}

- (NSMutableArray *)selectNodes{
    if (!_selectNodes) {
        _selectNodes = [NSMutableArray array];
    }
    return _selectNodes;
}

@end
