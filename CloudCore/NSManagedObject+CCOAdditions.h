//
//  NSManagedObject+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSManagedObject (CCOSerializing)

/**
 * Determine a record ID that uniquely identifies this managed object.
 */
- (CKRecordID *) cco_cloudKitRecordID;

/**
 * Return a CKRecord representation of this managed object as a record of the
 * specified CloudKit entity.
 *
 * @param entityName the CloudKit entity to use for this record
 */
- (CKRecord *) cco_recordRepresentationForCloudKitEntity:(NSString *)entityName;

@end

NS_ASSUME_NONNULL_END
