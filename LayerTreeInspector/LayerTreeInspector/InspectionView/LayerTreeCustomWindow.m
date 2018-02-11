//
//  LayerTreeCustomWindow.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/9.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeCustomWindow.h"

@implementation LayerTreeCustomWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)window{
    LayerTreeCustomWindow *window = [[LayerTreeCustomWindow alloc]init];
    return window;
}


@end
