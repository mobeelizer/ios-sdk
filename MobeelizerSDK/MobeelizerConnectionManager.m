// 
// MobeelizerConnectionManager.m
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

#import "MobeelizerConnectionManager.h"
#import "MobeelizerOperationError+Internal.h"

@implementation MobeelizerConnectionManager

@synthesize instance=_instance, initialSyncRequired=_initialSyncRequired, role=_role, instanceGuid=_instanceGuid, user=_user, group=_group;

- (void)loginToInstance:(NSString *)instance withUser:(NSString *)user andPassword:(NSString *)password returningError:(MobeelizerOperationError **)error {
    // empty
}

- (void)logout {
    _user = nil;
    _group = nil;    
    _instanceGuid = nil;
    _instance = nil;
    _role = nil;
    _initialSyncRequired = FALSE;
}

- (BOOL)isLoggedIn {
    return self.role != nil;
}

- (NSString *)requestSyncAllReturningError:(MobeelizerOperationError **)error {
    return nil;
}

- (NSString *)requestSyncDiff:(NSString *)dataPath returningError:(MobeelizerOperationError **)error {
    return nil;
}

- (void)waitUntilSyncRequestComplete:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    // empty
}

- (NSString *)getSyncData:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    return nil;
}

- (void)confirmTask:(NSString *)ticket returningError:(MobeelizerOperationError **)error {
    // empty
}

- (void)sendRemoteNotification:(NSDictionary *)notification toUsers:(NSArray *)users toGroup:(NSString *)group onDevice:(NSString *)device returningError:(MobeelizerOperationError **)error {
    // empty
}

- (void)registerDeviceToken:(NSString *)token returningError:(MobeelizerOperationError **)error {
    // empty
}

- (void)unregisterForRemoteNotificationsReturningError:(MobeelizerOperationError **)error {
    // empty
}

@end
