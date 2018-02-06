//
//  LayerTreeBaseNode.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/5.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeBaseNode.h"

CGFloat layerTreeHeight;
CGFloat layerTreetempNodeLevel;

#pragma mark 获取根节点
static inline id<NodeModelProtocol>RecursiveGetRootNodeWithNode(id<NodeModelProtocol> node){
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
static inline void RecursiveCalculateTreeHeightWithRootNode(id<NodeModelProtocol> rootNode){
    if (rootNode.subNodes.count == 0||!rootNode.isExpand) {
        return ;
    }
    if (!isnan(rootNode.subTreeHeight)) {
        layerTreeHeight += rootNode.subTreeHeight;
    }
    for (id<NodeModelProtocol>obj in rootNode.subNodes) {
        RecursiveCalculateTreeHeightWithRootNode(obj);
    }
}

@implementation LayerTreeBaseNode

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
LayerTreeNodeView = _LayerTreeNodeView;

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
        for (id<NodeModelProtocol>  _Nonnull obj in self.subNodes) {
            tempSubTreeHeight += obj.nodeHeight;
        }
        _subTreeHeight = tempSubTreeHeight;
    }
    return _subTreeHeight;
}

- (CGFloat)currentTreeHeight{
    layerTreeHeight = _currentTreeHeight = 0;
    if (self.fatherNode) {
        id<NodeModelProtocol> rootNode = RecursiveGetRootNodeWithNode(self);
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
        id<NodeModelProtocol> rootNode = RecursiveGetRootNodeWithNode(self);
        rootNode.nodeLevel = 0;
        _nodeLevel = layerTreetempNodeLevel;
    }
    return _nodeLevel;
}

- (void)getTreeHeightAtFatherNode:(id<NodeModelProtocol>)fatherNode{
    if (fatherNode.subNodes.count == 0||!fatherNode.isExpand) {//叶子节点
        return ;
    }
    if (!isnan(fatherNode.subTreeHeight)) {
        _currentTreeHeight += fatherNode.subTreeHeight;
    }
    for (id<NodeModelProtocol>obj in fatherNode.subNodes) {
        [self getTreeHeightAtFatherNode:obj];
    }
}

- (void)addSubNode:(id<NodeModelProtocol>)node{
    node.fatherNode = self;
    [self.subNodes addObject:node];
}

- (void)addSubNodesFromArray:(NSArray<id<NodeModelProtocol>> *)nodes{
    [nodes enumerateObjectsUsingBlock:^(id<NodeModelProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.fatherNode = self;
    }];
    [self.subNodes addObjectsFromArray:nodes];
}

- (void)deleteSubNode:(id<NodeModelProtocol>)node{
    [self.subNodes removeObject:node];
}

@end
