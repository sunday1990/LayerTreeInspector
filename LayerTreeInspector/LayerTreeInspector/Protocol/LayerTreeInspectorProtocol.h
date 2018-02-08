//
//  LayerTreeInspectorProtocol.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/8.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef LayerTreeInspectorProtocol_h
#define LayerTreeInspectorProtocol_h
#import "LayerTreeBaseNode.h"
@protocol LayerTreeInspectorProtocol
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
/**
 递归的将所有的子view在z轴方向按照各自的层级平移一段距离,同时改变所有控件的父视图为window

 @param levelPadding 每一层级需要平移的单位距离
 */
+ (void)layerTreeRecursiveTranslateAllSubviewsAtZAxisWith3DTranslatationLevelPadding:(CGFloat)levelPadding;
/**
 返回rootNode
 
 @return return rootNode
 */
+ (LayerTreeBaseNode *)currentRootNode;
@end

#endif /* LayerTreeInspectorProtocol_h */
