// 
// MobeelizerCriterion.m
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

#import "MobeelizerCriterion.h"
#import "MobeelizerDisjunction.h"
#import "MobeelizerConjunction.h"
#import "MobeelizerOperatorRestriction.h"
#import "MobeelizerNotRestrition.h"
#import "MobeelizerFieldRestrition.h"
#import "MobeelizerInRestrition.h"
#import "MobeelizerBelongsToRestrition.h"
#import "MobeelizerBetweenRestrition.h"
#import "MobeelizerNullRestrition.h"

@implementation MobeelizerCriterion

- (NSString *)addToQuery:(NSMutableArray *)params {
    return @"1 = 0";
}
 
+ (MobeelizerCriterion *)or:(MobeelizerCriterion *)firstCriterion, ... {
    MobeelizerDisjunction *disjunction = [[MobeelizerCriterion disjunction] add:firstCriterion];
    
    va_list args;
    va_start(args, firstCriterion);

    MobeelizerCriterion *criterion;
    
    while((criterion = va_arg(args, MobeelizerCriterion *)) != nil) {
        [disjunction add:criterion];
    }
    
    va_end(args);
    
    return disjunction;
}

+ (MobeelizerCriterion *)and:(MobeelizerCriterion *)firstCriterion, ... {
    MobeelizerConjunction *conjunction = [[MobeelizerCriterion conjunction] add:firstCriterion];
    
    va_list args;
    va_start(args, firstCriterion);
    
    MobeelizerCriterion *criterion;
    
    while((criterion = va_arg(args, MobeelizerCriterion *)) != nil) {
        [conjunction add:criterion];
    }
    
    va_end(args);
    
    return conjunction;
}
 
+ (MobeelizerCriterion *)not:(MobeelizerCriterion *)criterion {
    return [[MobeelizerNotRestrition alloc] initWithCriterion:criterion];
}

+ (MobeelizerCriterion *)guidEq:(NSString *)guid {
    if (guid == nil) {
        return [MobeelizerCriterion fieldIsNull:@"_guid"];
    }
    return [[MobeelizerOperatorRestriction alloc] initWithField:@"_guid" andOperator:@"=" andValue:guid];
}

+ (MobeelizerCriterion *)ownerEq:(NSString *)owner {
    if (owner == nil) {
        return [MobeelizerCriterion fieldIsNull:@"_owner"];
    }
    return [[MobeelizerOperatorRestriction alloc] initWithField:@"_owner" andOperator:@"=" andValue:owner];
}
 
 + (MobeelizerCriterion *)guidNe:(NSString *)guid {
     if (guid == nil) {
         return [MobeelizerCriterion fieldIsNotNull:@"_guid"];
     }
     return [[MobeelizerOperatorRestriction alloc] initWithField:@"_guid" andOperator:@"!=" andValue:guid];
}
 
+ (MobeelizerCriterion *)ownerNe:(NSString *)owner {
    if (owner == nil) {
        return [MobeelizerCriterion fieldIsNotNull:@"_owner"];
    }
    return [[MobeelizerOperatorRestriction alloc] initWithField:@"_owner" andOperator:@"!=" andValue:owner];
}

+ (MobeelizerCriterion *)isConflicted {
    return [[MobeelizerOperatorRestriction alloc] initWithField:@"_conflicted" andOperator:@"=" andValue:[NSNumber numberWithInt:1]];    
}

+ (MobeelizerCriterion *)isNotConflicted {
    return [[MobeelizerOperatorRestriction alloc] initWithField:@"_conflicted" andOperator:@"=" andValue:[NSNumber numberWithInt:0]];
}

+ (MobeelizerCriterion *)allEq:(NSDictionary *)values {
    MobeelizerConjunction *conjunction = [MobeelizerCriterion conjunction];
    
    for(NSString *field in [values keyEnumerator]) {
        id value = [values valueForKey:field];
        
        if(value == nil) {
            [conjunction add:[MobeelizerCriterion fieldIsNull:field]];
        } else {
            [conjunction add:[MobeelizerCriterion field:field eq:value]];
        }
    }
    
    return conjunction;
}
 
+ (MobeelizerCriterion *)field:(NSString *)field like:(NSString *)value {
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"like" andValue:value];
}
 
