//
//  ViewController.m
//  BarcodeScanApplication
//
//  Created by Галина  Муравьева on 16.12.2018.
//  Copyright © 2018 none. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self navigationDesign];
    [self barcodeButtonDesign];
}
-(void)navigationDesign
{
    self.title = @"napolke";
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:28.0f],
                                                                      NSForegroundColorAttributeName: [UIColor blackColor]
                                                                      }];
    
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    self.navigationItem.backBarButtonItem.tintColor=[UIColor blackColor];
}
-(void)barcodeButtonDesign
{
    [self.scanButton setTitle:@"отсканировать штрихкод" forState:UIControlStateNormal];
    self.scanButton.titleLabel.adjustsFontSizeToFitWidth=YES;
    [self.scanButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.scanButton.backgroundColor=[UIColor colorWithRed:230.0f/255.0f
                                                    green:230.0f/255.0f
                                                     blue:230.0f/255.0f
                                                    alpha:1.0f];
    self.scanButton.titleLabel.font=[UIFont boldSystemFontOfSize:21.0f];
    self.scanButton.layer.cornerRadius=self.scanButton.frame.size.height/2;
}
- (IBAction)scanButtonPressed:(id)sender {
    //push BarcodeScanViewController in storyboard
}
@end
