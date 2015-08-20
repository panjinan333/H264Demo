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
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *frameCountText, *frameSizeText;
    VideoFrameExtractor *videoDecoder;
    NSTimer *videoFrameTimer;
}

-(IBAction) playVideo:(id) sender;


@end

