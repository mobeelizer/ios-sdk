// 
// Mobeelizer.m
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

#import <UIKit/UIKit.h>
#import "Mobeelizer+Internal.h"
#import "MobeelizerFile+Internal.h"
#import "MobeelizerDatabase+Internal.h"
#import "MobeelizerInternalDatabase.h"
#import "MobeelizerConnectionManager.h"
#import "MobeelizerRealConnectionManager.h"
#import "MobeelizerDevelopmentConnectionManager.h"
#import "MobeelizerDefinitionManager.h"
#import "MobeelizerDeviceIdentifierUtil.h"
#import "MobeelizerSyncManager.h"

#define DEFAULT_TEST_URL @"http://cloud.mobeelizer.com/sync"
#define DEFAULT_PRODUCTION_URL @"http://cloud.mobeelizer.com/sync"

#define META_DEVICE @"device"
#define META_URL @"url"
#define META_MODEL_PREFIX @"modelPrefix"
#define META_DEFINITION_ASSET @"definitionAsset"
#define META_DEVELOPMENT_ROLE @"developmentRole"
#define META_MODE @"mode"

#define MODE_DEVELOPMENT @"development"
#define MODE_TEST @"test"
#define MODE_PRODUCTION @"production"

@interface Mobeelizer ()

@property (nonatomic, strong) MobeelizerSyncManager *syncManager;

