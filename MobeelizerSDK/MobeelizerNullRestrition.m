// 
// MobeelizerNullRestrition.m
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

#import "MobeelizerNullRestrition.h"
#import "MobeelizerCriterion+Internal.h"

@interface MobeelizerNullRestrition ()

@property (nonatomic, strong) NSString *field;
@property (nonatomic) BOOL isNull;

@end

@implementation MobeelizerNullRestrition

@synthesize field=_field, isNull=_isNull;

- (id)initWithField:(NSString *)field andIsNull:(BOOL)isNull {
    if(self = [super init]) {
        _field = field;
        _isNull = isNull;
    }
    return self;       
}

- (NSString *)addToQuery:(NSMutableArray *)params {
    return [NSString stringWithFormat:@"%@ %@", self.field, (self.isNull ? @"IS NULL" : @"IS NOT NULL")];
}

@end
