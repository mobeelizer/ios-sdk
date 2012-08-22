// 
// MobeelizerDateFieldType.m
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

#import "MobeelizerDateFieldType.h"
#import "MobeelizerPropertyUtil.h"
#import "MobeelizerFieldDefinition+Internal.h"

@implementation MobeelizerDateFieldType

- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params {
    id value = [object valueForKey:self.name];
    
    if(value == nil) {
        [params addObject:[NSNull null]];
    } else if ([self.cType isEqualToString:@"NSDate"]) {
        [params addObject:[NSNumber numberWithInt:[value timeIntervalSince1970]]];
    } else {
        [params addObject:value];
    }    
}

- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object {
    NSNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        if ([self.cType isEqualToString:@"NSDate"]) {
            [object setValue:[NSDate dateWithTimeIntervalSince1970:[value intValue]] forKey:self.name];
        } else {
            [object setValue:value forKey:self.name];
        }
    }    
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSString *value = [json valueForKey:self.name];    
    
    if(value != nil) {
        if ([self.cType isEqualToString:@"NSDate"]) {
            [object setValue:[NSDate dateWithTimeIntervalSince1970:[value intValue]] forKey:self.name];
        } else {
            [object setValue:[NSNumber numberWithInt:[value intValue]] forKey:self.name];
        }
    }
}

- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json {
    NSNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [json setValue:[NSString stringWithFormat:@"%d", [value intValue]] forKey:self.name];
    } else {
        [json setValue:[NSNull null] forKey:self.name];
    }
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return [NSDate dateWithTimeIntervalSince1970:[defaultValue integerValue]];
    }
}

- (NSString *)queryForCreate {
    return [self queryForCreateWithType:@"INTEGER(19)" andDefaultValueQuoting:FALSE];
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%d", [(NSDate *)defaultValue timeIntervalSince1970]];
    }
}

- (NSArray *)supportedCTypes {  
    if(self.required) {
        return [NSArray arrayWithObjects:@"NSDate", @"NSNumber", PROPERTY_TYPE_INTEGER, nil];
    } else {
        return [NSArray arrayWithObjects:@"NSDate", @"NSNumber", nil];
    }
}

- (NSString *)dictionaryCType {
    return @"NSDate";
}

- (NSString *)supportedTypes {
    if(self.required) {
        return @"NSDate, NSNumber, NSInteger, int, long";
    } else {
        return @"NSDate, NSNumber";
    }
}

@end
