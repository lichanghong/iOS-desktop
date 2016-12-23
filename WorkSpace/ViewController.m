//
//  ViewController.m
//  WorkSpace
//
//  Created by lichanghong on 2016/12/9.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import "ViewController.h"
#import "WSViewContent.h"
#import "WSAppItem.h"


//frame
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
@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic,strong)NSMutableArray *viewContents;
@property (nonatomic,strong)UIScrollView *bgScrollView;
@property (nonatomic,strong)UIPageControl *pageControl;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, KScreenHeight-100, KScreenWidth, 20)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [self.pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self.pageControl setNumberOfPages:3];
    //向 ScrollView 中加入第一个 View，View 的宽度 200 加上两边的空隙 5 等于 ScrollView 的宽度
    WSViewContent *view1 = [WSViewContent createWSVC];
    view1.backgroundColor = [UIColor blackColor];
    view1.group = 0;
    [self.bgScrollView addSubview:view1];
    //第二个 View，它的宽度加上两边的空隙 5 等于 ScrollView 的宽度，两个 View 间有 10 的间距
    WSViewContent*view2 = [WSViewContent createWSVC];
    setX(view2, KScreenWidth);
    view2.group = 2;
    view2.backgroundColor = [UIColor blackColor];

    [self.bgScrollView addSubview:view2];
    //第三个 View
    WSViewContent *view3 =[WSViewContent createWSVC];
    view3.backgroundColor = [UIColor blackColor];
    view3.group = 3;
    setX(view3, KScreenWidth*2);

    [_bgScrollView addSubview:view3];
    [self.view addSubview:self.bgScrollView];
    
    
    [self.viewContents addObject:view1];
    [self.viewContents addObject:view2];
    [self.viewContents addObject:view3];
    
    [self.view addSubview:self.pageControl];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleAction:) name:@"shakejaklfjsdklfjdslfjsfksk" object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)handleAction:(id)sender
{
    if ([sender isKindOfClass:[NSNotification class]]) {
        //颤动所有小图标
        for (WSViewContent *content in self.viewContents) {
            for (WSAppItem *item in content.appItems) {
                [item shake:YES];
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSMutableArray *)viewContents
{
    if (!_viewContents) {
        _viewContents = [NSMutableArray array];
    }
    return _viewContents;
}

-(UIScrollView *)bgScrollView
{
    if (!_bgScrollView) {
        _bgScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,KScreenWidth, KScreenHeight)];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.delegate =self;
        //高度上与 ScrollView 相同，只在横向扩展，所以只要在横向上滚动
        _bgScrollView.contentSize = CGSizeMake(KScreenWidth*3, KScreenHeight);
        //用它指定 ScrollView 中内容的当前位置，即相对于 ScrollView 的左上顶点的偏移
        _bgScrollView.contentOffset = CGPointMake(0, 0);
        //按页滚动，总是一次一个宽度，或一个高度单位的滚动
        _bgScrollView.pagingEnabled = YES;
        [_bgScrollView setShowsHorizontalScrollIndicator:NO];
    }
    return _bgScrollView;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x)/self.view.frame.size.width;
    _pageControl.currentPage = index;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
