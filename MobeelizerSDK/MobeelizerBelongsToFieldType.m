// 
// MobeelizerBelongsToFieldType.m
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

#import "MobeelizerBelongsToFieldType.h"
#import "MobeelizerPropertyUtil.h"
#import "MobeelizerError+Internal.h"
#import "MobeelizerErrors+Internal.h"
#import "Mobeelizer.h"
#import "MobeelizerDatabase+Internal.h"
#import "MobeelizerModelDefinition.h"

@implementation MobeelizerBelongsToFieldType

@synthesize referencedModel=_referencedModel;

- (void)copyOptions:(id)field {
    self.referencedModel = ((MobeelizerBelongsToFieldType *)field).referencedModel;
}

- (id)addOptionWithName:(NSString *)name andValue:(NSString *)value {    
    if([name isEqualToString:@"model"]) {
        self.referencedModel = value;
        return value;
    }
    return nil;
}

- (NSString *)queryForCreate {
    NSString *query = [self queryForCreateWithType:@"TEXT(36)" andDefaultValueQuoting:TRUE];    
    return [NSString stringWithFormat:@"%@ REFERENCES %@(_guid)", query, self.referencedModel];
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
    
    MobeelizerDatabase *database = [Mobeelizer database];
    
    if(![database existsByModel:[[database model:self.referencedModel] name] withGuid:value]) {
        [errors addError:[[MobeelizerError alloc] initWithCode:MobeelizerErrorCodeNotFound andArguments:[NSArray arrayWithObject:value]] forField:self.name];
    }    
}

@end
