//
//  WSAppItem.h
//  WorkSpace
//
//  Created by lichanghong on 12/21/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSViewContent.h"


@interface WSAppItem : UIView<UIGestureRecognizerDelegate>
//model
@property(nonatomic,strong)WSApp *appModel;



//ui
@property(nonatomic,strong)UIImageView *image;
@property(nonatomic,strong)UILabel  *label ;
@property(nonatomic,strong)UIButton *button;
 

+ (WSAppItem *)createItemWithFrame:(CGRect)frame;
- (void)shake:(BOOL)isAnimation;
- (void)scaleWhenSelect:(BOOL)toBig; //选中之后变大还是恢复
- (void)setGrayMaskHidden:(BOOL)hidden;
- (CGPoint)moveToLocation:(CGPoint)targetLocation inLocation:(CGPoint)inLocation;
 

- (void)dismiss;

@end
