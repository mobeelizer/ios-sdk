// 
// MobeelizerError.h
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

#import <Foundation/Foundation.h>

typedef enum {
    
    MobeelizerErrorCodeEmpty,
    MobeelizerErrorCodeTooLong,
    MobeelizerErrorCodeGreaterThan,
    MobeelizerErrorCodeGreaterThanOrEqualsTo,
    MobeelizerErrorCodeLessThan,
    MobeelizerErrorCodeLessThanOrEqualsTo,
    MobeelizerErrorCodeNotFound,
    NoCredentialsToPerformOperationOnModel,
    NoCredentialsToPerformOperationOnField
    
} MobeelizerErrorCode;

/**
 * Representation of the validation error.
 */

@interface MobeelizerError : NSObject

/**
 * The code of the error.
 *
 * The possible values:
 *
 * - MobeelizerErrorCodeEmpty - Value of the field can't be empty.
 * - MobeelizerErrorCodeTooLong - Value of the field is too long.
 * - MobeelizerErrorCodeGreaterThan - Value of the field is too low.
 * - MobeelizerErrorCodeGreaterThanOrEqualsTo - Value of the field is too low.
 * - MobeelizerErrorCodeLessThan - Value of the field is too high.
 * - MobeelizerErrorCodeLessThanOrEqualsTo - Value of the field is too high.
 * - MobeelizerErrorCodeNotFound - Value of the field points to not existing entity.
 */
@property(nonatomic, readonly) MobeelizerErrorCode code;

/**
 * The arguments for the message.
 */
@property(nonatomic, readonly, strong) NSArray *arguments;

/**
 * The readable message for the error.
 * 
 * @return The message for the errors.
 */
- (NSString *)message;

@end
