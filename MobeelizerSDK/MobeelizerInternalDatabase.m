// 
// MobeelizerInternalDatabase.m
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

#import "MobeelizerInternalDatabase.h"
#import "MobeelizerSqlite3Database.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerDigestUtil.h"

#define SQL_DATABASE_NAME @"internal"

#define SQL_CREATE_ROLES @"CREATE TABLE IF NOT EXISTS roles (instance TEXT NOT NULL, user TEXT NOT NULL, password TEXT NOT NULL, role TEXT, instanceGuid TEXT, initialSyncRequired INTEGER(1) NOT NULL DEFAULT 0, PRIMARY KEY(instance, user))"
#define SQL_CREATE_VERSIONS @"CREATE TABLE IF NOT EXISTS versions (instance TEXT NOT NULL, instanceGuid TEXT NOT NULL, user TEXT NOT NULL, version TEXT NOT NULL, PRIMARY KEY(version, user, instance, instanceGuid))"
#define SQL_DELETE_FROM_ROLES @"DELETE FROM roles"
#define SQL_COUNT_ROLES @"SELECT count(*) FROM roles WHERE instance = ? and user = ?"
#define SQL_UPDATE_ROLES @"UPDATE roles SET role = ?, instanceGuid = ?, password = ? WHERE instance = ? AND user = ?"
#define SQL_INSERT_ROLES @"INSERT INTO roles (role, instanceGuid, instance, user, password, initialSyncRequired) values (?, ?, ?, ?, ?, 1)"
#define SQL_CLEAR_ROLES @"UPDATE roles SET role = NULL, instanceGuid = NULL WHERE instance = ? and user = ?"
#define SQL_SELECT_ROLE @"SELECT role, instanceGuid FROM roles WHERE instance = ? and user = ? and password = ?"
#define SQL_DELETE_VERSIONS @"DELETE FROM versions WHERE instance = ? AND user = ?"
#define SQL_SELECT_VERSIONS @"SELECT version FROM versions WHERE instance = ? AND instanceGuid = ? AND user = ? LIMIT 1"
#define SQL_INSERT_VERSIONS @"INSERT INTO versions (instance, instanceGuid, user, version) VALUES (?, ?, ?, ?)"
#define SQL_SELECT_INITIAL_SYNC_REQUIRED @"SELECT initialSyncRequired, instanceGuid FROM roles WHERE instance = ? and user = ?"
#define SQL_UPDATE_INITIAL_SYNC_REQUIRED @"UPDATE roles SET initialSyncRequired = 0 WHERE instance = ? and user = ?"

@interface MobeelizerInternalDatabase ()

@property (nonatomic, strong) MobeelizerSqlite3Database *database;
@property (nonatomic, weak) NSString *versionDigest;

@end

@implementation MobeelizerInternalDatabase

@synthesize database=_database, versionDigest=_versionDigest;

- (id)initWithMobeelizer:(Mobeelizer *)mobeelizer {
    if (self = [super init]) {   
        if(self.database != nil) {
            [self destroy];
        }
        
        _versionDigest = mobeelizer.versionDigest;
        
        _database = [[MobeelizerSqlite3Database alloc] initWithName:SQL_DATABASE_NAME];
        
        [self.database execQuery:SQL_CREATE_ROLES];
        [self.database execQuery:SQL_CREATE_VERSIONS];
    }
    return self;
}

- (void)destroy {
    if(self.database != nil) {
        [self.database destroy];
        self.database = nil;
    }
}

- (void)setInitializationFinishedForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user {    
    [self.database execQuery:SQL_DELETE_VERSIONS withParams:@[instance, user]];    
    [self.database execQuery:SQL_INSERT_VERSIONS withParams:@[instance, instanceGuid, user, self.versionDigest]];
}

- (BOOL)checkIfInitializationIsRequiredForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user {    
    NSString *currentVersionDigest = [self.database execQueryForSingleResult:SQL_SELECT_VERSIONS withParams:@[instance, instanceGuid, user]];    
        
    if(currentVersionDigest != nil && [currentVersionDigest isEqualToString:self.versionDigest]) {
        return FALSE;
    } else {
        return TRUE;
    }        
}

- (BOOL)isInitialSyncRequiredForInstance:(NSString *)instance andInstanceGuid:(NSString *)instanceGuid andUser:(NSString *)user {
    NSNumber *count = [self.database execQueryForSingleResult:SQL_COUNT_ROLES withParams:@[instance, user]];
    
    if([count intValue] > 0) {
        NSDictionary *result = [self.database execQueryForRow:SQL_SELECT_INITIAL_SYNC_REQUIRED withParams:@[instance, user]];
        
        if(![instanceGuid isEqualToString:result[@"instanceGuid"]]) { 
            return TRUE;
        }
        
        return [result[@"initialSyncRequired"] intValue] == 1;
    } else {
        return TRUE;
    }
}

- (void)setInitialSyncAsNotRequiredForInstance:(NSString *)instance andUser:(NSString *)user {
    [self.database execQuery:SQL_UPDATE_INITIAL_SYNC_REQUIRED withParams:@[instance, user]];
}

- (void)setRole:(NSString *)role andInstanceGuid:(NSString *)instanceGuid forInstance:(NSString *)instance andUser:(NSString *)user andPassword:(NSString *)password {
    NSNumber *count = [self.database execQueryForSingleResult:SQL_COUNT_ROLES withParams:@[instance, user]];
        
    if([count intValue] > 0) {
        [self.database execQuery:SQL_UPDATE_ROLES withParams:@[role, instanceGuid, [MobeelizerDigestUtil stringFromSHA256:password], instance, user]];
    } else {
        [self.database execQuery:SQL_INSERT_ROLES withParams:@[role, instanceGuid, instance, user, [MobeelizerDigestUtil stringFromSHA256:password]]];
    }
}

- (NSDictionary *)getRoleAndInstanceGuidForInstance:(NSString *)instance andUser:(NSString *)user andPassword:(NSString *)password {
    return [self.database execQueryForRow:SQL_SELECT_ROLE withParams:@[instance, user, [MobeelizerDigestUtil stringFromSHA256:password]]];    
}

- (void)clearRoleAndInstanceGuidForInstance:(NSString *)instance andUser:(NSString *)user { 
    [self.database execQuery:SQL_CLEAR_ROLES withParams:@[instance, user]];
}

@end
