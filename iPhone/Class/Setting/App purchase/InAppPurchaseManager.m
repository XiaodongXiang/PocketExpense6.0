//
//  InAppPurchaseManager.m
//  VectorScanner
//
//  Created by Tommy Zhuang on 8/27/12.
//  Copyright (c) 2012 Tommy Zhuang. All rights reserved.
//

#import "InAppPurchaseManager.h"
//#import "InAppPurchaseViewController.h"
#import "PokcetExpenseAppDelegate.h"
#import "AppDelegate_iPhone.h"
#import "AppDelegate_iPad.h"
#import "OverViewWeekCalenderViewController.h"
#import "ExpenseViewController.h"
#import "SettingViewController.h"

#import "iPad_OverViewViewController.h"
#import "ipad_SettingViewController.h"

#import "ADSDeatailViewController.h"
#import "ipad_ADSDeatailViewController.h"
#import "BudgetViewController.h"

@implementation InAppPurchaseManager
@synthesize delegate,proUpgradeProduct;
//@synthesize alertView;
//@synthesize indicator;


#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

-(void)dealloc
{
    // NSLog(@"----> remove transcation <----");
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

}


//－－－－－－－－－－－－－－－－－－请求获取商品信息－－－－－－－－－－－－－－－－－－
#pragma Public methods
//1.请求商品信息
- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:kInAppPurchaseProUpgradeProductId ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    // we will release the request object in the delegate callback
}

//2.请求商品信息，获得反馈
#pragma mark SKProductsRequestDelegate methods
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [products lastObject] : nil;
    
    if (proUpgradeProduct)
    {
        //获取商品信息之后，保存上屏的价格，更新UI
        [delegate updateTheBarTitleWithPrice: [proUpgradeProduct.price doubleValue ] withLocal:proUpgradeProduct.priceLocale];
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    // finally release the reqest we alloc/init’ed in requestProUpgradeProductData
//    [productsRequest release];
    
    //请求商品信息成功，发送通知做什么？
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}
//－－－－－－－－－－－－－－－－－－请求获取商品信息结束－－－－－－－－－－－－－－－－－－


//－－－－－－－－－－－－－－－－－－外部调用方法－－－－－－－－－－－－－－－－－－－
//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
//   [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProUpgradeProductData];
    
}
//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseProUpgrade
{
    
    if(proUpgradeProduct == nil) return;
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showIndicator];
    
    SKPayment *payment = [SKPayment paymentWithProduct: proUpgradeProduct];
    //每次增加一个payment的时候都需要重新设置transactionObserver
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchase
{
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate showIndicator];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}
//－－－－－－－－－－－－－－－－－－外部调用方法结束－－－－－－－－－－－－－－－－－－－


- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        //记录产品信息，记录过了，不用再记录了
//         save the transaction receipt to disk
//        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"proUpgradeTransactionReceipt" ];
//
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

//在本地标记允许pro功能
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:kInAppPurchaseProUpgradeProductId])
    {
        // enable the pro features
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LITE_UNLOCK_FLAG  ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.isPurchased = YES;
    }
}

