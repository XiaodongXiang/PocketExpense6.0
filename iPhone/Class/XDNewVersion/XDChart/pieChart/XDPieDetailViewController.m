//
//  XDPieDetailViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/3/22.
//

#import "XDPieDetailViewController.h"
#import "XDPiePageView.h"
#import "XDChartDataClass.h"
#import "XDPieSelectCategoryTableViewController.h"
@interface XDPieDetailViewController ()<XDPiePageViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *dateScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *pieScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollBackView;

@property(nonatomic, strong)XDPiePageView * currentPiePageView;
@property(nonatomic, strong)XDPiePageView * lastPiePageView;
@property(nonatomic, strong)XDPiePageView * nextPiePageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dataScrollTopLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopLeading;

@end

@implementation XDPieDetailViewController
@synthesize index,type,dateArray,dataArray,pieType,account;

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    CGFloat width = SCREEN_WIDTH / 3;
    
    if (type == DateSelectedCustom) {
        UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(-width/2, 0, width*2, 20)];
        label.centerX = SCREEN_WIDTH/2;
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = [NSString stringWithFormat:@"%@ - %@",[self timeFormatter:self.dateArray.firstObject],[self timeFormatter:self.dateArray.lastObject]];
        
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        label.textAlignment = NSTextAlignmentCenter;
        [self.dateScrollView addSubview:label];

    }else{
        self.dateScrollView.contentSize = CGSizeMake(width * (dateArray.count + 2), 0);
        self.pieScrollView.contentSize = CGSizeMake(dateArray.count * SCREEN_WIDTH, 0);
     
        for (int i = 0; i < dateArray.count; i++) {
            UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(width * i + width, 0, width, 20)];
            label.tag = i;
            if (type == DateSelectedWeek) {
                label.text = [self coverDateToString:dateArray[i]];
            }else if(type == DateSelectedMonth){
                label.text = [NSString stringWithFormat:@"%@",[self monthFormatter:dateArray[i]]];
            }else if(type == DateSelectedYear){
                label.text = [NSString stringWithFormat:@"%@",[self yearFormatter:dateArray[i]]];
            }
            
            label.textColor = [UIColor grayColor];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
            label.textAlignment = NSTextAlignmentCenter;
            [self.dateScrollView addSubview:label];
        }
        
        [self.dateScrollView setContentOffset:CGPointMake(width * index , 0)];
        [self.pieScrollView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0)];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:FontSFUITextMedium size:17],NSForegroundColorAttributeName:RGBColor(85, 85, 85)}];

    CGFloat pointY;
    if (IS_IPHONE_X) {
        pointY = 48;
        self.dataScrollTopLeading.constant = 88;
        self.scrollViewTopLeading.constant = 112;
    }else{
        pointY = 24;
    }
    
    if (IS_IPHONE_X) {
        self.pieScrollView.frame = CGRectMake(0, CGRectGetMaxY(_dateScrollView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - 112);
    }else{
        self.pieScrollView.frame = CGRectMake(0, CGRectGetMaxY(_dateScrollView.frame), SCREEN_WIDTH, SCREEN_HEIGHT - 88);
    }
    [self setUpScrollView];
    
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"refreshUI" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"TransactionViewRefresh" object:nil];
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, pointY)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH/2 - 5, pointY)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH/2, pointY-4)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH/2 + 5, pointY)];
    [path addLineToPoint:CGPointMake(SCREEN_WIDTH, pointY)];
    
    layer.path = path.CGPath;
    layer.borderColor = RGBColor(229, 229, 229).CGColor;
    layer.borderWidth = 0.5;
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.strokeColor = RGBColor(229, 229, 229).CGColor;

    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(cancelClick) image:[UIImage imageNamed:@"Return_icon_normal"]];

    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self.scrollBackView.layer addSublayer:layer];
}

-(void)cancelClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reloadTableView{
    
    if (index > 0) {
        NSDate* date;
        if (type == DateSelectedWeek) {
            date = [dateArray[index - 1] firstObject];
        }else{
            date = dateArray[index - 1];
        }
        self.lastPiePageView.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
    }
    if (index < (dateArray.count-2) && dateArray.count >= 2) {
        NSDate* date;
        if (type == DateSelectedWeek) {
            date = [dateArray[index + 1] firstObject];
        }else{
            date = dateArray[index + 1];
        }
        self.nextPiePageView.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
    }
    
    NSDate* sdate = dateArray[index];
    
    
    self.currentPiePageView.dataArray = [XDChartDataClass pieCategoryWithDate:sdate endDate:nil dateType:type tranType:pieType account:account];
    
}

