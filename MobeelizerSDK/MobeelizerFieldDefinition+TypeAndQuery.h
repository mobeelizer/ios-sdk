// 
// MobeelizerFieldDefinition+TypeAndQuery.h
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

#import "MobeelizerFieldDefinition.h"
#import "MobeelizerErrors.h"

@interface MobeelizerFieldDefinition (TypeAndQuery)

- (NSArray *)supportedCTypes;
- (NSString *)supportedTypes;
- (NSString *)queryForCreate;
- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params;
- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object;
- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object;
- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json;
- (NSArray *)getColumns;
- (NSString *)queryForCreateWithType:(NSString *)type andDefaultValueQuoting:(BOOL)defaultValueQuoting;
- (void)setDefaultOptions;
- (void)copyOptions:(id)field;
- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value;
- (id)convertDefaultValueFromString:(NSString *)defaultValue;
- (NSString *)convertDefaultValueToString:(id)defaultValue;
- (void)validateTypeField:(id)object forErrors:(MobeelizerErrors *)errors;

@end
