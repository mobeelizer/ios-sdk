// 
// MobeelizerModelDefinition+Definition.m
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
#import "MobeelizerModelDefinition+Definition.h"
#import "MobeelizerFieldDefinition+Definition.h"
#import "MobeelizerModelCredentials+Internal.h"

@implementation MobeelizerModelDefinition (Definition)

- (id)initWithAttributes:(NSDictionary *)attributes andModelPrefix:(NSString *)modelPrefix {    
    NSString* nameAttribute = [attributes objectForKey:@"name"];
    NSString* name = [nameAttribute stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[nameAttribute substringToIndex:1] uppercaseString]];
    return [self initWithName:[attributes objectForKey:@"name"] andClassName:[NSString stringWithFormat:@"%@%@", modelPrefix, name]]; 
}

- (MobeelizerModelDefinition *)modelForRole:(NSString *)role {    
    MobeelizerModelCredentials *credentialForRole = [self.credentials objectForKey:role];
    
    if(credentialForRole == nil || ![credentialForRole hasAccess]) {
        return nil;
    }

    NSMutableArray *mutableFields = [NSMutableArray array];
        
    for (MobeelizerFieldDefinition *field in self.fields) {
        MobeelizerFieldDefinition *fieldForRole = [field fieldForRole:role];
            
        if(fieldForRole != nil) {
            [mutableFields addObject:fieldForRole];
        }
    }
        
    if([mutableFields count] == 0) {
        return nil;
    }
        
    return [[MobeelizerModelDefinition alloc] initWithName:self.name andClassName:self.clazzName andFields:mutableFields andCredential:credentialForRole];
}

- (void)addField:(MobeelizerFieldDefinition *)field {
    [(NSMutableArray *)self.fields addObject:field];
}

- (void)addCredentials:(MobeelizerModelCredentials *)credentials forRole:(NSString *)role {
    [self.credentials setValue:credentials forKey:role];
}

@end
