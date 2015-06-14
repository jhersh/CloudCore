//
//  CloudCoreTests.m
//  CloudCoreTests
//
//  Created by Jonathan Hersh on 06/13/2015.
//  Copyright (c) 2015 Jonathan Hersh. All rights reserved.
//

// https://github.com/Specta/Specta

#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import <MagicalRecord/MagicalRecord.h>
#import "CKQuery+CCOAdditions.h"
#import "NSManagedObject+CCOAdditions.h"
#import "CCOCloudCore.h"
#import "Entity.h"

SpecBegin(CloudCoreTests)

describe(@"CKQuery Additions", ^{
    it(@"creates a query with values filled in", ^{
        CKQuery *query = [CKQuery cco_queryWithRecordType:@"RecordType"
                                                  withKey:@"key"
                                             equalToValue:@1
                                                 sortedBy:@"sort"
                                                ascending:YES];
        
        expect(query.recordType).to.equal(@"RecordType");
        expect(query.predicate).to.equal([NSPredicate predicateWithFormat:@"%K == %@", @"key", @1]);
        expect(query.sortDescriptors).to.equal(@[[NSSortDescriptor sortDescriptorWithKey:@"sort" ascending:YES]]);
    });
});

describe(@"NSManagedObject Additions", ^{
    __block Entity *entity;
    
    beforeAll(^{
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
            entity = [Entity MR_createEntityInContext:context];
            entity.attribute = @"Attribute";
        }];
    });
    
    afterAll(^{
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
            [Entity MR_truncateAllInContext:context];
        }];
    });
    
    it(@"can generate an object ID for a managed object", ^{
        CKRecordID *recordID = [entity cco_cloudKitRecordID];
        expect(recordID).toNot.beNil();
        expect(recordID.recordName.length).to.beGreaterThan(0);
    });
    
    it(@"can generate a cloudkit record for a managed object", ^{
        CKRecord *record = [entity cco_recordRepresentationForCloudKitEntity:@"Entity"];
        expect(record).toNot.beNil();
        expect(record.recordType).to.equal(@"Entity");
        expect(record.recordID).to.equal([entity cco_cloudKitRecordID]);
    });
});

describe(@"CKRecord Additions", ^{
    it(@"can create reference relationships to records", ^{
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Record"];
        CKRecord *childRecord = [[CKRecord alloc] initWithRecordType:@"OtherRecord"];
        NSString *key = @"a_key";
        
        [childRecord cco_addReferenceForKey:key toRecord:record action:CKReferenceActionDeleteSelf];
        
        CKReference *reference = childRecord[key];
        
        expect(reference).toNot.beNil();
        expect(reference.referenceAction).to.equal(CKReferenceActionDeleteSelf);
        expect(reference.recordID).to.equal(record.recordID);
    });
    
    it(@"can create reference relationships to a managed object", ^{
        __block Entity *one, *two;
        
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context) {
            one = [Entity MR_createEntityInContext:context];
            two = [Entity MR_createEntityInContext:context];
        }];
        
        CKRecord *record = [one cco_recordRepresentationForCloudKitEntity:@"Entity"];
        
        expect(record).toNot.beNil();
        
        [record cco_addReferenceForKey:@"key" toManagedObject:two action:CKReferenceActionDeleteSelf];
        
        expect(record[@"key"]).toNot.beNil();
        expect(record[@"key"]).to.equal([[CKReference alloc] initWithRecordID:[two cco_cloudKitRecordID]
                                                                       action:CKReferenceActionDeleteSelf]);
    });
    
    it(@"can create dictionary representations of records", ^{
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"RecordType"];
        record[@"key"] = @"value";
        record[@"key1"] = @1;
        
        NSDictionary *dictionary = [record cco_dictionaryRepresentation];
        
        expect(dictionary[kCCORecordTypeKey]).to.equal(@"RecordType");
        expect(dictionary[@"key"]).to.equal(@"value");
        expect(dictionary[@"key1"]).to.equal(@1);
        expect(dictionary[kCCORecordNameKey]).to.equal(record.recordID.recordName);
    });
});

