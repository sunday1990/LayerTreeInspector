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

static LayerTreeBaseNode *_rootNode;
UIWindow *_window;
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

CATransform3D transForm;
static inline void RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(LayerTreeBaseNode *_Nonnull rootNode,CGFloat levelPadding){
    if (rootNode.subNodes.count == 0) {
        return;
    }else{
        [rootNode.subNodes enumerateObjectsUsingBlock:^(id<LayerTreeNodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            LayerTreeBaseNode *subNode = (LayerTreeBaseNode *)obj;
            [subNode.LayerTreeNodeView.superview convertRect:subNode.LayerTreeNodeView.frame toView:[UIApplication sharedApplication].keyWindow];
            [[UIApplication sharedApplication].keyWindow addSubview:subNode.LayerTreeNodeView];
            NSLog(@"view:%@ z轴平移：%f",NSStringFromClass(subNode.LayerTreeNodeView.class),(subNode.nodeLevel-1)*levelPadding);
            transForm = CATransform3DTranslate(CATransform3DIdentity, 0, 0, (subNode.nodeLevel-1)*levelPadding);
            subNode.LayerTreeNodeView.layer.transform = transForm;
            RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(subNode, levelPadding);
        }];
    }
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
    if (_rootNode.LayerTreeNodeView == nil) {//初始化根节点
        _rootNode.LayerTreeNodeView = self;
    }
    LayerTreeBaseNode *layerNode = RecursiveFindNodeWith(self, _rootNode);
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
    LayerTreeBaseNode *node = RecursiveFindNodeWith(view, _rootNode);
    [node.fatherNode.subNodes removeObject:node];
}
@end

@implementation LayerTreeInspector

+ (void)startMonitor{
    if (LayerTreeFirstInitializeState.startMonitor == 1) {//已经处于开启状态
        NSLog(@"Duplicate start monitor");
    }else{
        _rootNode = [[LayerTreeBaseNode alloc]init];
        LayerTreeFirstInitializeState.rootNodeInitialize = 1;
        LayerTreeFirstInitializeState.startMonitor = 1;
        LYT_EXChangeInstanceMethod([UIView class], @selector(addSubview:), [UIView class], @selector(LYT_addSubview:));
        LYT_EXChangeInstanceMethod([UIView class], @selector(removeFromSuperview), [UIView class], @selector(LYT_removeFromSuperview));
    }
}

+ (void)closeMonitor{
    if (LayerTreeFirstInitializeState.startMonitor == 1) {//已经处于开启状态，这时候需要关闭
        _rootNode = nil;
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
    return _rootNode;
}

+ (void)layerTreeFindRootNodeAtWindowWithCompletion:(void(^)(LayerTreeBaseNode *rootNode))completion{
//    UIViewController *topViewController = [self topViewController];
//    UIWindow *window = RecursiveFindWindow(topViewController.view);
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    LayerTreeBaseNode *rootNode = [[LayerTreeBaseNode alloc]init];
    rootNode.LayerTreeNodeView = window;
    RecursiveInitializeSubNodesAtNodeWithNewAddView(rootNode, window);
    _rootNode = rootNode;
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
    _rootNode = rootNode;
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
    RecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding(_rootNode, levelPadding);
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
