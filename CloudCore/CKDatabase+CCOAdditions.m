//
//  CKDatabase+CCOAdditions.m
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import "CKQuery+CCOAdditions.h"
#import "CKDatabase+CCOAdditions.h"

@implementation CKDatabase (SPLDefaults)

+ (nonnull instancetype)cco_defaultPublicDatabase {
    return [CKContainer defaultContainer].publicCloudDatabase;
}

+ (nonnull instancetype)cco_defaultPrivateDatabase {
    return [CKContainer defaultContainer].privateCloudDatabase;
}

@end

@implementation CKDatabase (CCOQuerying)

- (void)cco_performQueryForRecordType:(nonnull NSString *)recordType
                              withKey:(nonnull NSString *)key
                         equalToValue:(nonnull id)value
                           completion:(nonnull SPLCKQueryCompletion)completion {
    [self cco_performQueryForRecordType:recordType
                                withKey:key
                           equalToValue:value
                               sortedBy:nil
                              ascending:NO
                             completion:completion];
}

- (void)cco_performQueryForRecordType:(nonnull NSString *)recordType
                              withKey:(nonnull NSString *)key
                         equalToValue:(nonnull id)value
                             sortedBy:(nullable NSString *)sortedBy
                            ascending:(BOOL)ascending
                           completion:(nonnull SPLCKQueryCompletion)completion {
    
    CKQuery *query = [CKQuery cco_queryWithRecordType:recordType
                                              withKey:key
                                         equalToValue:value
                                             sortedBy:sortedBy
                                            ascending:ascending];
    
    [self performQuery:query
          inZoneWithID:nil
     completionHandler:completion];
}

- (void)cco_performQueryForRecordType:(nonnull NSString *)recordType
                        withPredicate:(nonnull NSPredicate *)predicate
                           completion:(nonnull SPLCKQueryCompletion)completion {
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    
    [self performQuery:query
          inZoneWithID:nil
     completionHandler:completion];
}

@end

@implementation CKDatabase (CCOFetching)

- (void)cco_fetchRecordsWithIDs:(nonnull NSArray *)recordIDs
       perRecordCompletionBlock:(nullable void (^)(CKRecord * __nullable, CKRecordID * __nullable, NSError * __nullable))perRecordCompletionBlock
           fetchCompletionBlock:(nonnull void (^)(NSArray * __nonnull, NSDictionary * __nullable, NSError * __nullable))fetchCompletionBlock {
    
    NSMutableArray *fetchedRecordIDs = [NSMutableArray array];
    
    CKFetchRecordsOperation *fetchOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:recordIDs];
    
    fetchOperation.perRecordCompletionBlock = ^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        if (recordID) {
            [fetchedRecordIDs addObject:recordID];
        }
        
        if (perRecordCompletionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                perRecordCompletionBlock(record, recordID, error);
            });
        }
    };
    
    fetchOperation.fetchRecordsCompletionBlock = ^(NSDictionary *recordsByID, NSError *error) {
        if (fetchCompletionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fetchCompletionBlock(fetchedRecordIDs, recordsByID, error);
            });
        }
    };

    [self addOperation:fetchOperation];
}

@end

@implementation CKDatabase (CCOWriting)

- (void)cco_performSaveRecords:(nullable NSArray *)saveRecords
               deleteRecordIDs:(nullable NSArray *)deleteRecordIDs
                    savePolicy:(CKRecordSavePolicy)savePolicy
                        atomic:(BOOL)atomic
                    completion:(void (^ __nonnull)(NSArray * __nullable, NSArray * __nullable, NSError * __nullable))completion {
 
    CKModifyRecordsOperation *operation = [[CKModifyRecordsOperation alloc]
                                           initWithRecordsToSave:saveRecords
                                           recordIDsToDelete:deleteRecordIDs];
    
    operation.savePolicy = savePolicy;
    operation.modifyRecordsCompletionBlock = completion;
    operation.atomic = atomic;
    
    [self addOperation:operation];
}

@end
