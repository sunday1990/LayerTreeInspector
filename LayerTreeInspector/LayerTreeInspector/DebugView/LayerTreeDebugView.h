//
//  LayerTreeDebugView.h
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayerTreeDebugView : UIView

/**
 默认展示普通的面包屑形式

 @return DebugView单例
 */
+ (instancetype _Nonnull )sharedDebugView;

@end
