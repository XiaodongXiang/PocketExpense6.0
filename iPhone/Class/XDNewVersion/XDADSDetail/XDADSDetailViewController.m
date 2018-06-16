//
//  XDADSDetailViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/5/4.
//

#import "XDADSDetailViewController.h"
#import "PokcetExpenseAppDelegate.h"
@interface XDADSDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *upgradeBtn;
@property (weak, nonatomic) IBOutlet UIButton *restoreBtn;

@property(nonatomic, strong)UILabel * priceLbl;

@property(nonatomic, strong)UIActivityIndicatorView * indicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top2;


@end

@implementation XDADSDetailViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
-(UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.upgradeBtn.width - 92, 24, 20, 20)];
        
        [self.upgradeBtn addSubview:_indicator];
    }
    return _indicator;
}

-(UILabel *)priceLbl{
    if (!_priceLbl) {
        _priceLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.upgradeBtn.width - 117, 24, 100, 21)];
        _priceLbl.font = [UIFont fontWithName:FontSFUITextRegular size:18];
        _priceLbl.textColor = [UIColor whiteColor];
        
        [self.upgradeBtn addSubview:_priceLbl];
    }
    return _priceLbl;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 0);
    NSArray* titleArr = @[@"Export data and reports",@"Remove ads"];
    for (int i = 0; i<2; i++) {
        UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i+1]]];
        imageView.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, 340);
        
        [self.scrollView addSubview:imageView];
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i , 340, SCREEN_WIDTH, 100)];
        lbl.text = titleArr[i];
        lbl.font = [UIFont fontWithName:@"Helvetica-Bold" size:28];
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.scrollView addSubview:lbl];
    }
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:recognizer];
    
    [self preVersionPrice:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSelf) name:@"DismissADSView" object:nil];
    
    //添加观察通知，当获取到价格的时候就将价格显示出来
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(preVersionPrice:) name:GET_PRO_VERSION_PRICE_ACTION object:nil];
//    [notificationCenter addObserver:self selector:@selector(ADViewRemove) name:@"ADViewRemove" object:nil];
    
    //更新产品信息
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.inAppPM.proUpgradeProduct == nil)
    {
        [appDelegate.inAppPM loadStore];
    }
    
    if (IS_IPHONE_X) {
        self.top1.constant = self.top2.constant = 44;
    }
   
}

-(void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)ADViewRemove{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSwipe:(UIPanGestureRecognizer *)swipe
{
    
    if (swipe.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[swipe translationInView:self.view]];
    }
}

- (void)commitTranslation:(CGPoint)translation
{
    
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    
    
    if (absX > absY ) {
        
        if (translation.x<0) {
            
            //向左滑动
        }else{
            
            //向右滑动
        }
        
    } else if (absY > absX) {
        if (translation.y<0) {
            
            //向上滑动
        }else{
            
            //向下滑动
            
            [self cancelClick:nil];
        }
    }
    
    
}

- (IBAction)upgradeBtnClick:(id)sender {
    
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];

    if ([appDelegate.inAppPM canMakePurchases])
    {
        [appDelegate.inAppPM  purchaseProUpgrade];
    }
    
    [appDelegate.epnc setFlurryEvent_withUpgrade:YES];
    
}

- (IBAction)cancelClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)restoreBtnClick:(id)sender {
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.inAppPM  restorePurchase];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index =(int) scrollView.contentOffset.x/SCREEN_WIDTH;
    
    self.pageControl.currentPage = index;
}
//获取保存在本地的商品价格，显示
-(void)preVersionPrice:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *purchasePrice = [userDefaults stringForKey:PURCHASE_PRICE];
    if ([purchasePrice length]>0)
    {
        self.priceLbl.text = purchasePrice;
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        
    }
    else
    {
        [self.indicator startAnimating];
        self.priceLbl.text = nil;
    }
}



@end
