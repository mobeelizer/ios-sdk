// 
// MobeelizerFieldDefinition+Definition.m
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

#import "MobeelizerFieldDefinition+Definition.h"
#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerFieldCredentials+Internal.h"

@implementation MobeelizerFieldDefinition (Definition)

- (id)initWithAttributes:(NSDictionary *)attributes {        
    BOOL required = [attributes objectForKey:@"required"] != nil && [[attributes objectForKey:@"required"] isEqualToString:@"true"];        
    return [self initWithName:[attributes objectForKey:@"name"] andType:[attributes objectForKey:@"type"] andRequired:required andDefaultValue:[attributes objectForKey:@"defaultValue"]];
}

- (void)addCredentials:(MobeelizerFieldCredentials *)credentials forRole:(NSString *)role {
    [self.credentials setValue:credentials forKey:role];
}

- (void)addOption:(NSString *)key withValue:(NSString *)value {
    [self.options setValue:value forKey:key];
}

- (MobeelizerFieldDefinition *)fieldForRole:(NSString *)role {
    MobeelizerFieldCredentials *credentialForRole = [self.credentials objectForKey:role];
    
    if(credentialForRole == nil || ![credentialForRole hasAccess]) {
        return nil;
    }
    
    MobeelizerFieldDefinition *fieldForRole = [[[self class] alloc] initWithName:self.name andType:self.type andRequired:self.required andDefaultValue:self.defaultValue andOptions:self.options andCredential:credentialForRole];
    
    return fieldForRole;
}

@end
