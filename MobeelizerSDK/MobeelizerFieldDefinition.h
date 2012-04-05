// 
// MobeelizerFieldDefinition.h
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

/**
 * Definition of the database model's field.
 */

@class MobeelizerFieldCredentials;

@interface MobeelizerFieldDefinition : NSObject

/**
 * The name of the field.
 */
@property (nonatomic, readonly, strong) NSString *name;

/**
 * The flag if the field is required.
 */
@property (nonatomic, readonly) BOOL required;

/**
 * The default value of the field.
 */
@property (nonatomic, readonly, strong) id defaultValue;

/**
 * The credentials for current user.
 *
 * @see MobeelizerFieldCredentials
 */
@property (nonatomic, readonly, strong) MobeelizerFieldCredentials *credential;

@end
