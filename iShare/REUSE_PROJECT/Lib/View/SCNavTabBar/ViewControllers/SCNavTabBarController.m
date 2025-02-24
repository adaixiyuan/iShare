//
//  SCNavTabBarController.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBarController.h"
#import "SCNavCommonMacro.h"
#import "SCNavTabBar.h"

@interface SCNavTabBarController () <UIScrollViewDelegate, SCNavTabBarDelegate,UIGestureRecognizerDelegate>
{
    NSInteger       _currentIndex;              // current page index
    NSMutableArray  *_titles;                   // array of children view controller's title
    
    SCNavTabBar     *_navTabBar;                // NavTabBar: press item on it to exchange view
    UIScrollView    *_mainView;                 // content view
}

@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -

- (id)initWithShowArrowButton:(BOOL)show
{
    self = [super init];
    if (self)
    {
        _showArrowButton = show;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController showArrowButton:(BOOL)show;
{
    self = [self initWithSubViewControllers:subControllers];
    
    _showArrowButton = show;
    [self addParentController:viewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initConfig];
    [self viewConfig];
}



#pragma mark - Private Methods
#pragma mark -
- (void)initConfig
{
    // Iinitialize value
    _currentIndex = 1;
    _navTabBarColor = _navTabBarColor ? _navTabBarColor : NavTabbarColor;
    
    // Load all title of children view controllers
    _titles = [[NSMutableArray alloc] initWithCapacity:_subViewControllers.count];
    for (UIViewController *viewController in _subViewControllers)
    {
        [_titles addObject:viewController.title];
    }
}

- (void)viewInit
{
    // Load NavTabBar and content view to show on window
    _navTabBar = [[SCNavTabBar alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAV_TAB_BAR_HEIGHT) showArrowButton:_showArrowButton];
    _navTabBar.delegate = self;
    _navTabBar.backgroundColor = _navTabBarColor;
    _navTabBar.lineColor = _navTabBarLineColor;
    _navTabBar.itemTitles = _titles;
    _navTabBar.arrowImage = _navTabBarArrowImage;
    [_navTabBar updateData];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, _navTabBar.frame.origin.y + _navTabBar.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - _navTabBar.frame.origin.y - _navTabBar.frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    _mainView.delegate = self;
    _mainView.pagingEnabled = YES;
    _mainView.scrollEnabled=NO;
    _mainView.bounces = _mainViewBounces;
    _mainView.showsHorizontalScrollIndicator = NO;
//    [_mainView.panGestureRecognizer addTarget:self action:@selector(panHandle:)];
    _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * _subViewControllers.count, DOT_COORDINATE);
    _mainView.delaysContentTouches = YES;
    _mainView.canCancelContentTouches=NO;

    
    [self.view addSubview:_mainView];
    [self.view addSubview:_navTabBar];
}
#pragma mark 

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        
        CGPoint vTranslationPoint = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self.view];
        
        return fabs(vTranslationPoint.x) > fabs(vTranslationPoint.y);//如果手势纵向移动位移比横向位移大则不响应
        
    }
    
    return YES;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    if ([scrollView isEqual:_mainView]) {
        //
//        _mainView.scrollEnabled=YES;
    }else{
//        _mainView.scrollEnabled=NO;
//        _mainView.pagingEnabled=NO;

    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:_mainView]) {
        //
    }else{
       

    }
}


- (void)viewConfig
{
    [self viewInit];
    
    // Load children view controllers and add to content view
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
//        [viewController.view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if ([obj isKindOfClass:[UIScrollView class]]) {
//                UIScrollView * scrollView =obj;
//                [scrollView.panGestureRecognizer addTarget:self action:@selector(panHandle:)];
//                *stop=YES;
//
//            }
//        }];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, _mainView.frame.size.height);
        [_mainView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];
}

#pragma mark - Public Methods
#pragma mark -
- (void)setNavTabbarColor:(UIColor *)navTabbarColor
{
    // prevent set [UIColor clear], because this set can take error display
    CGFloat red, green, blue, alpha;
    if ([navTabbarColor getRed:&red green:&green blue:&blue alpha:&alpha] && !red && !green && !blue && !alpha)
    {
        navTabbarColor = NavTabbarColor;
    }
    _navTabBarColor = navTabbarColor;
}

- (void)addParentController:(UIViewController *)viewController
{
    // Close UIScrollView characteristic on IOS7 and later
    if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
    {
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
}

#pragma mark - Scroll View Delegate Methods
#pragma mark -

-(void)panHandle:(UIPanGestureRecognizer*)pan{
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _mainView.scrollEnabled=NO;
            _mainView.pagingEnabled=NO;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _mainView.scrollEnabled=YES;
            _mainView.pagingEnabled=YES;
        }
            break;
            
        default:
            break;
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_mainView]) {
        _currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
        _navTabBar.currentItemIndex = _currentIndex;
    }
 
}

#pragma mark - SCNavTabBarDelegate Methods
#pragma mark -
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    [_mainView setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
}

//- (void)shouldPopNavgationItemMenu:(BOOL)pop height:(CGFloat)height
//{
//    if (pop)
//    {
//        [UIView animateWithDuration:0.5f animations:^{
//            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, height + NAV_TAB_BAR_HEIGHT);
//        }];
//    }
//    else
//    {
//        [UIView animateWithDuration:0.5f animations:^{
//            _navTabBar.frame = CGRectMake(_navTabBar.frame.origin.x, _navTabBar.frame.origin.y, _navTabBar.frame.size.width, NAV_TAB_BAR_HEIGHT);
//        }];
//    }
//    [_navTabBar refresh];
//}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
