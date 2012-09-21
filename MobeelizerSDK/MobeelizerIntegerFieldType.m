// 
// MobeelizerIntegerFieldType.m
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

#import "MobeelizerIntegerFieldType.h"
#import "MobeelizerPropertyUtil.h"
#import "MobeelizerError+Internal.h"
#import "MobeelizerErrors+Internal.h"

@implementation MobeelizerIntegerFieldType

@synthesize minValue=_minValue, maxValue=_maxValue;

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
        [object setValue:value forKey:self.name];
    }    
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSString *value = [json valueForKey:self.name];    
    
    if(value != nil) {
        [object setValue:@([value intValue]) forKey:self.name];
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

- (void)setDefaultOptions {
    self.minValue = @-2147483648;
    self.maxValue = @2147483647;
}

- (void)copyOptions:(id)field {
    self.minValue = ((MobeelizerIntegerFieldType *)field).minValue;
    self.maxValue = ((MobeelizerIntegerFieldType *)field).maxValue;
}

- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value {
    if([name isEqualToString:@"minValue"]) {
        self.minValue = @([value integerValue]);
        return self.minValue;
    } else if([name isEqualToString:@"maxValue"]) {
        self.maxValue = @([value integerValue]);
        return self.maxValue;
    }        
    return nil;
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return @([defaultValue integerValue]);
    }
}

- (NSString *)queryForCreate {
    NSInteger length = [[NSString stringWithFormat:@"%d", [self.maxValue intValue]] length];
    return [self queryForCreateWithType:[NSString stringWithFormat:@"INTEGER(%d)", length] andDefaultValueQuoting:FALSE];
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%d", [defaultValue intValue]];
    }
}

- (NSArray *)supportedCTypes {
    if(self.required) {
        return @[@"NSNumber", PROPERTY_TYPE_INTEGER];
    } else {
        return @[@"NSNumber"];
    }
}

- (NSString *)supportedTypes {
    if(self.required) {
        return @"NSNumber, int, short, long";
    } else {
        return @"NSNumber";
    }
}

- (NSString *)dictionaryCType {
    return @"NSNumber";
}

- (void)validateTypeField:(id)object forErrors:(MobeelizerErrors *)errors {
    NSNumber *value = [object valueForKey:self.name];
    
    if([value intValue] < [self.minValue intValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeGreaterThanOrEqualsTo andArguments:@[self.minValue]] forField:self.name];
        return;
    }
    
    if([value intValue] > [self.maxValue intValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeLessThanOrEqualsTo andArguments:@[self.maxValue]] forField:self.name];
        return;
    }
}


@end
