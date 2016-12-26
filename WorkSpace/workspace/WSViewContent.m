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
    WSViewContent *vc = [[WSViewContent alloc]initWithFrame:KScreenRect];
    CGFloat margin = 12;  //最外边距
    CGFloat xpadding = 5; //图标间距
    CGFloat ypadding = 5; //图标间距
    CGFloat w        = (KScreenWidth-2*margin-(COLUMN-1)*xpadding)/COLUMN;

    CGFloat marginBottom = 100;
    CGFloat marginTop = 30;
  
    CGFloat h        =( KScreenHeight-ypadding*(ROW-1) - marginBottom - marginTop)/ROW;
    CGFloat fy = KScreenHeight - h*ROW - ypadding*(ROW-1) - marginBottom;

    vc.baseItemBGs = [NSMutableArray array];
    vc.appItems = [NSMutableArray array];
    for (int i=0; i<ROW; i++) {
        for (int j=0; j<COLUMN; j++) {
            WSBaseItemBG *ibview = [[WSBaseItemBG alloc]init]; //item background view
            ibview.frame = CGRectMake(margin+(xpadding+w)*j, fy+(i*(h+ypadding)), w, h);
            ibview.backgroundColor = [UIColor greenColor];
            ibview.index = i*COLUMN+j;
            [vc addSubview:ibview];
            [vc.baseItemBGs addObject:ibview];
            
            WSAppItem *v = [WSAppItem createItemWithFrame:
                          CGRectMake(margin+(xpadding+w)*j, fy+(i*(h+ypadding)), w, h)];
            v.appModel.index = i*COLUMN+j;
            NSString *imagename = [NSString stringWithFormat:@"00%ld",(i*ROW+j)+19*vc.group];
//            NSLog(@"index = %ld",ibview.index);
            v.image.image = [UIImage imageNamed:imagename];
            v.label.text = NSStringFromCGPoint(CGPointMake(i,j));
            [vc addSubview:v];
            [vc.appItems addObject:v];

            UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:vc action:@selector(handleAction:)];
            longPressRecognizer.minimumPressDuration = 1;
            longPressRecognizer.delegate = vc;
            [v addGestureRecognizer:longPressRecognizer];
        
        }
    }
    return vc;
}

static CGPoint itemCenter; //拖动的item的坐标中心 in contentview
static CGPoint inLocationb; //item里面的point需要是初始值，如果一直变化则因坐标不确定而出问题
- (void)handleAction:(id)sender
{
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
            //通知所有的item shake
            [[NSNotificationCenter defaultCenter]postNotificationName:@"shakejaklfjsdklfjdslfjsfksk" object:sender];
            UILongPressGestureRecognizer *longpress = sender;
            WSAppItem *appitem = (id)longpress.view;
            CGPoint center         = CGPointZero;
            CGPoint targetLocation = [longpress locationInView:self];

            //长按拖动的坐标
            if (longpress.state == UIGestureRecognizerStateBegan) {
                [appitem scaleWhenSelect:YES];
                inLocationb     = [longpress locationInView:appitem.button];
                //找出itemCenter ，在移动item的时候判断中点是否在自己域内
                for (WSBaseItemBG *itembg in self.baseItemBGs) {
                    if (itembg.index == appitem.appModel.index) {
                        itemCenter = itembg.center;
                        break;
                    }
                }
            }
            else if(longpress.state == UIGestureRecognizerStateChanged)
            {
                center =  [appitem moveToLocation:targetLocation inLocation:inLocationb];
                [UIView animateWithDuration:0.1 animations:^{
                    appitem.center = center;
                }];
                [appitem.superview bringSubviewToFront: appitem];
//                NSLog(@"GestureRecognizerStateChanged---%@-",NSStringFromCGPoint(center));

            }
            else if(longpress.state == UIGestureRecognizerStateEnded)
            {
                NSLog(@"UIGestureRecognizerStateEnded---------");
                [appitem setGrayMaskHidden:YES];
                
                NSInteger preIndex = appitem.appModel.index; //拖走留下的空
                CGPoint itemlocation = [longpress locationInView:self];
                NSInteger lasIndex = appitem.appModel.index;
                
                int row=ROW,column=COLUMN;
                for (WSBaseItemBG *baseItemBG in self.baseItemBGs) {
                    if (CGRectContainsPoint(baseItemBG.frame, itemlocation)) {
                        lasIndex = baseItemBG.index;
                    }
                }
                if (preIndex < lasIndex || preIndex > lasIndex)
                {
                    //后面的图标往前移动
                    for (int i=0; i<row; i++) {
                        for (int j=0; j<column; j++) {
                            int index = i*column+j;
                            //所有需要前移的图标位置
                            WSAppItem *appitem = [self.appItems objectAtIndex:index];
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
                    NSArray *sortedArr = [self.appItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        WSAppItem *item1 = obj1;
                        WSAppItem *item2 = obj2;
                        if (item1.appModel.index<item2.appModel.index) {
                            return NSOrderedAscending;
                        }
                        return NSOrderedDescending;
                    }];
                    self.appItems = [NSMutableArray arrayWithArray:sortedArr];
                    for (WSAppItem *appItem in self.appItems) {
                        for (WSBaseItemBG *baseItemBG in self.baseItemBGs) {
                            if (baseItemBG.index == appItem.appModel.index) {
                                
                                [UIView animateWithDuration:0.2 animations:^{
                                    appItem.center = baseItemBG.center;
                                    [self bringSubviewToFront:appItem];
                                }];
                            }
                        }
                    }
                    
                }
                else if(preIndex == lasIndex)
                {
                    [UIView animateWithDuration:0.1 animations:^{
                        appitem.center = itemCenter;
                    }];
                }
    
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
