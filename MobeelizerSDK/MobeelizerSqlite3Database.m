// 
// MobeelizerSqlite3Database.m
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

#import <sqlite3.h>
#import "Mobeelizer+Internal.h"
#import "MobeelizerSqlite3Database.h"

@interface MobeelizerSqlite3Database () {
    sqlite3 *database;
}

- (NSString *)dataFilePathForName:(NSString *)name;
- (void)bindParam:(id)param toStatement:(sqlite3_stmt *)statement onPosition:(int)position;
- (id)getColumnFromStatement:(sqlite3_stmt *)statement onPosition:(int)position;
- (sqlite3_stmt *)createStatementForQuery:(NSString *)query withParams:(NSArray *)params;

@end


@implementation MobeelizerSqlite3Database

- (id)initWithName:(NSString *)name {
    if(self = [super init]) {
        if(database == nil) {
            sqlite3_close(database);
            database = nil;
        }
        if (sqlite3_open([[self dataFilePathForName:name] UTF8String], &database) != SQLITE_OK) {
            [self destroy];
            MobeelizerException(@"Failed to open database", @"Failed to open database");
        }
    }  
    return self;
}

- (void)destroy {
    if(database != nil) {
        sqlite3_close(database);
        database = nil;
    }    
}

- (void)execQuery:(NSString *)query {
    MobeelizerLogSql(@"%@", query);
    
    char *errorMsg;
    
    if (sqlite3_exec (database, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) { 
        [self destroy];
        MobeelizerException(@"Error while executing query", @"Error while executing query: %@, %s", query, errorMsg);
    }
}

- (NSDictionary *)execQueryForRow:(NSString *)query withParams:(NSArray *)params {
    MobeelizerLogSql(@"%@", query);
    
    sqlite3_stmt *statement;
    
    @try {    
        statement = [self createStatementForQuery:query withParams:params];
        
        int results = sqlite3_step(statement);
        
        if (results != SQLITE_DONE && results != SQLITE_ROW) {
            MobeelizerException(@"Error while executing query", @"Error while executing query: %@, %d", query, results);       
        }
        
        if(results == SQLITE_DONE) {
            return nil;
        }
        
        NSMutableDictionary *row = [NSMutableDictionary dictionary];
        
        int columnsCount = sqlite3_column_count(statement);
        
        for(int position = 0; position < columnsCount; position++) {
            NSString *name = @((char *) sqlite3_column_name(statement, position));        
            [row setValue:[self getColumnFromStatement:statement onPosition:position] forKey:name];
        }
        
        if(sqlite3_step(statement) == SQLITE_ROW) {
            MobeelizerException(@"Error while executing query", @"Unique result expected: %@", query);
        }
        
        return row;
    } @finally {
        if(statement != nil) {
            sqlite3_finalize(statement); 
        }
    }
}

- (NSArray *)execQueryForList:(NSString *)query withParams:(NSArray *)params {
    MobeelizerLogSql(@"%@", query);
    
    sqlite3_stmt *statement;
    
    @try {
        statement = [self createStatementForQuery:query withParams:params];
        
        int results = sqlite3_step(statement);
        
        if (results != SQLITE_DONE && results != SQLITE_ROW) {
            MobeelizerException(@"Error while executing query", @"Error while executing query: %@, %d", query, results);       
        }
        
        NSMutableArray *list = [NSMutableArray array];
        
        if(results == SQLITE_DONE) {
            return list;
        }
        
        while(results == SQLITE_ROW) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            
            int columnsCount = sqlite3_column_count(statement);
            
            for(int position = 0; position < columnsCount; position++) {
                NSString *name = @((char *) sqlite3_column_name(statement, position));        
                [row setValue:[self getColumnFromStatement:statement onPosition:position] forKey:name];
            }
            
            [list addObject:row];

            results = sqlite3_step(statement);
        }
        
        return list;    
    } @finally {
        if(statement != nil) {
            sqlite3_finalize(statement); 
        }
    }
}