- (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback;
- (MobeelizerLoginStatus)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password;
- (void)loginUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback;
- (MobeelizerLoginStatus)loginUser:(NSString *)user andPassword:(NSString *)password;
- (void)logout;
- (void)destroy;
- (BOOL)isLoggedIn;
- (MobeelizerSyncStatus)sync:(BOOL)all;
- (void)sync:(BOOL)all withCallback:(id<MobeelizerSyncCallback>)callback;
- (MobeelizerSyncStatus)checkSyncStatus;
- (MobeelizerFile *)createFile:(NSString *)name withData:(NSData *)data;
- (MobeelizerFile *)createFile:(NSString *)name withGuid:(NSString *)guid;
- (void)registerSyncStatusListener:(id<MobeelizerSyncListener>)listener;
- (BOOL)isMultitaskingSupported;
- (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users toGroup:(NSString *)group onDevice:(NSString *)device;
- (MobeelizerCommunicationStatus)registerDeviceToken:(NSString *)token;

@end

@implementation Mobeelizer

@synthesize mode=_mode, device=_device, deviceIdentifier=_deviceIdentifier, url=_url, database=_database, connectionManager=_connectionManager, definitionManager=_definitionManager, internalDatabase=_internalDatabase, syncManager=_syncManager, fileManager=_fileManager, multitaskingSupported=_multitaskingSupported;
@dynamic vendor, application, versionDigest, instance, user, role, instanceGuid;

static Mobeelizer *mobeelizer = nil;

+ (NSString*)version {
    return SDK_VERSION;
}

- (id)init {  
    if (self = [super init]) {
        _multitaskingSupported = [self isMultitaskingSupported];
        
        MobeelizerLog(@"Creating Mobeelizer SDK %@", [Mobeelizer version]);
        
        NSDictionary *meta = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Mobeelizer" ofType:@"plist"]];
        
        _device = [meta objectForKey:META_DEVICE];
        
        MobeelizerLog(@"Device: %@", self.device);
        
        NSString *modelPrefix = [meta objectForKey:META_MODEL_PREFIX];

        MobeelizerLog(@"Model Prefix: %@", modelPrefix);
        
        if(self.device == nil || modelPrefix == nil) {
            MobeelizerException(@"Missing configuration parameter", @"%@ and %@ must be set in Mobeelizer.plist file.", META_DEVICE, META_MODEL_PREFIX);
        }
        
        NSString *developmentRole = [meta objectForKey:META_DEVELOPMENT_ROLE];
        
        MobeelizerLog(@"Development Role: %@", developmentRole);
        
        _mode = [meta objectForKey:META_MODE];
        
        if(self.mode == nil) {
            _mode = MODE_DEVELOPMENT;
        }
        
        MobeelizerLog(@"Mode: %@", self.mode);
        
        if(!([self.mode isEqualToString:MODE_PRODUCTION] || [self.mode isEqualToString:MODE_TEST] || [self.mode isEqualToString:MODE_DEVELOPMENT])) {
            MobeelizerException(@"Invalid mode", @"Mode must be equal to %@, %@ or %@.", MODE_DEVELOPMENT, MODE_TEST, MODE_PRODUCTION);
        }
        
        if([self.mode isEqualToString:MODE_DEVELOPMENT] && developmentRole == nil) {
            MobeelizerException(@"Missing development role", @"%@ must be set in Mobeelizer.plist file if %@ is set.", META_DEVELOPMENT_ROLE, META_MODE);
        }
        
        NSString *definitionAsset = [meta objectForKey:META_DEFINITION_ASSET];
        
        if(definitionAsset == nil) {
            definitionAsset = @"application.xml";
        }
        
        MobeelizerLog(@"Definition Asset: %@", definitionAsset);        
        
        NSString *stringUrl = [meta objectForKey:META_URL];
        
        if(stringUrl == nil) {
            if([self.mode isEqualToString:MODE_PRODUCTION]) {
                stringUrl = DEFAULT_PRODUCTION_URL;            
            } else {
                stringUrl = DEFAULT_TEST_URL;
            }
        }
        
        _url = [NSURL URLWithString:stringUrl]; 
        
        MobeelizerLog(@"Url: %@", self.url);
        
        _deviceIdentifier = [MobeelizerDeviceIdentifierUtil deviceIdentifier];
        
        MobeelizerLog(@"Device Identifier: %@", self.deviceIdentifier);
        
        if(self.deviceIdentifier == nil) {
            MobeelizerException(@"Missing device identifier", @"Device identifier cannot be created.");
        }
        
        _definitionManager = [[MobeelizerDefinitionManager alloc] initWithAsset:definitionAsset andModelPrefix:modelPrefix];
        
        if(self.definitionManager == nil) {
            MobeelizerException(@"Cannot read application definition", @"Cannot read definition from %@.", definitionAsset);
        }
        
        MobeelizerLog(@"Application: %@", self.definitionManager.application);
        MobeelizerLog(@"Vendor: %@", self.definitionManager.vendor);
        MobeelizerLog(@"Version Digest: %@", self.definitionManager.versionDigest);
        
        _internalDatabase = [[MobeelizerInternalDatabase alloc] initWithMobeelizer:self];
        
        if ([self.mode isEqualToString:MODE_DEVELOPMENT]) {
            _connectionManager = [[MobeelizerDevelopmentConnectionManager alloc] initWithRole:developmentRole];
        } else {
            _connectionManager = [[MobeelizerRealConnectionManager alloc] initWithMobeelizer:self];
        }
        
        _syncManager = [[MobeelizerSyncManager alloc] initWithMobeelizer:self];
        _fileManager = [[MobeelizerFileManager alloc] initWithMobeelizer:self];        
    }
    
    return self;
}


- (NSString *)versionDigest {
    return self.definitionManager.versionDigest;
}

- (NSString *)application {    
    return self.definitionManager.application;
}

- (NSString *)vendor {
    return self.definitionManager.vendor;
}

- (NSString *)user {
    return self.connectionManager.user;
}

- (NSString *)role {
    return self.connectionManager.role;
}

- (NSString *)instanceGuid {
    return self.connectionManager.instanceGuid;
}

- (NSString *)instance {
    return self.connectionManager.instance;    
}

- (void)loginUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback {
    [self loginToInstance:([self.mode isEqualToString:MODE_PRODUCTION] ? MODE_PRODUCTION : MODE_TEST) withUser:user andPassword:password withCallback:callback];
}

- (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback {
    if(!self.multitaskingSupported) {
        [callback onLoginFinished:[self loginToInstance:instance withUser:user andPassword:password]];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            MobeelizerLoginStatus status = [self loginToInstance:instance withUser:user andPassword:password];
            
            dispatch_async(dispatch_get_main_queue(), ^{            
                [callback onLoginFinished:status];
            });
        });
        
    }
}

- (MobeelizerCommunicationStatus)registerDeviceToken:(NSString *)token {
    return [self.connectionManager registerDeviceToken:token];
}

- (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users toGroup:(NSString *)group onDevice:(NSString *)device {
    return [self.connectionManager sendRemoteNotification:notification toUsers:users toGroup:group onDevice:device];
}

- (MobeelizerLoginStatus)loginUser:(NSString *)user andPassword:(NSString *)password {
    return [self loginToInstance:([self.mode isEqualToString:MODE_PRODUCTION] ? MODE_PRODUCTION : MODE_TEST) withUser:user andPassword:password];
}

- (MobeelizerLoginStatus)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password {
    if([self isLoggedIn]) {
        [self logout];
    }
    
    MobeelizerLog(@"Login: %@, %@, %@, %@", self.vendor, self.application, instance, user);
    
    MobeelizerLoginStatus status = [self.connectionManager loginToInstance:instance withUser:user andPassword:password];
    
    MobeelizerLog(@"Login result: %d", status);
    
    if (status != MobeelizerLoginStatusOk) {
        return status;
    }
    
    MobeelizerLog(@"Role: %@", self.role);
    MobeelizerLog(@"Instance Guid: %@", self.instanceGuid);
    
    _database = [[MobeelizerDatabase alloc] initWithMobeelizer:self];
    
    if (self.connectionManager.initialSyncRequired) {
        if([self.syncManager sync:TRUE] != MobeelizerSyncStatusFinishedWithSuccess) {
            MobeelizerLog(@"Cannot perform initial sync");
            return MobeelizerLoginStatusOtherFailure;
        }
    }
    
    return MobeelizerLoginStatusOk;
}

- (void)logout {
    if([self isLoggedIn]) {
        MobeelizerLog(@"Logout");
        
        [self.connectionManager logout];        
        [self.database destroy];
        
        _database = nil;
    }
}

- (void)destroy {
    MobeelizerLog(@"Destroy");
    
    [self logout];    
    [self.internalDatabase destroy];
    
    _internalDatabase = nil;
    _connectionManager = nil;
}

- (BOOL)isLoggedIn {
    return [self.connectionManager isLoggedIn];    
}

- (void)sync:(BOOL)all withCallback:(id<MobeelizerSyncCallback>)callback {
    if(!self.multitaskingSupported) {
        [callback onSyncFinished:[self sync:all]];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            MobeelizerLoginStatus status = [self sync:all];
            
            dispatch_async(dispatch_get_main_queue(), ^{            
                [callback onSyncFinished:status];
            });
        });
    }
}

