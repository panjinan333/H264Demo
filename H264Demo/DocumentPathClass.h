//
//  DocumentPathClass.h
//  JoystickDemo
//
//  Created by apple on 13/5/29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentPathClass : NSObject

+(NSString *)bundlePath:(NSString *)fileName;
+(NSString *)documentsPath:(NSString *)fileName;

+(NSMutableArray *) getFileArrayOfPicture;
+(NSMutableArray *) getFileArrayOfVideo;

@end
