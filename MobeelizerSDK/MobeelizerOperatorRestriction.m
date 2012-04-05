// 
// MobeelizerOperatorRestriction.m
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

#import "MobeelizerOperatorRestriction.h"
#import "MobeelizerCriterion+Internal.h"

@interface MobeelizerOperatorRestriction ()

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSString *op;
@property (nonatomic, strong) id value;

@end

@implementation MobeelizerOperatorRestriction

@synthesize field=_field, op=_op, value=_value;

- (id)initWithField:(NSString *)field andOperator:(NSString *)op andValue:(id)value {
    if(self = [super init]) {
        _field = field;
        _op = op;
        _value = value;
    }
    return self;      
}

- (NSString *)addToQuery:(NSMutableArray *)params {
    [params addObject:self.value];
    return [NSString stringWithFormat:@"%@ %@ ?", self.field, self.op];
}

@end
