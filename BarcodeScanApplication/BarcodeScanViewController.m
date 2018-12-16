//
//  BarcodeScanViewController.m
//  BarcodeScanApplication
//
//  Created by Галина  Муравьева on 16.12.2018.
//  Copyright © 2018 none. All rights reserved.
//

#import "BarcodeScanViewController.h"
#import "MTBBarcodeScanner.h"
#import "BarcodeScaningResultViewController.h"
@interface BarcodeScanViewController ()
@property MTBBarcodeScanner *scanner;
@end

@implementation BarcodeScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:self.previewView];
   // self.scanner = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code]
   //                                                previewView:self.previewView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
    
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            
            NSError *error = nil;
            [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
                for (AVMetadataMachineReadableCodeObject *code in codes) {
                    NSLog(@"Found code: %@", code.stringValue);
                    [self passCodeToResultViewControllerWithString: code.stringValue];
                }
                [self.scanner stopScanning];
                
            } error:&error];
            
        } else {
            [self showAlertWithMassage:@"Нет доступа к камере."];
            // The user denied access to the camera
        }
    }];
}
-(void)showAlertWithMassage:(NSString *)massage
{
    //вынести в отдельный класс
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ошибка!"
                                                                   message:massage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)passCodeToResultViewControllerWithString:(NSString *)codeString
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BarcodeScaningResultViewController * singleNewsView=[sb instantiateViewControllerWithIdentifier:@"BarcodeScaningResultViewController"];
    singleNewsView.codeString=[codeString stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]] ;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[[self navigationController] viewControllers]];
    [viewControllers removeLastObject];
    [viewControllers addObject:singleNewsView];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
