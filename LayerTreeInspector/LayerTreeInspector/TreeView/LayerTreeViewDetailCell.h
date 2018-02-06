//
//  LayerTreeViewDetailCell.h
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LayerTreeViewDetailModel;

@interface LayerTreeViewDetailCell : UITableViewCell

@property (nonatomic,copy) void(^_Nullable changeAttribute)(LayerTreeViewDetailModel * _Nonnull model);

- (void)updateWithModel:(LayerTreeViewDetailModel *_Nonnull)model;

@end


@interface LayerTreeViewDetailModel:NSObject

@property (nonatomic, strong) NSString * _Nullable info;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat w;
@property (nonatomic, assign) CGFloat h;

@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, assign) CGFloat backGroundColoralpha;

@property (nonatomic, assign) CGFloat r;
@property (nonatomic, assign) CGFloat g;
@property (nonatomic, assign) CGFloat b;

@property (nonatomic,weak) UIView *_Nullable associateView;


+ (LayerTreeViewDetailModel *_Nullable)modelWithView:(UIView *_Nonnull)view;

@end