- (id)execQueryForSingleResult:(NSString *)query withParams:(NSArray *)params {
    MobeelizerLogSql(@"%@", query);
    
    sqlite3_stmt *statement;
    
    @try {
        statement = [self createStatementForQuery:query withParams:params];
        
        int results = sqlite3_step(statement);
        
        if (results != SQLITE_DONE && results != SQLITE_ROW) {
            MobeelizerException(@"Error while executing query", @"Error while executing query: %@, %d", query, results);
        }
        
        if(results == SQLITE_DONE) {
            return nil;
        }

        id singleResult = [self getColumnFromStatement:statement onPosition:0];
        
        return singleResult;
    } @finally {
        if(statement != nil) {
            sqlite3_finalize(statement); 
        }
    }
}

- (id)getColumnFromStatement:(sqlite3_stmt *)statement onPosition:(int)position {
    int type = sqlite3_column_type(statement, position);
    
    if(type == SQLITE_INTEGER) {
        return @(sqlite3_column_int(statement, position));
    } else if(type == SQLITE_FLOAT) {
        return [NSDecimalNumber numberWithDouble:sqlite3_column_double(statement, position)];
    } else if(type == SQLITE_NULL) {
        return nil;
    } else if(type == SQLITE_TEXT || type == SQLITE3_TEXT) {
        return @((char *)sqlite3_column_text(statement, position));
    } else {
        MobeelizerException(@"Error while getting column", @"Error while getting column: %d", type);
        return nil;
    }
}

- (sqlite3_stmt *)createStatementForQuery:(NSString *)query withParams:(NSArray *)params {
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) != SQLITE_OK) {
        MobeelizerException(@"Error while preparing query", @"Error while preparing query: %@, %s", query, sqlite3_errmsg(database));
    }
    
    int i = 1;
    
    for (id param in params) {        
        [self bindParam:param toStatement:statement onPosition:i];
        i++;
    }

    return statement;
}

- (void)execQuery:(NSString *)query withParams:(NSArray *)params {
    MobeelizerLogSql(@"%@", query);
    
    sqlite3_stmt *statement;
    
    @try {
        statement = [self createStatementForQuery:query withParams:params];
        
        int results = sqlite3_step(statement);
        
        if (results != SQLITE_DONE && results != SQLITE_ROW) {
           MobeelizerException(@"Error while executing query", @"Error while executing query: %@, %d", query, results);       
        }
    } @finally {
        if(statement != nil) {
            sqlite3_finalize(statement); 
        }
    }       
}

- (void)bindParam:(id)param toStatement:(sqlite3_stmt *)statement onPosition:(int)position {    
    if([param isKindOfClass:[NSString class]]) {
        sqlite3_bind_text(statement, position, [(NSString *)param UTF8String], -1, NULL);
    } else if([param isKindOfClass:[NSNull class]]) {
        sqlite3_bind_null(statement, position); 
    } else if([param isKindOfClass:[NSDecimalNumber class]]) {
        sqlite3_bind_double(statement, position, [(NSDecimalNumber *)param doubleValue]);     
    } else if([param isKindOfClass:[NSNumber class]]) {        
        NSNumber *number = param;
                
        if([number intValue] == [number doubleValue]) {
            sqlite3_bind_int(statement, position, [number intValue]);
        } else {
            sqlite3_bind_double(statement, position, [number doubleValue]);
        }
    } else if([param isKindOfClass:[NSDate class]]) {
        sqlite3_bind_int(statement, position, [(NSDate *)param timeIntervalSince1970]);
    } else {
        MobeelizerException(@"Error while binding param", @"Error while binding param: %@ of class %@", param, [param class]);
    }    
}

- (NSString *)dataFilePathForName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [[documentsDirectory stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"sqlite3"];
}

- (void)beginTransaction {
    MobeelizerLogSql(@"BEGIN");
    sqlite3_exec(database, "BEGIN", 0, 0, 0);
}

- (void)commitTransaction {
    MobeelizerLogSql(@"COMMIT");
    sqlite3_exec(database, "COMMIT", 0, 0, 0);    
}

- (void)rollbackTransaction {
    MobeelizerLogSql(@"ROLLBACK");
    sqlite3_exec(database, "ROLLBACK", 0, 0, 0);        
}

@end
