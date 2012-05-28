// 
// MobeelizerCriteriaBuilder.m
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

#import "MobeelizerCriteriaBuilder+Internal.h"
#import "MobeelizerDatabase+Internal.h"
#import "MobeelizerOrder+Internal.h"
#import "MobeelizerCriterion+Internal.h"
#import "MobeelizerModelDefinition.h"

@interface MobeelizerCriteriaBuilder ()

@property (nonatomic, weak) MobeelizerDatabase *database;
@property (nonatomic, weak) MobeelizerModelDefinition *model;
@property (nonatomic, strong) NSMutableArray *criteria;
@property (nonatomic, strong) NSMutableArray *orders;
@property (nonatomic) NSInteger firstResult;
@property (nonatomic) NSInteger maxResults;

- (id)queryWithSelector:(SEL)selector andCount:(BOOL)count;

@end

@implementation MobeelizerCriteriaBuilder

@synthesize firstResult=_firstResult, maxResults=_maxResults, orders=_orders, criteria=_criteria, model=_model, database=_database;

- (id)initWithDatabase:(MobeelizerDatabase *)database andModel:(MobeelizerModelDefinition *)model {
    if(self = [super init]) {
        _database = database;
        _model = model;
        _criteria = [NSMutableArray array];
        _orders = [NSMutableArray array];
        _firstResult = 0;
        _maxResults = -1;        
    } 
    return self;
}

- (id)queryWithSelector:(SEL)selector andCount:(BOOL)count {
    NSMutableArray *params = [NSMutableArray array];    
    NSMutableArray *columnsBuilder = [NSMutableArray array];
    NSMutableArray *ordersBuilder = [NSMutableArray array];
    NSMutableArray *selectionsBuilder = [NSMutableArray array];
    
    [selectionsBuilder addObject:@"_deleted = 0"];
    
    for(MobeelizerCriterion *criterion in self.criteria) {
        [selectionsBuilder addObject:[criterion addToQuery:params]];
    }

    for(MobeelizerOrder *order in self.orders) {
        [ordersBuilder addObject:[order addToQuery]];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE (%@)", ([columnsBuilder count] == 0 ? @"*" : [columnsBuilder componentsJoinedByString:@", "]), self.model.name, [selectionsBuilder componentsJoinedByString:@") AND ("]];
    
    if([ordersBuilder count] > 0 && !count) {
        query = [query stringByAppendingFormat:@" ORDER BY %@", [ordersBuilder componentsJoinedByString:@", "]];
    }
    
    if(self.maxResults > 0) {
        query = [query stringByAppendingFormat:@" LIMIT %d OFFSET %d", self.maxResults, self.firstResult];
    }
    
    if(count) {
        query = [NSString stringWithFormat:@"SELECT count(*) FROM (%@)", query];
    }
    
    return [self.database execQuery:query withParams:params withModel:self.model withSelector:selector];
}

- (id)uniqueResult {
    return [self queryWithSelector:@selector(execQueryForRow:withParams:) andCount:FALSE];
}

- (NSArray *)list {
    return [self queryWithSelector:@selector(execQueryForList:withParams:) andCount:FALSE];
}

- (NSUInteger)count {
    return [[self queryWithSelector:@selector(execQueryForSingleResult:withParams:) andCount:TRUE] intValue];
}

- (MobeelizerCriteriaBuilder *)add:(MobeelizerCriterion *)criterion {
    [self.criteria addObject:criterion];
    return self;
}

- (MobeelizerCriteriaBuilder *)addOrder:(MobeelizerOrder *)order {
    [self.orders addObject:order];
    return self;
}

- (MobeelizerCriteriaBuilder *)maxResults:(NSUInteger)maxResults {
    self.maxResults = maxResults;
    return self;
}

- (MobeelizerCriteriaBuilder *)firstResult:(NSUInteger)firstResult maxResults:(NSUInteger)maxResults {
    self.firstResult = firstResult;
    self.maxResults = maxResults;
    return self;
}

@end
