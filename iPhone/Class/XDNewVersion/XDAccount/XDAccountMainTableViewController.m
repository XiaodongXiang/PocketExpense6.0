//
//  XDAccountMainTableViewController.m
//  PocketExpense
//
//  Created by 晓东 on 2018/2/5.
//

#import "XDAccountMainTableViewController.h"
#import "XDAccountTableViewCell.h"
#import "XDAddAccountViewController.h"
#import "XDDataManager.h"
#import "Accounts.h"
#import "AccountCount.h"
#import "XDAccountDetailViewController.h"
#import "TableViewAnimationKitHeaders.h"
#import "PokcetExpenseAppDelegate.h"

@interface XDAccountMainTableViewController ()<XDAddAccountViewDelegate,UIActionSheetDelegate,XDAccountTableViewCellDelegate>
{
    BOOL _isEdit;
    
    BOOL _showCell;
    NSIndexPath* _indexPath;
    
    AccountCount* _editAccount;
}
@property(nonatomic, strong)NSMutableArray* dataMuArr;
@property (strong, nonatomic) IBOutlet UITableViewCell *addAccountCell;

@end

@implementation XDAccountMainTableViewController


-(NSMutableArray *)dataMuArr{
    if (!_dataMuArr) {
        _dataMuArr = [NSMutableArray array];
        NSArray* array = [[XDDataManager shareManager] getObjectsFromTable:@"Accounts" predicate:[NSPredicate predicateWithFormat:@"state contains[c] 1"] sortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"orderIndex" ascending:YES],[[NSSortDescriptor alloc] initWithKey:@"accName" ascending:YES]]];
        
        for (Accounts* account in array) {
            AccountCount* count = [[AccountCount alloc]init];
            count.accountsItem = account;
            count.defaultAmount = [self getAccountTransaction:account] + [account.amount doubleValue];
            count.totalBalance = [self getAccountFilterTransaction:account];
            [_dataMuArr addObject:count];
            
        }
    }
    return _dataMuArr;
}

-(double)getAccountTransaction:(Accounts*)account{
    NSDictionary *sub = [NSDictionary dictionaryWithObjectsAndKeys:account,@"incomeAccount",account,@"expenseAccount",nil];
    
    NSFetchRequest * fetchRequest = [[XDDataManager shareManager].managedObjectModel
                                     fetchRequestFromTemplateWithName:@"getAllTranscationByAccount" substitutionVariables:sub];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO]; // generate a description that describe which field you want to sort by
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:&sortDescriptor count:1]; // you can add more than one sort description
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError * error=nil;
    NSArray* objects = [[XDDataManager shareManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    double amount = 0;
    for (Transaction* transactions in objects) {
        if ([transactions.transactionType isEqualToString:@"income"] || ((transactions.expenseAccount == nil && transactions.incomeAccount != nil)&&[transactions.category.categoryType isEqualToString:@"INCOME"])) {
            amount += [transactions.amount doubleValue];
        }else if([transactions.transactionType isEqualToString:@"expense"] || ((transactions.expenseAccount != nil && transactions.incomeAccount == nil)&&[transactions.category.categoryType isEqualToString:@"EXPENSE"])){
            amount -= [transactions.amount doubleValue];
        }else{
            if (transactions.incomeAccount == account) {
                amount += [transactions.amount doubleValue];
            }else if (transactions.expenseAccount == account){
                amount -= [transactions.amount doubleValue];
            }
        }
    }

    
    return amount;
}

-(double)getAccountFilterTransaction:(Accounts*)account{
    NSDictionary *sub = [NSDictionary dictionaryWithObjectsAndKeys:account,@"incomeAccount",account,@"expenseAccount",nil];
    
    NSFetchRequest * fetchRequest = [[XDDataManager shareManager].managedObjectModel
                                     fetchRequestFromTemplateWithName:@"getAllTranscationByAccount" substitutionVariables:sub];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO]; // generate a description that describe which field you want to sort by
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:&sortDescriptor count:1]; // you can add more than one sort description
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError * error=nil;
    NSArray* objects = [[XDDataManager shareManager].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSArray* filterArr = [objects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClear = 0"]];
    double filterAmount = 0;
    for (Transaction *transactions in filterArr) {
        if ([transactions.transactionType isEqualToString:@"income"] || ((transactions.expenseAccount == nil && transactions.incomeAccount != nil)&&[transactions.category.categoryType isEqualToString:@"INCOME"])) {
            filterAmount += [transactions.amount doubleValue];
        }else if([transactions.transactionType isEqualToString:@"expense"] || ((transactions.expenseAccount != nil && transactions.incomeAccount == nil)&&[transactions.category.categoryType isEqualToString:@"EXPENSE"])){
            filterAmount -= [transactions.amount doubleValue];
        }else{
            if (transactions.incomeAccount == account) {
                filterAmount += [transactions.amount doubleValue];
            }else if (transactions.expenseAccount == account){
                filterAmount -= [transactions.amount doubleValue];
            }
        }
    }
    
    return filterAmount;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setColor: [UIColor whiteColor]];
    
    self.title =  NSLocalizedString(@"VC_Account", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:FontSFUITextMedium size:17],NSForegroundColorAttributeName:RGBColor(85, 85, 85)}];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(cancelClick) image:[UIImage imageNamed:@"Return_icon_normal"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick) image:[UIImage imageNamed:@"compile"]];
    
    
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"TransactionViewRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"refreshUI" object:nil];

    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1];

    self.tableView.separatorStyle = NO;
    
  
    UIScreenEdgePanGestureRecognizer *ges = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(cancelClick)];
    // 指定左边缘滑动
    ges.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:ges];
}

