//
//  LayerTreeInspector.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeInspector.h"
#import <objc/runtime.h>
#import "LayerTreeNodeModelProtocol.h"
#import "LayerTreeInspectionView.h"
#import "LayerTreeAssistMacros.h"
#import "LayerTreeSubImageView.h"

static LayerTreeBaseNode *LTI_rootNode;

static UIWindow * LTI_rootWindow;

#pragma mark将view生成图片
static inline UIImage *RenderImageFromViewWithRect(UIView *view,CGRect frame){
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

#pragma mark 根据节点视图和节点模型递归的将该节点视图所有的子节点加入到当前节点模型中
static inline void RecursiveInitializeSubNodesAtNodeWithNewAddView(LayerTreeBaseNode *_Nonnull node,UIView *_Nonnull view){
    if (view.subviews.count == 0) {
        return;
    }else{
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeBaseNode *subNode = [[LayerTreeBaseNode alloc]init];
            subNode.LayerTreeNodeView = obj;
            subNode.LayerTreeFatherNodeView = view;
            [node addSubNode:subNode];
            RecursiveInitializeSubNodesAtNodeWithNewAddView(subNode, obj);
        }];
    }
}

#pragma mark 递归的根据rootNode和view查找该view对应的Node
static inline LayerTreeBaseNode *_Nullable RecursiveFindNodeWith(UIView *view,LayerTreeBaseNode *rootNode){
    if (rootNode.LayerTreeNodeView == view) {
        return rootNode;
    }else{
        if (rootNode.subNodes.count > 0) {
            for (id<LayerTreeNodeModelProtocol>node in rootNode.subNodes) {
                LayerTreeBaseNode *layerNode = (LayerTreeBaseNode *)node;
                return RecursiveFindNodeWith(view, layerNode);
            }
        }else{
            return nil;
        }
    }
    return nil;
}

#pragma mark 递归的生成3D视图
CATransform3D LTI_transForm;
static inline void RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(LayerTreeBaseNode *_Nonnull rootNode,CGFloat levelPadding){
    if (rootNode.subNodes.count == 0||[rootNode.LayerTreeNodeView isMemberOfClass:[LayerTreeInspectionView class]]) {
        return;
    }else{
        [rootNode.subNodes enumerateObjectsUsingBlock:^(id<LayerTreeNodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeBaseNode *subNode = (LayerTreeBaseNode *)obj;
            UIView *subview = (UIView *)subNode.LayerTreeNodeView;
            NSMutableArray *tempHiddenArray = [NSMutableArray array];
            //先隐藏所有的子view，然后再生成该view对应的图片
            if (subview.hidden == NO) {
                for (UIView *contentView in subview.subviews) {
                    if (!contentView.hidden) {
                        contentView.hidden = YES;//记录那些被隐藏的view
                        [tempHiddenArray addObject:contentView];
                    }
                }
                //生成对应的图片
                UIImage *subImage = RenderImageFromViewWithRect(subview, subview.bounds);
                //转换frame
                CGRect imgViewFrame = [LTI_rootWindow convertRect:subview.frame fromView:subview.superview];
                //创建imageview
                LayerTreeSubImageView *imageview = [[LayerTreeSubImageView alloc]initWithFrame:imgViewFrame];
                imageview.layer.opacity = 0.9;
                imageview.viewNode = subNode;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:[LayerTreeInspectionView sharedDebugView] action:@selector(tapInspectionView:)];
#pragma clang diagnostic pop
                imageview.userInteractionEnabled = YES;
                [imageview addGestureRecognizer:tap];
                imageview.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
                imageview.image = subImage;
                //平移imageview
#warning 这里要区分大层级与小层级，暂时没有区分小层级，同一层级的目前都在一个面上，似乎没有必要区分小层级。
//                NSUInteger index = [rootNode.subNodes indexOfObject:subNode];//获取该视图在父亲视图中的位置
                LTI_transForm = CATransform3DTranslate(CATransform3DIdentity, 0, 0, (subNode.nodeLevel-1)*levelPadding);
                imageview.layer.transform = LTI_transForm;
                [LTI_rootWindow addSubview:imageview];
                //将tempHiddenArray中的view的隐藏状态置成NO
                for (UIView *view in tempHiddenArray) {
                    view.hidden = NO;
                }
                [tempHiddenArray removeAllObjects];
                RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(subNode, levelPadding);
            }else{//被隐藏，可以设置选项，看要不要进行显示。
                NSLog(@"subview:%@ is hidden",subview);
            }
        }];
    }
}

@implementation LayerTreeInspector

+ (void)showDebugView{
    if (LTI_rootWindow == nil) {
        LTI_rootWindow = [UIApplication sharedApplication].keyWindow;
    }
    [LayerTreeInspectionView sharedDebugView];
}

+ (LayerTreeBaseNode *)currentRootNode{
    return LTI_rootNode;
}

+ (void)layerTreeFindRootNodeAtWindowWithCompletion:(void(^)(LayerTreeBaseNode *rootNode))completion{
    UIWindow *window = LTI_rootWindow;
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
    LTI_rootNode = rootNode;
    if (completion) {
        completion(rootNode);
    }
}

+ (void)layerTreeFindCurrentNodeAtTopviewWithCompletion:(void(^)(LayerTreeBaseNode *currentNode,NSArray<LayerTreeBaseNode *> *frontNodes))completion{
    UIViewController *topViewController = [self topViewController];
    UIWindow *window = LTI_rootWindow;
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
    LTI_rootNode = rootNode;
    LayerTreeBaseNode *currentNode = RecursiveFindNodeWith(topViewController.view, rootNode);
    NSMutableArray *frontNodes = [NSMutableArray array];
    while (currentNode.fatherNode != rootNode && currentNode != nil) {
        [frontNodes insertObject:currentNode atIndex:0];
        currentNode = (LayerTreeBaseNode *)currentNode.fatherNode;
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

+ (void)layerTreeRecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding:(CGFloat)levelPadding{
    RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(LTI_rootNode, levelPadding);
    for (LayerTreeBaseNode *subNode in LTI_rootNode.subNodes) {
        subNode.LayerTreeNodeView.hidden = YES;
    }
}

+ (void)layerTreeRevertFrom3DTransformationToTheInitialPlanarStateWithCompletion:(void(^_Nullable)(BOOL isFinished))completion{
    for (LayerTreeBaseNode *subNode in LTI_rootNode.subNodes) {
        subNode.LayerTreeNodeView.hidden = NO;
    }
    for (UIView *subView in LTI_rootWindow.subviews) {
        if ([subView isMemberOfClass:[LayerTreeSubImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    if (completion) {
        completion(YES);
    }
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[LTI_rootWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
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
