//
//  LayerTreeInspector.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayerTreeBaseNode.h"

@interface LayerTreeInspector : NSObject
/**
 开始监控,自动刷新树，但是很耗费性能，不建议使用
 */
+ (void)startMonitor;
/**
 关闭监控
 */
+ (void)closeMonitor;

//////////以上方法自动监控，现在改为手动获取

/**
 展示DebugView,必须展示
 */
+ (void)showDebugView;

/**
 返回rootNode
 
 @return return rootNode
 */
+ (LayerTreeBaseNode *)currentRootNode;

#pragma mark api需要重新设计

/**
 获取节点视图为UIWindwo的根节点
 
 @param completion completion回调
 */
+ (void)layerTreeFindRootNodeAtWindowWithCompletion:(void(^)(LayerTreeBaseNode *rootNode))completion;

/**
 获取topViewController的视图所在的节点

 @param completion 获取后的回调
 */
+ (void)layerTreeFindCurrentNodeAtTopviewWithCompletion:(void(^)(LayerTreeBaseNode *currentNode,NSArray<LayerTreeBaseNode *> *node))completion;

+ (void)layerTreeRecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding:(CGFloat)levelPadding;

@end
