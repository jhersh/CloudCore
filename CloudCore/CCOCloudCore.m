//
//  CCOCloudCore.m
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import "CCOCloudCore.h"

@interface CCOCloudManagedObject : NSObject
@property (nonatomic, weak, readonly) Class managedObjectClass;
@property (nonatomic, copy, readonly) CCOManagedObjectBindBlock bindBlock;
@property (nonatomic, copy, readonly) NSString *cloudKitEntity;
@end

@implementation CCOCloudManagedObject

- (instancetype) initWithClass:(Class)class
                     bindBlock:(CCOManagedObjectBindBlock)bindBlock
                cloudKitEntity:(NSString *)cloudKitEntity {
    if ((self = [super init])) {
        _managedObjectClass = class;
        _bindBlock = bindBlock;
        _cloudKitEntity = cloudKitEntity;
    }
    
    return self;
}

@end

@interface CCOCloudCore ()

@property (nonatomic, strong) NSMutableDictionary *registeredObjects;

@end

@implementation CCOCloudCore

+ (nonnull instancetype)coreWithDefaultPublicDatabase {
    return [self coreWithPublicDatabaseInContainer:[CKContainer defaultContainer]];
}

+ (nonnull instancetype)coreWithDefaultPrivateDatabase {
    return [self coreWithPrivateDatabaseInContainer:[CKContainer defaultContainer]];
}

+ (nonnull instancetype)coreWithPublicDatabaseInContainer:(CKContainer * __nonnull)container {
    return [[self alloc] initWithDatabase:container.publicCloudDatabase
                              inContainer:container];
}

+ (nonnull instancetype)coreWithPrivateDatabaseInContainer:(CKContainer * __nonnull)container {
    return [[self alloc] initWithDatabase:container.privateCloudDatabase
                              inContainer:container];
}

- (nonnull instancetype)initWithDatabase:(CKDatabase * __nonnull)database
                             inContainer:(CKContainer * __nonnull)container {
    
    if ((self = [super init])) {
        _database = database;
        _container = container;
        _recordSavePolicy = CKRecordSaveIfServerRecordUnchanged;
        _registeredObjects = [NSMutableDictionary new];
        
        [self checkAccountStatus];
    }
    
    return self;
}

- (void)dealloc {
    [self stopObservingManagedObjectContextChanges];
}

#pragma mark - Account Status

- (void)checkAccountStatus {
    [self.container accountStatusWithCompletionHandler:^(CKAccountStatus status, NSError *error) {
        _lastKnownAccountStatus = status;
        
        if ([self.delegate respondsToSelector:@selector(cloudCore:accountStatusUpdated:error:)]) {
            [self.delegate cloudCore:self
                accountStatusUpdated:status
                               error:error];
        }
    }];
}

#pragma mark - Managed Object Context Events

CG_INLINE NSString * CCOStringFromClass(Class class) {
    return [@"CCO" stringByAppendingString:NSStringFromClass(class)];
};

- (void)registerManagedObjectClass:(Class __nonnull)klass
                 forCloudKitEntity:(NSString * __nonnull)entity
                  withBindingBlock:(CCOManagedObjectBindBlock __nonnull)bindingBlock {

    self.registeredObjects[CCOStringFromClass(klass)] = [[CCOCloudManagedObject alloc]
                                                         initWithClass:klass
                                                         bindBlock:bindingBlock
                                                         cloudKitEntity:entity];
}

- (NSArray *) _CKRecordsByBindingManagedObjects:(NSArray *)objects
                                    inDirection:(CCOBindDirection)direction {
    NSMutableArray *records = [NSMutableArray array];
    
    for (NSManagedObject *object in objects) {
        CCOCloudManagedObject *cloudObject = self.registeredObjects[CCOStringFromClass(object.class)];
        
        if (!cloudObject) {
            continue;
        }
        
        CKRecord *record = [object cco_recordRepresentationForCloudKitEntity:cloudObject.cloudKitEntity];
        
        cloudObject.bindBlock(object, record, direction);
        
        [records addObject:record];
    }
    
    return [NSArray arrayWithArray:records];
}

- (void) cco_managedObjectContextDidSave:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSManagedObjectContext *context = (NSManagedObjectContext *)notification.object;
    
    if (self.observedContext && self.observedContext != context) {
        return;
    }
    
    NSMutableArray *deleteRecordIDs = [NSMutableArray new];
    
    for (NSManagedObject *object in userInfo[NSDeletedObjectsKey]) {
        [deleteRecordIDs addObject:[object cco_cloudKitRecordID]];
    }
    
    NSArray *insertRecords = [self _CKRecordsByBindingManagedObjects:userInfo[NSInsertedObjectsKey]
                                                         inDirection:CCOBindDirectionLocalToCloud];
    
    __weak typeof (self.delegate) weakDel = self.delegate;
    
    [self.database cco_performSaveRecords:insertRecords
                          deleteRecordIDs:deleteRecordIDs
                               savePolicy:self.recordSavePolicy
                                   atomic:YES
                               completion:^(NSArray *savedRecords,
                                            NSArray *deletedRecordIDs,
                                            NSError *operationError) {
                                   
                                   id <CCOCloudCoreDelegate> delegate = weakDel;
                                   
                                   if ([delegate respondsToSelector:@selector(cloudCore:didSaveRecordsToCloud:deletedRecordsInCloud:error:)]) {
                                       [delegate cloudCore:self
                                     didSaveRecordsToCloud:savedRecords
                                     deletedRecordsInCloud:deletedRecordIDs
                                                     error:operationError];
                                   }
                               }];
}

- (void)startObservingChangesInContext:(NSManagedObjectContext * __nonnull)context {
    [self stopObservingManagedObjectContextChanges];
    
    _observedContext = context;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cco_managedObjectContextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
}

- (void)stopObservingManagedObjectContextChanges {
    _observedContext = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
}

#pragma mark - Notifications

- (void)receivedRemoteCloudKitNotification:(nonnull NSDictionary *)notification {
    CKNotification *event = [CKNotification notificationFromRemoteNotificationDictionary:notification];
    
    if (!event) {
        return;
    }
    
    switch (event.notificationType) {
        case CKNotificationTypeQuery: {
            
            CKQueryNotification *queryEvent = (CKQueryNotification *)event;
            
            if ([self.delegate respondsToSelector:@selector(cloudCore:didReceiveSubscriptionUpdate:)]) {
                [self.delegate cloudCore:self
            didReceiveSubscriptionUpdate:queryEvent];
            }
            
            break;
        }
            
        case CKNotificationTypeReadNotification:
            
            break;
            
        case CKNotificationTypeRecordZone:
            
            break;
            
        default:
            break;
    }
}

@end
