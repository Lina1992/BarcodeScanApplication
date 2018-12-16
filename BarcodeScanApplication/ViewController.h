//
//  ViewController.h
//  BarcodeScanApplication
//
//  Created by Галина  Муравьева on 16.12.2018.
//  Copyright © 2018 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
- (IBAction)scanButtonPressed:(id)sender;

@end