-(void)reloadTableView{
    [self.tableView reloadData];
}

- (void)loadData {
    _showCell = YES;

    [self.tableView reloadData];
    [self starAnimationWithTableView:self.tableView];
    
}

- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit showWithAnimationType:1 tableView:tableView];
}


-(void)rightBtnClick{
    _isEdit = !_isEdit;
    if (!_isEdit) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick) image:[UIImage imageNamed:@"compile"]];
    }else{
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick) title:@"Done" font:[UIFont fontWithName:FontSFUITextRegular size:17] titleColor:RGBColor(113, 163, 245) highlightedColor:RGBColor(113, 163, 245) titleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    }
    
    [self.tableView setEditing:_isEdit animated:YES];
    [self.tableView reloadData];

}

-(void)cancelClick{
    [TableViewAnimationKit showWithAnimationType:2 tableView:self.tableView];

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        return UITableViewCellEditingStyleNone | UITableViewCellEditingStyleDelete;
    }else
    return UITableViewCellEditingStyleNone ;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView == self.tableView)
        {
            AccountCount* account = self.dataMuArr[indexPath.row];
            _indexPath = indexPath;
            NSMutableString *string1 = [[NSMutableString alloc] initWithString:NSLocalizedString(@"VC_Delete %@ will cause to also delete its transactions. Are you sure want to delete it?", nil)];
            
            NSString *searchString = @"%@";
            //range是这个字符串的位置与长度
            NSRange range = [string1 rangeOfString:searchString];
            [string1 replaceCharactersInRange:NSMakeRange(range.location, [searchString length]) withString:account.accountsItem.accName];
            NSString *msg = string1;
            
            UIActionSheet *actionSheet= [[UIActionSheet alloc]
                                         initWithTitle:msg
                                         delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"VC_Cancel", nil)
                                         destructiveButtonTitle:NSLocalizedString(@"VC_Delete", nil)
                                         otherButtonTitles:nil,
                                         nil];
            [actionSheet showInView:[[UIApplication sharedApplication]keyWindow ]];
            actionSheet.tag = 1;
            PokcetExpenseAppDelegate    *appDelegate = (PokcetExpenseAppDelegate    *)[[UIApplication sharedApplication]delegate];
            appDelegate.appActionSheet = actionSheet;
        }
    }
   
    
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    int fromRow = (int)[sourceIndexPath row];
    int toRow = (int)[destinationIndexPath row];
    
    AccountCount* fromAccount = [self.dataMuArr objectAtIndex:fromRow];
    AccountCount* toAccount = [self.dataMuArr objectAtIndex:toRow];

    NSInteger fromNum = [fromAccount.accountsItem.orderIndex integerValue];
    NSInteger toNum = [toAccount.accountsItem.orderIndex integerValue];
    [self.dataMuArr exchangeObjectAtIndex:fromRow withObjectAtIndex:toRow];
    fromAccount.accountsItem.orderIndex = @(toNum);
    toAccount.accountsItem.orderIndex = @(fromNum);
    fromAccount.accountsItem.updatedTime = fromAccount.accountsItem.dateTime_sync = toAccount.accountsItem.updatedTime = toAccount.accountsItem.dateTime_sync = [NSDate date];
    [[XDDataManager shareManager] saveContext];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_showCell) {
        return 0;
    }
    if (_isEdit) {
        return self.dataMuArr.count;
    }
    return self.dataMuArr.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellID = @"cell";
    XDAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"XDAccountTableViewCell" owner:self options:nil]lastObject];;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row == self.dataMuArr.count) {
        return self.addAccountCell;
    }else{
        cell.account = self.dataMuArr[indexPath.row];
        cell.xxdDelegate = self;
        
    }
    
    
    
    return cell;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
        
        //  iOS7
        for(UIView* subview in self.tableView.subviews)
        {
            if([[[subview class] description] isEqualToString:@"UIShadowView"])
                [subview setHidden:YES];
        }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataMuArr.count) {
        XDAddAccountViewController* ac = [[XDAddAccountViewController alloc]initWithNibName:@"XDAddAccountViewController" bundle:nil];
        ac.delegate = self;
        [self presentViewController:ac animated:YES completion:nil];

    }else{
        XDAccountDetailViewController* ac = [[XDAccountDetailViewController alloc]initWithNibName:@"XDAccountDetailViewController" bundle:nil];
        ac.account = self.dataMuArr[indexPath.row];
        ac.dataArray = self.dataMuArr;
        [self.navigationController pushViewController:ac animated:YES];

    }
}


