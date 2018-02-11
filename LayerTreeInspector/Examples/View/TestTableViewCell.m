//
//  TestTableViewCell.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/11.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestTableViewCell.h"
#import "TestDataItem.h"

@interface TestTableViewCell ()
@property (nonatomic, strong) UIImageView *headerImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation TestTableViewCell

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

- (void)setupSubviews{
    [self.contentView addSubview:self.headerImgView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
}

- (void)updateCellWithItem:(TestDataItem *)item{
    self.headerImgView.image = [UIImage imageNamed:item.img];
    self.titleLabel.text = item.title;
    self.contentLabel.text = item.content;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.headerImgView.frame = CGRectMake(12, 12, 100, 100);
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.headerImgView.frame)+12, CGRectGetMinX(self.headerImgView.frame), self.frame.size.width-112-12-12, 14);
    self.contentLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame)+12, self.titleLabel.frame.size.width, 40);
}

- (UIImageView *)headerImgView{
    if (!_headerImgView) {
        _headerImgView = [[UIImageView alloc]init];
        _headerImgView.contentMode = UIViewContentModeScaleToFill;
    }
    return _headerImgView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor darkTextColor];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor darkTextColor];
    }
    return _contentLabel;
}

@end
