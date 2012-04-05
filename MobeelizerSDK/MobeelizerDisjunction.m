// 
// MobeelizerDisjunction.m
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

#import "MobeelizerDisjunction.h"
#import "MobeelizerCriterion+Internal.h"

@interface MobeelizerDisjunction ()
    
@property (nonatomic, strong) NSMutableArray *criteria;    
    
@end

@implementation MobeelizerDisjunction

@synthesize criteria=_criteria;

- (id)init {
    if(self = [super init]) {
        _criteria = [NSMutableArray array];
    }
    return self;
}

- (MobeelizerDisjunction *)add:(MobeelizerCriterion *)criterion {
    [self.criteria addObject:criterion];
    return self;
}

- (NSString *)addToQuery:(NSMutableArray *)params {
    if([self.criteria count] == 0) {
        return @"1 = 1";
    }
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(MobeelizerCriterion *criterion in self.criteria) {
        [array addObject:[criterion addToQuery:params]];
    }
    
    return [NSString stringWithFormat:@"(%@)", [array componentsJoinedByString:@") or ("]];
}

@end
