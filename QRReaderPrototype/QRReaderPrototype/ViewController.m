//
//  ViewController.m
//  QRReaderPrototype
//
//  Created by John Russel Usi on 3/9/16.
//  Copyright © 2016 CYS. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) IBOutlet UIView *readerView;
@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressHUDDismissed) name:SVProgressHUDDidDisappearNotification object:nil];
    
    [self setupReaderView];
}

- (void)setupReaderView
{
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.readerView.bounds;
    [self.readerView.layer addSublayer:previewLayer];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (input)
        [self.session addInput:input];
    else
        NSLog(@"Error %@", error);
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:output];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]];
    
    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];
    NSString *decodedString = [[metadataObjects valueForKey:@"stringValue"] objectAtIndex:0];
    [self getRequestForDecodedString:decodedString];
}

- (void)progressHUDDismissed
{
    [self.session startRunning];
}

- (void)getRequestForDecodedString:(NSString *)decodedString
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:decodedString
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        [SVProgressHUD showInfoWithStatus:@"Success"];
    }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         [SVProgressHUD showErrorWithStatus:@"Error"];
     }];
}

@end
