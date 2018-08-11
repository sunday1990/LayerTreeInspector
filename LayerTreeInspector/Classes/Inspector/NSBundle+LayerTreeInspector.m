//
//  NSBundle+LayerTreeInspector.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/8/11.
//

#import "NSBundle+LayerTreeInspector.h"
#import "LayerTreeInspector.h"

@implementation NSBundle (LayerTreeInspector)
+ (NSString *)LT_imageBundlePath{
    static NSString *bundlePath = nil;
    if (bundlePath == nil) {
        bundlePath = [[NSBundle bundleForClass:[LayerTreeInspector class]]resourcePath];
    }
    return bundlePath;
}

+ (instancetype)LT_imageBundle{
    static NSBundle *LT_bundle = nil;
    if (LT_bundle == nil) {
        LT_bundle = [NSBundle bundleForClass:[LayerTreeInspector class]];
    }
    return LT_bundle;
}

+ (UIImage *)LT_imageWithName:(NSString *)name{
    
   UIImage * targetImage = [UIImage imageWithContentsOfFile:[[self LT_imageBundlePath]stringByAppendingPathComponent:name]];
    return targetImage;
}

@end
