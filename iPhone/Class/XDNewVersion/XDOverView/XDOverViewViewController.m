//
//  XDOverViewViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/2/1.
//

#import "XDOverViewViewController.h"

#import "XDCalendarView.h"
#import "XDTransicationTableViewController.h"
#import "SearchRelatedViewController.h"
#import "AccountSearchViewController.h"
#import "XDAddTransactionViewController.h"
#import "XDAccountMainTableViewController.h"
#import "SettingViewController.h"
#import "XDNavigationViewController.h"
#import "XDSignInViewController.h"
#import "PokcetExpenseAppDelegate.h"

#import "Transaction.h"

@interface XDOverViewViewController ()<XDCalendarViewDelegate,XDTransicationTableViewDelegate,XDAddTransactionViewDelegate>

@property(nonatomic, strong)XDTransicationTableViewController* transTableView;
@property(nonatomic, strong)XDCalendarView * calView;
@property(nonatomic, strong)Transaction * currentTransication;
@property(nonatomic, strong)NSDate * selectedDate;

@property(nonatomic, strong)UIView * backCoverView;
@property(nonatomic, strong)UIView * lineView;;
@property(nonatomic, strong)UIView * datePickerView;

@property(nonatomic, strong)UIDatePicker * datePicker;

@property(nonatomic, strong)UIImageView * emptyImageView;

@property(nonatomic, strong)UIButton * titleBtn;

@property(nonatomic, strong)UIView * bubbleView;

@end

@implementation XDOverViewViewController
@synthesize tabbarVc;



-(UIView *)bubbleView{
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _bubbleView.backgroundColor = [UIColor clearColor];
        
        UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bubble"]];
        if (IS_IPHONE_X) {
            imageView.frame = CGRectMake(SCREEN_WIDTH - 104, 85, 95, 40);
        }else{
            imageView.frame = CGRectMake(SCREEN_WIDTH - 104, 64, 95, 40);
        }
        imageView.contentMode = UIViewContentModeCenter;
        
        [self popJumpAnimationView:imageView];
        
        [_bubbleView addSubview:imageView];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 14, 95, 16)];
        label.font = [UIFont fontWithName:FontSFUITextRegular size:14];
        label.text = NSLocalizedString(@"VC_Account", nil);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:label];
        
//        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        
        [self.navigationController.view addSubview:_bubbleView];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleDismiss)];
        [_bubbleView addGestureRecognizer:tap];
    }
    return _bubbleView;
}

-(UIImageView *)emptyImageView{
    if (!_emptyImageView) {
        _emptyImageView  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"empty state1"]];
        _emptyImageView.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame), self.view.width, self.view.height - 73);;
        _emptyImageView.contentMode = UIViewContentModeTop;
        _emptyImageView.hidden = YES;
        _emptyImageView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_emptyImageView];
        [self.view bringSubviewToFront:_emptyImageView];
        [self.view bringSubviewToFront:_bubbleView];

    }
    return _emptyImageView;
}

-(UIView *)datePickerView{
    if (!_datePickerView) {
        _datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 256)];
        _datePickerView.backgroundColor = [UIColor whiteColor];
        
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 66, SCREEN_WIDTH, 180)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePickerView addSubview:_datePicker];
//        [_datePicker setValue:RGBColor(113, 163, 245) forKey:@"textColor"];
        
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 56)];
        label.centerX = SCREEN_WIDTH/2;
        label.font = [UIFont fontWithName:FontSFUITextMedium size:17];
        label.textColor = RGBColor(85, 85, 85);
        label.text = @"Duplicate To Date";
        label.textAlignment = NSTextAlignmentCenter;
        [_datePickerView addSubview:label];
        
        UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 52, 19, 37, 19)];
        [btn setTitle:@"Save" forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentRight;
        [btn setTitleColor: RGBColor(113, 163, 245) forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:FontHelveticaNeueReguar size:16];
        [btn addTarget: self action:@selector(duplicateBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:btn];
        
        [self.view.window addSubview:_datePickerView];
    }
    return _datePickerView;
}



