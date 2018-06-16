//
//  XDPieSelectCategoryTableViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/3/27.
//

#import "XDPieSelectCategoryTableViewController.h"
#import "XDChartDataClass.h"
#import "XDPieChartModel.h"
#import "Transaction.h"
#import "Payee.h"
#import "XDAddTransactionViewController.h"
#import "XDCustomTransactionTableViewCell.h"
#import "PokcetExpenseAppDelegate.h"
@interface XDPieSelectCategoryTableViewController ()<XDAddTransactionViewDelegate>
@property(nonatomic, strong)NSMutableArray* dataArray;
@end

@implementation XDPieSelectCategoryTableViewController
@synthesize startDate,endDate,type,account;
-(void)setModel:(XDPieChartModel *)model{
    _model = model;
    if (type == DateSelectedCustom) {
        self.dataArray = [NSMutableArray arrayWithArray:[XDChartDataClass pieCategoryWithDate:startDate endDate:endDate dateType:type category:model.category account:account]];
    }else{
        self.dataArray = [NSMutableArray arrayWithArray:[XDChartDataClass pieCategoryWithDate:startDate endDate:nil dateType:type category:model.category account:account]];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

}

-(void)cancelClick{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(cancelClick) image:[UIImage imageNamed:@"Return_icon_normal"]];

    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;

    self.title = _model.category.categoryName;
    
    self.tableView.separatorColor = RGBColor(226 , 226 , 226);

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellID = @"cell";
    XDCustomTransactionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"XDCustomTransactionTableViewCell" owner:self options:nil]lastObject];
    }
    Transaction* tran = self.dataArray[indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:tran.category.iconName];
    cell.nameL.text = tran.payee.name?:@"-";
    cell.amountL.text = [XDDataManager moneyFormatter:[tran.amount doubleValue]];
    cell.dateL.text = [self returnInitDate:tran.dateTime];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Transaction* transition = self.dataArray[indexPath.row];

        PokcetExpenseAppDelegate *appDelegete = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegete.epdc deleteTransactionRel:transition];
        
        [self.dataArray removeObject:transition];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshUI" object:nil];
        });
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XDAddTransactionViewController* addVc = [[XDAddTransactionViewController alloc]initWithNibName:@"XDAddTransactionViewController" bundle:nil];
    addVc.editTransaction = self.dataArray[indexPath.row];
    addVc.delegate = self;
    [self presentViewController:addVc animated:YES completion:nil];
}
-(NSString*)returnInitDate:(NSDate*)date{
    
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [[NSCalendar currentCalendar] components:dayInfoUnits fromDate:date];
    
    NSDate* newDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"ccc, LLL d, yyyy";
    NSString* dateStr = [formatter stringFromDate:newDate];
    
    return dateStr;
    
}

-(void)addTransactionCompletion{
    
    if (type == DateSelectedCustom) {
        self.dataArray = [NSMutableArray arrayWithArray:[XDChartDataClass pieCategoryWithDate:startDate endDate:endDate dateType:type category:_model.category account:account]];
    }else{
        self.dataArray = [NSMutableArray arrayWithArray:[XDChartDataClass pieCategoryWithDate:startDate endDate:nil dateType:type category:_model.category account:account]];
    }
    [self.tableView reloadData];
}
@end
