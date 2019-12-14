//
//  LayerTreePodHelper.m
//  LayerTreeInspector
//
//  Created by Eychos on 2019/12/14.
//

#import "LayerTreePodHelper.h"
@interface LayerTreePodFakeClass : NSObject
@end
@implementation LayerTreePodFakeClass
@end

@implementation NSBundle (LayerTreePod)

+ (NSBundle *)LayerTreePodBundle {
    NSBundle *bundle = [NSBundle bundleForClass:[LayerTreePodFakeClass class]];
    NSURL *url = [bundle URLForResource:@"LayerTreeInspector" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:url];
}

@end

@implementation UIImage (LayerTreePod)

+ (UIImage *)LayerTreeImageNamed:(NSString *)name {
    NSBundle *targetBundle = [NSBundle LayerTreePodBundle];
    if (targetBundle) {
        return [UIImage imageNamed:name inBundle:targetBundle compatibleWithTraitCollection:nil]?:[UIImage imageNamed:name];
    }else {
        return [UIImage imageNamed:name];
    }
}

@end

