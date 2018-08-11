//
//  LayerTreeView3DDetailCell.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/11.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LayerTreeBaseNode;
@interface LayerTreeView3DDetailCell : UITableViewCell
- (void)updateWithNode:(LayerTreeBaseNode *)node;
@end
