//
//  XDDateSelectedView.h
//  PocketExpense
//
//  Created by 晓东 on 2018/2/22.
//

#import <UIKit/UIKit.h>

#import "XDDateSelectedModel.h"
//@protocol XDDateSelectedDelegate <NSObject>
//
//-(void)returnSelectedDate:(NSDate*)date index:(NSInteger)index;
//@end
@interface XDDateSelectedView : UIView

@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong)NSArray * dateArr;
@property(nonatomic, assign)DateSelectedType type;


//@property(nonatomic, weak)id<XDDateSelectedDelegate> dateDelegate;


@end
