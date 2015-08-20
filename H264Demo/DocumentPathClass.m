//
//  DocumentPathClass.m
//  JoystickDemo
//
//  Created by apple on 13/5/29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DocumentPathClass.h"

@implementation DocumentPathClass

//專案裡的resource路徑
+(NSString *)bundlePath:(NSString *)fileName
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
}

//App document底下的路徑
+(NSString *)documentsPath:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}

//取出圖片檔案
+(NSMutableArray *) getFileArrayOfPicture
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSMutableArray *fileArray = [[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil] mutableCopy];
    NSMutableArray *fileTemp = [[NSMutableArray alloc] initWithCapacity:0];
    
    //NSLog(@"%@",fileArray);
    
    for (int i=0;i<[fileArray count];i++)
    {
        //NSLog(@"picture %c", [[fileArray objectAtIndex:i] characterAtIndex:16]);
        if ([[fileArray objectAtIndex:i] characterAtIndex:[[fileArray objectAtIndex:i] length]-3] == 'j')
        {
            [fileTemp addObject:[fileArray objectAtIndex:i]];
        }
    }
    
    return fileTemp;
}

//取出錄影檔案
+(NSMutableArray *) getFileArrayOfVideo
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSMutableArray *fileArray = [[fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil] mutableCopy];
    NSMutableArray *fileTemp = [[NSMutableArray alloc] initWithCapacity:0];
    
    //NSLog(@"%@",fileArray);
    
    for (int i=0;i<[fileArray count];i++)
    {
        //NSLog(@"video %c", [[fileArray objectAtIndex:i] characterAtIndex:16]);
        if ([[fileArray objectAtIndex:i] characterAtIndex:[[fileArray objectAtIndex:i] length]-3] == 'A')
        {
            [fileTemp addObject:[fileArray objectAtIndex:i]];
        }
    }
    
    return fileTemp;
}

@end