-(UIView *)backCoverView{
    if (!_backCoverView) {
        _backCoverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backCoverView.backgroundColor = [UIColor colorWithRed:133/255 green:133/255 blue:133/255 alpha:1];
        _backCoverView.alpha = 0;
        _backCoverView.hidden = YES;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(tapClick)];
        [_backCoverView addGestureRecognizer:tap];
        [self.view.window addSubview:_backCoverView];
    }
    return _backCoverView;
}

-(XDCalendarView *)calView{
    if (!_calView) {
        _calView = [[XDCalendarView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 73)];
        _calView.delegate = self;
    }
    return _calView;
}

-(XDTransicationTableViewController *)transTableView{
    if (!_transTableView) {
        _transTableView = [[XDTransicationTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        _transTableView.selectedDate = [NSDate date];
        _transTableView.transcationDelegate = self;
        if (IS_IPHONE_X) {
            _transTableView.view.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame), self.view.width, SCREEN_HEIGHT - 254);
        }else{
            _transTableView.view.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame), self.view.width, SCREEN_HEIGHT - 196);
        }
    }
    return _transTableView;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tabbarDismiss" object:@NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.selectedDate = [NSDate date];
    [self initNavStyle];
    [self initXDtransicationTableView];
//    self.title = [self monthFormatterWithSeletedMonth:[NSDate date]];
    self.view.backgroundColor = RGBColor(246, 246, 246);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"TransactionViewRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"refreshUI" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDateHasData:) name:@"selectedDateHasData" object:nil];

    [self emptyImageViewShow];
    
    self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleBtn.frame = CGRectMake(0, 0, 150, 30);
    self.titleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.titleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.titleBtn setAttributedTitle:[self monthFormatterWithSeletedMonth:[NSDate date]] forState:UIControlStateNormal];
    [self.titleBtn addTarget:self action:@selector(titleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = self.titleBtn;
    
    
    [self getCurrentVersion];
    
}

-(void)titleBtnClick{
    [self scrollToToday];
}

-(void)selectedDateHasData:(NSNotification*)notif{
    BOOL show = [notif.object boolValue];
    if (show) {
        self.emptyImageView.hidden = YES;
    }else{
        self.emptyImageView.hidden = NO;
        self.emptyImageView.image = [UIImage imageNamed:@"empty state2"];
    }
}

-(void)emptyImageViewShow{
    
    NSArray* array = [[XDDataManager shareManager]getObjectsFromTable:@"Transaction" predicate:[NSPredicate predicateWithFormat:@"state = %@",@"1"] sortDescriptors:nil];
    if (array.count > 0) {
        self.emptyImageView.hidden = YES;
        
        double incomeAmount = 0;
        double expenseAmount = 0;
        
        NSArray* array = [[XDDataManager shareManager] getTransactionDate:self.selectedDate withAccount:nil];
        if (array.count > 0) {
            
            for (int i = 0; i<array.count; i++) {
                Transaction* transaction = array[i];
                
                if (transaction.parTransaction == nil) {
                    if ([transaction.transactionType isEqualToString:@"income"] || ((transaction.expenseAccount == nil && transaction.incomeAccount != nil) && [transaction.category.categoryType isEqualToString:@"INCOME"])) {
                        incomeAmount += [transaction.amount doubleValue];
                    }else if([transaction.transactionType isEqualToString:@"expense"] || ((transaction.expenseAccount != nil && transaction.incomeAccount == nil)&& [transaction.category.categoryType isEqualToString:@"EXPENSE"])){
                        expenseAmount += [transaction.amount doubleValue];
                    }
                }
            }
        }
        
        if (incomeAmount == 0 && expenseAmount == 0 && array.count == 0) {
            self.emptyImageView.hidden = NO;
            self.emptyImageView.image = [UIImage imageNamed:@"empty state2"];
        }
        
    }else{
        self.emptyImageView.hidden = NO;
        
    }
    
    
}


-(void)initXDtransicationTableView{
    [self.view addSubview:self.calView];

    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calView.frame), SCREEN_WIDTH, 10)];
    self.lineView.backgroundColor = RGBColor(246, 246, 246);
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.transTableView.tableView];
}

