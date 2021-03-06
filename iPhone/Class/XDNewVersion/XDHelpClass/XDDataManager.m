//
//  XDDataManager.m
//  PocketExpense
//
//  Created by 晓东 on 2018/1/11.
//

#import "XDDataManager.h"
#import "PokcetExpenseAppDelegate.h"

@implementation XDDataManager

@synthesize backgroundContext = _backgroundContext;

-(NSManagedObjectModel*)managedObjectModel{
    PokcetExpenseAppDelegate *appDelegete = (PokcetExpenseAppDelegate *) [[UIApplication sharedApplication] delegate];
    @synchronized(appDelegete.managedObjectModel) {
        return appDelegete.managedObjectModel;
    }
    return nil;
}

-(NSManagedObjectContext*)managedObjectContext{
    PokcetExpenseAppDelegate *appDelegete = (PokcetExpenseAppDelegate *) [[UIApplication sharedApplication] delegate];
    @synchronized(appDelegete.managedObjectContext){
        return appDelegete.managedObjectContext;
    }
    return nil;
}

+(XDDataManager *)shareManager{
    static XDDataManager* g_shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_shareManager = [[XDDataManager alloc]init];
    });
    return g_shareManager;
}

-(NSManagedObjectContext *)backgroundContext{
    if (!_backgroundContext) {
        _backgroundContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        PokcetExpenseAppDelegate *appDelegete = (PokcetExpenseAppDelegate *) [[UIApplication sharedApplication] delegate];

        [_backgroundContext setPersistentStoreCoordinator:appDelegete.persistentStoreCoordinator];
    }
    return _backgroundContext;
}

#pragma mark - insert
-(id)insertObjectToTable:(NSString*)tableName
{
    id object = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    return object;
}

-(NSArray *)getObjectsFromTable:(NSString *)tableName
{

    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDesc = [NSEntityDescription entityForName:tableName inManagedObjectContext:self. managedObjectContext];
    
    [request setEntity:entityDesc];
    NSError* error=nil;
    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return objects;
}

-(NSArray*)getTransactionDate:(NSDate* )date withAccount:(Accounts*)account{
    
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:[date startDate],@"startDate",[date endDate],@"endDate",nil];
    
    NSFetchRequest *fetchRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"getAllTranscationsWithDate" substitutionVariables:subs];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedTime" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];

    NSMutableArray   *sortDescriptors = [[NSMutableArray alloc] initWithObjects:sortDescriptor,sortDescriptor2, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error =nil;
    NSArray *objects1 = [[NSArray alloc]initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];

    if (account) {
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"incomeAccount.uuid = %@ or expenseAccount.uuid = %@",account.uuid,account.uuid];
        NSArray* array = [objects1 filteredArrayUsingPredicate:pre];
        
        return array;
    }
    
    return objects1;
}

-(NSArray*)backgroundGetTransactionDate:(NSDate* )date withAccount:(Accounts*)account{
    
    NSDictionary *subs = [NSDictionary dictionaryWithObjectsAndKeys:[date startDate],@"startDate",[date endDate],@"endDate",nil];
    
    NSFetchRequest *fetchRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"getAllTranscationsWithDate" substitutionVariables:subs];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedTime" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
    
    NSMutableArray   *sortDescriptors = [[NSMutableArray alloc] initWithObjects:sortDescriptor,sortDescriptor2, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error =nil;
    NSArray *objects1 = [[NSArray alloc]initWithArray:[self.backgroundContext executeFetchRequest:fetchRequest error:&error]];
    
    if (account) {
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"incomeAccount.uuid = %@ or expenseAccount.uuid = %@",account.uuid,account.uuid];
        NSArray* array = [objects1 filteredArrayUsingPredicate:pre];
        
        return array;
    }
    
    return objects1;
}

-(NSArray*)fetchParentExpenseCategory{
    NSError *error = nil;
    NSDictionary *subs = [[NSDictionary alloc]init];
    NSFetchRequest *fetchRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"fetchParentExpenseCategory" substitutionVariables:subs];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryName" ascending:YES];
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:&sortDescriptor count:1];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *objects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    return objects;
}

-(NSArray *)getObjectsFromTable:(NSString *)tableName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortArray
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entityDescription];
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortArray && sortArray.count > 0) {
        [request setSortDescriptors:sortArray];
    }
    
    NSError* error=nil;
    NSArray* objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return objects;
}

-(NSArray *)backgroundGetObjectsFromTable:(NSString *)tableName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortArray
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.backgroundContext];
    [request setEntity:entityDescription];
    if (predicate) {
        [request setPredicate:predicate];
    }
    if (sortArray && sortArray.count > 0) {
        [request setSortDescriptors:sortArray];
    }
    
    NSError* error=nil;
    NSArray* objects = [self.backgroundContext executeFetchRequest:request error:&error];
    
    return objects;
}


-(void)deleteTableObject:(id)object{
    [self.managedObjectContext deleteObject:object];
    NSError* error=nil;
    [self.managedObjectContext save:&error];
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}



+(NSString *)moneyFormatter:(double)doubleContext{
    PokcetExpenseAppDelegate *appDelegate = (PokcetExpenseAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *string = @"";
    if(doubleContext >= 0)
        string = [NSString stringWithFormat:@"%.2f",doubleContext];
    else
        string = [NSString stringWithFormat:@"%.2f",-doubleContext];
    
    NSArray *tmp = [string componentsSeparatedByString:@"."];
    NSNumberFormatter *numberStyle = [[NSNumberFormatter alloc] init];
    [numberStyle setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *tmpStr = [numberStyle stringFromNumber:[NSNumber numberWithDouble:[[tmp objectAtIndex:0] doubleValue]]];
    if([tmp count]<2)
    {
        string = tmpStr;
    }
    else
    {
        
        string = [[tmpStr stringByAppendingString:@"."] stringByAppendingString:[tmp objectAtIndex:1]];
    }
    
    
    NSString *typeOfDollar = appDelegate.settings.currency;
    NSArray *dollorArray = [typeOfDollar componentsSeparatedByString:@"-"];
    NSString *dollorStr = [[dollorArray objectAtIndex:0] substringToIndex:[[dollorArray objectAtIndex:0] length]-1];
    
    if (doubleContext<0) {
        dollorStr = [NSString stringWithFormat:@"-%@",dollorStr];
    }
    
    string = [dollorStr stringByAppendingString:string];
    
    if(doubleContext < 0)
        string = [NSString stringWithFormat:@"%@",string];
    
    
    
    return string;
    
}


@end

@implementation NSDate (customer)

-(NSDate *)startDate{
    NSCalendar* calendar = [NSCalendar currentCalendar];
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents* components = [calendar components:dayInfoUnits fromDate:self];
    
    NSDate* date = [calendar dateFromComponents:components];
    
    return date;
}

-(NSDate *)endDate{
    NSCalendar* calendar = [NSCalendar currentCalendar];
//    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSCalendarUnit dayInfoUnits  = NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents* components = [calendar components:dayInfoUnits fromDate:self];
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    NSDate* date = [calendar dateFromComponents:components];
//
//    NSDate* date = [self startDate];
//
//    [date dateByAddingTimeInterval:24*3600-1];
    
    return date;
}

@end
