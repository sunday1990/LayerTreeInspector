//
//  LayerTree3DNodeModelProtocol.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/12.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef LayerTree3DNodeModelProtocol_h
#define LayerTree3DNodeModelProtocol_h
#import <Accelerate/Accelerate.h>
#import "LayerTreeNodeModelProtocol.h"

#pragma mark 3D空间节点的数据结构定义
typedef struct ThreeDimensionalNodeVector *ThreeDimensionalPtrToNodeVector;
ThreeDimensionalPtrToNodeVector ThreeDimensionalTree;

struct ThreeDimensionalNodeVector {
    CGFloat edgeLength;                              //节点的边长
    void *element;                                   //节点所在的元素
    int depth;                                       //节点深度
    ThreeDimensionalPtrToNodeVector father3DNode;    //父节点
    ThreeDimensionalPtrToNodeVector sub3DNodes[];   //儿子节点
};

@protocol LayerTree3DNodeProtocol<LayerTreeNodeModelProtocol>

@end

#endif /* LayerTree3DNodeModelProtocol_h */
