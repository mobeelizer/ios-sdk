// 
// MobeelizerModelDefinition+Query.m
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

#import "Mobeelizer+Internal.h"
#import "MobeelizerModelDefinition+Query.h"
#import "MobeelizerFieldDefinition+TypeAndQuery.h"
#import "MobeelizerFieldDefinition.h"
#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerGuidUtil.h"
#import "MobeelizerErrors+Internal.h"
#import "MobeelizerError+Internal.h"

#define SQL_CREATE @"CREATE TABLE %@ (_guid TEXT(36) PRIMARY KEY, _owner TEXT(255) NOT NULL, _group TEXT(255) NOT NULL, _deleted INTEGER(1) NOT NULL DEFAULT 0, _modified INTEGER(1) NOT NULL DEFAULT 0, _conflicted INTEGER(1) NOT NULL DEFAULT 0%@)"
#define SQL_DELETE_ALL @"UPDATE %@ SET _deleted = 1, _modified = 1 WHERE _deleted = 0"
#define SQL_DELETE @"UPDATE %@ SET _deleted = 1, _modified = 1 WHERE _guid = ? AND _deleted = 0"
#define SQL_COUNT @"SELECT count(*) FROM %@ WHERE _deleted = 0"
#define SQL_EXISTS @"SELECT count(*) FROM %@ WHERE _guid = ? AND _deleted = 0"
#define SQL_LIST @"SELECT * FROM %@ WHERE _deleted = 0"
#define SQL_GET @"SELECT * FROM %@ WHERE _guid = ? AND _deleted = 0"
#define SQL_INSERT @"INSERT INTO %@ (_guid, _owner, _group, _modified, _deleted, _conflicted%@) values (?, ?, ?, ?, ?, ?%@)"
#define SQL_UPDATE @"UPDATE %@ SET _modified = ?, _deleted = ?, _conflicted = ?%@ WHERE _guid = ?"
#define SQL_UPDATE_WITHOUT_FIELDS @"UPDATE %@ SET _modified = ?, _deleted = ?, _conflicted = ? WHERE _guid = ?"
#define SQL_SIMPLE_UPDATE @"UPDATE %@ SET _modified = 1%@ WHERE _guid = ? AND _deleted = 0"

@implementation MobeelizerModelDefinition (Query)

- (NSString *) queryForDeleteAll {
    return [NSString stringWithFormat:SQL_DELETE_ALL, self.name];
}

- (NSString *) queryForDelete {
    return [NSString stringWithFormat:SQL_DELETE, self.name];
}

- (NSString *) queryForCount {
    return [NSString stringWithFormat:SQL_COUNT, self.name];
}

- (NSString *) queryForExists {
    return [NSString stringWithFormat:SQL_EXISTS, self.name];
}


- (NSString *) queryForCreate {
    NSMutableString *fieldCreates = [NSMutableString string];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [fieldCreates appendFormat:@", %@", [field queryForCreate]];
    }
    
    return [NSString stringWithFormat:SQL_CREATE, self.name, fieldCreates];    
}

- (NSString *) queryForInsert {
    NSMutableString *fieldNames = [NSMutableString string];
    NSMutableString *fieldQuestionMarks = [NSMutableString string];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        for(NSString *column in [field getColumns]) {
            [fieldNames appendFormat:@", %@", column];
            [fieldQuestionMarks appendString:@", ?"];
        }
    }
    
    return [NSString stringWithFormat:SQL_INSERT, self.name, fieldNames, fieldQuestionMarks];
}

- (NSString *) queryForUpdate {
    NSMutableString *fieldNamesAndQuestionMarks = [NSMutableString string];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        for(NSString *column in [field getColumns]) {
            [fieldNamesAndQuestionMarks appendFormat:@", %@ = ?", column];
        }
    }
    
    return [NSString stringWithFormat:SQL_UPDATE, self.name, fieldNamesAndQuestionMarks];    
}


- (NSString *) queryForUpdateWithoutFields {
    return [NSString stringWithFormat:SQL_UPDATE_WITHOUT_FIELDS, self.name];    
}

- (NSString *) queryForSimpleUpdate {
    NSMutableString *fieldNamesAndQuestionMarks = [NSMutableString string];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        for(NSString *column in [field getColumns]) {
            [fieldNamesAndQuestionMarks appendFormat:@", %@ = ?", column];
        }
    }
    
    return [NSString stringWithFormat:SQL_SIMPLE_UPDATE, self.name, fieldNamesAndQuestionMarks];    
}