//购买成功之后移除观察者
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful isRestore:(BOOL)isRestore
{
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
        
        if (isRestore)
        {
            UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"VC_Restore purchase successfully!", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
            [restoreAlert show];
            appDelegate.appAlertView = restoreAlert;
            
            AppDelegate_iPhone *appdelegate_iPhone = (AppDelegate_iPhone *)[[UIApplication sharedApplication]delegate];

            [appdelegate_iPhone  hideAds:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissADSView" object:nil];
            //remove adsDetailView
            if (appdelegate_iPhone.overViewController.settingViewController.adsDetailViewController != nil)
            {
                [appdelegate_iPhone.overViewController.settingViewController.adsDetailViewController contentViewDisAppear];
            }
            [appdelegate_iPhone.adsView removeFromSuperview];
        }
        else
        {
            //购买成功的提示
        }
        
        //购买成功，刷新一些界面的功能
        if (isPad)
        {
            AppDelegate_iPad *appDelegate = (AppDelegate_iPad *)[[UIApplication sharedApplication]delegate];
            
            if (appDelegate.mainViewController.popViewController != nil)
            {
                //setting里restore，直接刷新
                if (appDelegate.mainViewController.popViewController.view.tag == 100 )
                {
                    [appDelegate.mainViewController.iSettingViewController hideOrShowAds];
                }
                else
                {
                    [appDelegate.mainViewController.overViewController hideorShowAds];
                    [appDelegate.mainViewController.popViewController dismissViewControllerAnimated:YES completion:nil];
                }
                
            }
        }
        else
        {
            AppDelegate_iPhone *appdelegate_iPhone = (AppDelegate_iPhone *)[[UIApplication sharedApplication]delegate];
            [appdelegate_iPhone  hideAds:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissADSView" object:nil];
            //remove adsDetailView
            if (appdelegate_iPhone.overViewController.settingViewController.adsDetailViewController != nil)
            {
                [appdelegate_iPhone.overViewController.settingViewController.adsDetailViewController contentViewDisAppear];
            }
            [appdelegate_iPhone.adsView removeFromSuperview];
        }
    }
    //购买失败，应该提醒用户什么信息？
    else
    {
        //send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
        
        if (isRestore)
        {
            UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VC_Restore Error", nil) message:NSLocalizedString(@"VC_A prior purchase transaction could not be found. To restore the purchased product, tap the Buy button. Paid customers will NOT be charged again, but the purchase will be restored.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
            [restoreAlert show];
            appDelegate.appAlertView = restoreAlert;
        }
        else
        {
            UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VC_Purchase Stopped", nil) message:NSLocalizedString(@"VC_Either you cancelled the request or Apple reported a transaction error. Please try again later, or contact the app's customer support for assistance.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
            [failedAlert show];
            appDelegate.appAlertView = failedAlert;
        }
        
    }
}


//-----------------购买成功
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    //不需要记录产品信息吧
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES isRestore:NO];
}

//------------------恢复购买成功
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES isRestore:YES];
}

//------------------购买失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO isRestore:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}



//------------------------------购买商品代理------------------------------------
#pragma mark -
#pragma mark SKPaymentTransactionObserver methods
//当transaction的状态发生改变时，购买状态发生改变时会调用这个
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{    
    for (SKPaymentTransaction *transaction in transactions)
    {
        PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];

        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [appDelegate  hideIndicator];
                
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [appDelegate  hideIndicator];
                
                break;
            //购买成功与恢复购买成功都跑这里。
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [appDelegate  hideIndicator];

                
                break;
            case SKPaymentTransactionStatePurchasing:
                //  [self stillPurchasing]; // this creates an alertView and shows
                break;
            default:
                break;
        }
    }
}

//恢复购买检测结果出来
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    //回复失败的提醒
    if ([queue.transactions count] == 0)
    {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        [self incompleteRestore];
    }
    PokcetExpenseAppDelegate *appDelegate =(PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate  hideIndicator];
}

//恢复完成购买出现问题
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [self incompleteRestore_restorewithError];
    PokcetExpenseAppDelegate *appDelegate =(PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate  hideIndicator];
}

// Called when one or more transactions have been removed from the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"EBPurchase removedTransactions");
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}






//-----------------恢复购买失败
-(void) incompleteRestore
{
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIAlertView *restoreAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VC_Restore Error", nil) message:NSLocalizedString(@"VC_A prior purchase transaction could not be found. To restore the purchased product, tap the Buy button. Paid customers will NOT be charged again, but the purchase will be restored.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
    [restoreAlert show];
    appDelegate.appAlertView = restoreAlert;
}

-(void)incompleteRestore_restorewithError
{
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    UIAlertView *failedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"VC_Restore Stopped", nil) message:NSLocalizedString(@"VC_Either you cancelled the request or Apple reported a transaction error. Please try again later, or contact the app's customer support for assistance.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"VC_OK", nil) otherButtonTitles:nil];
    [failedAlert show];
    appDelegate.appAlertView = failedAlert;

}









@end
