//
//  LayerTreeViewDetailCell.m
//  LayerTree
//
//  Created by ccSunday on 2018/2/6.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTreeViewDetailCell.h"
#import "LayerTreeAssistMacros.h"
#define LYT_x_Slider 1000
#define LYT_y_Slider 1001
#define LYT_w_Slider 1002
#define LYT_h_Slider 1003

#define LYT_r_Slider 1004
#define LYT_g_Slider 1005
#define LYT_b_Slider 1006

#define LYT_alpha_Slider 1007

@interface LayerTreeViewDetailCell ()
@property (nonatomic, strong) LayerTreeViewDetailModel *model;

@property (nonatomic, strong) UILabel *LYT_clsLabel;
@property (nonatomic, strong) UILabel *LYT_frameLabel;

@property (nonatomic, strong) UISlider *LYT_xSlider;
@property (nonatomic, strong) UISlider *LYT_ySlider;
@property (nonatomic, strong) UISlider *LYT_wSlider;
@property (nonatomic, strong) UISlider *LYT_hSlider;
@property (nonatomic, strong) UILabel *LYT_xLabel;
@property (nonatomic, strong) UILabel *LYT_yLabel;
@property (nonatomic, strong) UILabel *LYT_wLabel;
@property (nonatomic, strong) UILabel *LYT_hLabel;


@property (nonatomic, strong) UILabel *LYT_colorLabel;
@property (nonatomic, strong) UISlider *LYT_rSlider;
@property (nonatomic, strong) UISlider *LYT_gSlider;
@property (nonatomic, strong) UISlider *LYT_bSlider;
@property (nonatomic, strong) UISlider *LYT_rLabel;
@property (nonatomic, strong) UISlider *LYT_gLabel;
@property (nonatomic, strong) UISlider *LYT_bLabel;


@property (nonatomic, strong) UILabel *LYT_alphaLabel;
@property (nonatomic, strong) UISlider *LYT_alphaSlider;

@end

@implementation LayerTreeViewDetailCell

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
    self.LYT_clsLabel.frame = CGRectMake(12, 12, self.frame.size.width-24, 44);
    self.LYT_frameLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_clsLabel.frame), self.frame.size.width-24, 44);
    self.LYT_xSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_frameLabel.frame)+12, self.frame.size.width-24, 12);
    self.LYT_ySlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_xSlider.frame)+12, self.frame.size.width-24, 12);
    self.LYT_wSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_ySlider.frame)+12, self.frame.size.width-24, 12);
    self.LYT_hSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_wSlider.frame)+12, self.frame.size.width-24, 12);
    self.LYT_colorLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_hSlider.frame)+12, self.frame.size.width-24, 44);
    self.LYT_rSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_colorLabel.frame)+12, self.frame.size.width-24, 12);
    self.LYT_gSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_rSlider.frame)+12, self.frame.size.width-24, 12);
    self.LYT_bSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_gSlider.frame)+12, self.frame.size.width-24, 12);
    self.LYT_alphaLabel.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_bSlider.frame)+12, self.frame.size.width-24, 44);
    self.LYT_alphaSlider.frame = CGRectMake(12, CGRectGetMaxY(self.LYT_alphaLabel.frame)+12, self.frame.size.width-24, 12);
}

#pragma mark =========== Private Methods ===========

- (void)setupSubviews{
    [self.contentView addSubview:self.LYT_clsLabel];
    [self.contentView addSubview:self.LYT_frameLabel];
    [self.contentView addSubview:self.LYT_xSlider];
    [self.contentView addSubview:self.LYT_ySlider];
    [self.contentView addSubview:self.LYT_wSlider];
    [self.contentView addSubview:self.LYT_hSlider];
    [self.contentView addSubview:self.LYT_colorLabel];
    [self.contentView addSubview:self.LYT_rSlider];
    [self.contentView addSubview:self.LYT_gSlider];
    [self.contentView addSubview:self.LYT_bSlider];
    [self.contentView addSubview:self.LYT_alphaLabel];
    [self.contentView addSubview:self.LYT_alphaSlider];

}

- (void)setModel:(LayerTreeViewDetailModel *)model{
    _model = model;
    self.LYT_clsLabel.text = model.info;
    self.LYT_frameLabel.text = [NSString stringWithFormat:@"frame(x,y,w,h): (x:%.2f,y,%.2f,w:%.2f,h:%.2f)",model.x,model.y,model.w,model.h];
    self.LYT_colorLabel.text = [NSString stringWithFormat:@"color(R,G,B): (R:%.2f ,G:%.2f ,B:%.2f)",model.r,model.g,model.b];
    self.LYT_alphaLabel.text = [NSString stringWithFormat:@"alpha(0-1):%.2f",model.alpha];
    if (self.changeAttribute) {
        self.changeAttribute(model);
    }
}

- (void)updateWithModel:(LayerTreeViewDetailModel *)model{
    _model = model;
    self.LYT_clsLabel.text = model.info;
    self.LYT_frameLabel.text = [NSString stringWithFormat:@"frame(x,y,w,h): (x:%.2f,y,%.2f,w:%.2f,h:%.2f)",model.x,model.y,model.w,model.h];
    self.LYT_colorLabel.text = [NSString stringWithFormat:@"color(R,G,B): (R:%.2f ,G:%.2f ,B:%.2f)",model.r,model.g,model.b];
    self.LYT_alphaLabel.text = [NSString stringWithFormat:@"alpha(0-1):%.2f",model.alpha];
    self.LYT_xSlider.value = model.x;
    self.LYT_ySlider.value = model.y;
    self.LYT_wSlider.value = model.w;
    self.LYT_hSlider.value = model.h;
    self.LYT_rSlider.value = model.r;
    self.LYT_gSlider.value = model.g;
    self.LYT_bSlider.value = model.b;
    self.LYT_alphaSlider.value = model.alpha;
}

