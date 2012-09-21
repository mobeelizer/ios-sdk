// 
// MobeelizerFieldDefinition+TypeAndQuery.m
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

#import "MobeelizerFieldDefinition+TypeAndQuery.h"

@implementation MobeelizerFieldDefinition (TypeAndQuery)

- (NSString *)queryForCreate {
    return nil; // overwrite me
}

- (NSArray *)getColumns {
    return @[self.name];
}

- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params {
    NSString *value = [object valueForKey:self.name];
    
    if(value == nil) {
        [params addObject:[NSNull null]];
    } else {
        [params addObject:value];
    }    
}

- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object {
    NSString *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [object setValue:value forKey:self.name];
    }    
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSString *value = [json valueForKey:self.name];    
    
    if(value != nil) {
        [object setValue:value forKey:self.name];
    }
}

- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json {
    NSString *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [json setValue:value forKey:self.name];
    } else {
        [json setValue:[NSNull null] forKey:self.name];
    }
}

- (void)setDefaultOptions {
    // empty
}

- (void)copyOptions:(id)field {
    // empty
}

- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value {
    return nil;
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    return nil;
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    return nil;
}

- (NSString *)queryForCreateWithType:(NSString *)theType andDefaultValueQuoting:(BOOL)defaultValueQuoting {
    NSMutableString *query = [NSMutableString stringWithFormat:@"%@ %@", self.name, theType];    
    
    if(self.required) {
        [query appendString:@" NOT NULL"];
    }
    
    if(self.defaultValue != nil) {
        [query appendString:@" DEFAULT "];
        
        NSString *string = [self convertDefaultValueToString:self.defaultValue];
        
        if(defaultValueQuoting) {
            [query appendFormat:@"'%@'", [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
        } else {
            [query appendString:string];
        }
    }
    
    return query;
}

- (NSArray *)supportedCTypes {
    return @[];
}

- (NSString *)supportedTypes {
    return @"";
}

- (NSString *)dictionaryCType {
    return @"";
}

- (void)validateTypeField:(id)object forErrors:(MobeelizerErrors *)errors {
    // empty
}

@end