+ (MobeelizerCriterion *)field:(NSString *)field like:(NSString *)value withMatchMode:(MobeelizerMatchMode)matchMode {
    NSString *preparedValue = [value stringByReplacingOccurrencesOfString:@"?" withString:@"\\?"];
    preparedValue = [preparedValue stringByReplacingOccurrencesOfString:@"%" withString:@"\\%"];
    preparedValue = [preparedValue stringByReplacingOccurrencesOfString:@"_" withString:@"\\_"];
    preparedValue = [preparedValue stringByReplacingOccurrencesOfString:@"*" withString:@"\\*"];
    
    switch (matchMode) {
        case MobeelizerMatchModeAnywhere:
            preparedValue = [NSString stringWithFormat:@"%%%@%%", preparedValue];
            break;            
        case MobeelizerMatchModeStart:
            preparedValue = [NSString stringWithFormat:@"%@%%", preparedValue];
            break;
        case MobeelizerMatchModeEnd:
            preparedValue = [NSString stringWithFormat:@"%%%@", preparedValue];
            break;
        case MobeelizerMatchModeExact:
            break;
    }
    
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"like" andValue:preparedValue];
}

+ (MobeelizerCriterion *)field:(NSString *)field le:(id)value {
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"<=" andValue:value];
}

+ (MobeelizerCriterion *)field:(NSString *)field lt:(id)value {
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"<" andValue:value];
}
 
+ (MobeelizerCriterion *)field:(NSString *)field ge:(id)value {
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@">=" andValue:value];
}

+ (MobeelizerCriterion *)field:(NSString *)field gt:(id)value {
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@">" andValue:value];
}

+ (MobeelizerCriterion *)field:(NSString *)field ne:(id)value {
    if (value == nil) {
        return [MobeelizerCriterion fieldIsNotNull:field];
    }
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"!=" andValue:value];
}

+ (MobeelizerCriterion *)field:(NSString *)field eq:(id)value {
    if (value == nil) {
        return [MobeelizerCriterion fieldIsNull:field];
    }
    return [[MobeelizerOperatorRestriction alloc] initWithField:field andOperator:@"=" andValue:value];
 }
 

+ (MobeelizerCriterion *)field:(NSString *)field leField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@"<=" andOtherField:otherField];
}

+ (MobeelizerCriterion *)field:(NSString *)field ltField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@"<" andOtherField:otherField];    
}

 + (MobeelizerCriterion *)field:(NSString *)field geField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@">=" andOtherField:otherField];
 }

 + (MobeelizerCriterion *)field:(NSString *)field gtField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@">" andOtherField:otherField];
}
 
+ (MobeelizerCriterion *)field:(NSString *)field neField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@"!=" andOtherField:otherField];
}

 + (MobeelizerCriterion *)field:(NSString *)field eqField:(NSString *)otherField {
    return [[MobeelizerFieldRestrition alloc] initWithField:field andOperator:@"=" andOtherField:otherField];
 }

+ (MobeelizerCriterion *)fieldIsNotNull:(NSString *)field {
    return [[MobeelizerNullRestrition alloc] initWithField:field andIsNull:FALSE];
}

+ (MobeelizerCriterion *)fieldIsNull:(NSString *)field {
    return [[MobeelizerNullRestrition alloc] initWithField:field andIsNull:TRUE];    
}

+ (MobeelizerCriterion *)field:(NSString *)field between:(id)lo and:(id)hi {
    return [[MobeelizerBetweenRestrition alloc] initWithField:field andLoValue:lo andHiValue:hi];    
 }

+ (MobeelizerCriterion *)field:(NSString *)field inArray:(NSArray *) values {
    return [[MobeelizerInRestrition alloc] initWithField:field andValues:values];
}

+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntityWithClass:(Class) clazz withGuid:(NSString *)guid {
    return [[MobeelizerBelongsToRestrition alloc] initWithField:field andClazz:clazz andGuid:guid];
}

+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntityWithModel:(NSString *)model withGuid:(NSString *)guid {
    return [[MobeelizerBelongsToRestrition alloc] initWithField:field andModel:model andGuid:guid];
}

+ (MobeelizerCriterion *)field:(NSString *)field belongsToEntity:(id)entity {    
    if([entity isKindOfClass:[NSDictionary class]]) {
        return [[MobeelizerBelongsToRestrition alloc] initWithField:field andModel:[entity valueForKey:@"@model"] andGuid:[entity valueForKey:@"guid"]];
    } else {
        return [[MobeelizerBelongsToRestrition alloc] initWithField:field andClazz:[entity class] andGuid:[entity valueForKey:@"guid"]];
    }
}

+ (MobeelizerDisjunction *)disjunction {
    return [[MobeelizerDisjunction alloc] init];
}

+ (MobeelizerConjunction *)conjunction {
 return [[MobeelizerConjunction alloc] init];
}
 
@end