- (NSString *) queryForGet {
    return [NSString stringWithFormat:SQL_GET, self.name];
}

- (NSString *) queryForList {
    return [NSString stringWithFormat:SQL_LIST, self.name];
}

- (NSArray *) paramsForInsert:(id)object forGuid:(NSString *)guid forOwner:(NSString *)owner withGroup:(NSString *)group withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(guid == nil) {
        guid = [MobeelizerGuidUtil generateGuid];
    }
    
    [object setValue:guid forKey:@"guid"];
    
    if(self.hasOwner) {
        [object setValue:owner forKey:@"owner"];
    }

    if(self.hasGroup) {
        [object setValue:group forKey:@"group"];
    }
    
    if(self.hasModified) {    
        [object setValue:@(modified) forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:@(deleted) forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:@(conflicted) forKey:@"conflicted"];
    }

    [array addObject:guid];    
    [array addObject:owner]; 
    [array addObject:group]; 
    [array addObject:@(modified)];
    [array addObject:@(deleted)];
    [array addObject:@(conflicted)];

    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromObject:object toQueryParams:array];
    }
    
    return array;
}

- (NSArray *) paramsForUpdate:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:@(modified) forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:@(deleted) forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:@(conflicted) forKey:@"conflicted"];
    }
    
    [array addObject:@(modified)];
    [array addObject:@(deleted)];
    [array addObject:@(conflicted)];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromObject:object toQueryParams:array];
    }
    
    [array addObject:[object valueForKey:@"guid"]];
    return array;    
}

- (NSArray *) paramsForUpdateWithoutFields:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:@(modified) forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:@(deleted) forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:@(conflicted) forKey:@"conflicted"];
    }
    
    [array addObject:@(modified)];
    [array addObject:@(deleted)];
    [array addObject:@(conflicted)];
        
    [array addObject:[object valueForKey:@"guid"]];
    return array;    
}

- (NSArray *) paramsForSimpleUpdate:(id)object {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:@TRUE forKey:@"modified"];
    }
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromObject:object toQueryParams:array];
    }
    
    [array addObject:[object valueForKey:@"guid"]];
    return array;    
}

- (id) convertJsonToObject:(NSDictionary *)json {
    id object = self.clazz == nil ? [NSMutableDictionary dictionary] : [[self.clazz alloc] init];
    
    if(self.clazz == nil) {
        [object setValue:[json valueForKey:@"model"] forKey:@"model"];   
    }
    
    [object setValue:[json valueForKey:@"guid"] forKey:@"guid"];
    
    if(self.hasOwner) {
        [object setValue:[json valueForKey:@"owner"] forKey:@"owner"];
    }
    
    if(self.hasGroup) {
        [object setValue:[json valueForKey:@"group"] forKey:@"group"];
    }
    
    if(self.hasDeleted) {
        [object setValue:@([[[json valueForKey:@"fields"] valueForKey:@"s_deleted"] isEqualToString:@"true"]) forKey:@"deleted"];
    }
    
    if(self.hasModified) {
        [object setValue:@FALSE forKey:@"modified"];
    }
    
    if(self.hasConflicted) {
        [object setValue:@([[json valueForKey:@"conflictState"] hasPrefix:@"IN_CONFLICT"]) forKey:@"conflicted"];
    }
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromJson:[json valueForKey:@"fields"] toObject:object];    
    }
    
    return object;    
}

- (NSString *) convertMapToJson:(NSDictionary *)row {
    NSMutableDictionary *json = [NSMutableDictionary dictionary];

    [json setValue:self.name forKey:@"model"];
    [json setValue:[row valueForKey:@"_guid"] forKey:@"guid"];
    [json setValue:[row valueForKey:@"_owner"] forKey:@"owner"];
    [json setValue:[row valueForKey:@"_group"] forKey:@"group"];
    
    NSMutableDictionary *jsonFields = [NSMutableDictionary dictionary];
    [jsonFields setValue:([[row valueForKey:@"_deleted"] boolValue] ? @"true" : @"false") forKey:@"s_deleted"];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromRow:row toJson:jsonFields];
    }
    
    [json setValue:jsonFields forKey:@"fields"];
    
    NSError* error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:&error];
    
    if(error != nil) {
        MobeelizerLog(@"JSON creation has failed: %@", [error localizedDescription]);
        return nil;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}


- (BOOL) checkCredential:(MobeelizerCredential)credential forOwner:(NSString *)owner andGroup:(NSString *)group {
    return credential == MobeelizerCredentialAll || (credential == MobeelizerCredentialGroup && [group isEqualToString:self.group]) || (credential == MobeelizerCredentialOwn && [owner isEqualToString:self.owner]);
}

