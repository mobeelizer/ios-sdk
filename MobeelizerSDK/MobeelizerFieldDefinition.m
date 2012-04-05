// 
// MobeelizerFieldDefinition.m
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

#import "MobeelizerFieldDefinition+Internal.h"
#import "MobeelizerFieldDefinition+TypeAndQuery.h"
#import "MobeelizerFieldCredentials+Internal.h"

@implementation MobeelizerFieldDefinition

@synthesize name=_name, required=_required, defaultValue=_defaultValue, type=_type, credentials=_credentials, options=_options, credential=_credential, cType=_cType;

- (id)initWithName:(NSString *)name andType:(NSString *)type andRequired:(BOOL)required andDefaultValue:(id)defaultValue {
    if(self = [super init]) {
        _name = name;
        _required = required;
        _defaultValue = defaultValue;
        _type = type;
        _credentials = [NSMutableDictionary dictionary];
        _options = [NSMutableDictionary dictionary];
        _credential = nil;
    }
    return self;
}

- (id)initWithName:(NSString *)name andType:(NSString *)type andRequired:(BOOL)required andDefaultValue:(id)defaultValue andOptions:(NSMutableDictionary *)options andCredential:(MobeelizerFieldCredentials *)credential {
    if(self = [super init]) {
        _name = name;
        _required = required;
        
        if([defaultValue isKindOfClass:[NSString class]]) {
            _defaultValue = [self convertDefaultValueFromString:defaultValue];
        } else {
            _defaultValue = defaultValue;
        }
        
        _type = type;
        _credentials = nil;
        _options = nil;
        _credential = credential;
        
        [self setDefaultOptions];
        
        for(NSString *option in [options keyEnumerator]) {
            [self addOptionWithName:option andValue:[options valueForKey:option]];
        }
    }
    return self;
}

@end
