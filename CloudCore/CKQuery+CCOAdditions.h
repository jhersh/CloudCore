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

+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                                 withKey:(NSString *)key
                            equalToValue:(id)value;

+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                                 withKey:(NSString *)key
                            equalToValue:(id)value
                                sortedBy:(nullable NSString *)sortKey
                               ascending:(BOOL)ascending;

+ (instancetype) cco_queryWithRecordType:(NSString *)recordType
                         sortDescriptors:(nullable NSArray *)sortDescriptors
                               predicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END