-(void)initNavStyle
{
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setColor: [UIColor whiteColor]];

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(settingButtonPress) image:[UIImage imageNamed:@"setting_new"]];
 
    UIView *barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 93, 44)];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 44, 44);
    [btn1 setImage:[UIImage imageNamed:@"inquire_new"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(49, 0, 44, 44);
    [btn2 setImage:[UIImage imageNamed:@"account_new"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(accountBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:btn2];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:barView];
}

-(NSAttributedString*)monthFormatterWithSeletedMonth:(NSDate*)date{
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM"];
    NSString* string = [formatter stringFromDate:date];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc]initWithString:string];
    [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontHelveticaNeueMedium size:17] range:NSMakeRange(0, string.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:RGBColor(113, 163, 245) range:NSMakeRange(0, string.length)];
    
    
    
    [formatter setDateFormat:@"yyyy"];
    NSString* string1 = [formatter stringFromDate:date];
    
    NSMutableAttributedString* attString1 = [[NSMutableAttributedString alloc]initWithString:string1];
    
    [attString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontHelveticaNeueMedium size:17] range:NSMakeRange(0, string1.length)];
    [attString1 addAttribute:NSForegroundColorAttributeName value:RGBColor(200, 200, 200) range:NSMakeRange(0, string1.length)];
    [attString appendAttributedString:[[NSMutableAttributedString alloc]initWithString:@" "]];
    [attString appendAttributedString:attString1];
    
    return attString;
}

-(void)tapClick{
    [UIView animateWithDuration:0.2 animations:^{
        self.backCoverView.alpha = 0;
        self.datePickerView.y = SCREEN_HEIGHT;

    }completion:^(BOOL finished) {
        self.backCoverView.hidden = YES;

    }];

}

-(void)duplicateBtnClick{
    [self tapClick];
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.epnc setFlurryEvent_WithIdentify:@"02_TRANS_DUPL"];
    
    [appDelegate.epdc duplicateTransaction:self.currentTransication withDate:self.datePicker.date];

    [self reloadTableView];
}

#pragma mark -  XDAddTransactionViewDelegate
-(void)addTransactionCompletion{
    [self.transTableView.tableView reloadData];
}
#pragma mark - XDTransicationTableViewDelegate
-(void)returnDragContentOffset:(CGFloat)offsetY{
    if (offsetY < 0) {
        if (self.calView.calendarType != CalendarMonth) {
            self.calView.calendarType = CalendarMonth;
            [UIView animateWithDuration:0.2 animations:^{
                self.lineView.y = 338;
                self.transTableView.view.y = CGRectGetMaxY(self.lineView.frame);
                self.emptyImageView.height = self.transTableView.view.height ;

            }];
        }
    }else{

        if (self.calView.calendarType != CalendarDay ) {
            self.calView.calendarType = CalendarDay;
            [UIView animateWithDuration:0.2 animations:^{
                self.lineView.y = 73;
                self.transTableView.view.y = CGRectGetMaxY(self.lineView.frame);
                self.emptyImageView.frame = self.transTableView.view.frame;
            }];
        }
    }
}
-(void)returnCellSelectedBtn:(Transaction *)transcation index:(NSInteger)index{
    self.currentTransication = transcation;
    
    if (index == 0) {
        SearchRelatedViewController *searchRelatedViewController= [[SearchRelatedViewController alloc]initWithNibName:@"SearchRelatedViewController" bundle:nil];
        searchRelatedViewController.transaction = transcation;
//        searchRelatedViewController.hidesBottomBarWhenPushed = TRUE;
        [self.navigationController pushViewController:searchRelatedViewController animated:YES];
    }else if (index == 1){
        self.backCoverView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.backCoverView.alpha = 0.5;
            self.datePickerView.y = SCREEN_HEIGHT - 256;
        }];
    }else if (index == 2){
      
        [self reloadTableView];
    }
}

