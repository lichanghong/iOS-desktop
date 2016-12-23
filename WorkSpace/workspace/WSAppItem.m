//
//  WSAppItem.m
//  WorkSpace
//
//  Created by lichanghong on 12/21/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//

#import "WSAppItem.h"

@implementation WSAppItem
{
    CGRect  imageR;
    CGRect  labelF;
    CGFloat paddingT ;
    CGFloat paddingL;
    CGFloat imageW;
}

+ (WSAppItem *)createItemWithFrame:(CGRect)frame
{
    WSAppItem *item = [[WSAppItem alloc]initWithFrame:frame];
    item.backgroundColor = [UIColor clearColor];
    [item setGrayMaskHidden:YES];
    [item initUIWithFrame:frame];
    
    item.button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [item.button addTarget:item action:@selector(btnTouchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [item.button addTarget:item action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [item.button addTarget:item action:@selector(btnDragged:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [item.button addTarget:item action:@selector(btnDragged:withEvent:) forControlEvents:UIControlEventTouchDragOutside];

    [item addSubview:item.image];
    [item addSubview:item.label];
    [item addSubview:item.button]; 
 
    return item;
}

- (void)initUIWithFrame:(CGRect)frame
{
    paddingT = 5;
    paddingL = 10;
    imageW   =frame.size.width-paddingL*2;
    imageR    = CGRectMake(paddingL, paddingT,imageW,  imageW);
    self.image = [[UIImageView alloc]initWithFrame:imageR];
    self.image.image = [UIImage imageNamed:@"applogo"];
 
    CGFloat labelY =CGRectGetMaxY(self.image.frame);
    CGFloat labelH =frame.size.height-labelY - 10;
    labelF = CGRectMake(0,labelY,frame.size.width, labelH);
    self.label = [[UILabel alloc]initWithFrame:labelF];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = @"管理中心区";
    [self.label setTextAlignment:NSTextAlignmentCenter];
    self.label.textColor = [UIColor whiteColor];
    CGFloat fontsize = 16;//适用于大屏
    if ([UIScreen mainScreen].bounds.size.width<=320) {
        fontsize = 12;
    }
    self.label.font = [UIFont systemFontOfSize:fontsize];

}

- (void)scaleWhenSelect:(BOOL)toBig
{
    [UIView animateWithDuration:0.1 animations:^{
        if (toBig) {
            CGFloat scale = 5;
            self.image.frame = CGRectMake(paddingL-scale, paddingT-scale,imageW+scale*2,  imageW+scale*2);
            
            CGFloat fontScale = 1;
            CGFloat fontsize = 16+fontScale;//适用于大屏
            if ([UIScreen mainScreen].bounds.size.width<=320) {
                fontsize = 12+fontScale;
            }
            self.label.font = [UIFont systemFontOfSize:fontsize];
            self.label.textColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
            self.label.frame = CGRectMake(labelF.origin.x, labelF.origin.y, labelF.size.width, labelF.size.height+4);
            self.image.alpha = 0.5;

        }
        else
        {
            self.image.frame = CGRectMake(paddingL, paddingT,imageW,  imageW);
            CGFloat fontsize = 16;//适用于大屏
            if ([UIScreen mainScreen].bounds.size.width<=320) {
                fontsize = 12;
            }
            self.label.frame = labelF;
            self.label.font = [UIFont systemFontOfSize:fontsize];
            self.image.alpha = 1;
            self.label.textColor = [UIColor whiteColor];

        }
    }];
}

- (void)handleAction:(id)sender
{
    NSLog(@"UIControlEventTouchUpOutside ---------------");

}
- (void)btnTouchUp:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
        NSLog(@"btnTouchUp ---------------");

        [self setGrayMaskHidden:YES];
    }

}

- (void)setGrayMaskHidden:(BOOL)hidden
{
    if (hidden) {
        self.image.alpha = 1;
    }
    else self.image.alpha = 0.5;
    
     [self scaleWhenSelect:!hidden];
}
- (void)btnTouchDown:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
        //正在动画点击，视图变大且可滑动
        NSLog(@" sender = touchdown");
        UIView *parentV = self.superview;
        [self setGrayMaskHidden:NO];
        [parentV bringSubviewToFront:self];
    }
}

//inlocation 是item内坐标，targetlocation 在content内坐标 return center point
- (CGPoint)moveToLocation:(CGPoint)targetLocation inLocation:(CGPoint)inLocation
{
    CGFloat x = targetLocation.x - (inLocation.x-self.center.x);
    CGFloat y = targetLocation.y - (inLocation.y-self.center.y);
    return CGPointMake(x, y);
}

- (void)btnDragged:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
        UITouch *touch = [[event allTouches] anyObject];
        UIView *parentV = self.superview;
        CGPoint location = [touch locationInView:parentV];
        [UIView animateWithDuration:0.1 animations:^{
            self.center = location;
        }];
        NSLog(@" sender = drag");
    }
}
- (void)handleAction:(UIButton *)sender WithEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
 
      
        
    }
    else
    {
        NSLog(@"%s isanimation=%@ sender = %@",__func__,[self isAnimation]?@"yes":@"no",sender);
    }
}

- (void)shake:(BOOL)isAnimation {
    if (isAnimation) {
        CGFloat duration = 0.4;
        CGFloat shakeFromValue = M_PI*0.012;
        CGFloat shakeToValue = -M_PI*0.012;
        
        CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.2], [NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:0.4], nil];
        rotationAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:shakeFromValue], [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:shakeToValue], [NSNumber numberWithFloat:0.0], nil];
        
        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation"];
        CGRect bounds = self.layer.bounds;
        CGFloat distance_x = bounds.size.width*0.014;
        CGFloat distance_y = bounds.size.height*0.006;
        CGMutablePathRef shakePath = CGPathCreateMutable();
        CGPathMoveToPoint(shakePath, NULL, distance_x, 0.0);
        CGPathAddCurveToPoint(shakePath, NULL, distance_x, distance_y, -distance_x, distance_y, -distance_x, 0.0);
        CGPathCloseSubpath(shakePath);
        positionAnimation.path = shakePath;
        CFRelease(shakePath);
        
        CAAnimationGroup *shakeAnimation = [CAAnimationGroup animation];
        shakeAnimation.duration = duration;
        shakeAnimation.repeatCount = HUGE_VALF;
        shakeAnimation.delegate = nil;
        shakeAnimation.removedOnCompletion = YES;
        shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        shakeAnimation.fillMode = kCAFillModeForwards;
        shakeAnimation.animations = [NSArray arrayWithObjects:rotationAnimation, positionAnimation, nil];
        [self.layer addAnimation:shakeAnimation forKey:@"shakeAnimation"];
    } else {
        [self.layer removeAnimationForKey:@"shakeAnimation"];
    }
}

- (BOOL)isAnimation
{
    return [self.layer animationForKey:@"shakeAnimation"]==NULL?NO:YES;
}

- (void)dismiss
{
    [self removeFromSuperview];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
