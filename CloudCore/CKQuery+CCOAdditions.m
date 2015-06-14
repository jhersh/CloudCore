//
//  CKQuery+CCOAdditions.m
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import "CKQuery+CCOAdditions.h"

@implementation CKQuery (CCOAdditions)

+ (nonnull instancetype)cco_queryWithRecordType:(nonnull NSString *)recordType
                                        withKey:(nonnull NSString *)key
                                   equalToValue:(nonnull id)value {
    return [self cco_queryWithRecordType:recordType
                                 withKey:key
                            equalToValue:value
                                sortedBy:nil
                               ascending:YES];
}

+ (nonnull instancetype)cco_queryWithRecordType:(nonnull NSString *)recordType
                                        withKey:(nonnull NSString *)key
                                   equalToValue:(nonnull id)value
                                       sortedBy:(nullable NSString *)sortKey
                                      ascending:(BOOL)ascending {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    NSArray *sortDescriptors = (sortKey
                                ? @[ [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending] ]
                                : nil);
    
    return [self cco_queryWithRecordType:recordType
                         sortDescriptors:sortDescriptors
                               predicate:predicate];
}

+ (nonnull instancetype)cco_queryWithRecordType:(nonnull NSString *)recordType
                                sortDescriptors:(nullable NSArray *)sortDescriptors
                                      predicate:(nonnull NSPredicate *)predicate {

    CKQuery *query = [[self alloc] initWithRecordType:recordType
                                            predicate:predicate];

    query.sortDescriptors = sortDescriptors;
    
    return query;
}

@end
