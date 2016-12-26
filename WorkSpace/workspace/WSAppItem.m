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
    item.appModel = [[WSApp alloc]init];
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
//    self.image.image = [UIImage imageNamed:@"applogo"];
 
    CGFloat labelY =CGRectGetMaxY(self.image.frame);
    CGFloat labelH =frame.size.height-labelY - 10;
    labelF = CGRectMake(0,labelY,frame.size.width, labelH);
    self.label = [[UILabel alloc]initWithFrame:labelF];
    self.label.backgroundColor = [UIColor clearColor];
//    self.label.text = @"管理中心区";
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


static CGPoint itemCenter; //拖动的item的坐标中心 in contentview
static CGPoint inLocation; //item里面的point需要是初始值，如果一直变化则因坐标不确定而出问题
- (void)btnTouchDown:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
        //正在动画点击，视图变大且可滑动
        NSLog(@" sender = touchdown");
        WSViewContent *parentV = (id)self.superview;
        [self setGrayMaskHidden:NO];
        [parentV bringSubviewToFront:self];
        UITouch *touch = [[event allTouches] anyObject];
        inLocation     = [touch locationInView:self.button];
        //找出itemCenter ，在移动item的时候判断中点是否在自己域内
        for (WSBaseItemBG *itembg in parentV.baseItemBGs) {
            if (itembg.appModel.index == self.appModel.index) {
                itemCenter = itembg.center;
                break;
            }
        }
    }
}
- (void)btnTouchUp:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) {
        NSLog(@"btnTouchUp ---------------");
        [self setGrayMaskHidden:YES];
        WSViewContent *parentV =(id)self.superview;
        UITouch *touch = [[event allTouches] anyObject];
        
        NSInteger preIndex = self.appModel.index; //拖走留下的空
        CGPoint itemlocation = [touch locationInView:parentV];
        NSInteger lasIndex = 0;
        
        //动态获取行列数
        int row=ROW,column=COLUMN;
        for (WSBaseItemBG *baseItemBG in parentV.baseItemBGs) {
            if (CGRectContainsPoint(baseItemBG.frame, itemlocation)) {
                lasIndex = baseItemBG.appModel.index;
            }
        }
        if (preIndex < lasIndex || preIndex > lasIndex)
        {
            //后面的图标往前移动
            for (int i=0; i<row; i++) {
                for (int j=0; j<column; j++) {
                    int index = i*column+j;
                    //所有需要前移的图标位置
                    WSAppItem *appitem = [parentV.appItems objectAtIndex:index];
                    //从上往下拖动图标
                    if (index>=preIndex && index<=lasIndex) {
                        //所有前移
                        if (index == preIndex) {
                            appitem.appModel.index = lasIndex;
                        }
                        else
                        {
                            appitem.appModel.index -= 1;
                        }
                    }
                    //从下往上拖动图标
                    else if(index>=lasIndex && index <= preIndex)
                    {
                        //所有后移
                        if (index == preIndex) {
                            appitem.appModel.index = lasIndex;
                        }
                        else
                        {
                            appitem.appModel.index += 1;
                        }
                    }
                }
            }
            //重新排序之后需要把数组元素重新排序
           NSArray *sortedArr = [parentV.appItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                WSAppItem *item1 = obj1;
                WSAppItem *item2 = obj2;
                if (item1.appModel.index<item2.appModel.index) {
                    return NSOrderedAscending;
                }
                return NSOrderedDescending;
            }];
            parentV.appItems = [NSMutableArray arrayWithArray:sortedArr];
            for (WSAppItem *appItem in parentV.appItems) {
                for (WSBaseItemBG *baseItemBG in parentV.baseItemBGs) {
                    if (baseItemBG.appModel.index == appItem.appModel.index) {
                        
                        [UIView animateWithDuration:0.2 animations:^{
                            appItem.center = baseItemBG.center;
                            [parentV bringSubviewToFront:appItem];
                        }];
                    }
                }
            }
            
            
            
        }
        else if(preIndex == lasIndex)
        {
            [UIView animateWithDuration:0.1 animations:^{
                self.center = itemCenter;
            }];
        }
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


//inlocation 是item内坐标，targetlocation 在content内坐标 return center point
- (CGPoint)moveToLocation:(CGPoint)targetLocation inLocation:(CGPoint)inLocation
{
    CGFloat x = targetLocation.x - (inLocation.x-self.bounds.size.width/2.0);
    CGFloat y = targetLocation.y - (inLocation.y-self.bounds.size.height/2.0);
    return CGPointMake(x, y);
}

- (void)btnDragged:(UIButton *)sender withEvent:(UIEvent *)event
{
    if ([self isAnimation]) { //长按并拖动使用longpress处理，颤动之后使用此方法处理拖动
        UITouch *touch = [[event allTouches] anyObject];
        WSViewContent *parentV =(id)self.superview;
        
        CGPoint center       = CGPointZero;
        CGPoint targetLocation = [touch locationInView:parentV];
        center =  [self moveToLocation:targetLocation inLocation:inLocation];
        [UIView animateWithDuration:0.1 animations:^{
            self.center = center;
        }];
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
