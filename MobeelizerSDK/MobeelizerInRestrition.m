// 
// MobeelizerInRestrition.m
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

#import "MobeelizerInRestrition.h"
#import "MobeelizerCriterion+Internal.h"

@interface MobeelizerInRestrition ()

@property (nonatomic, strong) NSString *field;
@property (nonatomic, strong) NSArray *values;

@end

@implementation MobeelizerInRestrition

@synthesize field=_field, values=_values;

- (id)initWithField:(NSString *)field andValues:(NSArray *)values {
    if(self = [super init]) {
        _field = field;
        _values = values;
    }
    return self;      
}

- (NSString *)addToQuery:(NSMutableArray *)params {
    if([self.values count] == 0) {
        return @"1 = 1";
    }    
    
    [params addObjectsFromArray:self.values];     
    
    NSMutableString *string = [NSMutableString string]; 
                               
    [string appendFormat:@"%@ IN (", self.field];
    
    for (int i = 0; i < [self.values count]; i++) {
        if(i > 0) {
            [string appendString:@", "];
        }
        [string appendString:@"?"];
    }
    
    [string appendString:@")"];
    
    return string;
}

@end
