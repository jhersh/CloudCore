//
//  CKRecord+CCOAdditions.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import "CKRecord+CCOAdditions.h"
#import "CKQuery+CCOAdditions.h"
#import "NSManagedObject+CCOAdditions.h"

NSString * const kCCORecordTypeKey = @"cco_recordType";
NSString * const kCCORecordNameKey = @"cco_recordName";

@implementation CKRecord (CCOSerializing)

- (nonnull NSDictionary *)cco_dictionaryRepresentation {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *key in [self allKeys]) {
        dict[key] = self[key];
    }
    
    dict[kCCORecordNameKey] = self.recordID.recordName;
    dict[kCCORecordTypeKey] = self.recordType;
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end

@implementation CKRecord (CCOReferences)

- (void)cco_addReferenceForKey:(NSString *)key
               toManagedObject:(NSManagedObject *)object
                        action:(CKReferenceAction)action {
    
    [self cco_addReferenceForKey:key
                  toRecordWithID:[object cco_cloudKitRecordID]
                          action:action];
}

- (void)cco_addReferenceForKey:(NSString *)key
                      toRecord:(CKRecord *)record
                        action:(CKReferenceAction)action {
    
    self[key] = [[CKReference alloc] initWithRecord:record action:action];
}

- (void)cco_addReferenceForKey:(NSString *)key
                toRecordWithID:(CKRecordID *)recordID
                        action:(CKReferenceAction)action {
    
    self[key] = [[CKReference alloc] initWithRecordID:recordID action:action];
}

@end

@implementation CKRecord (CCOQuerying)

+ (void)cco_recordFromDictionary:(NSDictionary *)dictionary
                      inDatabase:(CKDatabase *)database
                      completion:(void (^)(CKRecord * __nonnull, NSError * __nonnull))completion {
    
    NSString *recordName = dictionary[kCCORecordNameKey];
    
    if (!recordName) {
        return;
    }
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordName];
    
    [database fetchRecordWithID:recordID
              completionHandler:completion];
}

- (nonnull CKQuery *)cco_queryForRecordsWithKey:(NSString *)key
                              referencingObject:(CKRecordID *)object {
    
    CKReference *reference = [[CKReference alloc] initWithRecordID:object action:CKReferenceActionNone];
    
    return [CKQuery cco_queryWithRecordType:self.recordType
                                    withKey:key
                               equalToValue:reference];
}

@end
