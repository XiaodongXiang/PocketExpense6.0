//
//  XDAccountDetailTableViewCell.m
//  PocketExpense
//
//  Created by 晓东 on 2018/3/9.
//

#import "XDAccountDetailTableViewCell.h"
#import "Transaction.h"
#import "Category.h"
#import "Payee.h"
#import "Accounts.h"

#import "ParseDBManager.h"
#import <Parse/Parse.h>

@interface XDAccountDetailTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *tranCategoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *tranName;
@property (weak, nonatomic) IBOutlet UILabel *trantDate;
@property (weak, nonatomic) IBOutlet UILabel *tranAmount;

@property (weak, nonatomic) IBOutlet UIImageView *sImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *sImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *sImageView3;

@property (weak, nonatomic) IBOutlet UIButton *clearedBtn;

@end
@implementation XDAccountDetailTableViewCell
@synthesize account;

-(void)setCleared:(BOOL)cleared{
    _cleared = cleared;
 
    self.clearedBtn.hidden = !_cleared;
    self.tranCategoryIcon.hidden = _cleared;
}

-(void)setTransaction:(Transaction *)transaction{
    _transaction = transaction;
    
    self.tranName.text = transaction.payee.name?:@"-";
    self.trantDate.text = [self returnInitDate:transaction.dateTime];
    self.tranAmount.text = [XDDataManager moneyFormatter:[transaction.amount doubleValue]];
    
    if ([transaction.transactionType isEqualToString:@"income"] || ((transaction.expenseAccount == nil && transaction.incomeAccount != nil)&&[transaction.category.categoryType isEqualToString:@"INCOME"])) {
        self.tranAmount.textColor = RGBColor(19, 200, 48);
        self.tranCategoryIcon.image = [UIImage imageNamed:transaction.category.iconName];

    }else if ([transaction.transactionType isEqualToString:@"expense"] || ((transaction.expenseAccount != nil && transaction.incomeAccount == nil)&& [transaction.category.categoryType isEqualToString:@"EXPENSE"])){
        self.tranAmount.textColor = RGBColor(240, 106, 68);
        if (transaction.childTransactions.count >0) {
            self.tranCategoryIcon.image = [UIImage imageNamed:@"icon_mind.png"];
        }else{
            self.tranCategoryIcon.image = [UIImage imageNamed:transaction.category.iconName];
        }
    }else{
        self.tranCategoryIcon.image = [UIImage imageNamed:@"iocn_transfer"];
        self.tranName.text = [NSString stringWithFormat:@"%@ > %@",transaction.expenseAccount.accName,transaction.incomeAccount.accName];
        
        if (transaction.incomeAccount == account) {
            self.tranAmount.textColor = RGBColor(19, 200, 48);
        }
        if (transaction.expenseAccount == account){
            self.tranAmount.textColor = RGBColor(240, 106, 68);
        }
    }
    if (![transaction.isClear boolValue]) {
        self.backgroundColor = RGBColor(240, 245, 253);
    }else{
        self.backgroundColor =[UIColor whiteColor];
    }
    
    
    self.sImageView1.image = self.sImageView2.image = self.sImageView3.image = nil;
    
    NSMutableArray* muArr = [NSMutableArray array];
    if (![transaction.recurringType isEqualToString:@"Never"]) {
        [muArr addObject:[UIImage imageNamed:@"icon_cycle"]];
    }
    
    if (transaction.notes.length > 0) {
        [muArr addObject:[UIImage imageNamed:@"icon_memo"]];
    }
    
    if (transaction.photoName.length >0) {
        [muArr addObject:[UIImage imageNamed:@"icon_photo"]];
    }
    
    if (muArr.count == 1) {
        self.sImageView1.image = muArr.firstObject;
    }else if(muArr.count == 2){
        self.sImageView1.image = muArr.firstObject;
        self.sImageView2.image = muArr[1];
    }else if (muArr.count == 3){
        self.sImageView1.image = muArr.firstObject;
        self.sImageView2.image = muArr[1];
        self.sImageView3.image = muArr.lastObject;
    }
    
    self.clearedBtn.selected = [transaction.isClear boolValue];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tranCategoryIcon.layer.cornerRadius = self.tranCategoryIcon.width/2;
    self.tranCategoryIcon.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clearedBtnClick:(id)sender {
    self.clearedBtn.selected = !self.clearedBtn.selected;
    
    if (!self.clearedBtn.selected) {
        self.backgroundColor = RGBColor(240, 245, 253);
    }else{
        self.backgroundColor =[UIColor whiteColor];
    }
    
    
    _transaction.isClear = @(self.clearedBtn.selected);
    _transaction.updatedTime = _transaction.dateTime_sync = [NSDate date];
    [[XDDataManager shareManager] saveContext];
    
    if ([PFUser currentUser])
    {
        [[ParseDBManager sharedManager]updateTransactionFromLocal:_transaction];
    }
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
@end
