//
//  LayerTreeImageView.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LayerTreeNode;
@interface LayerTreeImageView : UIImageView
@property (nonatomic,strong) LayerTreeNode *viewNode;
@end
