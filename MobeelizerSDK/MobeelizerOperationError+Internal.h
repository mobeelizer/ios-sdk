//
// MobeelizerOperationError+Internal.h
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

#define MOBEELIZER_OPERATION_CODE_CONNECTION_FAILURE @"connectionFailure"
#define MOBEELIZER_OPERATION_CODE_MISSING_CONNECTION @"missingConnection"
#define MOBEELIZER_OPERATION_CODE_AUTHENTICATION_FAILURE @"authenticationFailure"
#define MOBEELIZER_OPERATION_CODE_SYNC_REJECTED @"syncRejected"
#define MOBEELIZER_OPERATION_CODE_OTHER @"other"

@interface MobeelizerOperationError (Internal)

- (id)initWithCode:(NSString *)code andMessage:(NSString *)message;
- (id)initWithJson:(NSDictionary *)json;
- (id)initWithException:(NSException *)exception;
- (id)initWithError:(NSError *)error;

@end
