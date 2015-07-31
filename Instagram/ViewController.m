//
//  ViewController.m
//  Instagram
//
//  Created by MS on 7/28/15.
//  Copyright (c) 2015 Sarbasov inc. All rights reserved.
//



#import "ViewController.h"
#import "AuthViewController.h"
#import "DataAPI.h"
#import "InstagramCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIProgressView+AFNetworking.h"
#import "AFNetworking/AFNetworking.h"
#import "Photo.h"
#import "Errors.h"
#import "Comment.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

@property (strong, nonatomic) NSString *currentLogin;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSMutableArray *data;


@property (nonatomic) BOOL loadingFlag;
@end

@implementation ViewController

- (NSMutableArray *)data
{
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.loadingView.hidden = YES;
    self.errorLabel.hidden = YES;
    
    self.tableView.estimatedRowHeight = 400.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}



- (void)viewDidAppear:(BOOL)animated
{
    //authorize if no access token
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessToken"];
    if (!accessToken) {
        AuthViewController *authVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"AuthViewController"];
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:authVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    }
    NSLog(@"Access token: %@", accessToken);

}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    InstagramCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"InstagramCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    Photo *photo = self.data[[indexPath row]];


    //set comments label
    
    NSMutableAttributedString *attributedCommentsString = [[NSMutableAttributedString alloc] init];
    for (Comment *comment in photo.comments) {
        NSAttributedString *author = [[NSAttributedString alloc] initWithString:comment.author attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];

        NSAttributedString *text = [[NSAttributedString alloc] initWithString:comment.text attributes:nil];
        
        
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithAttributedString:author];
        [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        [commentString appendAttributedString:text];
        
        [attributedCommentsString appendAttributedString:commentString];
        [attributedCommentsString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    [attributedCommentsString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:14.0] range:NSMakeRange(0, [attributedCommentsString length])];
    
    cell.commentsLabel.attributedText = attributedCommentsString;
    //cell.commentsLabel.text = [attributedCommentsString string];
    
    
    //download and set image view
    cell.photoView.backgroundColor = [UIColor lightGrayColor];
    
    [[DataAPI sharedManager] getImageByURL:photo.imageURL
                                   progressView:cell.progressView
                                      onSuccess:^(UIImage *image) {
        cell.photoView.image = image;
        cell.progressView.hidden = YES;
    } onFailure:^(NSError *error) {
        NSLog(@"Error loading image: %@", error);
    }];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.data count]) {
        Photo *photo = [self.data objectAtIndex:[indexPath row]];
        [[DataAPI sharedManager] cancelLoadingImageByURL:photo.imageURL];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == [tableView numberOfRowsInSection:0] - 1) && (!self.loadingFlag)) {
        self.loadingFlag = YES;
        [self getNextPortionOfData];
        
    }
}




#pragma mark - Search Bar

- (void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = self.currentLogin;
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *login = searchBar.text;
    [searchBar resignFirstResponder];
    [self changeUserTo: login];
}

#pragma mark - Getting Data

- (void)changeUserTo: (NSString *)login
{
    if (![login isEqualToString:self.currentLogin]) {
        [self.data removeAllObjects];
        [self.tableView reloadData];
        self.currentLogin = login;
        self.loadingView.hidden = NO;
        self.errorLabel.hidden = YES;
        
        [[DataAPI sharedManager] getUserIDOfLogin:login onSuccess:^(NSString *UserID) {
            self.userID = UserID;
            [self getDataForUserID:UserID];
            
        } onFailure:^(NSError *error) {
            NSLog(@"%@", error);
            self.loadingView.hidden = YES;
            [self showError: error];
        }];
    }
}

- (void)getDataForUserID: (NSString *)UserID
{
    [[DataAPI sharedManager] getNextPortionOfImageAndCommentsOfUserID:UserID onSuccess:^(NSArray *result) {
        self.data = [result mutableCopy];
        [self.tableView reloadData];
        self.loadingView.hidden = YES;
    } onFailure:^(NSError *error) {
        NSLog(@"%@", error);
        
        self.loadingView.hidden = YES;
        [self showError:error];
    }];
}

- (void)getNextPortionOfData
{
    [[DataAPI sharedManager] getNextPortionOfImageAndCommentsOfUserID:self.userID onSuccess:^(NSArray *result) {
        [self.data addObjectsFromArray:result];
        

        [self.tableView reloadData];
        self.loadingFlag = NO;
    } onFailure:^(NSError *error) {
        NSLog(@"%@", error);
        self.loadingFlag = NO;
    }];
}

- (void)showError: (NSError *)error
{
    NSString *errorText = @"";
    switch (error.code) {
        case MSInvalidAccessToken:
            errorText = @"Invalid access token";
            break;
            
        case MSUserNotFound:
            errorText = @"User not found";
            break;
        
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorCannotConnectToHost:
            errorText = @"No internet connection";
            break;
        
        case MSNoMorePhotos:
            errorText = @"No photos yet";
            break;
            
        default:
            errorText = @"Unknown error";
            break;
    }
    
    self.errorLabel.text = errorText;
    self.errorLabel.hidden = NO;

}

@end
