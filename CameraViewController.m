//
//  CameraViewController.m
//  Ribbit
//
//  Created by Gaurav Verma on 6/14/15.
//  Copyright (c) 2015 Shiny Mango. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
@interface CameraViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *videoFilePath;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) NSMutableArray *recipients;

@end

@implementation CameraViewController
//
-(UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = NO;
        _imagePicker.videoMaximumDuration = 5;
        
        
        
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

-(NSMutableArray *)recipients
{
    if (!_recipients) {
        _recipients = [[NSMutableArray alloc] init];
        
    }
    return _recipients;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    
    

    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void) viewWillAppear:(BOOL)animated
{
//    //[super vi:animated];
//    self.imagePicker = [[UIImagePickerController alloc] init];
//    self.imagePicker.delegate = self;
//    self.imagePicker.allowsEditing = NO;
//    self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    self.imagePicker.videoMaximumDuration = 10;
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    }
//    else {
//        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    
//    _imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    [super viewWillAppear:animated];
    
    
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
    
    if (!self.image && !self.videoFilePath) {
        
        [self.tabBarController presentViewController:self.imagePicker animated:NO completion:nil];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (![self.recipients containsObject:user.objectId]) {
        [self.recipients addObject:user.objectId];
        
    }
    else {
        [self.recipients removeObject:user.objectId];
    }
    
    [tableView reloadData];
    
    
    
   // NSLog(@"%@", self.recipients);
    
    
    
}


#pragma mark - Image Picker Controller Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
    
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSLog(@"picked media");

    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        // A photo was taken or selected
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
            
        }
        
        
    }
    else {
        
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        self.videoFilePath = [videoURL path];
        
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
            
        }
        
        
        
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];

    
}

#pragma mark - IB Actions

- (IBAction)cancel:(id)sender {
    
    [self reset];
    [self.tabBarController setSelectedIndex:0];
    
}

- (IBAction)send:(id)sender {
    
    if (self.image || [self.videoFilePath length]) {
        
        if (![self.recipients count]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again!" message:@"Please select recipients to send your message to" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            
        }
        else {
            
            [self uploadMessageWithImage:self.image videoFilePath:self.videoFilePath recipients:self.recipients];
            [self.tabBarController setSelectedIndex:0];
            
        }
        
        
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again!" message:@"Please capture or select a photo or video to share" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        
        
    }
    
}

#pragma mark - Helper methods
-(void)uploadMessageWithImage:(UIImage *)image videoFilePath:(NSString *)videoFilePath recipients:(NSArray *)recipients
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (image) {
        UIImage *newImage = [self resizeImage:image toWidth:320.0 height:480.0];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
        
        
    }
    else {
        fileData = [NSData dataWithContentsOfFile:videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
        
        
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData contentType:fileType];
    
    
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Upload File" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
            NSLog(@"%@", error);
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            
            NSLog(@"%@", recipients);
            
            [message setObject:recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:@"Please try sending your message again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                    
                }
                else {
                    //Success
                    [self reset];
                    NSLog(@"Message send success");
                }
            }];
            
            
        }
    }];
}

-(void)reset
{
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
    
}


-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width height:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
    
}
@end
