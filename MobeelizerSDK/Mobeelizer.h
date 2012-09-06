// 
// Mobeelizer.h
// 
// Copyright (C) 2012 Mobeelizer Ltd. All Rights Reserved.
//
// Mobeelizer SDK is free software; you can redistribute it and/or modify it 
// under the terms of the GNU Affero General Public License as published by 
// the Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
// for more details.
//
// You should have received a copy of the GNU Affero General Public License 
// along with this program; if not, write to the Free Software Foundation, Inc., 
// 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
// 

#import <Foundation/Foundation.h>

@class MobeelizerDatabase;
@class MobeelizerFile;
@class MobeelizerOperationError;

typedef enum {
    MobeelizerSyncStatusNone = -1,
    MobeelizerSyncStatusStarted = 1,
    MobeelizerSyncStatusFileCreated = 2,
    MobeelizerSyncStatusTaskCreated = 3,
    MobeelizerSyncStatusTaskPerformed = 4,
    MobeelizerSyncStatusFileReceived = 5,
    MobeelizerSyncStatusFinishedWithSuccess = -6,
    MobeelizerSyncStatusFinishedWithFailure = -7
} MobeelizerSyncStatus;

typedef enum {
    MobeelizerCredentialNone = 0,
    MobeelizerCredentialOwn,
    MobeelizerCredentialGroup,
    MobeelizerCredentialAll
} MobeelizerCredential;

/**
 * Callback used to notify when the async synchronization is finished.
 */

@protocol MobeelizerOperationCallback <NSObject>

/**
 * Method invoked when the operation is finished with failure.
 *
 * @param error The operation error.
 */
- (void)onFailure:(MobeelizerOperationError*)error;

/**
 * Method invoked when the operation is finished with success.
 */
- (void)onSuccess;

@end

/**
 * Protocol for sync status change listeners.
 */

@protocol MobeelizerSyncListener <NSObject>

/**
 * Hook invoked when sync status has changed.
 * 
 * The possible values of sync status:
 *
 * - MobeelizerSyncStatusNone - Sync has not been executed in the existing user session.
 * - MobeelizerSyncStatusStarted - Sync is in progress.  The file with local changes is being prepared.
 * - MobeelizerSyncStatusFileCreated - Sync is in progress. The file with local changes has been prepared and now is being transmitted to the cloud.
 * - MobeelizerSyncStatusTaskCreated - Sync is in progress. The file with local changes has been transmitted to the cloud. Waiting for the cloud to finish processing sync.
 * - MobeelizerSyncStatusTaskPerformed - Sync is in progress. The file with cloud changes has been prepared and now is being transmitted to the device.
 * - MobeelizerSyncStatusFileReceived - Sync is in progress. The file with cloud changes has been transmitted to the device cloud and now is being inserted into local database.
 * - MobeelizerSyncStatusFinishedWithSuccess - Sync has been finished successfully.
 * - MobeelizerSyncStatusFinishedWithFailure - Sync has not been finished successfully. Look for the explanation in the application logs.
 *
 * @param newStatus The new sync status.
 * @see [Mobeelizer registerSyncStatusListener:]
 */
- (void)syncStatusHasBeenChangedTo:(MobeelizerSyncStatus)newStatus;

@end

/**
 * Entry point to the Mobeelizer application that holds references to the user sessions and the database.
 */

@interface Mobeelizer : NSObject

/**
 * Version of Mobeelizer SDK.
 */
+ (NSString*)version;

///---------------------------------------------------------------------------------------
/// @name Lifecycle
///---------------------------------------------------------------------------------------

/**
 * Initializer Mobeelizer. Invoke it immediately after launching the application (didFinishLaunchingWithOptions). 
 */
+ (void)create;

/**
 * Destroy Mobeelizer. Invoke it just before terminating the application (applicationWillTerminate).
 */
+ (void)destroy;

///---------------------------------------------------------------------------------------
/// @name User Session
///---------------------------------------------------------------------------------------


/**
 * Create a user session for the given login, password and instance.
 *
 * @param instance Instance's name.
 * @param user User.
 * @param password Password.
 * @param callback Callback. 
 * @see MobeelizerOperationCallback
 */
+ (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerOperationCallback>)callback;

/**
 * Create a user session for the given login, password and instance. This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * @param instance Instance's name.
 * @param user User.
 * @param password Password.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password;

/**
 * Create a user session for the given login, password and instance equal to the mode ("test" or "production").
 *
 * @param user User.
 * @param password Password.
 * @param callback Callback.
 * @see loginToInstance:withUser:andPassword:withCallback:
 * @see MobeelizerOperationCallback
 */
+ (void)loginUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerOperationCallback>)callback;

/**
 * Create a user session for the given login, password and instance equal to the mode ("test" or "production"). This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * @param user User.
 * @param password Password.
 * @return Null if success, error otherwise.
 * @see loginToInstance:withUser:andPassword:
 */