-(void)setUpScrollView{
    
    self.currentPiePageView = [[XDPiePageView alloc]initWithFrame:CGRectMake(index * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.pieScrollView.height)];
    self.lastPiePageView = [[XDPiePageView alloc]initWithFrame:CGRectMake((index - 1) * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.pieScrollView.height)];
    self.nextPiePageView = [[XDPiePageView alloc]initWithFrame:CGRectMake((index + 1) * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.pieScrollView.height)];
    self.currentPiePageView.delegate = self;
    self.lastPiePageView.delegate= self;
    self.nextPiePageView.delegate = self;
    
    if (index > 0) {
        NSDate* date;
        if (type == DateSelectedWeek) {
            date = [dateArray[index - 1] firstObject];
        }else{
            date = dateArray[index - 1];
        }
        self.lastPiePageView.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
    }
    if (index < (dateArray.count-2) && dateArray.count >= 2) {
        NSDate* date;
        if (type == DateSelectedWeek) {
            date = [dateArray[index + 1] firstObject];
        }else{
            date = dateArray[index + 1];
        }
        self.nextPiePageView.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
    }
    
    self.currentPiePageView.dataArray = dataArray;
    
    [self.pieScrollView addSubview:self.currentPiePageView];
    [self.pieScrollView addSubview:self.lastPiePageView];
    [self.pieScrollView addSubview:self.nextPiePageView];
}
#pragma mark - XDPiePageViewDelegate
-(void)returnSelectedPieModel:(XDPieChartModel *)model{
    XDPieSelectCategoryTableViewController* vc = [[XDPieSelectCategoryTableViewController alloc]init];
    vc.account = account;
    if (type == DateSelectedCustom) {
        vc.startDate = [dateArray[index]firstObject];
        vc.endDate = [dateArray[index]lastObject];
    }else{
        vc.startDate = dateArray[index];
        vc.endDate = nil;
    }
    vc.type = type;
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.pieScrollView) {
        [self.dateScrollView setContentOffset:CGPointMake((scrollView.contentOffset.x / 3), 0)];
        
        NSInteger location =round(scrollView.contentOffset.x / SCREEN_WIDTH);
        
        if (location != index) {
            
            if (location > index) {
                
                if (location >= dateArray.count-1) {
                    
                    return;
                }
                
                self.lastPiePageView.x = SCREEN_WIDTH * (location + 1);
                
                XDPiePageView * temp = self.lastPiePageView;
                NSDate* date;
                if (type == DateSelectedWeek) {
                    date = [dateArray[location + 1] firstObject];
                }else{
                    date = dateArray[location + 1];
                }
                temp.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
                
                self.lastPiePageView = self.currentPiePageView;
                self.currentPiePageView = self.nextPiePageView;
                self.nextPiePageView = temp;
            }else{
                
                if (location <= 0 ) {
                    return;
                }
                
                self.nextPiePageView.x = SCREEN_WIDTH * (location - 1);
                
                XDPiePageView * temp = self.nextPiePageView;
                NSDate* date;
                if (type == DateSelectedWeek) {
                    date = [dateArray[location - 1] firstObject];
                }else{
                    date = dateArray[location - 1];
                }
                temp.dataArray = [XDChartDataClass pieCategoryWithDate:date endDate:nil dateType:type tranType:pieType account:account];
                
                self.nextPiePageView = self.currentPiePageView;
                self.currentPiePageView = self.lastPiePageView;
                self.lastPiePageView = temp;

                
            }
            
            index = location;
        }
    }
    
    
}


#pragma mark - other
-(NSString*)coverDateToString:(NSMutableArray*)muArr{
    NSDate* firstDate = [muArr firstObject];
    NSDate* lastDate = [muArr lastObject];
    
    NSString* string = [NSString stringWithFormat:@"%@-%@",[self dateformatter:firstDate],[self dateformatter:lastDate]];
    return string;
}

-(NSString*)dateformatter:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"LLL d"];
    return [format stringFromDate:date];
}

-(NSString*)monthFormatter:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"LLL yyyy"];
    return [format stringFromDate:date];
}

-(NSString*)yearFormatter:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy"];
    return [format stringFromDate:date];
}

-(NSString*)timeFormatter:(NSDate*)date{
    NSDateFormatter* format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"LLL d, yyyy"];
    return [format stringFromDate:date];
}


@end
