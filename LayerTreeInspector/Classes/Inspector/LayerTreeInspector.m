//
//  LayerTreeInspector.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeInspector.h"
#import <objc/runtime.h>
#import "LayerTreeMacros.h"
#import "LayerTreeInspectionView.h"
#import "LayerTreeImageView.h"
#import "LayerTreeNode.h"

CATransform3D _transForm;
UIWindow *_rootWindow;
LayerTreeInspector *_instance;

#pragma mark 生成view的截图
static inline UIImage *createScreenShotForView(UIView *view,CGRect frame){
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) {
        return nil;
    }
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    [view.layer renderInContext:context];
    UIImage *renderedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return renderedImage;
}

#pragma mark 递归生成可视化的3D视图
static inline void recursiveConstruct3DHierarchyTree(LayerTreeNode *_Nonnull rootNode,CGFloat levelPadding){
    if (rootNode.subNodes.count == 0||[rootNode.treeNodeView isMemberOfClass:[LayerTreeInspectionView class]]) {
        return;
    }else{
        [rootNode.subNodes enumerateObjectsUsingBlock:^(LayerTreeNode *subNode, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *subview = (UIView *)subNode.treeNodeView;
            NSMutableArray *tempHiddenArray = [NSMutableArray array];
            //先隐藏所有的子view，然后再生成该view对应的图片，否则会重影
            if (subview.hidden == NO) {
                for (UIView *contentView in subview.subviews) {
                    if (!contentView.hidden) {
                        contentView.hidden = YES;//记录那些被隐藏的view
                        [tempHiddenArray addObject:contentView];
                    }
                }
                //生成对应的图片
                UIImage *subImage = createScreenShotForView(subview, subview.bounds);
                //转换frame
                CGRect imgViewFrame = [_rootWindow convertRect:subview.frame fromView:subview.superview];
                //创建imageview
                LayerTreeImageView *imageview = [[LayerTreeImageView alloc]initWithFrame:imgViewFrame];
                imageview.layer.opacity = 0.9;
                imageview.viewNode = subNode;
                //添加点击事件
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:_instance action:@selector(tapInspectionView:)];
                imageview.userInteractionEnabled = YES;
                [imageview addGestureRecognizer:tap];
                imageview.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
                imageview.image = subImage;
                //平移imageview
                //TODO:这里要区分大层级与小层级，暂时没有区分小层级，同一层级的目前都在一个面上.
                _transForm = CATransform3DTranslate(CATransform3DIdentity, 0, 0, (subNode.nodeLevel-1)*levelPadding);
                imageview.layer.transform = _transForm;
                [_rootWindow addSubview:imageview];
                //将tempHiddenArray中的view的隐藏状态置成NO
                for (UIView *view in tempHiddenArray) {
                    view.hidden = NO;
                }
                [tempHiddenArray removeAllObjects];
                recursiveConstruct3DHierarchyTree(subNode, levelPadding);
            }else{//被隐藏，可以设置选项，看要不要进行显示。
                NSLog(@"subview:%@ is hidden",subview);
            }
        }];
    }
}

#pragma mark 以window为根节点，递归构造一颗模型树
static inline void recursiveConstructNodeTree(LayerTreeNode *_Nonnull rootNode,UIView *_Nonnull rootView){
    if (rootView.subviews.count == 0) {
        return;
    }else{
        [rootView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeNode *subNode = [[LayerTreeNode alloc]init];
            subNode.treeNodeView = obj;//记录当前视图
            subNode.isHidden = obj.isHidden;//记录当前视图的hidden状态
            subNode.treeNodeSuperView = rootView;//记录父视图
            [rootNode addSubNode:subNode];
            recursiveConstructNodeTree(subNode, obj);
        }];
    }
}

#pragma mark 查找view所对应的的Node
static inline LayerTreeNode *_Nullable RecursiveFindNode(UIView *view,LayerTreeNode *rootNode){
    if (rootNode.treeNodeView == view) {
        return rootNode;
    }else{
        if (rootNode.subNodes.count > 0) {
            for (LayerTreeNode *layerNode in rootNode.subNodes) {
                return RecursiveFindNode(view, layerNode);
            }
        }else{
            return nil;
        }
    }
    return nil;
}

@interface LayerTreeInspector()<LayerTreeInspectionViewDelegate>
{
    @private
    LayerTreeNode *_rootNode;
}
@end

@implementation LayerTreeInspector

+ (void)showDebugView{
    _instance = [LayerTreeInspector sharedInspector];
    [[LayerTreeInspectionView sharedInspectionView]registerDelegate:_instance];
}

+ (instancetype)sharedInspector{
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
    }
    return self;
}

#pragma ----- LayerTreeInspectionViewDelegate -----
/**
 调试窗口隐藏回调，外界需要重置window的优先级
 */
- (void)layerTreeInspectionViewDidDismiss{
    [_rootWindow makeKeyAndVisible];
}
/**
 刷新树
 注：现在每次刷新都会重新生成一颗以window为根节点的模型树
*/
- (void)layerTreeShouldRefreshHierarchyWithCompletion:(void(^)(LayerTreeNode *currentNode,NSArray<LayerTreeNode *> *frontNodes))completion{
    //获取当前展示的视图控制器
    UIViewController *topViewController = [[LayerTreeInspector sharedInspector] topViewController];
    //重新创建一个根节点
    LayerTreeNode *rootNode = [[LayerTreeNode alloc]init];
    rootNode.treeNodeView = _rootWindow;
    _rootNode = rootNode;
    //重新构造树
    recursiveConstructNodeTree(_rootNode, _rootWindow);
    //查找当前控制器所对应的node
    LayerTreeNode *currentNode = RecursiveFindNode(topViewController.view, _rootNode);
    NSMutableArray *frontNodes = [NSMutableArray array];
    //获取所点击的视图在整个Hierarchy的位置
    while (currentNode.fatherNode != rootNode && currentNode != nil) {
        [frontNodes insertObject:currentNode atIndex:0];
        currentNode = (LayerTreeNode *)currentNode.fatherNode;
    }
    [frontNodes insertObject:rootNode atIndex:0];
    if (completion) {
        if (frontNodes.count == 1) {
            completion(rootNode,frontNodes);
        }else{
            completion(currentNode,frontNodes);
        }
    }
}
/**
3D变换
*/
- (void)layerTreeShouldBegin3DTransformWitPadding:(CGFloat)levelPadding{
    recursiveConstruct3DHierarchyTree(_rootNode, levelPadding);
    for (LayerTreeNode *subNode in _rootNode.subNodes) {
        subNode.treeNodeView.hidden = YES;//强行隐藏
    }
}
/**
从3D状态回到初始状态
*/
- (void)layerTreeShouldResetToIniaialFrom3DTransformWithCompletion:(void(^_Nullable)(BOOL isFinished))completion{
    for (LayerTreeNode *subNode in _rootNode.subNodes) {
        subNode.treeNodeView.hidden = subNode.isHidden;//复原hiden的状态
    }
    for (UIView *subView in _rootWindow.subviews) {
        if ([subView isMemberOfClass:[LayerTreeImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    if (completion) {
        completion(YES);
    }
}

#pragma ----- Event -----
- (void)tapInspectionView:(UITapGestureRecognizer *)ges{
    LayerTreeImageView *subImgView = (LayerTreeImageView *)ges.view;
    [[LayerTreeInspectionView sharedInspectionView]updateSelectNodeView:subImgView];
}

#pragma ----- Private -----

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[_rootWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
       return vc;
    }
    return nil;
}

@end
