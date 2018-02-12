//
//  LayerTreeAssistMacros.h
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#ifndef LayerTreeAssistMacros_h
#define LayerTreeAssistMacros_h

#define LTI_ScreenWidth [UIScreen mainScreen].bounds.size.width

#define LTI_ScreenHeight [UIScreen mainScreen].bounds.size.height

#define LTI_BackGroundColor [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1]

#define LTI_AffineTransformLevelPadding 20

#define LTI_Image(imgName) [UIImage imageNamed:[NSString stringWithFormat:@"LayerTreeAsset.bundle/%@",imgName]]

#endif /* LayerTreeAssistMacros_h */