#pragma mark - XDAccountTableViewCellDelegate
- (void)selectedAccountEdit:(AccountCount *)account{
    
    
    XDAddAccountViewController* ac = [[XDAddAccountViewController alloc]initWithNibName:@"XDAddAccountViewController" bundle:nil];
    ac.delegate = self;
    ac.editAccount = account.accountsItem;
    _editAccount = account;
    [self presentViewController:ac animated:YES completion:^{
        [self.tableView setEditing:NO animated:YES];
        _isEdit = !_isEdit;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick) image:[UIImage imageNamed:@"compile"]];
        [self.tableView reloadData];
    }];
   

}
#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   
    if(buttonIndex == 1)
        return;
    
    AccountCount* account = self.dataMuArr[_indexPath.row];
//    account.accountsItem.state = @"0";
//    account.accountsItem.dateTime_sync = account.accountsItem.updatedTime = [NSDate date];
//    [[XDDataManager shareManager]saveContext];
    // 删除模型
    [self.dataMuArr removeObjectAtIndex:_indexPath.row];
    // 刷新
    [self.tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.epdc deleteAccountRel:account.accountsItem];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionViewRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"accountRefresh" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshUI" object:nil];

}
#pragma mark -  XDAddAccountViewDelegate
-(void)returnAccount:(Accounts *)account{
    
    AccountCount* count = [[AccountCount alloc]init];
    count.accountsItem = account;
    count.defaultAmount = [account.amount doubleValue];
    [self.dataMuArr addObject:count];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"accountRefresh" object:nil];
}

-(void)returnEditAccount:(Accounts *)account{
    
    _editAccount.defaultAmount = [self getAccountTransaction:account] + [account.amount doubleValue];

    [self.tableView reloadData];

}
@end
