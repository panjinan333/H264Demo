//
//  ViewController.m
//  H264Demo
//
//  Created by B1403001 on 2015/7/21.
//  Copyright (c) 2015年 B1403001. All rights reserved.
//

#import "ViewController.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libavcodec/avcodec.h"

@interface ViewController ()
{
    AVFormatContext *pFormatCtx;
    AVCodec *pCodec;
    AVPacket packet;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVPicture picture;
    struct SwsContext *img_convert_ctx;
    int nWidth, nHeight;
    int frameCount;
    int videoStream;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //decodeH264 = [[DecodeH264Class alloc] init];
    
    [self initFFMPEG];
}

-(IBAction) playURL:(id) sender
{
    if ([[sender titleLabel].text isEqualToString:@"URL"])
    {
        playTime = 1 / 30;
        
        //rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov
        //rtsp://quicktime.tc.columbia.edu:554/users/lrf10/movies/sixties.mov
        [self parserVideoFrame:@"rtsp://184.72.239.149/vod/mp4:BigBuckBunny_115k.mov"];
        
        [url setTitle:@"Stop" forState:UIControlStateNormal];
    }
    else if ([[sender titleLabel].text isEqualToString:@"Stop"])
    {
        [videoFrameTimer invalidate];
        
        [videoDecoder releaseFFMPEG];
        
        [url setTitle:@"URL" forState:UIControlStateNormal];
    }
    
}

-(void) parserVideoFrame:(NSString *) filePath
{
    frameCount = 0;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        videoDecoder = [[VideoFrameExtractor alloc] initWithVideo:filePath];
        //videoDecoder.outputWidth = imageView.frame.size.width;
        //videoDecoder.outputHeight = imageView.frame.size.height;
        NSLog(@"video size: %d x %d", videoDecoder.outputWidth, videoDecoder.outputHeight);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self playVideoAction];
        });
        
    });
}

-(void) playVideoAction
{
    //依據video實際的frame數量給予適當的播放速度
    //float playTime = videoDecoder.frameNumber / 30;
    
    videoFrameTimer = [NSTimer scheduledTimerWithTimeInterval:playTime
                                                       target:self
                                                     selector:@selector(displayNextFrame:)
                                                     userInfo:nil
                                                      repeats:YES];
}

-(void) displayNextFrame:(NSTimer *) timer
{
    if ([videoDecoder stepFrame] == 0)
    {
        frameCount = 0;
        [timer invalidate];
        return;
    }
    
    frameCountText.text = [NSString stringWithFormat:@"frame count:%d", frameCount + 1];
    
    imageView.image = videoDecoder.currentImage;
    
    frameCount++;
}

#pragma mark ============= test decode function =============

-(IBAction) playFile:(id) sender
{
    //decode file
    frameCountText.text = @"frame count:0";
    frameSizeText.text = @"frame size:0";
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"TEST8" ofType:@"MP4"];
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    
    playTime = 1;
    
    // Close the video file
    if (pFormatCtx)
        avformat_close_input(&(pFormatCtx));
    
    // Open video file - new ffmpeg 20150120
    if(avformat_open_input(&pFormatCtx, [filePath cStringUsingEncoding:NSASCIIStringEncoding], NULL, 0)!=0)
    {
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
    }
    
    // Retrieve stream information
    if(avformat_find_stream_info(pFormatCtx, 0)<0)
    {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
    }
    
    // Find the first video stream
    videoStream=-1;
    for(int i=0; i<pFormatCtx->nb_streams; i++)
    {
        //新版本ffmpeg
        if(pFormatCtx->streams[i]->codec->codec_type== AVMEDIA_TYPE_VIDEO)
        {
            videoStream=i;
            break;
        }
    }
    
    if(videoStream==-1)
    {
        av_log(NULL, AV_LOG_ERROR, "Didn't find a video stream");
    }
    
    unsigned char *arg = (unsigned char *)[data bytes];
    int length = [data length];
    
    [self decodeAndShow:arg length:length];
}