+ (MobeelizerOperationError*)loginUser:(NSString *)user andPassword:(NSString *)password;

/**
 *  Check if the user session is active.
 *
 * @return TRUE if user session is active.
 */
+ (BOOL)isLoggedIn;

/**
 * Close the user session.
 */
+ (void)logout;

///---------------------------------------------------------------------------------------
/// @name Database
///---------------------------------------------------------------------------------------

/**
 *  Database for the active user session.
 *
 * @see MobeelizerDatabase
 */
+ (MobeelizerDatabase *)database;


///---------------------------------------------------------------------------------------
/// @name Synchronization
///---------------------------------------------------------------------------------------

/**
 * Start a differential sync. This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * @return Null if success, error otherwise.
 * @see syncWithCallback:
 */
+ (MobeelizerOperationError*)sync;

/**
 * Start a differential sync and wait until it finishes.
 *
 * @param callback Callback.
 * @see MobeelizerOperationCallback
 * @see sync
 */
+ (void)syncWithCallback:(id<MobeelizerOperationCallback>)callback;

/**
 * Start a full sync. This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * @return Null if success, error otherwise.
 * @see syncAllWithCallback:
 */
+ (MobeelizerOperationError*)syncAll;

/**
 * Start a full sync and wait until it finishes.
 *
 * @param callback Callback.
 * @see MobeelizerOperationCallback
 * @see syncAll
 */
+ (void)syncAllWithCallback:(id<MobeelizerOperationCallback>)callback;

/**
 * Check and return the status of current sync.
 *
 * The possible values of sync status:
 *
 * - MobeelizerSyncStatusNone - Sync has not been executed in the existing user session.
 * - MobeelizerSyncStatusStarted - Sync is in progress.  The file with local changes is being prepared.
 * - MobeelizerSyncStatusFileCreated - Sync is in progress. The file with local changes has been prepared and now is being transmitted to the cloud.
 * - MobeelizerSyncStatusTaskCreated - Sync is in progress. The file with local changes has been transmitted to the cloud. Waiting for the cloud to finish processing sync.
 * - MobeelizerSyncStatusTaskPerformed - Sync is in progress. The file with cloud changes has been prepared and now is being transmitted to the device.
 * - MobeelizerSyncStatusFileReceived - Sync is in progress. The file with cloud changes has been transmitted to the device cloud and now is being inserted into local database.
 * - MobeelizerSyncStatusFinishedWithSuccess - Sync has been finished successfully.
 * - MobeelizerSyncStatusFinishedWithFailure - Sync has not been finished successfully. Look for the explanation in the application logs.
 *
 * @return Sync status.
 */
+ (MobeelizerSyncStatus)checkSyncStatus;

/**
 * Register listener that will be notified if sync status is changed.
 *
 * @param listener listener.
 * @see MobeelizerSyncListener
 */
+ (void)registerSyncStatusListener:(id<MobeelizerSyncListener>)listener;

///---------------------------------------------------------------------------------------
/// @name Files
///---------------------------------------------------------------------------------------

/**
 * Create a new file with a given name and content.
 *
 * @param name Name.
 * @param data Content.
 * @return File.
 * @see MobeelizerFile
 */
+ (MobeelizerFile *)createFile:(NSString *)name withData:(NSData *)data;

/**
 * Create a file with a given name that points to a file with a given guid.
 *
 * @param name Name.
 * @param guid Existing file's guid.
 * @return File.
 * @see MobeelizerFile
 */
+ (MobeelizerFile *)createFile:(NSString *)name withGuid:(NSString *)guid;

///---------------------------------------------------------------------------------------
/// @name Remote Notifications
///---------------------------------------------------------------------------------------

/**
 * Register the token received from Apple Push Notification Service.
 *
 * @param token Device token.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)registerForRemoteNotificationsWithDeviceToken:(NSData *)token;

/**
 * Unregister device from Apple Push Notification Service.
 *
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)unregisterForRemoteNotifications;

/**
 * Broadcast the remote notification.
 *
 * @param notification Notification to send.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification;

/**
 * Broadcast the remote notification to given device.
 *
 * @param notification Notification to send.
 * @param device Recipients' device.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification toDevice:(NSString *)device;

/**
 * Send the remote notification to given users.
 *
 * @param notification Notification to send.
 * @param users Lists of recipients.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users;

/**
 * Send the remote notification to given users and device.
 *
 * @param notification Notification to send.
 * @param users Lists of recipients.
 * @param device Recipients' device. 
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users onDevice:(NSString *)device;

/**
 * Send the remote notification to given users' group.
 *
 * @param notification Notification to send.
 * @param group Recipients' group.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group;

/**
 * Send the remote notification to given group and device.
 *
 * @param notification Notification to send.
 * @param group Recipients' group.
 * @param device Recipients' device.
 * @return Null if success, error otherwise.
 */
+ (MobeelizerOperationError*)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group onDevice:(NSString *)device;

@end
