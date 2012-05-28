// 
// MobeelizerDatabase+Dictionary.h
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

#import "MobeelizerDatabase.h"

/**
 * Mobeelizer extension to worh with NSDictionary object as entities.
 */

@interface MobeelizerDatabase (Dictionary)

/**
 * Get all entities for the given model from the database.
 *
 * @param model The model.
 * @return The list of entities.
 */
- (NSArray *)listByModel:(NSString *)model;

/**
 * Prepare the query builder for the given model.
 *
 * @param model The model.
 * @return The criteria builder.
 * @see MobeelizerCriteriaBuilder
 */
- (MobeelizerCriteriaBuilder *)findByModel:(NSString *)model;

/**
 * Delete all entities for the given model from the database.
 *
 * @param model The model.
 */
- (void)removeAllByModel:(NSString *)model;

/**
 * Delete the entity for the given model and guid from the database.
 *
 * @param model The model.
 * @param guid The guid of entity.
 */
- (void)removeByModel:(NSString *)model withGuid:(NSString *)guid;

/**
 * Check whether the entity for the given model and guid exist.
 *
 * @param model The model.
 * @param guid The guid of entity.
 * @return TRUE if exists.
 */
- (BOOL)existsByModel:(NSString *)model withGuid:(NSString *)guid;

/**
 * Get an entity for the given model and guid. If not found return null.
 *
 * @param model The model.
 * @param guid The guid of entity.
 * @return The entity or NIL if not found.
 */
- (id)getByModel:(NSString *)model withGuid:(NSString *)guid;

/**
 * Return the count of the entities of the given model.
 *
 * @param model The model.
 * @return The number of entities.
 */
- (NSUInteger)countByModel:(NSString *)model;

@end
