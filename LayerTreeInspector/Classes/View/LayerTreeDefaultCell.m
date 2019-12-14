//
//  LayerTreeDefaultCell.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeDefaultCell.h"
#import "LayerTreeMacros.h"
#define LTI_x_Slider 1000
#define LTI_y_Slider 1001
#define LTI_w_Slider 1002
#define LTI_h_Slider 1003

#define LTI_r_Slider 1004
#define LTI_g_Slider 1005
#define LTI_b_Slider 1006

#define LTI_alpha_Slider 1007

@interface LayerTreeDefaultCell ()
@property (nonatomic, strong) LayerTreeViewDetailModel *model;

@property (nonatomic, strong) UILabel *LTI_clsLabel;
@property (nonatomic, strong) UILabel *LTI_frameLabel;

@property (nonatomic, strong) UISlider *LTI_xSlider;
@property (nonatomic, strong) UISlider *LTI_ySlider;
@property (nonatomic, strong) UISlider *LTI_wSlider;
@property (nonatomic, strong) UISlider *LTI_hSlider;
@property (nonatomic, strong) UILabel *LTI_xLabel;
@property (nonatomic, strong) UILabel *LTI_yLabel;
@property (nonatomic, strong) UILabel *LTI_wLabel;
@property (nonatomic, strong) UILabel *LTI_hLabel;


@property (nonatomic, strong) UILabel *LTI_colorLabel;
@property (nonatomic, strong) UISlider *LTI_rSlider;
@property (nonatomic, strong) UISlider *LTI_gSlider;
@property (nonatomic, strong) UISlider *LTI_bSlider;
@property (nonatomic, strong) UISlider *LTI_rLabel;
@property (nonatomic, strong) UISlider *LTI_gLabel;
@property (nonatomic, strong) UISlider *LTI_bLabel;


@property (nonatomic, strong) UILabel *LTI_alphaLabel;
@property (nonatomic, strong) UISlider *LTI_alphaSlider;

@end

@implementation LayerTreeDefaultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

#pragma mark =========== Method Overrides ===========

- (void)layoutSubviews{
    [super layoutSubviews];
    self.LTI_clsLabel.frame = CGRectMake(12, 12, self.frame.size.width-24, 44);
    self.LTI_frameLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_clsLabel.frame), self.frame.size.width-24, 44);
    self.LTI_xSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_frameLabel.frame)+12, self.frame.size.width-24, 12);
    self.LTI_ySlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_xSlider.frame)+12, self.frame.size.width-24, 12);
    self.LTI_wSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_ySlider.frame)+12, self.frame.size.width-24, 12);
    self.LTI_hSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_wSlider.frame)+12, self.frame.size.width-24, 12);
    self.LTI_colorLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_hSlider.frame)+12, self.frame.size.width-24, 44);
    self.LTI_rSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_colorLabel.frame)+12, self.frame.size.width-24, 12);
    self.LTI_gSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_rSlider.frame)+12, self.frame.size.width-24, 12);
    self.LTI_bSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_gSlider.frame)+12, self.frame.size.width-24, 12);
    self.LTI_alphaLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_bSlider.frame)+12, self.frame.size.width-24, 44);
    self.LTI_alphaSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LTI_alphaLabel.frame)+12, self.frame.size.width-24, 12);
}

#pragma mark =========== Private Methods ===========

- (void)setupSubviews{
    [self.contentView addSubview:self.LTI_clsLabel];
    [self.contentView addSubview:self.LTI_frameLabel];
    [self.contentView addSubview:self.LTI_xSlider];
    [self.contentView addSubview:self.LTI_ySlider];
    [self.contentView addSubview:self.LTI_wSlider];
    [self.contentView addSubview:self.LTI_hSlider];
    [self.contentView addSubview:self.LTI_colorLabel];
    [self.contentView addSubview:self.LTI_rSlider];
    [self.contentView addSubview:self.LTI_gSlider];
    [self.contentView addSubview:self.LTI_bSlider];
    [self.contentView addSubview:self.LTI_alphaLabel];
    [self.contentView addSubview:self.LTI_alphaSlider];
}

- (void)setModel:(LayerTreeViewDetailModel *)model{
    _model = model;
    self.LTI_clsLabel.text = model.info;
    self.LTI_frameLabel.text = [NSString stringWithFormat:@"frame(x,y,w,h): (x:%.2f,y,%.2f,w:%.2f,h:%.2f)",model.x,model.y,model.w,model.h];
    self.LTI_colorLabel.text = [NSString stringWithFormat:@"color(R,G,B): (R:%.2f ,G:%.2f ,B:%.2f)",model.r,model.g,model.b];
    self.LTI_alphaLabel.text = [NSString stringWithFormat:@"alpha(0-1):%.2f",model.alpha];
    if (self.changeAttribute) {
        self.changeAttribute(model);
    }
}

- (void)updateWithModel:(LayerTreeViewDetailModel *)model{
    _model = model;
    self.LTI_clsLabel.text = model.info;
    self.LTI_frameLabel.text = [NSString stringWithFormat:@"frame(x,y,w,h): (x:%.2f,y,%.2f,w:%.2f,h:%.2f)",model.x,model.y,model.w,model.h];
    self.LTI_colorLabel.text = [NSString stringWithFormat:@"color(R,G,B): (R:%.2f ,G:%.2f ,B:%.2f)",model.r,model.g,model.b];
    self.LTI_alphaLabel.text = [NSString stringWithFormat:@"alpha(0-1):%.2f",model.alpha];
    self.LTI_xSlider.value = model.x;
    self.LTI_ySlider.value = model.y;
    self.LTI_wSlider.value = model.w;
    self.LTI_hSlider.value = model.h;
    self.LTI_rSlider.value = model.r;
    self.LTI_gSlider.value = model.g;
    self.LTI_bSlider.value = model.b;
    self.LTI_alphaSlider.value = model.alpha;
}

