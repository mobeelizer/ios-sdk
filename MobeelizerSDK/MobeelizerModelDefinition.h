// 
// MobeelizerModelDefinition.h
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
 * Definition of the database model.
 */

@class MobeelizerModelCredentials;

@interface MobeelizerModelDefinition : NSObject

/**
 * The name of the model.
 */
@property (nonatomic, readonly, strong) NSString *name;

/**
 * The class of the model.
 */
@property (nonatomic, readonly, strong) Class clazz;

/**
 * The list of fields.
 *
 * @see MobeelizerFieldDefinition
 */
@property (nonatomic, strong) NSArray *fields;

/**
 * The credentials for current user.
 *
 * @see MobeelizerModelCredentials
 */
@property (nonatomic, strong) MobeelizerModelCredentials *credential;

@end