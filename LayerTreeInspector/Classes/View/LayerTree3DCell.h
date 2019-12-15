//
//  LayerTree3DCell.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/11.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LayerTreeNode;
@interface LayerTree3DCell : UITableViewCell
- (void)updateWithNode:(LayerTreeNode *)node;
@end
