// 
// MobeelizerErrors.h
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
 * Holder for validation errors.
 */

@interface MobeelizerErrors : NSObject

/**
 * Check if entity is valid - doesn't contain any global or field's errors.
 *
 * @return TRUE if valid.
 */
- (BOOL)isValid;

/**
 * Check if field is valid.
 *
 * @param field Field's name.
 * @return TRUE if valid.
 */
- (BOOL)isFieldValid:(NSString *)field;

/**
 * The list of global errors.
 *
 * @return The list of errors.
 */
- (NSArray *)errors;

/**
 * The list of field's errors.
 *
 * @param field Field's name.
 * @return The list of errors.
 */
- (NSArray *)fieldErrors:(NSString *)field;

@end
