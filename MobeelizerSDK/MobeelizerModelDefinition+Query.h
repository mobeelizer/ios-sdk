// 
// MobeelizerModelDefinition+Query.h
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

#import "MobeelizerModelDefinition+Internal.h"

@interface MobeelizerModelDefinition (Query)

- (NSString *) queryForCreate;
- (NSString *) queryForDeleteAll;
- (NSString *) queryForDelete;
- (NSString *) queryForCount;
- (NSString *) queryForExists;
- (NSString *) queryForInsert;
- (NSString *) queryForUpdate;
- (NSString *) queryForUpdateWithoutFields;
- (NSString *) queryForSimpleUpdate;
- (NSString *) queryForGet;
- (NSString *) queryForList;
- (NSArray *) paramsForInsert:(id)object forGuid:(NSString *)guid forOwner:(NSString *)user withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted;
- (NSArray *) paramsForUpdate:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted;
- (NSArray *) paramsForUpdateWithoutFields:(id)object withModified:(BOOL)modified withDeleted:(BOOL)deleted withConflicted:(BOOL)conflicted;
- (NSArray *) paramsForSimpleUpdate:(id)object;
- (id) convertMapToObject:(NSDictionary *)row;
- (id) convertJsonToObject:(NSDictionary *)json;
- (NSString *) convertMapToJson:(NSDictionary *)row;
- (void) setAsDeleted:(id)object;

@end
