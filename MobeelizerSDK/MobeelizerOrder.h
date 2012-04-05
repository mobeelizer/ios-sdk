// 
// MobeelizerOrder.h
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
 * Utility with factory methods for query order.
 */
@interface MobeelizerOrder : NSObject

/**
 * Create ascending order for the given field.
 *
 * @param field The field name.
 * @return The order.
 */
+ (MobeelizerOrder *)asc:(NSString *)field;

/**
 * Create descending order for the given field.
 *
 * @param field The field name.
 * @return The order.
 */
+ (MobeelizerOrder *)desc:(NSString *)field;

@end
