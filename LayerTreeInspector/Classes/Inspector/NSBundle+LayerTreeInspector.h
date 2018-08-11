//
//  NSBundle+LayerTreeInspector.h
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/8/11.
//

#import <Foundation/Foundation.h>

@interface NSBundle (LayerTreeInspector)
+ (instancetype)LT_imageBundle;
+ (NSString *)LT_imageBundlePath;
+ (UIImage *)LT_imageWithName:(NSString *)name;
@end
