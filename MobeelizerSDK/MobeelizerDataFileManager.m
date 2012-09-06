// 
// MobeelizerDataFileManager.m
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

#import "MobeelizerDataFileManager.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerDatabase+Internal.h"
#import "MobeelizerOperationError+Internal.h"

@interface MobeelizerDataFileManager ()

@property (weak) Mobeelizer *mobeelizer;

- (NSData *)readFile:(NSString *)file fromZip:(ZipFile *)zip;
- (void)writeFile:(NSString *)file withContent:(NSData *)data toZip:(ZipFile *)zip;

@end

@implementation MobeelizerDataFileManager

@synthesize mobeelizer=_mobeelizer;

- (id)initWithMobeelizer:(Mobeelizer *)mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
    }
    return self;
}

- (void)prepareOutputFile:(NSString *)dataFilePath returningError:(MobeelizerOperationError**)error {
    ZipFile *zip = nil;
    
    @try {        
        zip = [[ZipFile alloc] initWithFileName:dataFilePath mode:ZipFileModeCreate];
        
        NSData *data = [self.mobeelizer.database getEntitiesToSync];
        
        [self writeFile:@"data" withContent:data toZip:zip];
        [self writeFile:@"deletedFiles" withContent:[@"" dataUsingEncoding:NSUTF8StringEncoding] toZip:zip];
        
        NSArray *files = [self.mobeelizer.fileManager getFilesToSync];
        
        MobeelizerLog(@"Add files to sync: %d", [files count]);
        
        for(NSString *file in files) {            
            MobeelizerLog(@"Add file to sync: %@", file);
            
            NSData *fileData = [self.mobeelizer.fileManager getDataForGuid:file];
            
            if(fileData == nil) {
                continue; // @TODO V3 external storage was removed?
            }
            
            [self writeFile:file withContent:fileData toZip:zip];
        }
    } @catch (NSException * e) {
        *error = [[MobeelizerOperationError alloc] initWithException:e];
    } @finally {
        [zip close];
    }
}

- (void)processInputFile:(NSString *)dataFilePath andSyncAll:(BOOL)all returningError:(MobeelizerOperationError**)error {
    ZipFile *zip = nil;
    
    @try {        
        zip = [[ZipFile alloc] initWithFileName:dataFilePath mode:ZipFileModeUnzip];
        
        NSMutableArray *files = [NSMutableArray array];
        
        for (FileInZipInfo *file in [zip listFileInZipInfos]) {            
            if([file.name isEqualToString:@"data"] || [file.name isEqualToString:@"deletedFiles"]) {
                continue;
            }            
            [files addObject:file.name];
        }
        
        [self.mobeelizer.fileManager addFiles:files fromSync:zip];
        
        NSData *data = [self readFile:@"data" fromZip:zip];
        
        [self.mobeelizer.database updateEntitiesFromSync:data withAll:all returningError:error];
        
        if (*error != nil) {
            return;
        }
        
        NSData *deletedFiles = [self readFile:@"deletedFiles" fromZip:zip];
    
        [self.mobeelizer.fileManager deleteFilesFromSync:deletedFiles];
    } @catch (NSException * e) {
        *error = [[MobeelizerOperationError alloc] initWithException:e];
    } @finally {
        [zip close];
    }
}
         
- (void)writeFile:(NSString *)file withContent:(NSData *)data toZip:(ZipFile *)zip {
    ZipWriteStream *stream= [zip writeFileInZipWithName:file compressionLevel:ZipCompressionLevelBest];
    [stream writeData:data];
    [stream finishedWriting];
}

- (NSData *)readFile:(NSString *)file fromZip:(ZipFile *)zip {
    [zip locateFileInZip:file];
    
    FileInZipInfo *info = [zip getCurrentFileInZipInfo];    
    ZipReadStream *read= [zip readCurrentFileInZip];    
    
    NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];

    [read readDataWithBuffer:data];    
    [read finishedReading];

    return data;
}

@end