-(void)returnSelectedCellTranscation:(Transaction *)transcation{
    XDAddTransactionViewController* tranVc = [[XDAddTransactionViewController alloc]initWithNibName:@"XDAddTransactionViewController" bundle:nil];
    tranVc.editTransaction = transcation;
    tranVc.delegate = (id)tabbarVc;
    [self presentViewController:tranVc animated:YES completion:nil];
}


#pragma mark Btn Action

-(void)settingButtonPress{
    
    SettingViewController *settingVC=[[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:settingVC];
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)searchBtnClick{
    
    AccountSearchViewController *searchVC = [[AccountSearchViewController alloc]initWithNibName:@"AccountSearchViewController" bundle:nil];
    [self presentViewController:searchVC  animated:YES completion:nil];
}

-(void)accountBtnPressed{
    XDAccountMainTableViewController* vc = [[XDAccountMainTableViewController alloc]initWithNibName:@"XDAccountMainTableViewController" bundle:nil];
    XDNavigationViewController* nav = [[XDNavigationViewController alloc]initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - XDCalendarViewDelegate
-(void)returnCurrentShowDate:(NSDate *)date{
    [self.titleBtn setAttributedTitle:[self monthFormatterWithSeletedMonth:date] forState:UIControlStateNormal];
}

-(void)returnSelectedDate:(NSDate *)date{
    self.selectedDate = date;
    self.transTableView.selectedDate = date;
    
    self.dateBlock(date);
}

-(void)returnCalendarFrame:(CGRect)rect{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.y = rect.size.height;
        self.transTableView.tableView.y =  CGRectGetMaxY(self.lineView.frame);
        self.emptyImageView.frame = CGRectMake(0, CGRectGetMaxY(self.lineView.frame),self.view.width, self.view.height - rect.size.height);
    }];
}


-(void)reloadTableView{
    
    self.transTableView.selectedDate = self.selectedDate;
    [self.calView reloadCalendarView];
    
    [self emptyImageViewShow];
}

-(void)scrollToToday{
    self.selectedDate = [[NSDate date]initDate];
    [self.titleBtn setAttributedTitle:[self monthFormatterWithSeletedMonth:self.selectedDate] forState:UIControlStateNormal];

    [self.calView scrollToToday];
    self.transTableView.selectedDate = self.selectedDate;
    [self emptyImageViewShow];
    self.dateBlock(self.selectedDate);

}

#pragma mark - other
- (void)popJumpAnimationView:(UIView *)sender
{
    
    CGFloat duration = 1.f;
    CGFloat height = 7.f;
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    CGFloat currentTy = sender.transform.ty;
    animation.duration = duration;
    animation.values = @[@(currentTy), @(currentTy - height/4), @(currentTy-height/4*2), @(currentTy-height/4*3), @(currentTy - height), @(currentTy-height/4*3), @(currentTy -height/4*2), @(currentTy - height/4), @(currentTy)];
    animation.keyTimes = @[ @(0), @(0.025), @(0.085), @(0.2), @(0.5), @(0.8), @(0.915), @(0.975), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = HUGE_VALF;
    [sender.layer addAnimation:animation forKey:@"kViewShakerAnimationKey"];
    
}

-(void)bubbleDismiss{
    [self.bubbleView removeFromSuperview];
}

-(void)getCurrentVersion
{
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"CFBundleVersion"];
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    if (![currentVersion isEqualToString:lastVersion]) {
        self.bubbleView.hidden = NO;
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"CFBundleVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        self.bubbleView.hidden = YES;
    }
}


@end