#pragma mark =========== EventResponse ===========
- (void)sliderValueChanged:(UISlider *)slider{
    switch (slider.tag) {
        case LYT_x_Slider:
        {
            self.model.x = slider.value;
        }
            break;
        case LYT_y_Slider:
        {
            self.model.y = slider.value;
        }
            break;
        case LYT_w_Slider:
        {
            self.model.w = slider.value;
            
        }
            break;
        case LYT_h_Slider:
        {
            self.model.h = slider.value;
            
        }
            break;
        case LYT_r_Slider:
        {
            self.model.r = slider.value;
            
        }
            break;
        case LYT_g_Slider:
        {
            self.model.g = slider.value;
            
        }
            break;
        case LYT_b_Slider:
        {
            self.model.b = slider.value;
            
        }
            break;
        case LYT_alpha_Slider:
        {
            self.model.alpha = slider.value;
        }
            break;
            
        default:
            break;
    }
    [self setModel:_model];
}

#pragma mark =========== Setters && Getters ===========
- (UILabel *)LYT_clsLabel{
    if (!_LYT_clsLabel) {
        _LYT_clsLabel = [[UILabel alloc]init];
        _LYT_clsLabel.text = @"class:";
        _LYT_clsLabel.font = [UIFont systemFontOfSize:12];
        _LYT_clsLabel.textColor = [UIColor darkTextColor];
    }
    return _LYT_clsLabel;
}

- (UILabel *)LYT_frameLabel{
    if (!_LYT_frameLabel) {
        _LYT_frameLabel = [[UILabel alloc]init];
        _LYT_frameLabel.text = @"frame(x,y,w,h):";
        _LYT_frameLabel.font = [UIFont systemFontOfSize:12];
        _LYT_frameLabel.textColor = [UIColor darkTextColor];
    }
    return _LYT_frameLabel;
}

- (UILabel *)LYT_colorLabel{
    if (!_LYT_colorLabel) {
        _LYT_colorLabel = [[UILabel alloc]init];
        _LYT_colorLabel.text = @"color(R,G,B):";
        _LYT_colorLabel.font = [UIFont systemFontOfSize:12];
        _LYT_colorLabel.textColor = [UIColor darkTextColor];
    }
    return _LYT_colorLabel;
}

- (UILabel *)LYT_alphaLabel{
    if (!_LYT_alphaLabel) {
        _LYT_alphaLabel = [[UILabel alloc]init];
        _LYT_alphaLabel.text = @"alpha(0-1):";
        _LYT_alphaLabel.font = [UIFont systemFontOfSize:12];
        _LYT_alphaLabel.textColor = [UIColor darkTextColor];
    }
    return _LYT_alphaLabel;
}

- (UISlider *)LYT_xSlider{
    if (!_LYT_xSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_x_Slider;
        slider.maximumValue = LYT_ScreenWidth;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_xSlider = slider;
    }
    return _LYT_xSlider;
}

- (UISlider *)LYT_ySlider{
    if (!_LYT_ySlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_y_Slider;
        slider.maximumValue = LYT_ScreenHeight;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_ySlider = slider;
    }
    return _LYT_ySlider;
}

- (UISlider *)LYT_wSlider{
    if (!_LYT_wSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_w_Slider;
        slider.maximumValue = LYT_ScreenWidth;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_wSlider = slider;
    }
    return _LYT_wSlider;
}

- (UISlider *)LYT_hSlider{
    if (!_LYT_hSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_h_Slider;
        slider.maximumValue = LYT_ScreenHeight;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_hSlider = slider;
    }
    return _LYT_hSlider;
}

- (UISlider *)LYT_rSlider{
    if (!_LYT_rSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_r_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
//        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.minimumTrackTintColor = [UIColor redColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_rSlider = slider;
    }
    return _LYT_rSlider;
}

- (UISlider *)LYT_gSlider{
    if (!_LYT_gSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_g_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
//        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.minimumTrackTintColor = [UIColor greenColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_gSlider = slider;
    }
    return _LYT_gSlider;
}

- (UISlider *)LYT_bSlider{
    if (!_LYT_bSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_b_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
//        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.minimumTrackTintColor = [UIColor blueColor];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_bSlider = slider;
    }
    return _LYT_bSlider;
}

- (UISlider *)LYT_alphaSlider{
    if (!_LYT_alphaSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.minimumValue = 0;// 设置最小值
        slider.tag = LYT_alpha_Slider;
        slider.maximumValue = 1;// 设置最大值
        slider.continuous = YES;// 设置可连续变化
        slider.minimumTrackTintColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        slider.maximumTrackTintColor = [UIColor grayColor];
        [slider setThumbImage:[UIImage imageNamed:@"LYT_sliderIcon"] forState:UIControlStateNormal];
        
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
        _LYT_alphaSlider = slider;
    }
    return _LYT_alphaSlider;
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
