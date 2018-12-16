//
//  BarcodeScaningResultViewController.m
//  BarcodeScanApplication
//
//  Created by Галина  Муравьева on 16.12.2018.
//  Copyright © 2018 none. All rights reserved.
//

#import "BarcodeScaningResultViewController.h"

@interface BarcodeScaningResultViewController ()

@end

@implementation BarcodeScaningResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image=nil;
    self.label.text=@"";
    [self askDataFromServer];
    
}
-(void)askDataFromServer
{
    [self addLoader];
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.my.backgroundQueue", NULL);
    dispatch_async(concurrentQueue, ^{
        NSURL *url = [NSURL URLWithString:@"https:catalog.napolke.ru/search/catalog"];
        NSMutableDictionary *dict =@{@"text":self.codeString, @"region":[NSArray arrayWithObjects:@"0c5b2444-70a0-4932-980c-b4dc0d3f02b5",nil,nil]}.mutableCopy;
        NSError *serr;
        NSData *jsonData = [NSJSONSerialization
                            dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&serr];
        if (serr)
        {
            //error must be here
            return;
        }
        NSLog(@"Successfully generated JSON for send dictionary");
        NSLog(@"now sending this dictionary...\n%@\n\n\n", dict);
        // Create request object
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        // Set method, body & content-type
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [request setValue:
         [NSString stringWithFormat:@"%lu",
          (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        NSURLSessionDataTask *datatask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(data!=nil)
            {
                NSDictionary *respArr = [[NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&error] mutableCopy];
                NSLog(@"respArr=%@",respArr);
                
                if(respArr!=nil && ![respArr isKindOfClass:[NSNull class]])
                {
                    NSDictionary *dict;
                    BOOL hereSomeResults=NO;
                    if([respArr valueForKey:@"data"]!=nil && ![[respArr valueForKey:@"data"] isKindOfClass:[NSNull class]])
                    {
                        NSArray *dataArraay=[respArr valueForKey:@"data"];
                        @try {
                            if([dataArraay objectAtIndex:0]!=nil && ![[dataArraay objectAtIndex:0] isKindOfClass:[NSNull class]])
                            {
                                dict=[dataArraay objectAtIndex:0];
                                hereSomeResults=YES;
                            }
                            
                        } @catch (NSException *exception) {
                            
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(!hereSomeResults)
                            [self nonResultsAction];
                        else
                            [self parseResultsFromDict:dict];
                    });
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self removeLoader];
                        //alert no connection
                        [self showAlertWithMassage:@"Нет соединения."];
                        //Воврат обратно на кнопку сканирования?
                    });
                    
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self removeLoader];
                    //alert no connection
                    [self showAlertWithMassage:@"Нет соединения."];
                    //Воврат обратно на кнопку сканирования?
                });
                
            }
            
           
                
        }];
        [datatask resume];
    });
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)nonResultsAction
{
    [self removeLoader];
    
    self.imageView.image=[UIImage imageNamed:@"sad-no-results.png"];
    self.label.text=@"товар не найден!";
}
-(void)parseResultsFromDict:(NSDictionary *)dict
{
    NSString *productName=@"";
    if([dict valueForKey:@"name"]!=nil && ![[dict valueForKey:@"name"] isKindOfClass:[NSNull class]])
    {
        productName=[NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
    }
    self.label.text=productName;
    [self.label sizeToFit];
    self.label.frame=CGRectMake(self.imageView.frame.origin.x, self.label.frame.origin.y, self.imageView.frame.size.height, MIN(self.view.frame.size.height-self.label.frame.origin.y-30,self.label.frame.size.height));// ограничиваем высоты на случай длнинного текста // лучше переделать на скролл
    
    [self loadImageFromDict:dict];
}
-(void)loadImageFromDict:(NSDictionary *)dict
{
    NSString *imageUUID=@"";
    if([dict valueForKey:@"images"]!=nil && ![[dict valueForKey:@"images"] isKindOfClass:[NSNull class]])
    {
        NSArray *ar=[dict valueForKey:@"images"];
        if(ar.count>0)
        {
            if([ar objectAtIndex:0]!=nil && ![[ar objectAtIndex:0] isKindOfClass:[NSNull class]])
                imageUUID=[NSString stringWithFormat:@"%@",[[dict valueForKey:@"images"] objectAtIndex:0]];
        }
        
    }
    
    if(imageUUID.length>0)
    {
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.my.backgroundQueue", NULL);
        dispatch_async(concurrentQueue, ^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://img.napolke.ru/image/get?uuid=%@",imageUUID]]];
            if(imageData!=nil)
            {
                UIImage *image=[[UIImage alloc]initWithData:imageData];
                if([image isKindOfClass:[UIImage class]])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image=image;
                        [self removeLoader];
                    });
                }
                else
                    dispatch_async(dispatch_get_main_queue(), ^{[self setDefaultImage];});
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithMassage:@"Ошибка загрузки картинки."];
                    [self removeLoader];
                    });
                
            }
            
            
        });
       
        //load here
    }
    else{
        [self setDefaultImage];
    }
       
    
    
}
-(void)setDefaultImage
{
    [self removeLoader];
    
    UIImage *image;
    image=[UIImage imageNamed:@"default-no-image_2.png"];
    self.imageView.image=image;

}
-(void)addLoader
{
    [self removeLoader];
    UIActivityIndicatorView *spinner=[[UIActivityIndicatorView alloc] init];
    spinner.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    spinner.frame=self.imageView.bounds;
    spinner.tag=1;
    [self.imageView addSubview:spinner];
    [spinner startAnimating];
}
-(void)removeLoader
{
    [[self.imageView viewWithTag:1] removeFromSuperview];
}
@end