#pragma mark =========== EventResponse ===========
- (void)sliderValueChanged:(UISlider *)slider{
    switch (slider.tag) {
        case LTI_x_Slider:
        {
            self.model.x = slider.value;
        }
            break;
        case LTI_y_Slider:
        {
            self.model.y = slider.value;
        }
            break;
        case LTI_w_Slider:
        {
            self.model.w = slider.value;
            
        }
            break;
        case LTI_h_Slider:
        {
            self.model.h = slider.value;
            
        }
            break;
        case LTI_r_Slider:
        {
            self.model.r = slider.value;
            
        }
            break;
        case LTI_g_Slider:
        {
            self.model.g = slider.value;
            
        }
            break;
        case LTI_b_Slider:
        {
            self.model.b = slider.value;
            
        }
            break;
        case LTI_alpha_Slider:
        {
            self.model.alpha = slider.value;
        }
            break;
    }
    [self setModel:_model];
}

#pragma mark =========== Setters && Getters ===========
- (UILabel *)LTI_clsLabel{
    if (!_LTI_clsLabel) {
        _LTI_clsLabel = [[UILabel alloc]init];
        _LTI_clsLabel.text = @"class:";
        _LTI_clsLabel.font = [UIFont systemFontOfSize:12];
        _LTI_clsLabel.textColor = [UIColor darkTextColor];
    }
    return _LTI_clsLabel;
}

- (UILabel *)LTI_frameLabel{
    if (!_LTI_frameLabel) {
        _LTI_frameLabel = [[UILabel alloc]init];
        _LTI_frameLabel.text = @"frame(x,y,w,h):";
        _LTI_frameLabel.font = [UIFont systemFontOfSize:12];
        _LTI_frameLabel.textColor = [UIColor darkTextColor];
    }
    return _LTI_frameLabel;
}

- (UILabel *)LTI_colorLabel{
    if (!_LTI_colorLabel) {
        _LTI_colorLabel = [[UILabel alloc]init];
        _LTI_colorLabel.text = @"color(R,G,B):";
        _LTI_colorLabel.font = [UIFont systemFontOfSize:12];
        _LTI_colorLabel.textColor = [UIColor darkTextColor];
    }
    return _LTI_colorLabel;
}

- (UILabel *)LTI_alphaLabel{
    if (!_LTI_alphaLabel) {
        _LTI_alphaLabel = [[UILabel alloc]init];
        _LTI_alphaLabel.text = @"alpha(0-1):";
        _LTI_alphaLabel.font = [UIFont systemFontOfSize:12];
        _LTI_alphaLabel.textColor = [UIColor darkTextColor];
    }
    return _LTI_alphaLabel;
}

- (UISlider *)LTI_xSlider{
    if (!_LTI_xSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_x_Slider;
        slider.maximumValue = LTI_ScreenWidth;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_xSlider = slider;
    }
    return _LTI_xSlider;
}

- (UISlider *)LTI_ySlider{
    if (!_LTI_ySlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_y_Slider;
        slider.maximumValue = LTI_ScreenHeight;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_ySlider = slider;
    }
    return _LTI_ySlider;
}

- (UISlider *)LTI_wSlider{
    if (!_LTI_wSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_w_Slider;
        slider.maximumValue = LTI_ScreenWidth;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_wSlider = slider;
    }
    return _LTI_wSlider;
}

- (UISlider *)LTI_hSlider{
    if (!_LTI_hSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_h_Slider;
        slider.maximumValue = LTI_ScreenHeight;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_hSlider = slider;
    }
    return _LTI_hSlider;
}

- (UISlider *)LTI_rSlider{
    if (!_LTI_rSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_r_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
//        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.minimumTrackTintColor = [UIColor redColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_rSlider = slider;
    }
    return _LTI_rSlider;
}

- (UISlider *)LTI_gSlider{
    if (!_LTI_gSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_g_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor greenColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_gSlider = slider;
    }
    return _LTI_gSlider;
}

- (UISlider *)LTI_bSlider{
    if (!_LTI_bSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_b_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor blueColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_bSlider = slider;
    }
    return _LTI_bSlider;
}

- (UISlider *)LTI_alphaSlider{
    if (!_LTI_alphaSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LTI_alpha_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:LTI_Image(@"LTI_sliderIcon") forState:UIControlStateNormal];
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LTI_alphaSlider = slider;
    }
    return _LTI_alphaSlider;
}

@end

@implementation LayerTreeViewDetailModel

+ (LayerTreeViewDetailModel *)modelWithView:(UIView *)view{
    LayerTreeViewDetailModel *model = [[LayerTreeViewDetailModel alloc]init];
    model.associateView = view;
    model.info = [NSString stringWithFormat:@"<%@:%p>",NSStringFromClass(view.class),view];
    
    model.frame = view.frame;
    model.x = view.frame.origin.x;
    model.y = view.frame.origin.y;
    model.w = view.frame.size.width;
    model.h = view.frame.size.height;
    model.alpha = view.alpha;
    
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [view.backgroundColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    model.r = fromRed;
    model.g = fromGreen;
    model.b = fromBlue;
    model.backGroundColoralpha = fromAlpha;
    return model;
}

@end
