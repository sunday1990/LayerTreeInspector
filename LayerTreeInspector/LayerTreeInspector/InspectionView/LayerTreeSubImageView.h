//
//  LayerTreeSubImageView.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/10.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LayerTreeBaseNode;
@interface LayerTreeSubImageView : UIImageView
@property (nonatomic,strong) LayerTreeBaseNode *viewNode;
@end
