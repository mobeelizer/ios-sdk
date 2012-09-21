// 
// MobeelizerCriterion.h
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

@class MobeelizerDisjunction;
@class MobeelizerConjunction;

typedef enum {
    MobeelizerMatchModeAnywhere = 0,
    MobeelizerMatchModeEnd,
    MobeelizerMatchModeExact,
    MobeelizerMatchModeStart
} MobeelizerMatchMode;  

/**
 * Utility with factory methods for query criterion.
 */

@interface MobeelizerCriterion : NSObject

/**
 * Create restriction that joins the criteria with "OR" operator.
 *
 * @param firstCriterion The first criterion.
 * @param ... The other criteria.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)or:(MobeelizerCriterion *)firstCriterion, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Create restriction that joins the given criteria with "AND" operator.
 *
 * @param firstCriterion The first criterion.
 * @param ... The other criteria.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)and:(MobeelizerCriterion *)firstCriterion, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Wrap given criterion with "not" operator.
 *
 * @param criterion The criterion.
 * @return The negated criterion.
 */
+ (MobeelizerCriterion *)not:(MobeelizerCriterion *)criterion;

/**
 * Create criterion that checks if guid is equal to the given value.
 *
 * @param guid The guid.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)guidEq:(NSString *)guid;

/**
 * Create criterion that checks if owner is equal to the given value.
 *
 * @param owner The owner.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)ownerEq:(NSString *)owner;

/**
 * Create criterion that checks if group is equal to the given value.
 *
 * @param group The group.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)groupEq:(NSString *)group;

/**
 * Create criterion that checks if guid isn't equal to the given value.
 *
 * @param guid The guid.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)guidNe:(NSString *)guid;

/**
 * Create criterion that checks if owner isn't equal to the given value.
 *
 * @param owner The owner.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)ownerNe:(NSString *)owner;

/**
 * Create criterion that checks if group isn't equal to the given value.
 *
 * @param group The group.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)groupNe:(NSString *)group;

/**
 * Create criterion that checks if entity is conflicted.
 *
 * @return The criterion.
 */
+ (MobeelizerCriterion *)isConflicted;

/**
 * Create criterion that checks if entity isn't conflicted.
 *
 * @return The criterion.
 */
+ (MobeelizerCriterion *)isNotConflicted;

/**
 * Create criterion that checks if all given fields match given values.
 *
 * @param values Dictionary where the key is the field's name and the value is the expected value. 
 * @return The criterion.
 */
+ (MobeelizerCriterion *)allEq:(NSDictionary *)values;

/**
 * Create criterion that checks if field is equal (using "like" operator) to the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field like:(NSString *)value;

/**
 * Create criterion that checks if field is equal (using "like" operator) to the given value.
 *
 * The possible values of match mode:
 *
 * - MobeelizerMatchModeAnywhere - match anywhere.
 * - MobeelizerMatchModeEnd - match at the end.
 * - MobeelizerMatchModeExact - match exact value.
 * - MobeelizerMatchModeStart - match at the beginning.
 *
 * @param field The field.
 * @param value The expected value.
 * @param matchMode The matchMode.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field like:(NSString *)value withMatchMode:(MobeelizerMatchMode)matchMode;

/**
 * Create criterion that checks if field is less than or equal to the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field le:(id)value;

/**
 * Create criterion that checks if field is less than the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field lt:(id)value;

/**
 * Create criterion that checks if field is greater than or equal to the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field ge:(id)value;

/**
 * Create criterion that checks if field is greater than the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field gt:(id)value;

/**
 * Create criterion that checks if field is not equal to the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field ne:(id)value;

/**
 * Create criterion that checks if field is equal to the given value.
 *
 * @param field The field.
 * @param value The expected value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field eq:(id)value;

/**
 * Create criterion that checks if field is less than or equal to other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field leField:(NSString *)otherField;

/**
 * Create criterion that checks if field is less than other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field ltField:(NSString *)otherField;

/**
 * Create criterion that checks if field is greater than or equal to other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field geField:(NSString *)otherField;

/**
 * Create criterion that checks if field is greater than other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field gtField:(NSString *)otherField;

/**
 * Create criterion that checks if field is not equal to other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field neField:(NSString *)otherField;

/**
 * Create criterion that checks if field is equal to other field.
 *
 * @param field The field.
 * @param otherField The other field.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field eqField:(NSString *)otherField;

/**
 * Create criterion that checks if field is between the given values.
 *
 * @param field The field.
 * @param lo The low value.
 * @param hi The high value.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field between:(id)lo and:(id)hi;

/**
 * Create criterion that checks if field is in the given values.
 *
 * @param field The field.
 * @param values The values.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field inArray:(NSArray *) values;

/**
 * Create criterion that checks if field is equal to the entity for the given class and guid.
 *
 * @param field The field.
 * @param clazz The class of related entity.
 * @param guid The guid of related entity.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntityWithClass:(Class) clazz withGuid:(NSString *)guid;

/**
 * Create criterion that checks if field is equal to the entity for the given model and guid.
 *
 * @param field The field.
 * @param model The model of related entity.
 * @param guid The guid of related entity.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntityWithModel:(NSString *)model withGuid:(NSString *)guid;

/**
 * Create criterion that checks if field is equal to the given entity.
 *
 * @param field The field.
 * @param entity The related entity.
 * @return The criterion.
 */
+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntity:(id)entity;

/**
 * Create criterion that checks if field is not null.
 *
 * @param field The field. 
 * @return The criterion.
 */
+ (MobeelizerCriterion *)fieldIsNotNull:(NSString *)field;

/**
 * Create criterion that checks if field is null.
 *
 * @param field The field. 
 * @return The criterion.
 */
+ (MobeelizerCriterion *)fieldIsNull:(NSString *)field;

/**
 * Create the disjunction - (... OR ... OR ...).
 *
 * @return The disjunction.
 * @see MobeelizerDisjunction
 */
+ (MobeelizerDisjunction *)disjunction;

/**
 * Create the conjunction - (... AND ... AND ...).
 *
 * @return The conjunction.
 * @see MobeelizerConjunction
 */
+ (MobeelizerConjunction *)conjunction;

@end
