// 
// MobeelizerDatabase.h
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

@class Mobeelizer;
@class MobeelizerErrors;
@class MobeelizerModelDefinition;
@class MobeelizerCriteriaBuilder;

/**
 * Representation of the database.
 */
@interface MobeelizerDatabase : NSObject

/**
 * Get the definition of model for the given model.
 *
 * @param model The model model.
 * @return The definition of model.
 * @see MobeelizerModelDefinition
 */
- (MobeelizerModelDefinition *)model:(NSString *)model;

/**
 * Get all entities for the given class from the database.
 *
 * @param clazz The model class.
 * @return The list of entities.
 */
- (NSArray *)list:(Class)clazz;

/**
 * Prepare the query builder for the given class.
 *
 * @param clazz The model class.
 * @return The criteria builder.
 * @see MobeelizerCriteriaBuilder
 */
- (MobeelizerCriteriaBuilder *)find:(Class)clazz;

/**
 * Delete all entities for the given class from the database.
 *
 * @param clazz The model class.
 */
- (void)removeAll:(Class)clazz;

/**
 * Delete the entity for the given class and guid from the database.
 *
 * @param clazz The model class.
 * @param guid The guid of entity.
 */
- (void)remove:(Class)clazz withGuid:(NSString *)guid;
/**
 * Delete the given entity from the database.
 *
 * @param object The entity to remove.
 */
- (void)remove:(id)object;

/**
 * Check whether the entity for the given class and guid exist.
 *
 * @param clazz The model class.
 * @param guid The guid of entity.
 * @return TRUE if exists.
 */
- (BOOL)exists:(Class)clazz withGuid:(NSString *)guid;

/**
 * Get an entity for the given class and guid. If not found return null.
 *
 * @param clazz The model class.
 * @param guid The guid of entity.
 * @return The entity or NIL if not found.
 */
- (id)get:(Class)clazz withGuid:(NSString *)guid;

/**
 * Return the count of the entities of the given class.
 *
 * @param clazz The model class.
 * @return The number of entities.
 */
- (NSUInteger)count:(Class)clazz;

/**
 * Save the given entity in the database and return validation errors.
 *
 * Check the result of [MobeelizerErrors isValid] to confirm that save has finished with success.
 *
 * @param object The entity to save.
 * @return The validation errors.
 * @see MobeelizerErrors
 */
- (MobeelizerErrors *)save:(id)object;

@end
