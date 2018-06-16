//
//  historyViewController.m
//  PocketExpense
//
//  Created by APPXY_DEV005 on 16/1/15.
//
//

#import "historyViewController.h"
#import "NSStringAdditions.h"
@interface historyViewController ()

@end

@implementation historyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *hisImage=[UIImage imageNamed:[NSString customImageName:@"updatehistory"]];

    UIScrollView *scrollview=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    scrollview.contentSize=CGSizeMake(hisImage.size.width, hisImage.size.height);
    [self.view addSubview:scrollview];
    scrollview.bounces=NO;
    UIImageView *back=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, hisImage.size.width, hisImage.size.height)];
    back.image=hisImage;
    [scrollview addSubview:back];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
