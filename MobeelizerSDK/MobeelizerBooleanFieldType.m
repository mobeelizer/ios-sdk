// 
// MobeelizerBooleanFieldType.m
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

#import "MobeelizerBooleanFieldType.h"
#import "MobeelizerPropertyUtil.h"

@implementation MobeelizerBooleanFieldType

- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params {
    NSNumber *value = [object valueForKey:self.name];
    
    if(value == nil) {
        [params addObject:[NSNull null]];
    } else {
        [params addObject:value];
    }    
}

- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object {
    NSNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [object setValue:@((BOOL)([value intValue] == 1)) forKey:self.name];
    }
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSString *value = [json valueForKey:self.name];    
    
    if(value != nil) {
        [object setValue:@([value isEqualToString:@"true"]) forKey:self.name];
    }
}

- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json {
    NSNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [json setValue:(([value intValue] == 1) ? @"true" : @"false") forKey:self.name];
    } else {
        [json setValue:[NSNull null] forKey:self.name];
    }
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else if([defaultValue isEqualToString:@"true"]) {
        return @TRUE;
    } else {
        return @FALSE;
    }
}

- (NSString *)queryForCreate {
    return [self queryForCreateWithType:@"INTEGER(1)" andDefaultValueQuoting:FALSE];
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else if([(NSNumber *)defaultValue boolValue]) {
        return @"1";
    } else {
        return @"0";
    }
}

- (NSArray *)supportedCTypes {
    if(self.required) {
        return @[@"NSNumber", PROPERTY_TYPE_BOOL];    
    } else {
        return @[@"NSNumber"];
    }
}

- (NSString *)dictionaryCType {
    return @"NSNumber";
}

- (NSString *)supportedTypes {
    if(self.required) {
        return @"NSNumber, BOOL, Boolean, char";
    } else {
        return @"NSNumber";
    }
}

@end
