//
//  GalleryViewController.m
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "GalleryViewController.h"
#import "GalleryCollectionViewCell.h"
#import "LinkedImage.h"
#import "UIImage+Resize.h"
#import "NSString+Random.h"
#import "ImageDetailViewController.h"

static NSString *const kImageSegue = @"ImageDetail";

@interface GalleryViewController () <ImageDetailViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (assign, nonatomic) NSInteger currentSelectedRow;
@property (assign, nonatomic) NSInteger currentChangeableTag;
@property (assign, nonatomic) CGPoint currentSavedTapViewPosition;
@property (assign, nonatomic) BOOL isReturnTag;

@end

@implementation GalleryViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.galleryState = GalleryStateView;
    self.editButton.hidden = NO;
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Actions

- (IBAction)backButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerWillGoBack:)]){
        [self.delegate galleryViewControllerWillGoBack:self.linkedImages];
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
    if (self.galleryState == GalleryStateChange) {
        self.isReturnTag = NO;
    } else if (self.galleryState == GalleryStateSelect) {
        self.isReturnTag = YES;
    }
    
    self.galleryState = GalleryStateBackToImage;
    [self.collectionView reloadData];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentSelectedRow inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:path];
    
    self.selectLabel.hidden = YES;
    self.backButton.hidden = NO;
}

- (IBAction)editButtonAction:(id)sender
{
    self.editButton.selected = !self.editButton.selected;
    [self.collectionView reloadData];
}

#pragma mark - Navigations

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kImageSegue]) {
        
        if (self.galleryState == GalleryStateView)
        {
            ImageDetailViewController *vc = segue.destinationViewController;
            
            vc.delegate = self;
            vc.linkedImage = self.linkedImages[self.currentSelectedRow];
            
            [self imageDetailViewControllerResetNavigationInfo];
            [vc.linkedImage setHome:vc.linkedImage];
        }
        else if (self.galleryState == GalleryStateBackToImage)
        {
            ImageDetailViewController *vc = segue.destinationViewController;
            
            vc.delegate = self;
            vc.linkedImage = self.linkedImages[self.currentSelectedRow];
            
            if (self.isReturnTag) {
                vc.imageState = ImageStateEdit;
            }
            
            vc.currentPosition = self.currentSavedTapViewPosition;
            self.galleryState = GalleryStateView;
        }
        else if (self.galleryState == GalleryStateSelect || self.galleryState == GalleryStateChange)
        {
            ImageDetailViewController *vc = segue.destinationViewController;
            
            vc.delegate = self;
            vc.linkedImage = self.linkedImages[self.currentSelectedRow];
            
            self.galleryState = GalleryStateView;
            [self.collectionView reloadData];
        }
    }
    
    self.cancelButton.hidden = YES;
    self.editButton.hidden = NO;
    self.selectLabel.hidden = YES;
    self.backButton.hidden = NO;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.galleryState == GalleryStateSelect || self.galleryState == GalleryStateChange || self.editButton.selected) {
        return self.linkedImages.count;
    }
    
    return self.linkedImages.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    if (indexPath.row < self.linkedImages.count) {
        GalleryCollectionViewCell *galleryCell = [[GalleryCollectionViewCell alloc]init];
        
        galleryCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
        
        NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        LinkedImage *linkedImage = self.linkedImages[indexPath.row];
        NSString *imageName = [imagePath stringByAppendingPathComponent:linkedImage.name];
        
        UIImage *image = [UIImage imageWithContentsOfFile:imageName];
        
        galleryCell.image = [UIImage scaleImage:image toSize:CGSizeMake(70,70)];
        
        cell = galleryCell;
    } else {
        GalleryCollectionViewCell *galleryCell = [[GalleryCollectionViewCell alloc]init];
        
        galleryCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
        
        cell = galleryCell;
    }
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.galleryState == GalleryStateView) {
        if (indexPath.row >= self.linkedImages.count) {
            [self addNewImageToGallery];
        } else {
            self.currentSelectedRow = indexPath.row;

            if (self.editButton.selected) {
                [self showDeleteAlert];
            } else {
                [self performSegueWithIdentifier:kImageSegue sender:self];
            }
        }
    }
    else if (self.galleryState == GalleryStateSelect)
    {
        [self addLinkToSelectedImage:indexPath.row];
    }
    else if (self.galleryState == GalleryStateChange)
    {
        [self changeLinkToSelectedImage:indexPath.row];
    }
    else if (self.galleryState == GalleryStateBackToImage)
    {
        self.currentSelectedRow = indexPath.row;
        [self performSegueWithIdentifier:kImageSegue sender:self];
    }
}

