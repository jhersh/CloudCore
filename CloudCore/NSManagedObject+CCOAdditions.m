//
//  NSManagedObject+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import "NSManagedObject+CCOAdditions.h"
#import "CKRecord+CCOAdditions.h"

@implementation NSManagedObject (CCOSerializing)

- (nonnull CKRecordID *)cco_cloudKitRecordID {
    NSAssert(!self.objectID.isTemporaryID, @"Cannot save temporary objects.");
    
    NSString *recordName = self.objectID.URIRepresentation.absoluteString;
    
    return [[CKRecordID alloc] initWithRecordName:recordName];
}

- (nonnull CKRecord *)cco_recordRepresentationForCloudKitEntity:(NSString * __nonnull)entityName {
    NSAssert(!self.objectID.isTemporaryID, @"Cannot save temporary objects.");
    
    CKRecord *record = [[CKRecord alloc] initWithRecordType:entityName
                                                   recordID:[self cco_cloudKitRecordID]];
    
    return record;
}

@end
