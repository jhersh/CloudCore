//
//  CKDatabase+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

typedef void (^SPLCKQueryCompletion) (NSArray * __nullable results,
                                      NSError * __nullable error);

typedef void (^SPLCKFetchPerRecordCompletionBlock) (CKRecord * __nullable record,
                                                    CKRecordID * __nullable recordID,
                                                    NSError * __nullable error);

typedef void (^SPLCKFetchCompletionBlock) (NSArray * __nonnull fetchedRecordIDs,
                                           NSDictionary * __nullable recordsByID,
                                           NSError * __nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface CKDatabase (CCODefaults)

/**
 * Returns the default public CloudKit database from the default CloudKit container.
 */
+ (instancetype) cco_defaultPublicDatabase;

/**
 * Returns the default private CloudKit database from the default CloudKit container.
 */
+ (instancetype) cco_defaultPrivateDatabase;

@end

@interface CKDatabase (CCOQuerying)

/**
 * Executes a query that returns records of a single type.
 *
 * @param recordType CloudKit entity to query
 * @param key field to use for matching
 * @param value the value for which you are searching in the @c key
 * @param completion a block called when the query completes
 */
- (void) cco_performQueryForRecordType:(NSString *)recordType
                               withKey:(NSString *)key
                          equalToValue:(id)value
                            completion:(SPLCKQueryCompletion)completion;

/**
 * Executes a query that returns records of a single type and sorts the results.
 *
 * @param recordType CloudKit entity to query
 * @param key field to use for matching
 * @param value the value for which you are searching in the @c key
 * @param sortedBy field by which to sort the results
 * @param ascending whether the results should be sorted ascending
 * @param completion a block called when the query completes
 */
- (void) cco_performQueryForRecordType:(NSString *)recordType
                               withKey:(NSString *)key
                          equalToValue:(id)value
                              sortedBy:(nullable NSString *)sortedBy
                             ascending:(BOOL)ascending
                            completion:(SPLCKQueryCompletion)completion;

/**
 * Executes a query that returns records of a single type.
 *
 * @param recordType CloudKit entity to query
 * @param predicate predicate to use for matching records
 * @param completion a block called when the query completes
 */
- (void) cco_performQueryForRecordType:(NSString *)recordType
                         withPredicate:(NSPredicate *)predicate
                            completion:(SPLCKQueryCompletion)completion;

@end

@interface CKDatabase (CCOFetching)

/**
 * Fetch records from CloudKit where you already know the record IDs.
 *
 * @param recordIDs an array of CKRecordID specifying your records
 * @param perRecordCompletionBlock a block called serially for each record returned from the server
 * @param fetchCompletionBlock a block called only once when the fetch has completed
 */
- (void) cco_fetchRecordsWithIDs:(NSArray *)recordIDs
        perRecordCompletionBlock:(nullable SPLCKFetchPerRecordCompletionBlock)perRecordCompletionBlock
            fetchCompletionBlock:(SPLCKFetchCompletionBlock)fetchCompletionBlock;

@end

@interface CKDatabase (CCOWriting)

/**
 * Executes a batch save and delete operation in the current database.
 *
 * @param records records to be upserted (inserted or updated)
 * @param recordIDs an array of CKRecordID to delete in this remote database.
 * @param savePolicy save policy to use for saving records
 * @param atomic whether the operation succeed or fail atomically
 * @param completion block called when the operation completes
 */
- (void) cco_performSaveRecords:(nullable NSArray *)records
                deleteRecordIDs:(nullable NSArray *)recordIDs
                     savePolicy:(CKRecordSavePolicy)savePolicy
                         atomic:(BOOL)atomic
                     completion:(void (^)(NSArray * __nullable saved, NSArray * __nullable deleted, NSError * __nullable error))completion;

@end

NS_ASSUME_NONNULL_END
