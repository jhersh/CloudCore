//
//  CCOCloudCore.h
//  CloudCore
//
//  Created by Jonathan Hersh on 6/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "CKDatabase+CCOAdditions.h"
#import "CKRecord+CCOAdditions.h"
#import "CKQuery+CCOAdditions.h"
#import "NSManagedObject+CCOAdditions.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CCOBindDirection) {
    CCOBindDirectionLocalToCloud,
    CCOBindDirectionCloudToLocal,
};

typedef void (^CCOAccountStatusCheckedBlock) (CKAccountStatus, NSError *);

typedef void (^CCOQueryNotificationBlock) (CKQueryNotification *);

typedef void (^CCOManagedObjectBindBlock) (NSManagedObject *, CKRecord *, CCOBindDirection);

@protocol CCOCloudCoreDelegate;

@interface CCOCloudCore : NSObject

+ (instancetype) coreWithDefaultPublicDatabase;

+ (instancetype) coreWithDefaultPrivateDatabase;

+ (instancetype) coreWithPublicDatabaseInContainer:(CKContainer *)container;

+ (instancetype) coreWithPrivateDatabaseInContainer:(CKContainer *)container;

- (instancetype) initWithDatabase:(CKDatabase *)database
                      inContainer:(CKContainer *)container;

@property (nonatomic, strong, readonly) CKDatabase *database;

@property (nonatomic, strong, readonly) CKContainer *container;

@property (nonatomic, assign) CKRecordSavePolicy recordSavePolicy;

@property (nonatomic, weak) id <CCOCloudCoreDelegate> delegate;

#pragma mark - CloudKit Account Status

@property (nonatomic, assign, readonly) CKAccountStatus lastKnownAccountStatus;

@property (nonatomic, copy) CCOAccountStatusCheckedBlock accountStatusCheckedBlock;

- (void) checkAccountStatus;

#pragma mark - Managed Object Context Events

@property (nonatomic, strong, readonly) NSManagedObjectContext *observedContext;

- (void) registerManagedObjectClass:(Class)class forCloudKitEntity:(NSString *)entity withBindingBlock:(CCOManagedObjectBindBlock)bindingBlock;

- (void) startObservingChangesInContext:(NSManagedObjectContext *)context;

- (void) stopObservingManagedObjectContextChanges;

#pragma mark - Notifications

@property (nonatomic, copy) CCOQueryNotificationBlock queryNotificationBlock;

- (void)receivedRemoteCloudKitNotification:(NSDictionary *)notification;

@end

@protocol CCOCloudCoreDelegate <NSObject>

- (void) cloudCore:(CCOCloudCore *)cloudCore
didSaveRecordsToCloud:(NSArray *)savedRecords
deletedRecordsInCloud:(NSArray *)deletedRecordIDs
             error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
