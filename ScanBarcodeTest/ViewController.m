//
//  ViewController.m
//  ScanBarcodeTest
//
//  Created by baidu on 16/1/6.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prePlayer;
@property (nonatomic) BOOL isDecoding;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _isDecoding = NO;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"扫码二维码/条形码" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(100, 270, 140, 50)];
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)pressButton:(UIButton *)button
{
    [self setupCaptureSession];
    return;
}



//安装session，获取摄像头界面
- (void) setupCaptureSession {
    NSError *error = nil;
    
    //建立获取摄像头流的session
    AVCaptureSession *session = [[AVCaptureSession alloc]init];
    //设置摄像头流获取图片的清晰等级
    session.sessionPreset = AVCaptureSessionPresetHigh;
    //寻找适合的摄像硬件设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alter =[[UIAlertView alloc]initWithTitle:@"警告"
                                                      message:@"该设备不支持摄像头，无法进行二维码扫描"
                                                     delegate:self
                                            cancelButtonTitle:@"返回"
                                            otherButtonTitles: nil];
        [alter show];
        return;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        //error waiting for code
        return;
    }
    
    [session addInput:input];
    
    //设置输出流队列:必须是串行的
    dispatch_queue_t queue = dispatch_queue_create("myQueue", nil);
    
    //设置输出流并且加入session中
    //AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [session addOutput:output];
    [output setMetadataObjectsDelegate:self queue:queue];
    [output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
    
    
    //视频层显示在界面中的展示
    _prePlayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _prePlayer.frame = [[UIScreen mainScreen] bounds];
    _prePlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //添加控件到界面中去
    [self.view.layer addSublayer:_prePlayer];
    
    
    //running
    [_prePlayer.session startRunning];
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (_isDecoding) {
        return;
    }
    _isDecoding = YES;
    for (AVMetadataMachineReadableCodeObject *metadata in metadataObjects) {
        NSString * string = [NSString stringWithFormat:@"type:%@  value:%@", metadata.type, metadata.stringValue];
        NSLog(@"%@", string);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIAlertView *alter =[[UIAlertView alloc]initWithTitle:@"扫码结果"
                                                          message:string
                                                         delegate:self
                                                cancelButtonTitle:@"返回"
                                                otherButtonTitles: nil];
            [alter show];
        });
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _isDecoding = NO;
}

@end
