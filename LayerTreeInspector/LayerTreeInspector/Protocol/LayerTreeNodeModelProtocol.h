//
//  LayerTreeNodeModelProtocol.h
//  LayerTree
//
//  Created by ccSunday on 2018/2/5.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef LayerTreeNodeModelProtocol_h
#define LayerTreeNodeModelProtocol_h
#import <UIKit/UIKit.h>
#import "NodeModelProtocol.h"
@protocol LayerTreeNodeModelProtocol<NodeModelProtocol>
/**
 该节点元素对应的所有子节点,添加子节点的时候，不要直接向数组中添加，而应该通过addNode的方式，这样会自动设置父节点
 */
@property (nonatomic ,weak) UIView *LayerTreeNodeView;

@end

#endif /* LayerTreeNodeModelProtocol_h */