-(void)initFFMPEG
{
    // Register all formats and codecs
    //avcodec_init();
    av_register_all();
    av_init_packet(&packet);
    
    // Find the decoder for the 264
    pCodec=avcodec_find_decoder(CODEC_ID_H264);
    if(pCodec==NULL)
        goto initError; // Codec not found
    
    pCodecCtx = avcodec_alloc_context3(pCodec);
    // Open codec
    if(avcodec_open2(pCodecCtx, pCodec, 0) < 0)
        goto initError; // Could not open codec
    // Allocate video frame
    
    pFrame = avcodec_alloc_frame();
    
    pCodecCtx->width = 640;
    pCodecCtx->height = 352;
    pCodecCtx->pix_fmt = PIX_FMT_YUV420P;
    NSLog(@"init FFMpeg success");
    return;
    
initError:
    //error action
    NSLog(@"init FFMpeg failed");
    return ;
}

-(void)releaseFFMPEG
{
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx)
        avcodec_close(pCodecCtx);
}

-(void) decodeAndShow:(unsigned char *) buf length:(int) len
{
    packet.size = len;
    packet.data = buf;
    int got_picture_ptr = 0;
    int nImageSize;
    nImageSize = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture_ptr, &packet);
    NSLog(@"nImageSize:%d -- got_picture_ptr:%d", nImageSize, got_picture_ptr);
    
    if (nImageSize > 0)
    {
        frameCount = 0;
        videoFrameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(displayVideoFrame:) userInfo:nil repeats:YES];
    }
}

-(void) displayVideoFrame:(NSTimer *) timer
{
    if (pFrame->data[0])
    {
        if ([self stepFrame])
        {
            [self convertFrameToRGB];
            
            nWidth = pCodecCtx->width;
            nHeight = pCodecCtx->height;
            CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
            CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, picture.data[0], nWidth*nHeight*3,kCFAllocatorNull);
            CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGImageRef cgImage = CGImageCreate(nWidth,
                                               nHeight,
                                               8,
                                               24,
                                               nWidth*3,
                                               colorSpace,
                                               bitmapInfo,
                                               provider,
                                               NULL,
                                               YES,
                                               kCGRenderingIntentDefault);
            CGColorSpaceRelease(colorSpace);
            UIImage* image = [[UIImage alloc]initWithCGImage:cgImage];   //crespo modify 20111020
            CGImageRelease(cgImage);
            CGDataProviderRelease(provider);
            CFRelease(data);
            
            imageView.image = image;
            
            //NSLog(@"display video frame:%d", frameCount);
            
            frameCountText.text = [NSString stringWithFormat:@"frame count:%d", frameCount];
        }
        else
        {
            [timer invalidate];
            
            frameCount = 0;
            
            NSLog(@"Stop display video frame");
        }
    }
}

//解析串流裡面屬於video stream的方法
-(BOOL)stepFrame
{
    int frameFinished = 0;
    
    while(!frameFinished && av_read_frame(pFormatCtx, &packet)>=0) {
        
        //若為video stream
        if(packet.stream_index == videoStream) {
            
            // Decode video frame,並傳回video player的imageView
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
            
            frameCount++;
            
            frameSizeText.text = [NSString stringWithFormat:@"frame size:%d", packet.size];
            //NSLog(@"frame size:%d", packet.size);
        }
        
        // Free the packet that was allocated by av_read_frame
        av_free_packet(&packet);
    }
    
    //NSLog(@"frameFinished:%d", frameFinished);
    
    return frameFinished !=0;
}

-(void) setupScaler
{
    //Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    //Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, pCodecCtx->width, pCodecCtx->height);
    
    //Setup scaler
    static int sws_flags = SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     pCodecCtx->width,
                                     pCodecCtx->height,
                                     PIX_FMT_BGR24,
                                     sws_flags, NULL, NULL, NULL);
}

-(void) convertFrameToRGB
{
    [self setupScaler];
    
    sws_scale(img_convert_ctx, pFrame->data, pFrame->linesize, 0, pCodecCtx->height, picture.data, picture.linesize);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
