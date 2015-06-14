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

/**
 * @c CCOCloudCore is a bridge between your local CoreData records and
 * your remote CloudKit entities.
 */
@interface CCOCloudCore : NSObject

#pragma mark - Initializing

/**
 * Create a @c CCOCloudCore using the default public databse in the default CloudKit
 * container.
 */
+ (instancetype) coreWithDefaultPublicDatabase;

/**
 * Create a @c CCOCloudCore using the default private databse in the default CloudKit
 * container.
 */
+ (instancetype) coreWithDefaultPrivateDatabase;

/**
 * Create a @c CCOCloudCore using the public databse in the specified CloudKit
 * container.
 */
+ (instancetype) coreWithPublicDatabaseInContainer:(CKContainer *)container;

/**
 * Create a @c CCOCloudCore using the private databse in the specified CloudKit
 * container.
 */
+ (instancetype) coreWithPrivateDatabaseInContainer:(CKContainer *)container;

/**
 * Create a @c CCOCloudCore using the specified databse in the specified CloudKit
 * container.
 */
- (instancetype) initWithDatabase:(CKDatabase *)database
                      inContainer:(CKContainer *)container;

/**
 * The CloudKit database being managed by this adapter.
 */
@property (nonatomic, strong, readonly) CKDatabase *database;

/**
 * The CloudKit container being managed by this adapter.
 */
@property (nonatomic, strong, readonly) CKContainer *container;

/**
 * When saving local records to CloudKit, the record saving policy to use.
 */
@property (nonatomic, assign) CKRecordSavePolicy recordSavePolicy;

/**
 * The @c CCOCloudCoreDelegate is informed of CloudCore events.
 */
@property (nonatomic, weak) id <CCOCloudCoreDelegate> delegate;

#pragma mark - CloudKit Account Status

/**
 * The last known CloudKit authorization status for this database.
 * This is populated after you call @c checkAccountStatus.
 */
@property (nonatomic, assign, readonly) CKAccountStatus lastKnownAccountStatus;

/**
 * A block called when the application receives an account authorization result.
 * This is called after you call @c checkAccountStatus.
 */
@property (nonatomic, copy) CCOAccountStatusCheckedBlock accountStatusCheckedBlock;

/**
 * Initiate a check for the current account status, populating
 * @c lastKnownAccountStatus and calling your @c accountStatusCheckedBlock.
 */
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
