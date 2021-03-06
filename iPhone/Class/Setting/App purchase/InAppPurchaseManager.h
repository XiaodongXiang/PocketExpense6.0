//
//  InAppPurchaseManager.h
//  VectorScanner
//
//  Created by Tommy Zhuang on 8/27/12.
//  Copyright (c) 2012 Tommy Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseProUpgradeProductId @"BTGS_001IAP"
//#define kInAppPurchaseProUpgradeProductId @"BTGS_029IAP"
//#define kInAppPurchaseProUpgradeProductId @"BTGS_028IAP"


#define LITE_UNLOCK_FLAG    @"isProUpgradePurchased"

@protocol PurchaseManagerDelegate;
@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *proUpgradeProduct;
    SKProductsRequest *productsRequest;
    NSObject <PurchaseManagerDelegate> *delegate;
    
//    UIAlertView *alertView;
//    UIActivityIndicatorView *indicator;
}
@property (nonatomic,strong) NSObject <PurchaseManagerDelegate> *delegate;
@property(nonatomic,strong) SKProduct *proUpgradeProduct;
//@property (nonatomic,retain) UIAlertView *alertView;
//@property (nonatomic,retain)  UIActivityIndicatorView *indicator;
// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (void)restorePurchase;
@end

@protocol PurchaseManagerDelegate
// indicates single touch and allows controller repsond and go toggle fullscreen
-(void)updateTheBarTitleWithPrice:(double )p withLocal:(NSLocale*)l;
@end