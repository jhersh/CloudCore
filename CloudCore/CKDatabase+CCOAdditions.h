//
//  CKDatabase+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

typedef void (^SPLCKQueryCompletion) (NSArray * __nullable results, NSError * __nullable error);

typedef void (^SPLCKFetchPerRecordCompletionBlock) (CKRecord * __nullable record, CKRecordID * __nullable recordID, NSError * __nullable error);

typedef void (^SPLCKFetchCompletionBlock) (NSArray * __nonnull fetchedRecordIDs, NSDictionary * __nullable recordsByID, NSError * __nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface CKDatabase (CCODefaults)

+ (instancetype) cco_defaultPublicDatabase;

+ (instancetype) cco_defaultPrivateDatabase;

@end

@interface CKDatabase (CCOQuerying)

- (void) cco_performQueryForRecordType:(NSString *)recordType
                               withKey:(NSString *)key
                          equalToValue:(id)value
                            completion:(SPLCKQueryCompletion)completion;

- (void) cco_performQueryForRecordType:(NSString *)recordType
                               withKey:(NSString *)key
                          equalToValue:(id)value
                              sortedBy:(nullable NSString *)sortedBy
                             ascending:(BOOL)ascending
                            completion:(SPLCKQueryCompletion)completion;

- (void) cco_performQueryForRecordType:(NSString *)recordType
                         withPredicate:(NSPredicate *)predicate
                            completion:(SPLCKQueryCompletion)completion;

@end

@interface CKDatabase (CCOFetching)

- (void) cco_fetchRecordsWithIDs:(NSArray *)recordIDs
        perRecordCompletionBlock:(nullable SPLCKFetchPerRecordCompletionBlock)perRecordCompletionBlock
            fetchCompletionBlock:(SPLCKFetchCompletionBlock)fetchCompletionBlock;

@end

@interface CKDatabase (CCOWriting)

- (void) cco_performSaveRecords:(nullable NSArray *)records
                deleteRecordIDs:(nullable NSArray *)recordIDs
                     savePolicy:(CKRecordSavePolicy)savePolicy
                         atomic:(BOOL)atomic
                     completion:(void (^)(NSArray * __nullable saved, NSArray * __nullable deleted, NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END