- (id) convertMapToObject:(NSDictionary *)row {
    id object = self.clazz == nil ? [NSMutableDictionary dictionary] : [[self.clazz alloc] init];
    
    if(self.clazz == nil) {
        [object setValue:self.name forKey:@"model"];   
    }
    
    [object setValue:[row valueForKey:@"_guid"] forKey:@"guid"];
    
    if(self.hasOwner) {
        [object setValue:[row valueForKey:@"_owner"] forKey:@"owner"];
    }
    
    if(self.hasGroup) {
        [object setValue:[row valueForKey:@"_group"] forKey:@"group"];
    }
    
    if(self.hasDeleted) {
        [object setValue:[row valueForKey:@"_deleted"] forKey:@"deleted"];
    }
    
    if(self.hasModified) {
        [object setValue:[row valueForKey:@"_modified"] forKey:@"modified"];
    }
    
    if(self.hasConflicted) {
        [object setValue:[row valueForKey:@"_conflicted"] forKey:@"conflicted"];
    }
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        if([self checkCredential:field.credential.readAllowed forOwner:[row valueForKey:@"_owner"] andGroup:[row valueForKey:@"_group"]]) {
            [field addValueFromRow:row toObject:object];
        }
    }
    
    return object;
}

- (void) setAsDeleted:(id)object {
    if(self.hasDeleted) {
        [object setValue:@TRUE forKey:@"deleted"];
    }    
}

- (MobeelizerErrors*) checkPermissionForDeleteAllWithOwnersAndGroups:(NSArray*)ownersAndGroups {
    if(self.credential.deleteAllowed == MobeelizerCredentialAll) {
        return nil;
    }

    if(self.credential.deleteAllowed == MobeelizerCredentialNone) {
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnModel andArguments:@[@"delete"]]];
        return error;
    }
    
    for (NSDictionary *ownerAndGroup in ownersAndGroups) {
        if(![self checkCredential:self.credential.deleteAllowed forOwner:ownerAndGroup[@"_owner"] andGroup:ownerAndGroup[@"_group"]]) {
            MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
            [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnModel andArguments:@[@"delete"]]];
            return error;
        }
    }
    
    return nil;
}

- (MobeelizerErrors*) checkPermissionForDeleteWithOwnerAndGroup:(NSDictionary*)ownerAndGroup {
    if(![self checkCredential:self.credential.deleteAllowed forOwner:ownerAndGroup[@"_owner"] andGroup:ownerAndGroup[@"_group"]]) {
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnModel andArguments:@[@"delete"]]];
        return error;
    }
    return nil;
}

- (MobeelizerErrors*) checkPermissionForInsert:(id)object {
    if(![self checkCredential:self.credential.createAllowed forOwner:self.owner andGroup:self.group]) {
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnModel andArguments:@[@"create"]]];
        return error;
    }
    for(MobeelizerFieldDefinition *field in self.fields) {
        id value = [object valueForKey:field.name];
        
        if(field.credential.createAllowed != MobeelizerCredentialNone || value == nil || (field.defaultValue != nil && [[value stringValue] isEqualToString:[field.defaultValue stringValue]])) {
            continue;
        }
           
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnField andArguments:@[@"create", field.name]]];
        return error;
    }
    
    return nil;
}

- (MobeelizerErrors*) checkPermissionForUpdate:(id)object withOriginalObject:(id)originalObject withOriginalOwnerAndGroup:(NSDictionary*)originalOwnerAndGroup {
    if(![self checkCredential:self.credential.updateAllowed forOwner:originalOwnerAndGroup[@"_owner"] andGroup:originalOwnerAndGroup[@"_group"]]) {
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnModel andArguments:@[@"update"]]];
        return error;
    }
    for(MobeelizerFieldDefinition *field in self.fields) {
        id value = [object valueForKey:field.name];
        id originalValue = [originalObject valueForKey:field.name];
                
        if([self checkCredential:field.credential.updateAllowed forOwner:originalOwnerAndGroup[@"_owner"] andGroup:originalOwnerAndGroup[@"_group"]] || value == originalValue || [[value stringValue] isEqualToString:[originalValue stringValue]]) {
            continue;
        }
        
        MobeelizerErrors *error = [[MobeelizerErrors alloc] init];
        [error addGlobalError:[[MobeelizerError alloc] initWithCode:NoCredentialsToPerformOperationOnField andArguments:@[@"update", field.name]]];
        return error;
    }
    
    return nil;
}

@end
