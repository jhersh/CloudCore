//
//  CKQuery+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKQuery (CCOAdditions)

/**
 * Creates a query that matches records of a given type that have a particular
 * value in one field.
 * 
 * @param recordType record type for which to query
 * @param key the field to use for matching
 * @param value desired value in that field
 */
+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                                 withKey:(NSString *)key
                            equalToValue:(id)value;

/**
 * Creates a query that matches records of a given type that have a particular
 * value in one field.
 * 
 * @param recordType record type for which to query
 * @param key the field to use for matching
 * @param value desired value in that field
 * @param sortKey key to use for sorting the results
 * @param ascending whether the results should be sorted ascending
 */
+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                                 withKey:(NSString *)key
                            equalToValue:(id)value
                                sortedBy:(nullable NSString *)sortKey
                               ascending:(BOOL)ascending;

/**
 * Creates a query that matches records of a given type.
 * 
 * @param recordType record type for which to query
 * @param sortDescriptors an array of sort descriptors for sorting the results
 * @param predicate predicate to use for matching records
 */
+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                         sortDescriptors:(nullable NSArray *)sortDescriptors
                               predicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
