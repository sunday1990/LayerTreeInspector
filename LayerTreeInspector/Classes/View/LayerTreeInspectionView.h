//
//  LayerTreeInspectionView.h
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,LayerTreeStyle)
{
    LayerTreeStyleDefault = 0,      //默认的面包屑形式
    LayerTreeStyle3DTransForm = 1,  //3D变换形式
    LayerTreeStyleGraphics = 2      //🌲形式
};

@class LayerTreeBaseNode;
@class LayerTreeImageView;

@protocol LayerTreeInspectionViewDelegate
/**
 调试窗口隐藏回调，外界需要重置window的优先级
 */
- (void)layerTreeInspectionViewDidDismiss;
/**
 获取topViewController的视图所在的节点
 
 @param completion 获取后的回调
 */
- (void)layerTreeShouldRefreshCurrentNodeAtTopviewWithCompletion:(void(^_Nullable)(LayerTreeBaseNode * _Nullable currentNode,NSArray<LayerTreeBaseNode *> * _Nullable node))completion;
/**
图层树进行3D变换
 @param levelPadding 每一层级需要平移的单位距离
 */
- (void)layerTreeShould3DTransformWitPadding:(CGFloat)levelPadding;
/**
 图层树从3D状态恢复到初始的平面状态

 */
- (void)layerTreeShouldResetToIniaialFrom3DTransform:(void(^_Nullable)(BOOL isFinished))completion;

@end

@interface LayerTreeInspectionView : UIView
/**
 默认展示普通的面包屑形式

 @return DebugView单例
 */
+ (instancetype _Nonnull )sharedInspectionView;
/**
设置代理
*/
- (void)registerDelegate:(_Nonnull id<LayerTreeInspectionViewDelegate>)delegate;
/**
更新所点击的视图
*/
- (void)updateSelectNodeView:( LayerTreeImageView * _Nonnull )nodeView;

@end
