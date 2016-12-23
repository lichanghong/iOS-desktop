//
//  WSViewContent.m
//  WorkSpace
//
//  Created by lichanghong on 12/21/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//
#import "WSViewContent.h"
#import "WSAppItem.h"


@implementation WSBaseItemBG
@end

@implementation WSApp
@end


#define KScreenWidth            [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight           [[UIScreen mainScreen] bounds].size.height
#define KScreenRect             [[UIScreen mainScreen] bounds]
#define ViewW(v)                (v).frame.size.width
#define ViewH(v)                (v).frame.size.height
#define ViewX(v)                (v).frame.origin.x
#define ViewY(v)                (v).frame.origin.y
#define MinX(v)                 CGRectGetMinX((v).frame)
#define MinY(v)                 CGRectGetMinY((v).frame)
#define MaxX(v)                 CGRectGetMaxX((v).frame)
#define MaxY(v)                 CGRectGetMaxY((v).frame)
#define setX(v,x)   v.frame=CGRectMake(x, v.frame.origin.y , v.frame.size.width, v.frame.size.height)
#define setY(v,y)   v.frame=CGRectMake(v.frame.origin.x, y , v.frame.size.width, v.frame.size.height)
#define setW(v,w)   v.frame=CGRectMake(v.frame.origin.x,v.frame.origin.y, w, v.frame.size.height)
#define setH(v,h)   v.frame=CGRectMake(v.frame.origin.x,v.frame.origin.y, v.frame.size.width, h)


@implementation WSViewContent

+ (WSViewContent *)createWSVC
{
    CGFloat column = 4.0;
    CGFloat row = 5.0;
    WSViewContent *vc = [[WSViewContent alloc]initWithFrame:KScreenRect];
    CGFloat margin = 12;  //最外边距
    CGFloat xpadding = 5; //图标间距
    CGFloat ypadding = 5; //图标间距
    CGFloat w        = (KScreenWidth-2*margin-(column-1)*xpadding)/column;

    CGFloat marginBottom = 100;
    CGFloat marginTop = 30;
  
    CGFloat h        =( KScreenHeight-ypadding*(row-1) - marginBottom - marginTop)/row;
    CGFloat fy = KScreenHeight - h*row - ypadding*(row-1) - marginBottom;

    vc.appItems = [NSMutableArray array];
    for (int i=0; i<column; i++) {
        for (int j=0; j<row; j++) {
            WSBaseItemBG *ibview = [[WSBaseItemBG alloc]init]; //item background view
            ibview.frame = CGRectMake(margin+(xpadding+w)*i, fy+(j*(h+ypadding)), w, h);
            ibview.backgroundColor = [UIColor greenColor];
            ibview.point = CGPointMake(i,j);
            [vc addSubview:ibview];
            
            WSAppItem *v = [WSAppItem createItemWithFrame:
                          CGRectMake(margin+(xpadding+w)*i, fy+(j*(h+ypadding)), w, h)];
            v.point = CGPointMake(i, j);
            [vc addSubview:v];
            [vc.appItems addObject:v];

            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:vc action:@selector(handleAction:)];
            longPressRecognizer.minimumPressDuration = 1;
            longPressRecognizer.delegate = vc;
            [v addGestureRecognizer:longPressRecognizer];
            
//            UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:vc action:@selector(handleAction:)];
//            [v addGestureRecognizer:panGestureRecognizer];
        
        }
    }
    return vc;
}


- (void)handleAction:(id)sender
{
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
            //通知所有的item shake
            [[NSNotificationCenter defaultCenter]postNotificationName:@"shakejaklfjsdklfjdslfjsfksk" object:sender];
            UILongPressGestureRecognizer *longpress = sender;
            WSAppItem *appitem = (id)longpress.view;
            //长按拖动的坐标
            CGPoint location = [longpress locationInView:self];
            CGPoint itemLocation = CGPointZero;
            if (longpress.state == UIGestureRecognizerStateBegan) {
                [appitem scaleWhenSelect:YES];
                itemLocation = [longpress locationInView:appitem];
            }
            else if(longpress.state == UIGestureRecognizerStateChanged)
            {
                [UIView animateWithDuration:0.1 animations:^{
                    appitem.center = location;
                }];
                [appitem.superview bringSubviewToFront: appitem];
                NSLog(@"GestureRecognizerStateChanged---%@-",NSStringFromCGPoint(appitem.point));

            }
            else if(longpress.state == UIGestureRecognizerStateEnded)
            {
                NSLog(@"UIGestureRecognizerStateEnded---------");
                [appitem setGrayMaskHidden:YES];

                
            }
        }
        else if ([sender isKindOfClass:[UIPanGestureRecognizer class]])  {
            UIPanGestureRecognizer *pan = sender;
            if (pan.state == UIGestureRecognizerStateBegan) {
             }

        }
    }
    else
        NSLog(@"%s",__func__);
}


- (void)dismiss
{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
