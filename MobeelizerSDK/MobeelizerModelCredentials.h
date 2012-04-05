// 
// MobeelizerModelCredentials.h
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
#import <MobeelizerSDK/Mobeelizer.h>

/**
 * Credentials for the database model and the user role.
 */

@interface MobeelizerModelCredentials : NSObject

/**
 * Credential for read operation.
 *
 * The possible values:
 *
 * - MobeelizerCredentialNone - No permission.
 * - MobeelizerCredentialOwn - Permission only for own entities.
 * - MobeelizerCredentialGroup - Permission only for group entities.
 * - MobeelizerCredentialAll - All permission.
 */
@property (nonatomic, readonly) MobeelizerCredential readAllowed;

/**
 * Credential for update operation.
 *
 * The possible values:
 *
 * - MobeelizerCredentialNone - No permission.
 * - MobeelizerCredentialOwn - Permission only for own entities.
 * - MobeelizerCredentialGroup - Permission only for group entities.
 * - MobeelizerCredentialAll - All permission.
 */
@property (nonatomic, readonly) MobeelizerCredential updateAllowed;

/**
 * Credential for create operation.
 *
 * The possible values:
 *
 * - MobeelizerCredentialNone - No permission.
 * - MobeelizerCredentialOwn - Permission only for own entities.
 * - MobeelizerCredentialGroup - Permission only for group entities.
 * - MobeelizerCredentialAll - All permission.
 */
@property (nonatomic, readonly) MobeelizerCredential createAllowed;

/**
 * Credential for delete operation.
 *
 * The possible values:
 *
 * - MobeelizerCredentialNone - No permission.
 * - MobeelizerCredentialOwn - Permission only for own entities.
 * - MobeelizerCredentialGroup - Permission only for group entities.
 * - MobeelizerCredentialAll - All permission.
 */
@property (nonatomic, readonly) MobeelizerCredential deleteAllowed;

/**
 * The flag if role has permission to the resolve conflicts.
 */
@property (nonatomic, readonly) BOOL resolveConflictAllowed;

@end
