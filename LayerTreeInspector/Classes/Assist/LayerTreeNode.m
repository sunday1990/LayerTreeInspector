//
//  LayerTreeNode.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/5.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeNode.h"

CGFloat layerTreeHeight;
CGFloat layerTreetempNodeLevel;

#pragma mark 获取根节点
static inline id<LayerTreeNodeProtocol>RecursiveGetRootNodeWithNode(id<LayerTreeNodeProtocol> node){
    if (node.fatherNode == node) {
        node.expand = YES;
        return node;
    }else{
        node = node.fatherNode;
        layerTreetempNodeLevel = layerTreetempNodeLevel+1;
        return  RecursiveGetRootNodeWithNode(node);
    }
}

#pragma mark 根据根节点获取树的高度
static inline void RecursiveCalculateTreeHeightWithRootNode(id<LayerTreeNodeProtocol> rootNode){
    if (rootNode.subNodes.count == 0||!rootNode.isExpand) {
        return ;
    }
    if (!isnan(rootNode.subTreeHeight)) {
        layerTreeHeight += rootNode.subTreeHeight;
    }
    for (id<LayerTreeNodeProtocol>obj in rootNode.subNodes) {
        RecursiveCalculateTreeHeightWithRootNode(obj);
    }
}

@implementation LayerTreeNode

@synthesize
subNodes = _subNodes,
nodeHeight = _nodeHeight,
nodeID = _nodeID,
fatherNode = _fatherNode,
/*NodeTreeViewStyleBreadcrumbs*/
subTreeHeight = _subTreeHeight,
/*NodeTreeViewStyleExpansion*/
expand = _expand,
currentTreeHeight = _currentTreeHeight,
nodeLevel = _nodeLevel,
treeNodeView = _treeNodeView,
isHidden = _isHidden,
treeNodeSuperView = _treeNodeSuperView;

- (instancetype)init{
    if (self = [super init]) {
        _subNodes = [NSMutableArray array];
        _nodeHeight = 44;
        _subTreeHeight = 0;
    }
    return self;
}

- (CGFloat)subTreeHeight{
    if (!_subTreeHeight) {
        CGFloat tempSubTreeHeight = 0;
        for (id<LayerTreeNodeProtocol>  _Nonnull obj in self.subNodes) {
            tempSubTreeHeight += obj.nodeHeight;
        }
        _subTreeHeight = tempSubTreeHeight;
    }
    return _subTreeHeight;
}

- (CGFloat)currentTreeHeight{
    layerTreeHeight = _currentTreeHeight = 0;
    if (self.fatherNode) {
        id<LayerTreeNodeProtocol> rootNode = RecursiveGetRootNodeWithNode(self);
        if (rootNode == nil) {
            NSLog(@"未获取到rootNode");
        }else{
            RecursiveCalculateTreeHeightWithRootNode(rootNode);
            _currentTreeHeight = layerTreeHeight;
        }
    }
    return _currentTreeHeight;
}

- (NSInteger)nodeLevel{
    if (!_nodeLevel || _nodeLevel == 0) {
        layerTreetempNodeLevel = 0;
        id<LayerTreeNodeProtocol> rootNode = RecursiveGetRootNodeWithNode(self);
        rootNode.nodeLevel = 0;
        _nodeLevel = layerTreetempNodeLevel;
    }
    return _nodeLevel;
}

- (void)getTreeHeightAtFatherNode:(id<LayerTreeNodeProtocol>)fatherNode{
    if (fatherNode.subNodes.count == 0||!fatherNode.isExpand) {//叶子节点
        return ;
    }
    if (!isnan(fatherNode.subTreeHeight)) {
        _currentTreeHeight += fatherNode.subTreeHeight;
    }
    for (id<LayerTreeNodeProtocol>obj in fatherNode.subNodes) {
        [self getTreeHeightAtFatherNode:obj];
    }
}

- (void)addSubNode:(id<LayerTreeNodeProtocol>)node{
    node.fatherNode = self;
    [self.subNodes addObject:node];
}

- (void)addSubNodesFromArray:(NSArray<id<LayerTreeNodeProtocol>> *)nodes{
    [nodes enumerateObjectsUsingBlock:^(id<LayerTreeNodeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.fatherNode = self;
    }];
    [self.subNodes addObjectsFromArray:nodes];
}

- (void)deleteSubNode:(id<LayerTreeNodeProtocol>)node{
    [self.subNodes removeObject:node];
}

@end
