//
//  CameraViewController.m
//  Ribbit
//
//  Created by Gaurav Verma on 6/14/15.
//  Copyright (c) 2015 Shiny Mango. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@end

@implementation CameraViewController


-(UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        _imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:_imagePicker.sourceType];
    }
    return _imagePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self presentViewController:self.imagePicker animated:NO completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/


#pragma mark - Image Picker Controller Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
    
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}


@end
