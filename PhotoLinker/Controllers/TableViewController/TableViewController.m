//
//  TableViewController.m
//  PhotoLinker
//
//  Created by #50 on 10/20/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "TableViewController.h"
#import "TitleTableViewCell.h"
#import "EmptyTableViewCell.h"
#import "Gallery.h"

static NSString *const kGallerySegue = @"GallerySegue";
static NSString *const kGalleriesList = @"galleriesList";

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GalleryViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *galleries;
@property (assign, nonatomic) NSInteger currentSelectedGallery;

@end 

@implementation TableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveGalleriesList)
                                                 name:@"saveGalleries"
                                               object:nil];
    
    self.galleries = [[NSMutableArray alloc] init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    
    [self retreiveGalleriesList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor colorWithRed:36.0/255.0 green:179.0/255.0 blue:255.0/255.0 alpha:1.0]}];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.galleries.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row < self.galleries.count) {
        TitleTableViewCell *titleCell = [[TitleTableViewCell alloc] init];
        
        titleCell = [tableView dequeueReusableCellWithIdentifier:@"TitleTableViewCell" forIndexPath:indexPath];
        Gallery *gallery = self.galleries[indexPath.row];

        titleCell.title = gallery.galleryName;
        
        cell = titleCell;
    } else {
        EmptyTableViewCell *emptyCell = [[EmptyTableViewCell alloc] init];
        
        emptyCell = [tableView dequeueReusableCellWithIdentifier:@"EmptyTableViewCell" forIndexPath:indexPath];
        
        cell = emptyCell;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.galleries.count) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.galleries removeObjectAtIndex:indexPath.row];
        
        [self.tableView deleteRowsAtIndexPaths:[[NSArray alloc]initWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.galleries.count) {
        [self showAlert];
    } else {
        self.currentSelectedGallery = indexPath.row;
        [self performSegueWithIdentifier:kGallerySegue sender:self];
    }
}

#pragma mark - Private

- (void)showAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add gallery" message:@"Enter name" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.delegate = self;
    }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        Gallery *gallery = [[Gallery alloc] init];
        gallery.linkedImages = [[NSMutableArray alloc] init];
       
        UITextField *field;
        if (alertController.textFields.count > 0) {
            field = alertController.textFields[0];
        }
        
        gallery.galleryName = field.text;
       
        [self.galleries addObject:gallery];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.galleries.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
   }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)saveGalleriesList
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *galleriesToSave = [NSMutableArray new];
    
    for (Gallery *galery in self.galleries) {
        NSDictionary *galeryInfo = [galery getGalleryInfoForSave];
        [galleriesToSave addObject:galeryInfo];
    }
    
    [defaults setObject:galleriesToSave forKey:kGalleriesList];
}

- (void)retreiveGalleriesList
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *savedGalleries = [defaults valueForKey:kGalleriesList];
    
    for (NSDictionary *galleryInfo in savedGalleries) {
        Gallery *gallery = [[Gallery alloc]init];
        
        [gallery setGalleryInfoFromSaved:galleryInfo];
        
        [self.galleries addObject:gallery];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kGallerySegue]) {
        GalleryViewController *vc = segue.destinationViewController;
        
        if (self.currentSelectedGallery < self.galleries.count) {
            Gallery *gallery = self.galleries[self.currentSelectedGallery];
            vc.linkedImages = gallery.linkedImages;
        }
        
        vc.galeryIndex = self.currentSelectedGallery;
        vc.delegate = self;
    }
}

#pragma mark - GalleryViewController delegate

- (void)galleryViewControllerWillGoBack:(NSArray *)array
{
    [self galleryViewControllerUpdatedArray:array];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)galleryViewControllerUpdatedArray:(NSArray *)array
{
    Gallery *gallery = self.galleries[self.currentSelectedGallery];
    gallery.linkedImages = [array mutableCopy];
    
    [self saveGalleriesList];
}

@end
