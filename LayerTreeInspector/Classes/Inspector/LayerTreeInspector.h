//
//  LayerTreeInspector.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayerTreeInspectorProtocol.h"

@interface LayerTreeInspector : NSObject<LayerTreeInspectorProtocol>
/**
 展示DebugView
 */
+ (void)showDebugView;

@end
