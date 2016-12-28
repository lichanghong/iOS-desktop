//
//  ViewController.m
//  WorkSpace
//
//  Created by lichanghong on 2016/12/9.
//  Copyright © 2016年 lichanghong. All rights reserved.
//

#import "WSViewController.h"
#import "WSAppItem.h"

@implementation WSBaseItemBG
- (WSApp *)appModel
{
    if (!_appModel) {
        _appModel = [[WSApp alloc]init];
    }
    return _appModel;
}
@end

@implementation WSApp
@end
 
@interface WSViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong)UIScrollView *bgScrollView;
@property (nonatomic,strong)UIPageControl *pageControl;

@end

@implementation WSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, KScreenHeight-100, KScreenWidth, 20)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
    [self.pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
    [self.pageControl setNumberOfPages:3];
    [self.view addSubview:self.bgScrollView];
    [self.view addSubview:self.pageControl];
    
    [self refreshContent];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)moveToSide:(BOOL)isleft Group:(int)group
{
    int currentPage = group;
    if (isleft) {
        currentPage-=1;
    }
    else
    {
        currentPage+=1;
    }
//    _pageControl.currentPage = currentPage;
//    [self.bgScrollView setContentOffset:CGPointMake(currentPage*KScreenWidth, 0) animated:YES];
    
    
    
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

- (void)refreshContent
{
    CGFloat margin = 12;  //最外边距
    CGFloat xpadding = 5; //图标间距
    CGFloat ypadding = 5; //图标间距
    CGFloat w        = (KScreenWidth-2*margin-(COLUMN-1)*xpadding)/COLUMN;
    
    CGFloat marginBottom = 100;
    CGFloat marginTop = 30;
    
    CGFloat h        =( KScreenHeight-ypadding*(ROW-1) - marginBottom - marginTop)/ROW;
    CGFloat fy = KScreenHeight - h*ROW - ypadding*(ROW-1) - marginBottom;
    
    self.baseItemBGs = [NSMutableArray array];
    self.appItems = [NSMutableArray array];
    for (int g=0; g<3; g++) {
        for (int i=0; i<ROW; i++) {
            for (int j=0; j<COLUMN; j++) {
                WSBaseItemBG *ibview = [[WSBaseItemBG alloc]init]; //item background view
                ibview.frame = CGRectMake((margin+(xpadding+w)*j)+g*KScreenWidth, fy+(i*(h+ypadding)), w, h);
                ibview.backgroundColor = [UIColor greenColor];
                ibview.appModel.index = i*COLUMN+j;
                ibview.appModel.group = g;
                [self.bgScrollView addSubview:ibview];
                [self.baseItemBGs addObject:ibview];
                NSString *imagename = [NSString stringWithFormat:@"00%d",(i*ROW+j)+19*g];
                UIImage *image = [UIImage imageNamed:imagename];
                NSLog(@"iamgename = %@",imagename);
                if (image) {
                    WSAppItem *v = [WSAppItem createItemWithFrame:
                                    CGRectMake(margin+(xpadding+w)*j+KScreenWidth*g, fy+(i*(h+ypadding)), w, h)];
                    v.appModel.index = i*COLUMN+j;
                    v.appModel.group = g;
                    v.image.image = image;
                    v.label.text = [NSString stringWithFormat:@"%d",v.appModel.index];
                    [self.bgScrollView addSubview:v];
                    [self.appItems addObject:v];
                    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAction:)];
                    longPressRecognizer.minimumPressDuration = 1;
                    longPressRecognizer.delegate = self;
                    [v addGestureRecognizer:longPressRecognizer];
                }
            }
        }
        
    }
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
            CGPoint targetLocation = [longpress locationInView:self.bgScrollView];
            
            //长按拖动的坐标
            if (longpress.state == UIGestureRecognizerStateBegan) {
                [appitem scaleWhenSelect:YES];
                inLocationb     = [longpress locationInView:appitem.button];
                //找出itemCenter ，在移动item的时候判断中点是否在自己域内
                for (WSBaseItemBG *itembg in self.baseItemBGs) {
                    if (itembg.appModel.index == appitem.appModel.index) {
                        itemCenter = itembg.center;
                        break;
                    }
                }
                for (WSAppItem *item in self.appItems) {
                    [item shake:YES];
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
                
                int preIndex = appitem.appModel.index; //拖走留下的空
                CGPoint itemlocation = [longpress locationInView:self.bgScrollView];
                int lasIndex = appitem.appModel.index;
                
                int row=ROW,column=COLUMN;
                int hasIconCount = 0;
                int group = 3;
                for (WSBaseItemBG *baseItemBG in self.baseItemBGs) {
                    if (CGRectContainsPoint(baseItemBG.frame, itemlocation))
                    {
                        lasIndex = baseItemBG.appModel.index;
                    }
                }
                //遍历所有item，所有和item同一组的个数就是该组图标数
                NSMutableArray *currentGroupItems = [NSMutableArray array];
                for (WSAppItem *item in self.appItems) {
                    if (appitem.appModel.group==item.appModel.group)
                    {
                        hasIconCount++;
                        [currentGroupItems addObject:item];
                    }
                }
                NSLog(@"preindex=%d lasindex=%d hasicons=%d",preIndex,lasIndex,hasIconCount);
                //如果超过图标数，范围内图标前移，拖动的图标放在最后
                if (hasIconCount-1 < lasIndex) { //拖动到所有图标之外，拖动的图标放在最后
                    for (WSAppItem *item in self.appItems) {
                        if (item.appModel.index>preIndex) {
                            item.appModel.index--;
                        }
                    }
                    appitem.appModel.index = hasIconCount-1;
                }
                else  if (preIndex < lasIndex || preIndex > lasIndex)
                {
                    //遍历所有item，所有和item同一组的个数就是该组
                    for (WSAppItem *item in currentGroupItems) {
                        int index = item.appModel.index;
                        if (index>=preIndex && index<=lasIndex)
                        {
                            //所有前移
                            if (index == preIndex)
                            {
                                item.appModel.index = lasIndex;
                            }
                            else
                            {
                                item.appModel.index -= 1;
                            }
                        }
                        else if (index>=lasIndex && index <= preIndex)
                        {
                            //所有后移
                            if (index == preIndex) {
                                item.appModel.index = lasIndex;
                            }
                            else
                            {
                                item.appModel.index += 1;
                            }
                        }
                    }
                }
//                //重新排序之后需要把数组元素重新排序
//                NSArray *sortedArr = [self.appItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                    WSAppItem *item1 = obj1;
//                    WSAppItem *item2 = obj2;
//                    if (item1.appModel.index<item2.appModel.index) {
//                        return NSOrderedAscending;
//                    }
//                    return NSOrderedDescending;
//                }];
//                self.appItems = [NSMutableArray arrayWithArray:sortedArr];
                     for (WSAppItem *item in self.appItems) {
//                        NSLog(@" = %@ index = %ld group=%ld",NSStringFromCGPoint(item.center),item.appModel.index,item.appModel.group);
                        for (WSBaseItemBG *baseItemBG in self.baseItemBGs) {
                            if (baseItemBG.appModel.group == item.appModel.group && baseItemBG.appModel.index == item.appModel.index) {
//                                NSLog(@"baseitembgcenter = %@",NSStringFromCGPoint(baseItemBG.center));
                                [UIView animateWithDuration:0.2 animations:^{
                                    item.center = baseItemBG.center;
                                    [self.bgScrollView bringSubviewToFront:item];
                                }];
                            }
                        }
                }
            }
        }
        
    }
    else
        NSLog(@"%s",__func__);
}


 


@end
