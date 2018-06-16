//
//  AboutViewController.m
//  PocketExpense
//
//  Created by APPXY_DEV005 on 15/12/17.
//
//

#import "AboutViewController.h"
#import "AppDelegate_iPhone.h"
#import "UIDevice.h"
#import "policyViewController.h"
#import "historyViewController.h"
#import <StoreKit/StoreKit.h>

@interface AboutViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation AboutViewController
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initNav];    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewSet];
    [self initPoint];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(cancelClick) image:[UIImage imageNamed:@"Return_icon_normal"]];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:FontSFUITextMedium size:17],NSForegroundColorAttributeName:RGBColor(85, 85, 85)}];
    
    [self.tableview setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    
#ifdef LITE
    if (IS_IPHONE_5) {
        self.topBg.image = [UIImage imageNamed:@"setting_bj_se"];
    }else if (IS_IPHONE_6PLUS){
        self.topBg.image = [UIImage imageNamed:@"setting_bj_plus"];
    }else{
        self.topBg.image = [UIImage imageNamed:@"by"];
    }
#else
    if (IS_IPHONE_5) {
        self.topBg.image = [UIImage imageNamed:@"bj_se_pro"];
    }else if (IS_IPHONE_6PLUS){
        self.topBg.image = [UIImage imageNamed:@"bj_plus_pro"];
    }else{
        self.topBg.image = [UIImage imageNamed:@"bj_pro"];
    }
#endif
    
    self.tableview.separatorColor = RGBColor(226, 226, 226);

    
//    if([SKStoreReviewController respondsToSelector:@selector(requestReview)]){
//
//        [SKStoreReviewController requestReview];
//
//    }
}

-(void)cancelClick{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initPoint
{
    _reviewLabel.text=NSLocalizedString(@"VC_WriteReview", nil);
    _reviewDetail.text=NSLocalizedString(@"VC_If you like this app, please rate and review.", nil);
    _feedbackLabel.text=NSLocalizedString(@"VC_SendFeedback", nil);
    _feedbackDetail.text=NSLocalizedString(@"VC_Send us some questions and suggestions.", nil);
    _updateLabel.text=NSLocalizedString(@"VC_Update History", nil);
    _policyLabel.text=NSLocalizedString(@"VC_Privacy Policy", nil);
}
-(void)tableViewSet
{
    _tableview.delegate=self;
    _tableview.dataSource=self;
}
-(void)initNav
{
    self.navigationItem.title=NSLocalizedString(@"VC_About", nil);
}
#pragma mark - TAableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        switch (indexPath.row)
        {
            case 0:
                _reviewtoplineW.constant=SCREEN_WIDTH;
                _reviewbottomlineH.constant=EXPENSE_SCALE;
                return _reviewCell;
                break;
            default:
                _feedbackbottomlineW.constant=SCREEN_WIDTH;
                _feedbackbottomlineH.constant=EXPENSE_SCALE;
                return _feedbackCell;
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                _updatetoplineW.constant=SCREEN_WIDTH;
                _updatetoplineH.constant=EXPENSE_SCALE;
                return _updateCell;
                break;
            default:
                _policybottomlineW.constant=SCREEN_WIDTH;
                _privacybottomlineH.constant=EXPENSE_SCALE;
                return _privacyCell;
                break;
        }
    }
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//
//    if (section==0) {
//        return 0;
//    }
//
//    return 35.f;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
//    view.backgroundColor=[UIColor clearColor];
//    return view;
//}
//-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
//{
////    view.backgroundColor=[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
//}
//-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
//    view.backgroundColor=[UIColor whiteColor];
//}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    AppDelegate_iPhone *appdelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication]delegate];
    if (indexPath.section==0)
    {
        if (indexPath.row==0)
        {
//            if (appdelegate.isPurchased)
//            {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/pocket-expense-lite/id830063876?mt=8"]];
//            }
//            else
//            {
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/pocket-expense-personal-finance/id424575621?mt=8"]];
//            }
#ifdef LITE
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/pocket-expense-personal-finance/id424575621?action=write-review"]];

#else
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/pocket-expense-lite/id830063876?action=write-review"]];
#endif

        }
        else if (indexPath.row==1)
        {
            Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
            if (mailClass != nil)
            {
                // We must always check whether the current device is configured for sending emails
                if ([mailClass canSendMail])
                {
                    [self displayComposerSheet];
                }
                else
                {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VC_No Mail Accounts", nil) message:NSLocalizedString(@"VC_Please set up a mail account in order to send mail.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
                    [alertView show];
                    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
                    appDelegate.appAlertView = alertView;
                }
            }

        }
    }
    if (indexPath.section==1)
    {
        if (indexPath.row==1)
        {
            policyViewController *policyVC=[[policyViewController alloc]initWithNibName:@"policyViewController" bundle:nil];
            [self.navigationController pushViewController:policyVC animated:YES];
        }
        if (indexPath.row==0)
        {
            historyViewController *historyVC=[[historyViewController alloc]init];
            [self.navigationController pushViewController:historyVC animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)displayComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Pocket Expense Feedback"];
    [picker setToRecipients:[NSArray arrayWithObject:@"expense5@appxy.com"]];
    [picker setCcRecipients:nil];
    [picker setCcRecipients:nil];
    
    NSString * versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * deviceType = [[UIDevice currentDevice] systemName];
    NSString * deviceVersion = [[UIDevice currentDevice] systemVersion];
    NSString * deviceStr = [UIDevice platformString];
    
    NSString *liteorpro;
    
#ifdef LITE
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if(appDelegate.isPurchased)
    {
        liteorpro = @"Pur";
    }
    else
    {
        liteorpro = @"Lite";
    }
#else
    liteorpro = @"Pro";
#endif
    NSString *mailBody = [NSString stringWithFormat:@"<html><body>App:v%@ %@<br/>%@：v%@<br/>Device: %@<br/>Feedback here: </body></html>", versionStr,liteorpro, deviceType, deviceVersion, deviceStr];
    
    
    
    
    [picker setMessageBody:mailBody isHTML:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mailComposeController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