describe(@"CKDatabase Additions", ^{
    it(@"has a default public database", ^{
        expect([CKDatabase cco_defaultPublicDatabase]).toNot.beNil();
        expect([CKDatabase cco_defaultPublicDatabase]).to.beKindOf([CKDatabase class]);
    });
    
    it(@"has a default public database equal to the default container's public database", ^{
        expect([CKDatabase cco_defaultPublicDatabase]).to.equal([CKContainer defaultContainer].publicCloudDatabase);
    });
    
    it(@"has a default private database", ^{
        expect([CKDatabase cco_defaultPrivateDatabase]).toNot.beNil();
        expect([CKDatabase cco_defaultPrivateDatabase]).to.beKindOf([CKDatabase class]);
    });
    
    it(@"has a default private database equal to the default container's private database", ^{
        expect([CKDatabase cco_defaultPrivateDatabase]).to.equal([CKContainer defaultContainer].privateCloudDatabase);
    });
    
    it(@"can query for a record with a key and value", ^{
        waitUntil(^(DoneCallback done) {
            [[CKDatabase cco_defaultPublicDatabase] cco_performQueryForRecordType:@"RecordType"
                                                                          withKey:@"key"
                                                                     equalToValue:@"value"
                                                                       completion:^(NSArray *objectsIDs, NSError *error) {
                                                                           expect(error).toNot.beNil();
                                                                           done();
                                                                       }];
        });
    });
});

describe(@"CloudCore", ^{
    __block CCOCloudCore *widget;
    __block OCMockObject *mockDatabase;
    __block OCMockObject *mockContainer;
    __block OCMockObject *mockDelegate;
    
    beforeAll(^{
        mockDatabase = OCMClassMock([CKDatabase class]);
        mockContainer = OCMClassMock([CKContainer class]);
        mockDelegate = OCMProtocolMock(@protocol(CCOCloudCoreDelegate));
        
        widget = [[CCOCloudCore alloc] initWithDatabase:(CKDatabase *)mockDatabase
                                            inContainer:(CKContainer *)mockContainer];
        widget.delegate = (id <CCOCloudCoreDelegate>)mockDelegate;
    });
    
    afterAll(^{
        widget = nil;
    });
    
    it(@"can be initialized with default public database", ^{
        CCOCloudCore *w = [CCOCloudCore coreWithDefaultPublicDatabase];
        expect(w.database).to.equal([CKDatabase cco_defaultPublicDatabase]);
    });
    
    it(@"can be initialized with default private database", ^{
        CCOCloudCore *w = [CCOCloudCore coreWithDefaultPrivateDatabase];
        expect(w.database).to.equal([CKDatabase cco_defaultPrivateDatabase]);
    });
    
    it(@"can be initialized with a container", ^{
        CCOCloudCore *w = [CCOCloudCore coreWithPublicDatabaseInContainer:[CKContainer defaultContainer]];
        expect(w.database).to.equal([CKContainer defaultContainer].publicCloudDatabase);
    });
    
    it(@"calls a delegate method after checking status", ^{
        CCOCloudCore *w = [CCOCloudCore coreWithDefaultPublicDatabase];
        w.delegate = (id <CCOCloudCoreDelegate>)mockDelegate;
        
        [[mockDelegate expect] cloudCore:w
                    accountStatusUpdated:CKAccountStatusCouldNotDetermine
                                   error:[OCMArg isNotNil]];

        [w checkAccountStatus];
        
        [mockDelegate verifyWithDelay:3];
    });
    
    it(@"calls a binding function when a context saves", ^{
        waitUntil(^(DoneCallback done) {
            [widget registerManagedObjectClass:[Entity class]
                             forCloudKitEntity:@"Entity"
                              withBindingBlock:^(NSManagedObject *object, CKRecord *record, CCOBindDirection direction) {
                                  expect(object).to.beKindOf([Entity class]);
                                  expect(direction).to.equal(CCOBindDirectionLocalToCloud);
                                  [widget stopObservingManagedObjectContextChanges];
                                  done();
                              }];

            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *context) {
                [widget startObservingChangesInContext:context];
                [Entity MR_createEntityInContext:context];
            }];
        });
    });
});


SpecEnd
