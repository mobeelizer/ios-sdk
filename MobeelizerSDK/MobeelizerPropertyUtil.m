// 
// MobeelizerPropertyUtil.m
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

#import "objc/runtime.h"
#import "MobeelizerPropertyUtil.h"
#import "Mobeelizer+Internal.h"

@interface MobeelizerPropertyUtil ()

+ (NSString *)propertyType:(objc_property_t)property;

@end

@implementation MobeelizerPropertyUtil

+ (NSString *)propertyType:(objc_property_t)property {         
    NSString *attributesString = @(property_getAttributes(property));
    NSArray *attributes = [attributesString componentsSeparatedByString:@","];
    
    if([attributes containsObject:@"R"]) {
        MobeelizerLog(@"Invalid \"readonly\" field: %@", attributesString);
        return nil;
    }
    
    if([attributes containsObject:@"C"]) {
        MobeelizerLog(@"Invalid \"copy\" field: %@", attributesString);
        return nil;
    }
    
    if([attributes[0] hasPrefix:@"T@\""]) {
        return [attributes[0] substringWithRange:NSMakeRange(3, [attributes[0] length] - 4)];
    } else if([attributes[0] isEqualToString:@"T@"]) {
        return @"id";
    } else if([attributes[0] length] == 2) {
        return [attributes[0] substringFromIndex:1];
    } else if([attributes[0] isEqualToString:@"T{?=b8b4b1b1b18[8S]}"]) {
        return @"NSDecimal";        
    }
    
    MobeelizerLog(@"Unsupported field type for attributes: %@", attributesString);
    
    return nil;
}

+ (NSDictionary *)classProperties:(Class)clazz {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    do {
        unsigned int propertiesCount;
        
        objc_property_t *properties = class_copyPropertyList(clazz, &propertiesCount);
        
        for (int i = 0; i < propertiesCount; i++) {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                NSString *propertyName = @(propName);
                NSString *propertyType = [self propertyType:property];
                
                if(propertyType != nil) {            
                    dictionary[propertyName] = propertyType;                
                }
            }
        }
        
        free(properties);
        
        clazz = class_getSuperclass(clazz);
        
        if(clazz == nil || clazz == [NSObject class]) {
            break;
        }        
    } while (TRUE);
    
    return dictionary;
}


@end
