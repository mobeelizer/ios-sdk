//
// MobeelizerOperationError.m
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

#import "MobeelizerOperationError.h"
#import "MobeelizerOperationError+Internal.h"

@implementation MobeelizerOperationError

@synthesize code=_code, message=_message, arguments=_arguments;

- (id)initWithCode:(NSString *)code andMessage:(NSString *)message {
    if (self = [super init]) {
        _code = code;
        _message = message;
        _arguments = [NSArray array];
    }
    
    return self;
}

- (id)initWithJson:(NSDictionary *)json {
    if (self = [super init]) {
        _code = [json objectForKey:@"code"];
        _message = [json objectForKey:@"message"];
        _arguments = [json objectForKey:@"arguments"];
        if(_arguments == nil) {
            _arguments = [NSArray array];
        }
    }
    
    return self;
}

- (id)initWithException:(NSException *)exception {
    if (self = [super init]) {
        _code = MOBEELIZER_OPERATION_CODE_OTHER;
        _message = [exception description];
        _arguments = [NSArray array];
    }
    
    return self;
}

- (id)initWithError:(NSError *)error {
    if (self = [super init]) {
        _code = MOBEELIZER_OPERATION_CODE_OTHER;
        _message = [error localizedDescription];
        _arguments = [NSArray array];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"MobeelizerOperationError[%@ : %@]", self.code, self.message];
}

@end
