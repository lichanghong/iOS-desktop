//
//  ViewController.h
//  WorkSpace
//
//  Created by lichanghong on 2016/12/9.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import <UIKit/UIKit.h>

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


#define COLUMN 4
#define ROW    5

@interface WSApp : NSObject
@property(nonatomic,assign)int group;
@property(nonatomic,assign)int index;
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong)NSString *appSchema;
@end

@interface WSBaseItemBG : UIView
@property(nonatomic,strong)WSApp *appModel;

@end


@interface WSViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic,strong)NSMutableArray *viewContents;
@property(nonatomic,assign)NSInteger group;
@property (nonatomic,strong)NSMutableArray *baseItemBGs;
@property (nonatomic,strong)NSMutableArray *appItems;

- (void)refreshContent;

- (void)dismiss;


@end