#pragma mark - ImagePicker protocol

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    LinkedImage *linkedImage = [[LinkedImage alloc] init];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *string = [NSString generateRandomStringWithNumber:20];
    
    NSString *imageName = [imagePath stringByAppendingPathComponent:string];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    [imageData writeToFile:imageName atomically:YES];
    
    linkedImage.name = string;
    
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:self.linkedImages];
    [array addObject:linkedImage];
    
    self.linkedImages = array;
    
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerUpdatedArray:)]){
        [self.delegate galleryViewControllerUpdatedArray:self.linkedImages];
    }
    
    [self.collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)removeImage
{
    LinkedImage *image = [self.linkedImages objectAtIndex:self.currentSelectedRow];
    
    NSArray *linkingImages = [image getLinksFrom];
    
    //remove links to THIS image from other images
    for (NSString *linkingImageName in linkingImages) {
        LinkedImage *linkingImage = [self getLinkedImageModelByName:linkingImageName];
        
        [linkingImage removeLinkWithImage:image];
    }
    
    //remove linksFrom to THIS image from other images
    NSArray *linkedImages = [[image links] copy];
    
    for (NSDictionary *linkTo in linkedImages) {
        NSString *linkedImageName = [linkTo valueForKey:kImageName];
        
        LinkedImage *linkedImage = [self getLinkedImageModelByName:linkedImageName];
        [linkedImage removeLinkFromByName:image.name];
    }
    
    [self.linkedImages removeObject:image];
    
    if ([self.delegate respondsToSelector:@selector(galleryViewControllerUpdatedArray:)]){
        [self.delegate galleryViewControllerUpdatedArray:self.linkedImages];
    }
    
    [self.collectionView reloadData];
        
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [imagePath stringByAppendingPathComponent:image.name];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:imageName error:&error];
}

- (void)addLinkToSelectedImage:(NSInteger)row
{
    LinkedImage *currentEditableImage = self.linkedImages[self.currentSelectedRow];
    LinkedImage *selectedImage = self.linkedImages[row];
    
    [currentEditableImage addNewLinkWithImage:selectedImage atPoint:self.currentSavedTapViewPosition];
    [selectedImage addNewLinkFromImage:currentEditableImage];
    
    [self showSaveAlert];
}

- (void)changeLinkToSelectedImage:(NSInteger)row
{
    LinkedImage *currentEditableImage = self.linkedImages[self.currentSelectedRow];
    LinkedImage *selectedImage = self.linkedImages[row];
    
    NSString *oldImageName = [currentEditableImage getOldLinkByIndex:self.currentChangeableTag andChangeToNewImage:selectedImage];
    LinkedImage *oldImage = [self getLinkedImageModelByName:oldImageName];
    
    [oldImage removeLinkFromByName:currentEditableImage.name];
    
    [self showSaveAlert];
}

#pragma mark - ImageDetailProtocol

- (void)imageDetailViewControllerWillGoBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageDetailViewControllerSaveActionAndCGPoint:(CGPoint)point
{
    self.selectLabel.hidden = NO;
    self.backButton.hidden = YES;
    self.cancelButton.hidden = NO;
    self.currentSavedTapViewPosition = point;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.galleryState = GalleryStateSelect;
    self.editButton.hidden = YES;
    
    [self.collectionView reloadData];
}

- (LinkedImage *)getLinkedImageModelByName:(NSString *)name
{
    for (LinkedImage *linkedImage in self.linkedImages) {
        if ([linkedImage.name isEqualToString:name]) {
            return linkedImage;
        }
    }
    
    return nil;
}

- (void)imageDetailViewControllerChangedImageTo:(LinkedImage *)image
{
    for (int i = 0; i < self.linkedImages.count; i++) {
        LinkedImage *linkedImage = self.linkedImages[i];
        if ([linkedImage.name isEqualToString:image.name]) {
            self.currentSelectedRow = i;
        }
    }
}

- (void)imageDetailViewControllerChangeLinkOfImage:(LinkedImage *)image andViewTag:(NSInteger)tag
{
    self.currentChangeableTag = tag;
    self.selectLabel.hidden = NO;
    self.backButton.hidden = YES;
    self.cancelButton.hidden = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.galleryState = GalleryStateChange;
    self.editButton.hidden = YES;
    
    [self.collectionView reloadData];
}

- (void)imageDetailViewControllerResetNavigationInfo
{
    for (LinkedImage *image in self.linkedImages) {
        [image resetNavigationInfo];
    }
}

#pragma mark - Alert

-(void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message actions:(NSArray *)actions
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlert
{
    UIAlertAction *firstOkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    [self presentAlertControllerWithTitle:@"Error" message:@"ImagePicker source not available" actions:@[firstOkAction]];
}

- (void)showSaveAlert
{
    UIAlertAction *firstOkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        self.editButton.hidden = NO;
        [self performSegueWithIdentifier:kImageSegue sender:self];
    }];
    
    [self presentAlertControllerWithTitle:@"Info" message:@"Succesfully saved" actions:@[firstOkAction]];
}

- (void)showDeleteAlert
{
    UIAlertAction *firstYesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self removeImage];
    }];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    
    [self presentAlertControllerWithTitle:@"Info" message:@"Delete item?" actions:@[firstYesAction, secondAction]];
}

#pragma mark - UIImagePicker

- (void)addNewImageToGallery
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showImagePickingAlert];
    } else {
        [self initializeImagePickerGalleryStyle];
    }
}

- (void)showImagePickingAlert
{
    UIAlertAction *makeShotAction = [UIAlertAction actionWithTitle:@"Make a shot" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
       
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *fromGalleryAction = [UIAlertAction actionWithTitle:@"From gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self initializeImagePickerGalleryStyle];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
    
    [self presentAlertControllerWithTitle:@"Info" message:@"Select resource" actions:@[makeShotAction, fromGalleryAction, cancelAction]];
}

- (void)initializeImagePickerGalleryStyle
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];

        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self showAlert];
    }
}

@end
