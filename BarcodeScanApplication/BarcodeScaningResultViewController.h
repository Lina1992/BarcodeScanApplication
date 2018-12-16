//
//  BarcodeScaningResultViewController.h
//  BarcodeScanApplication
//
//  Created by Галина  Муравьева on 16.12.2018.
//  Copyright © 2018 none. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BarcodeScaningResultViewController : UIViewController<NSURLSessionDelegate>
@property NSString *codeString;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

NS_ASSUME_NONNULL_END
