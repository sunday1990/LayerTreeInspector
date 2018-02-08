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
#import "LayerTreeDebugView.h"
#import "LayerTreeAssistMacros.h"

static LayerTreeBaseNode *LTI_rootNode;
UIWindow *_window;
struct {
    unsigned int rootNodeInitialize:1;
    unsigned int windowInitialize:1;
    unsigned int startMonitor:1;
}LayerTreeFirstInitializeState;

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

CATransform3D LTI_transForm;
NSInteger LTI_treeDepth;
static inline void RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(LayerTreeBaseNode *_Nonnull rootNode,CGFloat levelPadding){
    if (rootNode.subNodes.count == 0||[rootNode.LayerTreeNodeView isMemberOfClass:[LayerTreeDebugView class]]) {
        return;
    }else{
        [rootNode.subNodes enumerateObjectsUsingBlock:^(id<LayerTreeNodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeBaseNode *subNode = (LayerTreeBaseNode *)obj;
            if (![subNode.LayerTreeNodeView isMemberOfClass:NSClassFromString(@"LayerTreeDebugView")]) {
                LTI_treeDepth = subNode.nodeLevel>LTI_treeDepth?subNode.nodeLevel:LTI_treeDepth;
                subNode.LayerTreeNodeView.frame = [[UIApplication sharedApplication].keyWindow convertRect:subNode.LayerTreeNodeView.frame fromView:subNode.LayerTreeNodeView.superview];
                [[UIApplication sharedApplication].keyWindow addSubview:subNode.LayerTreeNodeView];                
                LTI_transForm = CATransform3DTranslate(CATransform3DIdentity, 0, 0, (subNode.nodeLevel-1)*levelPadding);
                subNode.LayerTreeNodeView.layer.transform = LTI_transForm;
                RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(subNode, levelPadding);
            }else{
                NSLog(@"过滤掉debugView");
            }
        }];
    }
}

#pragma mark 递归查找UIWindow           (可废弃)
static inline UIWindow *_Nullable RecursiveFindWindow(UIView *view){
    if ([view isMemberOfClass:[UIWindow class]]) {
        return (UIWindow *)view;
    }else{
        if (view.superview) {
            return RecursiveFindWindow(view.superview);
        }else{
            return nil;
        }
    }
    return nil;
}

@implementation LayerTreeInspector

#pragma mark 分界线
+ (void)showDebugView{
    [LayerTreeDebugView sharedDebugView];
}

+ (LayerTreeBaseNode *)currentRootNode{
    return LTI_rootNode;
}

+ (void)layerTreeFindRootNodeAtWindowWithCompletion:(void(^)(LayerTreeBaseNode *rootNode))completion{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
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
    UIWindow *window = RecursiveFindWindow(topViewController.view);
    _window = window;
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
    LTI_rootNode = rootNode;
    LayerTreeBaseNode *currentNode = RecursiveFindNodeWith(topViewController.view, rootNode);
    NSMutableArray *frontNodes = [NSMutableArray array];
    while (currentNode.fatherNode != rootNode) {
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
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[LayerTreeDebugView sharedDebugView]];
    LTI_transForm = CATransform3DTranslate(CATransform3DIdentity, 0, 0, LTI_treeDepth*levelPadding);
    [LayerTreeDebugView sharedDebugView].layer.transform = LTI_transForm;
}

+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
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
