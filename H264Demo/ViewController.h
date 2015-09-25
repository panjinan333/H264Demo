//
//  ViewController.h
//  H264Demo
//
//  Created by B1403001 on 2015/7/21.
//  Copyright (c) 2015年 B1403001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoFrameExtractor.h"
#import "DocumentPathClass.h"

@interface ViewController : UIViewController
{
    IBOutlet UILabel *frameCountText, *frameSizeText;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *file, *url;
    VideoFrameExtractor *videoDecoder;
    NSTimer *videoFrameTimer;
    float playTime;
}

-(IBAction) playFile:(id) sender;

-(IBAction) playURL:(id) sender;


@end

