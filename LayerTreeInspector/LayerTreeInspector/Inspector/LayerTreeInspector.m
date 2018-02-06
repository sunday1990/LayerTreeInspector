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
static LayerTreeBaseNode *rootNode;

struct {
    unsigned int rootNodeInitialize:1;
    unsigned int windowInitialize:1;
    unsigned int startMonitor:1;
}LayerTreeFirstInitializeState;

static inline void LYT_EXChangeInstanceMethod(Class _originalClass ,SEL _originalSel,Class _targetClass ,SEL _targetSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_targetClass, _targetSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

#pragma mark 根据节点视图和节点模型递归的将该节点视图所有的子节点加入到当前节点模型中
static inline void RecursiveInitializeSubNodesAtNodeWithNewAddView(LayerTreeBaseNode *_Nonnull node,UIView *_Nonnull view){
    if (view.subviews.count == 0) {
        return;
    }else{
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeBaseNode *subNode = [[LayerTreeBaseNode alloc]init];
            subNode.LayerTreeNodeView = obj;
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
            for (id<NodeModelProtocol>node in rootNode.subNodes) {
                LayerTreeBaseNode *layerNode = (LayerTreeBaseNode *)node;
                return RecursiveFindNodeWith(view, layerNode);
            }
        }else{
            return nil;
        }
    }
    return nil;
}

#pragma mark 递归查找UIWindow
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

@interface UIView (LYT_Extend)

@end

@implementation UIView (LYT_Extend)

- (void)LYT_addSubview:(UIView *)view{
    [self LYT_addSubview:view];
    if (LayerTreeFirstInitializeState.windowInitialize == 1) {
        if (![view isKindOfClass:[LayerTreeDebugView class]]) {
            [self constructTreeNodeWithView:view];
        }
    }else{
        if ([self isMemberOfClass:[UIWindow class]]) {
            LayerTreeFirstInitializeState.windowInitialize = 1;
            [self constructTreeNodeWithView:view];
        }
    }
}

- (void)LYT_removeFromSuperview{
    [self destructTreeNodeWithView:self];
    [self LYT_removeFromSuperview];
}

- (void)constructTreeNodeWithView:(UIView *)view{
    if (rootNode.LayerTreeNodeView == nil) {//初始化根节点
        rootNode.LayerTreeNodeView = self;
    }
    LayerTreeBaseNode *layerNode = RecursiveFindNodeWith(self, rootNode);
    if (layerNode) {
        LayerTreeBaseNode *subLayerNode = [[LayerTreeBaseNode alloc]init];
        subLayerNode.LayerTreeNodeView = view;
        RecursiveInitializeSubNodesAtNodeWithNewAddView(subLayerNode, view);
        [layerNode addSubNode:subLayerNode];
    }else{
        
    }
}

- (void)destructTreeNodeWithView:(UIView *)view{
    //根据view找到对应的node，然后删除这个node,这个操作可以记录下来，就不用每次都查找了。
    LayerTreeBaseNode *node = RecursiveFindNodeWith(view, rootNode);
    [node.fatherNode.subNodes removeObject:node];
}
@end

@implementation LayerTreeInspector

+ (void)startMonitor{
    if (LayerTreeFirstInitializeState.startMonitor == 1) {//已经处于开启状态
        NSLog(@"Duplicate start monitor");
    }else{
        rootNode = [[LayerTreeBaseNode alloc]init];
        LayerTreeFirstInitializeState.rootNodeInitialize = 1;
        LayerTreeFirstInitializeState.startMonitor = 1;
        LYT_EXChangeInstanceMethod([UIView class], @selector(addSubview:), [UIView class], @selector(LYT_addSubview:));
        LYT_EXChangeInstanceMethod([UIView class], @selector(removeFromSuperview), [UIView class], @selector(LYT_removeFromSuperview));
    }
}

+ (void)closeMonitor{
    if (LayerTreeFirstInitializeState.startMonitor == 1) {//已经处于开启状态，这时候需要关闭
        rootNode = nil;
        LayerTreeFirstInitializeState.rootNodeInitialize = 0;
        LayerTreeFirstInitializeState.startMonitor = 0;
        LYT_EXChangeInstanceMethod([UIView class], @selector(addSubview:), [UIView class], @selector(LYT_addSubview:));
        LYT_EXChangeInstanceMethod([UIView class], @selector(removeFromSuperview), [UIView class], @selector(LYT_removeFromSuperview));
    }else{
        NSLog(@"Please start monitor first");
    }
}

#pragma mark 分界线
+ (void)showDebugView{
    [LayerTreeDebugView sharedDebugView];
}

+ (LayerTreeBaseNode *)currentRootNode{
    return rootNode;
}

+ (void)layerTreeFindRootNodeAtWindowWithCompletion:(void(^)(LayerTreeBaseNode *rootNode))completion{
    UIViewController *topViewController = [self topViewController];
    UIWindow *window = RecursiveFindWindow(topViewController.view);
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
    if (completion) {
        completion(rootNode);
    }
}

+ (void)layerTreeFindCurrentNodeAtTopviewWithCompletion:(void(^)(LayerTreeBaseNode *currentNode,NSArray<LayerTreeBaseNode *> *frontNodes))completion{
    UIViewController *topViewController = [self topViewController];
    UIWindow *window = RecursiveFindWindow(topViewController.view);
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
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
