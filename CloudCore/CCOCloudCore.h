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
 * Create a @c CCOCloudCore using the default public database in the default CloudKit
 * container.
 */
+ (instancetype) coreWithDefaultPublicDatabase;

/**
 * Create a @c CCOCloudCore using the default private database in the default CloudKit
 * container.
 */
+ (instancetype) coreWithDefaultPrivateDatabase;

/**
 * Create a @c CCOCloudCore using the public database in the specified CloudKit
 * container.
 */
+ (instancetype) coreWithPublicDatabaseInContainer:(CKContainer *)container;

/**
 * Create a @c CCOCloudCore using the private database in the specified CloudKit
 * container.
 */
+ (instancetype) coreWithPrivateDatabaseInContainer:(CKContainer *)container;

/**
 * Create a @c CCOCloudCore using the specified database in the specified CloudKit
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
 * Initiate a check for the current account status, populating
 * @c lastKnownAccountStatus and calling the CCOCloudCoreDelegate method
 * cloudCore:accountStatusUpdated:error.
 */
- (void) checkAccountStatus;

#pragma mark - Managed Object Context Events

@property (nonatomic, strong, readonly) NSManagedObjectContext *observedContext;

- (void) registerManagedObjectClass:(Class)class forCloudKitEntity:(NSString *)entity withBindingBlock:(CCOManagedObjectBindBlock)bindingBlock;

- (void) startObservingChangesInContext:(NSManagedObjectContext *)context;

- (void) stopObservingManagedObjectContextChanges;

#pragma mark - Notifications

/**
 * A block called when your application receives a remote notification
 * that a CloudKit subscription has been updated.
 */
@property (nonatomic, copy) CCOQueryNotificationBlock queryNotificationBlock;

/**
 * Parse a remote notification dictionary. The notification will be parsed into
 * a CloudKit notification and your @c queryNotificationBlock will be called.
 * 
 * @param notification the notification dictionary received by your application delegate.
 * Pass the same dictionary that your app delegate received in 
 * @c application:didReceiveRemoteNotification:fetchCompletionHandler:
 */
- (void)receivedRemoteCloudKitNotification:(NSDictionary *)notification;

@end

@protocol CCOCloudCoreDelegate <NSObject>

- (void) cloudCore:(CCOCloudCore *)cloudCore
accountStatusUpdated:(CKAccountStatus)status
             error:(NSError *)error;

- (void) cloudCore:(CCOCloudCore *)cloudCore
didSaveRecordsToCloud:(NSArray *)savedRecords
deletedRecordsInCloud:(NSArray *)deletedRecordIDs
             error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
