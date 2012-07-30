// 
// MobeelizerError.m
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

#import "MobeelizerError+Internal.h"

#define MESSAGE_MOBEELIZERERRORCODEEMPTY @"Value can't be empty."
#define MESSAGE_MOBEELIZERERRORCODETOOLONG @"Value is too long (maximum is %@ characters)."
#define MESSAGE_MOBEELIZERERRORCODEGREATERTHAN @"Value must be greater than %@."
#define MESSAGE_MOBEELIZERERRORCODEGREATERTHANOREQUALSTO @"Value must be greater than or equal to %@."
#define MESSAGE_MOBEELIZERERRORCODELESSTHAN @"Value must be less than %@."
#define MESSAGE_MOBEELIZERERRORCODELESSTHANOREQUALSTO @"Value must be less than or equal to %@."
#define MESSAGE_MOBEELIZERERRORCODENOTFOUND @"Relation '%@' must exist."
#define MESSAGE_MOBEELIZERERRORCODENOCREDENTIALSTOPERFORMOPERATIONONMODEL @"No permission to perform '%@' operation on this entity."
#define MESSAGE_MOBEELIZERERRORCODENOCREDENTIALSTOPERFORMOPERATIONONFIELD @"No permission to perform '%@' operation on field '%@'."

@interface MobeelizerError ()

- (NSString *)messageForCode;

@end

@implementation MobeelizerError

@synthesize code=_code, arguments=_arguments;

- (id)initWithCode:(MobeelizerErrorCode)code andArguments:(NSArray *)arguments {
    if(self = [super init]) {
        _code = code;
        _arguments = arguments;        
    }
    
    return self;
}

- (NSString *)message {
    return [NSString stringWithFormat:[self messageForCode], 
            (self.arguments.count > 0) ? [self.arguments objectAtIndex:0] : nil,
            (self.arguments.count > 1) ? [self.arguments objectAtIndex:1] : nil,
            (self.arguments.count > 2) ? [self.arguments objectAtIndex:2] : nil,
            (self.arguments.count > 3) ? [self.arguments objectAtIndex:3] : nil,
            (self.arguments.count > 4) ? [self.arguments objectAtIndex:4] : nil, nil];
}

- (NSString *)messageForCode {
    switch (self.code) {
        case MobeelizerErrorCodeEmpty:
            return MESSAGE_MOBEELIZERERRORCODEEMPTY;
        case MobeelizerErrorCodeTooLong:            
            return MESSAGE_MOBEELIZERERRORCODETOOLONG;
        case MobeelizerErrorCodeGreaterThan:
            return MESSAGE_MOBEELIZERERRORCODEGREATERTHAN;
        case MobeelizerErrorCodeGreaterThanOrEqualsTo:
            return MESSAGE_MOBEELIZERERRORCODEGREATERTHANOREQUALSTO;
        case MobeelizerErrorCodeLessThan:
            return MESSAGE_MOBEELIZERERRORCODELESSTHAN;
        case MobeelizerErrorCodeLessThanOrEqualsTo:
            return MESSAGE_MOBEELIZERERRORCODELESSTHANOREQUALSTO;
        case MobeelizerErrorCodeNotFound:
            return MESSAGE_MOBEELIZERERRORCODENOTFOUND;
        case NoCredentialsToPerformOperationOnModel:
            return MESSAGE_MOBEELIZERERRORCODENOCREDENTIALSTOPERFORMOPERATIONONMODEL;
        case NoCredentialsToPerformOperationOnField:
            return MESSAGE_MOBEELIZERERRORCODENOCREDENTIALSTOPERFORMOPERATIONONFIELD;
        default:
            return @"";
    }
}

@end
