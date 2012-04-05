// 
// MobeelizerCriteriaBuilder.h
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

@class MobeelizerCriterion;
@class MobeelizerOrder;

/**
 * Representation of the query builder.
 *
 * Examples:
 *
 * - [query list] - list all entities.
 * - [[query maxResults:1] uniqueResult] - get the first entity.
 * - [[query add:[MobeelizerCriterion field:@"name" eq:@"xxx"]] list] - list the entities with name equals to "xxx".
 * - [[query addOrder:[MobeelizerOrder asc:@"name"]] list] - get all entities sorted ascending by name.
 * - [[query add:[MobeelizerCriterion or:[MobeelizerCriterion field:@"name" eq:@"xxx"], [MobeelizerCriterion field:@"name" eq:@"yyy"], nil]] list] - get the entities with name equals to "xxx" or "yyy". 
 */

@interface MobeelizerCriteriaBuilder : NSObject

/**
 * Find the unique entity matching to this query.
 *
 * @return The matching entity or NIL if not found.
 * @exception NSException If too many entities have been matched.
 */
- (id)uniqueResult;

/**
 * List the entities matching to this query.
 *
 * @return The matching entities.
 */
- (NSArray *)list;

/**
 * Count the entities matching to this query.
 *
 * @return The number of matching entities.
 */
- (NSUInteger)count;

/**
 * Add restriction to the query.
 *
 * @param criterion The criterion.
 * @return The criteria builder.
 * @see MobeelizerCriterion
 */
- (MobeelizerCriteriaBuilder *)add:(MobeelizerCriterion *)criterion;

/**
 * Add order to the query.
 *
 * @param order The order.
 * @return The criteria builder.
 * @see MobeelizerOrder
 */
- (MobeelizerCriteriaBuilder *)addOrder:(MobeelizerOrder *)order;

/**
 * Set the max results, by default there is no limit.
 *
 * @param maxResults The max number of matching entities.
 * @return The criteria builder.
 */
- (MobeelizerCriteriaBuilder *)maxResults:(NSUInteger)maxResults;

/**
 * Set the first result, by default the first result is equal to zero, and the max results, by default there is no limit.
 *
 * @param firstResult The number of first returned matching entity.
 * @param maxResults The max number of matching entities.
 * @return The criteria builder.
 */
- (MobeelizerCriteriaBuilder *)firstResult:(NSUInteger)firstResult maxResults:(NSUInteger)maxResults;

// @TODO query - (id)query;
// @TODO query - projection
// @TODO query -join
// @TODO query -alias

@end
