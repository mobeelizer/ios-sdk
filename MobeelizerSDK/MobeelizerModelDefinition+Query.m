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
#import "MobeelizerGuidUtil.h"

#define SQL_CREATE @"CREATE TABLE %@ (_guid TEXT(36) PRIMARY KEY, _owner TEXT(255) NOT NULL, _deleted INTEGER(1) NOT NULL DEFAULT 0, _modified INTEGER(1) NOT NULL DEFAULT 0, _conflicted INTEGER(1) NOT NULL DEFAULT 0%@)"
#define SQL_DELETE_ALL @"UPDATE %@ SET _deleted = 1, _modified = 1 WHERE _deleted = 0"
#define SQL_DELETE @"UPDATE %@ SET _deleted = 1, _modified = 1 WHERE _guid = ? AND _deleted = 0"
#define SQL_COUNT @"SELECT count(*) FROM %@ WHERE _deleted = 0"
#define SQL_EXISTS @"SELECT count(*) FROM %@ WHERE _guid = ? AND _deleted = 0"
#define SQL_LIST @"SELECT * FROM %@ WHERE _deleted = 0"
#define SQL_GET @"SELECT * FROM %@ WHERE _guid = ? AND _deleted = 0"
#define SQL_INSERT @"INSERT INTO %@ (_guid, _owner, _modified, _deleted, _conflicted%@) values (?, ?, ?, ?, ?%@)"
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

- (NSArray *) paramsForInsert:(id)object forGuid:(NSString *)guid forOwner:(NSString *)owner withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(guid == nil) {
        guid = [MobeelizerGuidUtil generateGuid];
    }
    
    [object setValue:guid forKey:@"guid"];
    
    if(self.hasOwner) {
        [object setValue:owner forKey:@"owner"];
    }
    
    if(self.hasModified) {    
        [object setValue:[NSNumber numberWithBool:modified] forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:[NSNumber numberWithBool:deleted] forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:[NSNumber numberWithBool:conflicted] forKey:@"conflicted"];
    }

    [array addObject:guid];    
    [array addObject:owner];    
    [array addObject:[NSNumber numberWithBool:modified]];
    [array addObject:[NSNumber numberWithBool:deleted]];
    [array addObject:[NSNumber numberWithBool:conflicted]];

    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromObject:object toQueryParams:array];
    }
    
    return array;
}

- (NSArray *) paramsForUpdate:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:[NSNumber numberWithBool:modified] forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:[NSNumber numberWithBool:deleted] forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:[NSNumber numberWithBool:conflicted] forKey:@"conflicted"];
    }
    
    [array addObject:[NSNumber numberWithBool:modified]];
    [array addObject:[NSNumber numberWithBool:deleted]];
    [array addObject:[NSNumber numberWithBool:conflicted]];
    
    for(MobeelizerFieldDefinition *field in self.fields) {
        [field addValueFromObject:object toQueryParams:array];
    }
    
    [array addObject:[object valueForKey:@"guid"]];
    return array;    
}

- (NSArray *) paramsForUpdateWithoutFields:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:[NSNumber numberWithBool:modified] forKey:@"modified"];
    }
    
    if(self.hasDeleted) {
        [object setValue:[NSNumber numberWithBool:deleted] forKey:@"deleted"];
    }
    
    if(self.hasConflicted) {
        [object setValue:[NSNumber numberWithBool:conflicted] forKey:@"conflicted"];
    }
    
    [array addObject:[NSNumber numberWithBool:modified]];
    [array addObject:[NSNumber numberWithBool:deleted]];
    [array addObject:[NSNumber numberWithBool:conflicted]];
        
    [array addObject:[object valueForKey:@"guid"]];
    return array;    
}

- (NSArray *) paramsForSimpleUpdate:(id)object {
    NSMutableArray *array = [NSMutableArray array];
    
    if(self.hasModified) {    
        [object setValue:[NSNumber numberWithBool:TRUE] forKey:@"modified"];
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
    
    if(self.hasDeleted) {
        [object setValue:[NSNumber numberWithBool:[[[json valueForKey:@"fields"] valueForKey:@"s_deleted"] isEqualToString:@"true"]] forKey:@"deleted"];
    }
    
    if(self.hasModified) {
        [object setValue:[NSNumber numberWithBool:FALSE] forKey:@"modified"];
    }
    
    if(self.hasConflicted) {
        [object setValue:[NSNumber numberWithBool:[[json valueForKey:@"conflictState"] hasPrefix:@"IN_CONFLICT"]] forKey:@"conflicted"];
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

- (id) convertMapToObject:(NSDictionary *)row {
    id object = self.clazz == nil ? [NSMutableDictionary dictionary] : [[self.clazz alloc] init];
    
    if(self.clazz == nil) {
        [object setValue:self.name forKey:@"model"];   
    }
    
    [object setValue:[row valueForKey:@"_guid"] forKey:@"guid"];
    
    if(self.hasOwner) {
        [object setValue:[row valueForKey:@"_owner"] forKey:@"owner"];
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
        [field addValueFromRow:row toObject:object];
    }
    
    return object;
}

- (void) setAsDeleted:(id)object {
    if(self.hasDeleted) {
        [object setValue:[NSNumber numberWithBool:TRUE] forKey:@"deleted"];
    }    
}

@end
