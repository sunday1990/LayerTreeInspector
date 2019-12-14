//
//  LayerTreePodHelper.h
//  LayerTreeInspector
//
//  Created by Eychos on 2019/12/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (LayerTreePod)

+ (NSBundle *)LayerTreePodBundle;

@end



@interface UIImage (LayerTreePod)

+ (UIImage *)LayerTreeImageNamed:(NSString *)name;

@end


NS_ASSUME_NONNULL_END
