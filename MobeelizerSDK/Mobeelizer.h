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

typedef enum {
    MobeelizerLoginStatusOk = 1,
    MobeelizerLoginStatusAuthenticationFailure = -1,
    MobeelizerLoginStatusConnectionFailure = -2,
    MobeelizerLoginStatusMissingConnectionFailure = -3,
    MobeelizerLoginStatusOtherFailure = -4
} MobeelizerLoginStatus;    

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
    MobeelizerCommunicationStatusSuccess = 1,
    MobeelizerCommunicationStatusConnectionFailure = -1,
    MobeelizerCommunicationStatusResponseFailure = -2,
    MobeelizerCommunicationStatusOtherFailure = -3
} MobeelizerCommunicationStatus;    

typedef enum {
    MobeelizerCredentialNone = 0,
    MobeelizerCredentialOwn,
    MobeelizerCredentialGroup,
    MobeelizerCredentialAll
} MobeelizerCredential;

/**
 * Callback used to notify when the async synchronization is finished.
 */

@protocol MobeelizerSyncCallback <NSObject>

/**
 * Method invoked when the synchronization is finished.
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
 * @param status The sync status.
 * @see [Mobeelizer syncWithCallback:]
 * @see [Mobeelizer syncAllWithCallback:] 
 */
- (void)onSyncFinished:(MobeelizerSyncStatus)status;

@end

/**
 * Callback used to notify when the async login is finished.
 */

@protocol MobeelizerLoginCallback <NSObject>

/**
 * Method invoked when the login is finished.
 * 
 * The possible values of login status:
 *
 * - MobeelizerLoginStatusOk - The user session has been successfully created.
 * - MobeelizerLoginStatusAuthenticationFailure - Login, password and instance do not match to any existing users.
 * - MobeelizerLoginStatusConnectionFailure - Connection error. Look for the explanation in the application logs.
 * - MobeelizerLoginStatusMissingConnectionFailure - Missing connection. First login requires active Internet connection.
 * - MobeelizerLoginStatusOtherFailure - Unknown error. Look for the explanation in the instance logs and the application logs.
 *
 * @param status The login status.
 * @see [Mobeelizer loginToInstance:withUser:andPassword:withCallback:]
 * @see [Mobeelizer loginUser:andPassword:withCallback:]
 */

- (void)onLoginFinished:(MobeelizerSyncStatus)status;

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
 * @see MobeelizerLoginCallback
 */
+ (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback;

/**
 * Create a user session for the given login, password and instance. This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * The possible values of login status:
 *
 * - MobeelizerLoginStatusOk - The user session has been successfully created.
 * - MobeelizerLoginStatusAuthenticationFailure - Login, password and instance do not match to any existing users.
 * - MobeelizerLoginStatusConnectionFailure - Connection error. Look for the explanation in the application logs.
 * - MobeelizerLoginStatusMissingConnectionFailure - Missing connection. First login requires active Internet connection.
 * - MobeelizerLoginStatusOtherFailure - Unknown error. Look for the explanation in the instance logs and the application logs.
 *
 * @param instance Instance's name.
 * @param user User.
 * @param password Password.
 * @return Login status.
 */
+ (MobeelizerLoginStatus)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password;

/**
 * Create a user session for the given login, password and instance equal to the mode ("test" or "production").
 *
 * @param user User.
 * @param password Password.
 * @param callback Callback.
 * @see loginToInstance:withUser:andPassword:withCallback:
 * @see MobeelizerLoginCallback
 */
+ (void)loginUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback;

/**
 * Create a user session for the given login, password and instance equal to the mode ("test" or "production"). This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * The possible values of login status:
 *
 * - MobeelizerLoginStatusOk - The user session has been successfully created.
 * - MobeelizerLoginStatusAuthenticationFailure - Login, password and instance do not match to any existing users.
 * - MobeelizerLoginStatusConnectionFailure - Connection error. Look for the explanation in the application logs.
 * - MobeelizerLoginStatusMissingConnectionFailure - Missing connection. First login requires active Internet connection.
 * - MobeelizerLoginStatusOtherFailure - Unknown error. Look for the explanation in the instance logs and the application logs.
 *
 * @param user User.
 * @param password Password.
 * @return Login status.
 * @see loginToInstance:withUser:andPassword:
 */
+ (MobeelizerLoginStatus)loginUser:(NSString *)user andPassword:(NSString *)password;

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
 * The possible values of sync status:
 *
 * - MobeelizerSyncStatusFinishedWithSuccess - Sync has been finished successfully.
 * - MobeelizerSyncStatusFinishedWithFailure - Sync has not been finished successfully. Look for the explanation in the application logs.
 *
 * @return Sync status.
 * @see syncWithCallback:
 */
+ (MobeelizerSyncStatus)sync;

/**
 * Start a differential sync and wait until it finishes.
 *
 * @param callback Callback.
 * @see MobeelizerSyncCallback
 * @see sync
 */
+ (void)syncWithCallback:(id<MobeelizerSyncCallback>)callback;

/**
 * Start a full sync. This version of method is synchronous and lock the invoker thread. Do not call this method in UI thread.
 *
 * The possible values of sync status:
 *
 * - MobeelizerSyncStatusFinishedWithSuccess - Sync has been finished successfully.
 * - MobeelizerSyncStatusFinishedWithFailure - Sync has not been finished successfully. Look for the explanation in the application logs.
 *
 * @return Sync status. 
 * @see syncAllWithCallback:
 */
+ (MobeelizerSyncStatus)syncAll;

/**
 * Start a full sync and wait until it finishes.
 *
 * @param callback Callback.
 * @see MobeelizerSyncCallback
 * @see syncAll
 */
+ (void)syncAllWithCallback:(id<MobeelizerSyncCallback>)callback;

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
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operatioIn has failed.
 *
 * @param token Device token.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)registerForRemoteNotificationsWithDeviceToken:(NSData *)token;

/**
 * Unregister device from Apple Push Notification Service.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)unregisterForRemoteNotifications;

/**
 * Broadcast the remote notification.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification;

/**
 * Broadcast the remote notification to given device.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @param device Recipients' device.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toDevice:(NSString *)device;

/**
 * Send the remote notification to given users.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @param users Lists of recipients.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users;

/**
 * Send the remote notification to given users and device.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @param users Lists of recipients.
 * @param device Recipients' device. 
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users onDevice:(NSString *)device;

/**
 * Send the remote notification to given users' group.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @param group Recipients' group.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group;

/**
 * Send the remote notification to given group and device.
 *
 * The possible values of operation status:
 * 
 * - MobeelizerCommunicationStatusSuccess - The operation has finished successfully.
 * - MobeelizerCommunicationStatusConnectionFailure - The operation has failed because of an connection error.
 * - MobeelizerCommunicationStatusResponseFailure - The operation has failed because of an invalid response error.
 * - MobeelizerCommunicationStatusOtherFailure - The operation has failed.
 *
 * @param notification Notification to send.
 * @param group Recipients' group.
 * @param device Recipients' device.
 * @return Operation status.
 */
+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group onDevice:(NSString *)device;

@end
