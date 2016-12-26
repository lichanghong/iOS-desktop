//
//  WSViewContent.h
//  WorkSpace
//
//  Created by lichanghong on 12/21/16.
//  Copyright © 2016 lichanghong. All rights reserved.
//

// WS workspace

#import <UIKit/UIKit.h>

#define COLUMN 4
#define ROW    5

@interface WSApp : NSObject
@property(nonatomic,assign)NSInteger group;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)BOOL      hasItem;  //有无图标
@property(nonatomic,strong)NSString *appName;
@property(nonatomic,strong)NSString *appSchema;
@end

@interface WSBaseItemBG : UIView    
@property(nonatomic,strong)WSApp *appModel;

@end



@interface WSViewContent : UIView<UIGestureRecognizerDelegate>
@property(nonatomic,assign)NSInteger group;
@property (nonatomic,strong)NSMutableArray *baseItemBGs;
@property (nonatomic,strong)NSMutableArray *appItems;

+ (WSViewContent *)createWSVC;
- (void)refreshContent;

- (void)dismiss;


@end
