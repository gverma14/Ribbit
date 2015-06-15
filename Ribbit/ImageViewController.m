//
//  ImageViewController.m
//  Ribbit
//
//  Created by Gaurav Verma on 6/14/15.
//  Copyright (c) 2015 Shiny Mango. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFFile *imageFile = [self.message objectForKey:@"file"];
    NSURL *imageFileURL = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
    self.imageView.image = [UIImage imageWithData:imageData];
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.hidesBarsOnTap = YES;
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(timeout)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.hidesBarsOnTap = NO;
}


#pragma mark - Helper methods
-(void)timeout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}




@end