- (MobeelizerSyncStatus)sync:(BOOL)all {
    if(![self isLoggedIn]) {
        MobeelizerException(@"Sync failed.", @"User must be logged in.")
    }
    
    MobeelizerLog(@"Sync: %@", all ? @"all" : @"diff");
    
    return [self.syncManager sync:all];
}

- (void)registerSyncStatusListener:(id<MobeelizerSyncListener>)listener {
    [self.syncManager registerSyncStatusListener:listener];
}

- (MobeelizerSyncStatus)checkSyncStatus {
    return self.syncManager.syncStatus;    
}

- (MobeelizerFile *)createFile:(NSString *)name withData:(NSData *)data {
    MobeelizerLog(@"Create file: %@", name);    
    return [[MobeelizerFile alloc] initWithName:name andData:data andMobeelizer:self];
}

- (MobeelizerFile *)createFile:(NSString *)name withGuid:(NSString *)guid {
    MobeelizerLog(@"Create file: %@, %@", name, guid);    
    return [[MobeelizerFile alloc] initWithGuid:guid andName:name andMobeelizer:self];
}

+ (void)create {
    mobeelizer = [[Mobeelizer alloc] init];
}

+ (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback {
    [mobeelizer loginToInstance:instance withUser:user andPassword:password withCallback:callback];
}

+ (MobeelizerLoginStatus)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password {
    return [mobeelizer loginToInstance:instance withUser:user andPassword:password];    
}

+ (void)loginUser:(NSString *)user andPassword:(NSString *)password withCallback:(id<MobeelizerLoginCallback>)callback {
    [mobeelizer loginUser:user andPassword:password withCallback:callback];
}

+ (MobeelizerLoginStatus)loginUser:(NSString *)user andPassword:(NSString *)password {
    return [mobeelizer loginUser:user andPassword:password];    
}

+ (void)logout {
    [mobeelizer logout];
}

+ (void)destroy {
    [mobeelizer destroy];
}

+ (BOOL)isLoggedIn {
    return [mobeelizer isLoggedIn];    
}

+ (MobeelizerSyncStatus)sync {
    return [mobeelizer sync:FALSE];
}

+ (MobeelizerSyncStatus)syncAll {
    return [mobeelizer sync:TRUE];
}

+ (void)syncWithCallback:(id<MobeelizerSyncCallback>)callback {
    [mobeelizer sync:FALSE withCallback:callback];
}

+ (void)syncAllWithCallback:(id<MobeelizerSyncCallback>)callback {
    [mobeelizer sync:TRUE withCallback:callback];
}

+ (MobeelizerDatabase *)database {
    return mobeelizer.database;
}

+ (MobeelizerSyncStatus)checkSyncStatus {
    return [mobeelizer checkSyncStatus];    
}

+ (MobeelizerFile *)createFile:(NSString *)name withData:(NSData *)data {
    return [mobeelizer createFile:name withData:data];
}

+ (MobeelizerFile *)createFile:(NSString *)name withGuid:(NSString *)guid {
    return [mobeelizer createFile:name withGuid:guid];    
}

+ (void)registerSyncStatusListener:(id<MobeelizerSyncListener>)listener {
    [mobeelizer registerSyncStatusListener:listener]; 
}

+ (Mobeelizer *)sharedInstance {
    return mobeelizer;
}

+ (MobeelizerCommunicationStatus)registerForRemoteNotificationsWithDeviceToken:(NSData *)token {    
    return [mobeelizer registerDeviceToken:[[[token description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""]];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification {
    return [mobeelizer sendRemoteNotification:notification toUsers:nil toGroup:nil onDevice:nil];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification onDevice:(NSString *)device {
    return [mobeelizer sendRemoteNotification:notification toUsers:nil toGroup:nil onDevice:device];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users {
    return [mobeelizer sendRemoteNotification:notification toUsers:users toGroup:nil onDevice:nil];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users onDevice:(NSString *)device {
    return [mobeelizer sendRemoteNotification:notification toUsers:users toGroup:nil onDevice:device];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group {
    return [mobeelizer sendRemoteNotification:notification toUsers:nil toGroup:group onDevice:nil];
}

+ (MobeelizerCommunicationStatus)sendRemoteNotification:(NSDictionary *)notification toGroup:(NSString *)group onDevice:(NSString *)device {
    return [mobeelizer sendRemoteNotification:notification toUsers:nil toGroup:group onDevice:device];
}

- (BOOL)isMultitaskingSupported {
    if (![[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { 
        return false;
    }
    return [[UIDevice currentDevice] isMultitaskingSupported];
}

@end
