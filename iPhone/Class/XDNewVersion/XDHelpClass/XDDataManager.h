//
//  XDDataManager.h
//  PocketExpense
//
//  Created by 晓东 on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "Accounts.h"
@interface XDDataManager : NSObject

@property(nonatomic, strong,readonly)NSManagedObjectContext * backgroundContext;


+(XDDataManager*)shareManager;
-(NSManagedObjectModel*)managedObjectModel;
-(NSManagedObjectContext*)managedObjectContext;


-(id)insertObjectToTable:(NSString*)tableName;
-(NSArray *)getObjectsFromTable:(NSString *)tableName;
-(NSArray *)getObjectsFromTable:(NSString *)tableName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortArray;

-(NSArray *)backgroundGetObjectsFromTable:(NSString *)tableName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortArray;
-(NSArray*)backgroundGetTransactionDate:(NSDate* )date withAccount:(Accounts*)account;


-(NSArray*)getTransactionDate:(NSDate* )date withAccount:(Accounts*)account;
-(NSArray*)fetchParentExpenseCategory;

    
-(void)deleteTableObject:(id)object;

-(void)saveContext;

+(NSString* )moneyFormatter:(double)doubleContext;

@end

@interface NSDate (customer)

-(NSDate*)startDate;
-(NSDate*)endDate;

@end
