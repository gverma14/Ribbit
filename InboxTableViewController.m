//
//  InboxTableViewController.m
//  Ribbit
//
//  Created by Gaurav Verma on 6/1/15.
//  Copyright (c) 2015 Shiny Mango. All rights reserved.
//

#import "InboxTableViewController.h"
#import "ImageViewController.h"
#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InboxTableViewController ()
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end

@implementation InboxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (!currentUser) {
        
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    else {
        NSLog(@"%@", currentUser.username);
        
    }
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if ([PFUser currentUser]) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        
        
        [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"createdAt"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"%@ %@", error, [error userInfo]);
                
            }
            else {
                NSLog(@"%d Messages found", [objects count]);
                self.messages = objects;
                [self.tableView reloadData];
            }
        }];
        

        
    }
    
}


- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self.tabBarController.viewControllers[1] popToRootViewControllerAnimated:YES];
    
    
    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLogin"]) {
        [[segue.destinationViewController navigationItem] setHidesBackButton:YES animated:NO];
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    }
    else if ([segue.identifier isEqualToString:@"showImage"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    NSString *fileType = [message objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
        
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else {
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        //[self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [self.moviePlayer requestThumbnailImagesAtTimes:@[@0] timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
        
        
    }
    
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    
    if ([recipientIds count] == 1) {
        [self.selectedMessage deleteInBackground];
    }
    else {
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
        
    }
}

-(MPMoviePlayerController *)moviePlayer
{
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] init];
    }
    
    return _moviePlayer;
}



@end
