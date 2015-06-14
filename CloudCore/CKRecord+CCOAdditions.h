//
//  CKRecord+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kCCORecordTypeKey;
FOUNDATION_EXPORT NSString * const kCCORecordNameKey;

@interface CKRecord (CCOSerializing)

/**
 * Populate a dictionary with this record's fields and values.
 * Also included are @c kCCORecordTypeKey, the record's CloudKit entity type,
 * and @c kCCORecordNameKey, the record's unique record name.
 */
- (NSDictionary *) cco_dictionaryRepresentation;

@end

@interface CKRecord (CCOReferences)

/**
 * Create a CloudKit entity reference to the target managed object.
 *
 * @param key the field to use on the CloudKit entity for this relationship
 * @param object the target managed object
 * @param action the CloudKit reference strategy for this relationship
 */
- (void) cco_addReferenceForKey:(NSString *)key
                toManagedObject:(NSManagedObject *)object
                         action:(CKReferenceAction)action;

/**
 * Create a CloudKit entity reference to the target CloudKit record.
 *
 * @param key the field to use on the CloudKit entity for this relationship
 * @param record the target CloudKit record
 * @param action the CloudKit reference strategy for this relationship
 */
- (void) cco_addReferenceForKey:(NSString *)key
                       toRecord:(CKRecord *)record
                         action:(CKReferenceAction)action;

/**
 * Create a CloudKit entity reference to the target CloudKit record.
 *
 * @param key the field to use on the CloudKit entity for this relationship
 * @param recordID the record ID of the target record
 * @param action the CloudKit reference strategy for this relationship
 */
- (void) cco_addReferenceForKey:(NSString *)key
                 toRecordWithID:(CKRecordID *)recordID
                         action:(CKReferenceAction)action;

@end

@interface CKRecord (CCOQuerying)

/**
 * Fetch a record from CloudKit based on its local dictionary representation.
 *
 * @param dictionary the record dictionary to use - this assumes you used
 * @c cco_dictionaryRepresentation.
 * @param database the database in which to search for this record
 * @param completion block called when a response is received from CloudKit
 */
+ (void) cco_recordFromDictionary:(NSDictionary *)dictionary
                       inDatabase:(CKDatabase *)database
                       completion:(void (^)(CKRecord *, NSError *))completion;

/**
 * A query that you could use to fetch all children that are related to
 * a target parent record.
 *
 * @param key the reference field on this object
 * @param recordID the record ID of the parent
 */
- (CKQuery *)cco_queryForRecordsWithKey:(NSString *)key
                      referencingObject:(CKRecordID *)recordID;

@end

NS_ASSUME_NONNULL_END
