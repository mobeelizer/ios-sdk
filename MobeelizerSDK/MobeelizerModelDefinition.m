// 
// MobeelizerModelDefinition.m
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
#import "MobeelizerModelCredentials+Internal.h"
#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerFieldDefinition+TypeAndQuery.h"
#import "MobeelizerErrors.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerPropertyUtil.h"

@implementation MobeelizerModelDefinition

@synthesize name=_name, clazz=_clazz, fields=_fields, credentials=_credentials, credential=_credential, clazzName=_clazzName, hasOwner=_hasOwner, hasGroup=_hasGroup, hasDeleted=_hasDeleted, hasModified=_hasModified, hasConflicted=_hasConflicted, owner=_owner, group=_group;

- (id)initWithName:(NSString *)name andClassName:(NSString *)clazzName {
    if(self = [super init]) {
        _name = name;
        _clazzName = clazzName;        
        _fields = [NSMutableArray array];
        _credentials = [NSMutableDictionary dictionary];        
        _credential = nil;
        _clazz = nil;
    }
    return self;
}

- (id)initWithName:(NSString *)name andClassName:(NSString *)clazzName andFields:(NSArray *)fields andCredential:(MobeelizerModelCredentials *)credential andOwner:(NSString *)owner andGroup:(NSString *)group {
    if(self = [super init]) {
        _name = name;
        _clazzName = clazzName;        
        _fields = fields;
        _credentials = nil;       
        _credential = credential;
        _owner = owner;
        _group = group;

        if(self.clazzName == nil) {
            _clazz = nil;
            _hasOwner = true;
            _hasGroup = true;            
            _hasModified = true;
            _hasConflicted = true;
            _hasDeleted = true;
            
            for(MobeelizerFieldDefinition *field in _fields) {
                field.cType = field.dictionaryCType;        
            }            
        } else {        
            _clazz = NSClassFromString(self.clazzName);
            
            if(self.clazz == nil) {
                MobeelizerException(@"Missing class for model", @"Cannot find class %@ for model %@.", self.clazzName, self.name);
            }
            
            NSDictionary *properties = [MobeelizerPropertyUtil classProperties:self.clazz];

            _hasOwner = [[properties allKeys] containsObject:@"owner"];
            _hasGroup = [[properties allKeys] containsObject:@"group"];            
            _hasModified = [[properties allKeys] containsObject:@"modified"];
            _hasConflicted = [[properties allKeys] containsObject:@"conflicted"];
            _hasDeleted = [[properties allKeys] containsObject:@"deleted"];        
            
            if(![[properties objectForKey:@"guid"] isEqualToString:@"NSString"]) {
                MobeelizerException(@"Missing property", @"Missing property guid with type NSString");
            }
            
            if(self.hasOwner && ![[properties objectForKey:@"owner"] isEqualToString:@"NSString"]) {
                MobeelizerException(@"Invalid property", @"Invalid property owner - wrong type, should be NSString");
            }
            
            if(self.hasGroup && ![[properties objectForKey:@"group"] isEqualToString:@"NSString"]) {
                MobeelizerException(@"Invalid property", @"Invalid property group - wrong type, should be NSString");
            }
            
            if(self.hasModified && ![[properties objectForKey:@"modified"] isEqualToString:@"c"]) {
                MobeelizerException(@"Invalid property", @"Invalid property modified - wrong type, should be BOOL");
            }
            
            if(self.hasDeleted && ![[properties objectForKey:@"deleted"] isEqualToString:@"c"]) {
                MobeelizerException(@"Invalid property", @"Invalid property deleted - wrong type, should be BOOL");
            }
            
            if(self.hasConflicted && ![[properties objectForKey:@"conflicted"] isEqualToString:@"c"]) {
                MobeelizerException(@"Invalid property", @"Invalid property conflicted - wrong type, should be BOOL");
            }
            
            for(MobeelizerFieldDefinition *field in _fields) {
                NSString *fieldType = [properties valueForKey:field.name];
                
                if(fieldType == nil || ![field.supportedCTypes containsObject:fieldType]) {
                    MobeelizerException(@"Missing property", @"Missing property %@ with type %@", field.name, field.supportedTypes)
                    return nil;
                }
                
                field.cType = fieldType;        
            }
        }
    }
    
    return self;
}

@end
