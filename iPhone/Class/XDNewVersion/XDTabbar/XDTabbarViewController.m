//
//  XDTabbarViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/1/9.
//

#import "XDTabbarViewController.h"
#import "XDOverViewViewController.h"
#import "AccountsViewController.h"
#import "XDBudgetMainViewController.h"
#import "XDBillMainViewController.h"
#import "XDAddTransactionViewController.h"
#import "XDTabbarView.h"
#import "XDChartMainViewController.h"
#import "AppDelegate_iPhone.h"
@interface XDTabbarViewController ()<XDAddTransactionViewDelegate>
@property(nonatomic, strong)XDOverViewViewController * overViewCalendarViewController;
@property(nonatomic, strong)XDBudgetMainViewController * budgetViewController;
@property(nonatomic, strong)XDBillMainViewController * billViewController;
@property(nonatomic, strong)TransactionEditViewController * transacitionViewController;
@property(nonatomic, strong)__block NSDate * date;
@property(nonatomic, strong)XDTabbarView * tabbarView;
@property(nonatomic, strong)XDChartMainViewController * chartViewController;



@end

@implementation XDTabbarViewController

-(XDOverViewViewController *)overViewCalendarViewController{
    if (!_overViewCalendarViewController) {
        _overViewCalendarViewController = [[XDOverViewViewController alloc]init];
        _overViewCalendarViewController.tabbarVc = self;
        __weak __typeof__(self) weakSelf = self;
        _overViewCalendarViewController.dateBlock = ^(NSDate *selectedDate) {
            weakSelf.date = selectedDate;
        };
    }
    return _overViewCalendarViewController;
}

-(XDChartMainViewController *)chartViewController{
    if (!_chartViewController) {
        _chartViewController = [[XDChartMainViewController alloc]initWithNibName:@"XDChartMainViewController" bundle:nil];
    }
    return _chartViewController;
}

-(XDBudgetMainViewController *)budgetViewController{
    if (!_budgetViewController) {
        _budgetViewController = [[XDBudgetMainViewController alloc]initWithNibName:@"XDBudgetMainViewController" bundle:nil];
    }
    return _budgetViewController;
}

-(XDBillMainViewController *)billViewController{
    if (!_billViewController) {
        _billViewController = [[XDBillMainViewController alloc]initWithNibName:@"XDBillMainViewController" bundle:nil];
        
    }
    return _billViewController;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabbarDismiss:) name:@"tabbarDismiss" object:nil];
    
    self.date = [NSDate initCurrentDate];
    [self setupChildControllers];
    if (IS_IPHONE_X) {
        self.tabbarView = [[XDTabbarView alloc]initWithFrame:CGRectMake(0, self.view.height - 83, SCREEN_WIDTH, 83)];
    }else{
        self.tabbarView = [[XDTabbarView alloc]initWithFrame:CGRectMake(0, self.view.height - 49, SCREEN_WIDTH, 83)];
    }
    [self.view bringSubviewToFront:self.tabbarView];
    [self.view addSubview:self.tabbarView];
    self.tabBar.hidden = YES;
    __weak __typeof__(self) weakSelf = self;
    self.tabbarView.block = ^(NSInteger index) {
        if (index == 2) {
            XDAddTransactionViewController* addVc = [[XDAddTransactionViewController alloc]initWithNibName:@"XDAddTransactionViewController" bundle:nil];
            addVc.calSelectedDate = weakSelf.date;
            addVc.delegate = weakSelf;
//            NSLog(@"selectedDate = %@", weakSelf.date);
            [weakSelf presentViewController:addVc animated:YES completion:nil];
        }else{
            if (index == weakSelf.selectedIndex) {
                [weakSelf.overViewCalendarViewController scrollToToday];
            }
            weakSelf.selectedIndex = index;
        }
    };
    
//    [self adView];
}

-(void)tabbarDismiss:(NSNotification*)notif{
    [UIView animateWithDuration:0.2 animations:^{
        if ([[notif object] boolValue]) {
            self.tabbarView.y =  self.view.height + 20;
        }else{
            if (IS_IPHONE_X) {
                self.tabbarView.y = self.view.height - 83;
            }else{
                self.tabbarView.y = self.view.height - 49;
            }
        }
    }];
}

-(void)setupChildControllers{
    [self addChildViewController:[[UINavigationController alloc]initWithRootViewController:self.overViewCalendarViewController]];
    [self addChildViewController:[[UINavigationController alloc]initWithRootViewController:self.chartViewController]];
    [self addChildViewController:[[UINavigationController alloc]initWithRootViewController:[[UIViewController alloc]init]]];
    [self addChildViewController:[[UINavigationController alloc]initWithRootViewController:self.budgetViewController]];
    [self addChildViewController:[[UINavigationController alloc]initWithRootViewController:self.billViewController]];
}
- (UIImage *)imageWithColor:(UIColor *)color{
    // 一个像素
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // 开启上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//-(void)adView{
//    NSString *purchasePrice = [[NSUserDefaults standardUserDefaults] stringForKey:PURCHASE_PRICE];
//
//    UIImage *adsImage=[UIImage imageNamed:[NSString customImageName:@"advertisement"]];
//
//    AppDelegate_iPhone *appdelegate=(AppDelegate_iPhone *)[[UIApplication sharedApplication]delegate];
//
//    appdelegate.adsView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-79-70-adsImage.size.height, SCREEN_WIDTH, adsImage.size.height)];
//    appdelegate.adsView.backgroundColor=[UIColor colorWithPatternImage:adsImage];
//    [self.view addSubview:appdelegate.adsView];
//
//    UILabel *priceLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-80, (adsImage.size.height-30)/2, 80, 30)];
//    priceLabel.text=purchasePrice;
//    priceLabel.textAlignment=NSTextAlignmentCenter;
//    priceLabel.textColor=[UIColor whiteColor];
//    priceLabel.font=[UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
//    [appdelegate.adsView addSubview:priceLabel];
//    if (appdelegate.isPurchased)
//    {
//        [appdelegate.adsView removeFromSuperview];
//    }
//
//    UIButton *adsBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, adsImage.size.height)];
//    adsBtn.backgroundColor=[UIColor clearColor];
//    [adsBtn addTarget:self action:@selector(adsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [appdelegate.adsView addSubview:adsBtn];
//}

#pragma mark - XDAddTransactionViewDelegate
-(void)addTransactionCompletion{
    [self.overViewCalendarViewController reloadTableView];
}


@end
