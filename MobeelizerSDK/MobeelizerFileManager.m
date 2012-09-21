// 
// MobeelizerFileManager.m
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

#import "MobeelizerFileManager.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"
#import "MobeelizerGuidUtil.h"
#import "Mobeelizer+Internal.h"
#import "MobeelizerDatabase+Internal.h"

@interface MobeelizerFileManager ()

@property (nonatomic, weak) Mobeelizer *mobeelizer;
@property (nonatomic, weak) NSFileManager *fileManager;

- (NSString *)savaFile:(NSString *)guid withData:(NSData *)data;

@end

@implementation MobeelizerFileManager

@synthesize mobeelizer=_mobeelizer, fileManager=_fileManager;

- (id) initWithMobeelizer:(Mobeelizer *) mobeelizer {
    if(self = [super init]) {
        _mobeelizer = mobeelizer;
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)addFiles:(NSArray *)files fromSync:(ZipFile *)zip {
    MobeelizerLog(@"Add files from sync: %d", [files count]);
    
    for(NSString *guid in files) {
        if([self.mobeelizer.database isFileExists:guid]) {
            MobeelizerLog(@"Skip existing file from sync: %@", guid);
            continue;
        }
        
        MobeelizerLog(@"Add file from sync: %@", guid);
        
        [zip locateFileInZip:guid];
        
        FileInZipInfo *info = [zip getCurrentFileInZipInfo];    
        ZipReadStream *read = [zip readCurrentFileInZip];    
        
        NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];
        
        [read readDataWithBuffer:data];    
        [read finishedReading];
        
        NSString *path = [self savaFile:guid withData:data];
     
        [self.mobeelizer.database addFileFromSync:guid withPath:path];
    }
}

- (void)deleteFilesFromSync:(NSData *)deletedFiles {
    NSArray *guids = [[[NSString alloc] initWithData:deletedFiles encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
    
    for (NSString *guid in guids) {
        MobeelizerLog(@"Delete file from sync: %@", guid);
        
        NSString *path = [self.mobeelizer.database getFilePath:guid];
        
        if (path == nil) {
            continue;
        }
        
        NSError *error;
        
        if([self.fileManager removeItemAtPath:path error:&error] != YES) {
            MobeelizerLog(@"Unable to delete file: %@ - %@", path, [error localizedDescription]);
        }
        
        [self.mobeelizer.database deleteFileFromSync:guid];
    }
}

- (NSArray *)getFilesToSync {
    return [self.mobeelizer.database getFilesToSync];
}

- (NSData *)getDataForGuid:(NSString *)guid {
    NSString *path = [self.mobeelizer.database getFilePath:guid];
    
    if (path == nil) {
        return nil;
    }

    return [NSData dataWithContentsOfFile:path];
}

- (BOOL)fileExists:(NSString *)guid {
    return [self.mobeelizer.database isFileExists:guid];
}

- (NSString *)addFile:(NSData *)data {
    NSString *guid = [MobeelizerGuidUtil generateGuid];        
    NSString *path = [self savaFile:guid withData:data];
    
    [self.mobeelizer.database addFile:guid andPath:path];
    
    return guid;
}

- (NSString *)savaFile:(NSString *)guid withData:(NSData *)data {
    NSString *root = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];    
    NSString *dir = [NSString stringWithFormat:@"%@/%@/%@/", root, self.mobeelizer.instance, self.mobeelizer.user];
        
    NSError *error;
    
    if([self.fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error] != YES) {
        MobeelizerLog(@"Unable to create directory: %@ - %@", dir, [error localizedDescription]);
    }
    
    NSString *path = [dir stringByAppendingString:guid];
    
    if([self.fileManager createFileAtPath:path contents:data attributes:nil] != YES) {
        MobeelizerLog(@"Unable to create file: %@", path);
    }
    
    return path;
}

@end
