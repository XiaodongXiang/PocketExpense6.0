//
//  XDTransactionPayeeCollectionView.m
//  PocketExpense
//
//  Created by 晓东 on 2018/2/9.
//

#import "XDTransactionPayeeCollectionView.h"
#import "XDTransactionHelpClass.h"
#import "XDPayeeCollectionViewCell.h"
@interface XDTransactionPayeeCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray* _dataArr;
}

@end

static NSString * cellID = @"payeeCell";

@implementation XDTransactionPayeeCollectionView

-(void)setTranType:(TransactionType)tranType{
    _tranType = tranType;
    
    _dataArr = [XDTransactionHelpClass getPayeeWithTransactionType:tranType];
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    
    
    UICollectionViewFlowLayout *flow =[[UICollectionViewFlowLayout alloc]init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:flow];
    
    if (self) {
        self.delegate = self;
        self.dataSource = self;
                
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerNib:[UINib nibWithNibName:@"XDPayeeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        view.backgroundColor = RGBColor(236, 236, 236);
        [self addSubview:view];
    }
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return  15;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    XDPayeeCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.payee = _dataArr[indexPath.row];
    
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15, 0, 0);//分别为上、左、下、右
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    Payee* payee = _dataArr[indexPath.row];
    UIFont* font = [UIFont fontWithName:FontSFUITextRegular size:12];
    CGSize size = [payee.name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    
    return CGSizeMake(size.width+ 40, 30);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Payee* payee = _dataArr[indexPath.row];

    if ([self.payeeDelegate respondsToSelector:@selector(returnSelectedPayee:)]) {
        [self.payeeDelegate returnSelectedPayee:payee];
    }
    
}



@end
