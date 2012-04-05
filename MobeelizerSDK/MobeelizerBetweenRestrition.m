// 
// MobeelizerBetweenRestrition.m
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

#import "MobeelizerBetweenRestrition.h"
#import "MobeelizerCriterion+Internal.h"

@interface MobeelizerBetweenRestrition ()

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) id lo;
@property (nonatomic, strong) id hi;

@end

@implementation MobeelizerBetweenRestrition

@synthesize field=_field, lo=_lo, hi=_hi;

- (id)initWithField:(NSString *)field andLoValue:(id)lo andHiValue:(id)hi {
    if(self = [super init]) {
        _field = field;
        _lo = lo;
        _hi = hi;
    }
    return self;      
}

- (NSString *)addToQuery:(NSMutableArray *)params {
    [params addObject:self.lo];
    [params addObject:self.hi];
    return [NSString stringWithFormat:@"%@ BETWEEN ? AND ?", self.field];
}

@end
