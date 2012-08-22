// 
// MobeelizerDecimalFieldType.m
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

#import "MobeelizerDecimalFieldType.h"
#import "MobeelizerPropertyUtil.h"
#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerError+Internal.h"
#import "MobeelizerErrors+Internal.h"

@implementation MobeelizerDecimalFieldType

@synthesize includeMaxValue=_includeMaxValue, includeMinValue=_includeMinValue, scale=_scale, minValue=_minValue, maxValue=_maxValue, length=_length;

- (void)addValueFromObject:(id)object toQueryParams:(NSMutableArray *)params {
    NSDecimalNumber *value = [object valueForKey:self.name];
    
    if(value == nil) {
        [params addObject:[NSNull null]];
    } else {
        [params addObject:value];
    }    
}

- (void)addValueFromRow:(NSDictionary *)row toObject:(id)object {
    NSDecimalNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [object setValue:value forKey:self.name];
    }    
}

- (void)addValueFromJson:(NSDictionary *)json toObject:(id)object {
    NSString *value = [json valueForKey:self.name];    
    
    if(value != nil) {
        [object setValue:[NSDecimalNumber numberWithDouble:[value doubleValue]] forKey:self.name];
    }
}

- (void)addValueFromRow:(NSDictionary *)row toJson:(NSDictionary *)json {
    NSDecimalNumber *value = [row valueForKey:self.name];
    
    if(value != nil) {
        [json setValue:[NSString stringWithFormat:[NSString stringWithFormat:@"%%.%@f", self.scale], [value doubleValue]] forKey:self.name];
    } else {
        [json setValue:[NSNull null] forKey:self.name];
    }
}

- (void)setDefaultOptions {
    self.includeMinValue = [NSNumber numberWithBool:TRUE];
    self.includeMaxValue = [NSNumber numberWithBool:TRUE];
    self.scale = [NSNumber numberWithInt:3];
    self.length = [NSNumber numberWithInt:309];
    self.minValue = nil;
    self.maxValue = nil;
}

- (void)copyOptions:(id)field {
    self.includeMinValue = ((MobeelizerDecimalFieldType *)field).includeMinValue;
    self.includeMaxValue = ((MobeelizerDecimalFieldType *)field).includeMaxValue;
    self.scale = ((MobeelizerDecimalFieldType *)field).scale;
    self.length = ((MobeelizerDecimalFieldType *)field).length;
    self.minValue = ((MobeelizerDecimalFieldType *)field).minValue;
    self.maxValue = ((MobeelizerDecimalFieldType *)field).maxValue;
}

- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value {
    if([name isEqualToString:@"minValue"]) {
        self.minValue = [NSNumber numberWithDouble:[value doubleValue]];
        return self.minValue;
    } else if([name isEqualToString:@"maxValue"]) {
        self.maxValue = [NSNumber numberWithDouble:[value doubleValue]];
        self.length = [NSNumber numberWithInteger:[[NSString stringWithFormat:@"%d", [self.maxValue intValue]] length]];
        return self.maxValue;
    } else if([name isEqualToString:@"scale"]) {
        self.scale = [NSNumber numberWithInteger:[value integerValue]];
        return self.scale;
    } else if([name isEqualToString:@"includeMinValue"]) {
        self.includeMinValue = [NSNumber numberWithBool:[value isEqualToString:@"true"]];
        return self.includeMinValue;
    } else if([name isEqualToString:@"includeMaxValue"]) {
        self.includeMaxValue = [NSNumber numberWithBool:[value isEqualToString:@"true"]];
        return self.includeMaxValue;
    }        
    return nil;
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return [NSNumber numberWithDouble:[defaultValue doubleValue]];
    }
}

- (NSString *)queryForCreate {
    return [self queryForCreateWithType:[NSString stringWithFormat:@"REAL(%d,%d)", [self.length intValue], [self.scale intValue]] andDefaultValueQuoting:FALSE];
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    if(defaultValue == nil) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%f", defaultValue];
    }
}

- (NSArray *)supportedCTypes {
    if(self.required) {
        return [NSArray arrayWithObjects:@"NSNumber", @"NSDecimalNumber", PROPERTY_TYPE_DOUBLE, nil];
    } else {
        return [NSArray arrayWithObjects:@"NSNumber", @"NSDecimalNumber", nil];
    }
}

- (NSString *)dictionaryCType {
    return @"NSDecimalNumber";
}

- (NSString *)supportedTypes {
    if(self.required) {
        return @"NSDecimalNumber, double, float";
    } else {
        return @"NSDecimalNumber";
    }
}

- (void)validateTypeField:(id)object forErrors:(MobeelizerErrors *)errors {
    NSDecimalNumber *value = [object valueForKey:self.name];

    if([self.includeMinValue boolValue] && [value doubleValue] < [self.minValue doubleValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeGreaterThanOrEqualsTo andArguments:[NSArray arrayWithObject:self.minValue]] forField:self.name];
        return;
    } 
    
    if(![self.includeMinValue boolValue] && [value doubleValue] <= [self.minValue doubleValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeGreaterThan andArguments:[NSArray arrayWithObject:self.minValue]] forField:self.name];
        return;
    }
    
    if([self.includeMaxValue boolValue] && [value doubleValue] > [self.maxValue doubleValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeLessThanOrEqualsTo andArguments:[NSArray arrayWithObject:self.maxValue]] forField:self.name];
        return;
    } 
    
    if(![self.includeMaxValue boolValue] && [value doubleValue] >= [self.maxValue doubleValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeLessThan andArguments:[NSArray arrayWithObject:self.maxValue]] forField:self.name];
        return;
    }
}

@end
