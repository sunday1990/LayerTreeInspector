//
//  LayerTree3DCell.m
//  LayerTreeInspector
//
//  Created by ccSunday on 2018/2/11.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "LayerTree3DCell.h"
#import "LayerTreeBaseNode.h"

@interface LayerTree3DCell ()
{
    NSMutableArray *_hierarchys;
}
@property (nonatomic, strong) UILabel *hierarchiesLb;
@property (nonatomic, strong) UILabel *detailLabel;

@end

@implementation LayerTree3DCell

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
        _hierarchys = [NSMutableArray array];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    [self.contentView addSubview:self.hierarchiesLb];
    [self.contentView addSubview:self.detailLabel];
}

- (void)updateWithNode:(LayerTreeBaseNode *)node{
    [_hierarchys removeAllObjects];
    self.hierarchiesLb.text = [@"Hierarchy:UIWindow->" stringByAppendingString:[self getHierarchyAtNode:node]];
    self.detailLabel.text = [NSString stringWithFormat:@"View:%@",node.treeNodeView==nil?@"":node.treeNodeView];
}

- (NSString *)getHierarchyAtNode:(LayerTreeBaseNode *)node{
    if (node.fatherNode == nil) {
        return  [_hierarchys componentsJoinedByString:@"->"];
    }else{
        [_hierarchys insertObject:NSStringFromClass(node.treeNodeView.class) atIndex:0];
        return [self getHierarchyAtNode:(LayerTreeBaseNode *)node.fatherNode];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.hierarchiesLb.frame = CGRectMake(12, 12, self.frame.size.width-24, [self heightForString:self.hierarchiesLb.text withFont:self.hierarchiesLb.font lineSpace:3 width:self.frame.size.width-24]+12);
    self.detailLabel.frame = CGRectMake(12, CGRectGetMaxY(self.hierarchiesLb.frame)+12, self.hierarchiesLb.frame.size.width, [self heightForString:self.detailLabel.text withFont:self.detailLabel.font lineSpace:3 width:self.detailLabel.frame.size.width]);
}

- (UILabel *)hierarchiesLb{
    if (!_hierarchiesLb) {
        _hierarchiesLb = [[UILabel alloc]init];
        _hierarchiesLb.font = [UIFont systemFontOfSize:12];
        _hierarchiesLb.numberOfLines = 0;
        _hierarchiesLb.textColor = [UIColor darkTextColor];
    }
    return _hierarchiesLb;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc]init];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textColor = [UIColor darkTextColor];
    }
    return _detailLabel;
}

- (CGFloat)heightForString:(NSString *)string withFont:(UIFont *)font lineSpace:(CGFloat)lineSpace width:(CGFloat)width{
    CGSize result;
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = CGSizeMake(width, HUGE);
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = lineBreakMode;
        paragraphStyle.lineSpacing = lineSpace;
        attr[NSParagraphStyleAttributeName] = paragraphStyle;
        
        CGRect rect = [string boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [string sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result.height;
}


@end

\
