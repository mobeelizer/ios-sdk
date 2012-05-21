// 
// MobeelizerTextFieldType.m
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

#import "MobeelizerTextFieldType.h"
#import "MobeelizerPropertyUtil.h"
#import "MobeelizerError+Internal.h"
#import "MobeelizerErrors+Internal.h"

@implementation MobeelizerTextFieldType

@synthesize maxLength=_maxLength;

- (void)setDefaultOptions {
    self.maxLength = [NSNumber numberWithInt:4096];
}

- (void)copyOptions:(id)field {
    self.maxLength = ((MobeelizerTextFieldType *)field).maxLength;
}

- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value {
    if([name isEqualToString:@"maxLength"]) {
        self.maxLength = [NSNumber numberWithInteger:[value integerValue]];
        return self.maxLength;
    }    
    return nil;
}

- (id)convertDefaultValueFromString:(NSString *)defaultValue {
    return defaultValue;
}

- (NSString *)queryForCreate {
    return [self queryForCreateWithType:[NSString stringWithFormat:@"TEXT(%d)", [self.maxLength intValue]] andDefaultValueQuoting:TRUE];
}

- (NSString *)convertDefaultValueToString:(id)defaultValue {
    return defaultValue;
}

- (NSArray *)supportedCTypes {
    return [NSArray arrayWithObjects:@"NSString", nil];
}

- (NSString *)dictionaryCType {
    return @"NSString";
}

- (NSString *)supportedTypes {
    return @"NSString";
}

- (void)validateTypeField:(id)object forErrors:(MobeelizerErrors *)errors {
    NSString *value = [object valueForKey:self.name];
    
    if([value length] > [self.maxLength intValue]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeTooLong andArguments:[NSArray arrayWithObject:self.maxLength]] forField:self.name];
    }
}

@end
