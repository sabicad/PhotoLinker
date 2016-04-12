//
//  ImageDetailViewController.m
//  PhotoLinker
//
//  Created by #50 on 10/21/15.
//  Copyright © 2015 #50. All rights reserved.
//

#import "ImageDetailViewController.h"

#define kDefineBottomBarNotHiddenConstant 0.0
#define kDefineBottomBarHiddenConstant -44.0

@interface ImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomBarBottom;
@property (weak, nonatomic) IBOutlet UIButton *prevImageButton;
@property (weak, nonatomic) IBOutlet UIButton *nextImageButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *viewUnderImage;

@property (strong, nonatomic) UITapGestureRecognizer *imageTapRecognizer;
@property (strong, nonatomic) UITapGestureRecognizer *viewTapRecognizer;

@property (strong, nonatomic) UIView *currentView;

@property (strong, nonatomic) NSMutableArray *storedViews;

@end

@implementation ImageDetailViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.storedViews = [NSMutableArray new];
    
    self.imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    self.viewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadMainImage];
    [self showZones];
    [self setPrevNextButton];
    
    [self.imageView addGestureRecognizer:self.imageTapRecognizer];
    [self.viewUnderImage addGestureRecognizer:self.viewTapRecognizer];
    
    if (self.imageState == ImageStateEdit) {
        self.editButton.selected = YES;
        self.saveButton.hidden = NO;
        
        [self addCurrentFrameView];
        
        self.imageState = ImageStateView;
        
        self.constraintBottomBarBottom.constant = kDefineBottomBarHiddenConstant;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView removeGestureRecognizer:self.imageTapRecognizer];
    [self.viewUnderImage removeGestureRecognizer:self.viewTapRecognizer];
}


#pragma mark - Private

- (void)changeMainImageTo:(LinkedImage *)image
{
    if (image) {
        [self removeStoredViews];
        
        self.linkedImage = image;
        
        if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerChangedImageTo:)]) {
            [self.delegate imageDetailViewControllerChangedImageTo:image];
        }
        
        [self loadMainImage];
        [self showZones];
        [self setPrevNextButton];
    }
}

- (void)loadMainImage
{
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageName = [imagePath stringByAppendingPathComponent:self.linkedImage.name];
    
    self.imageView.image = [UIImage imageWithContentsOfFile:imageName];
}

- (void)removeSelectedLink
{
    NSInteger linkNumber = [self.currentView tag];
    
    NSString *imageToGoName = [self.linkedImage imageToGo:linkNumber];
    LinkedImage *destinationImage = [self.delegate getLinkedImageModelByName:imageToGoName];
    
    [self.linkedImage removeLinkWithImage:destinationImage byIndex:linkNumber];
    
    [self.storedViews removeObjectAtIndex:linkNumber];
    
    for (int i = (int)linkNumber; i < [self.storedViews count]; i++) {
        UIView *linkView = self.storedViews[i];
        
        linkView.tag--;
    }
    
    [self.currentView removeFromSuperview];
}

- (void)removeStoredViews
{
    for (UIView *storedLinkView in self.storedViews) {
        [storedLinkView removeFromSuperview];
    }
    
    [self.storedViews removeAllObjects];
}

- (void)setPrevNextButton
{
    if ([self.linkedImage getNext]) {
        self.nextImageButton.hidden = NO;
    } else {
        self.nextImageButton.hidden = YES;
    }
    
    if ([self.linkedImage getPrev]) {
        self.prevImageButton.hidden = NO;
    } else {
        self.prevImageButton.hidden = YES;
    }
}

#pragma mark - TappedViews

- (void)addNewTappedView:(UITapGestureRecognizer *)sender
{
    if (self.editButton.selected) {
        CGPoint tappedPoint = [sender locationInView:self.viewUnderImage];
        
        CGSize imageSize = self.imageView.image.size;
        CGFloat imageScale = fminf(CGRectGetWidth(self.imageView.bounds)/imageSize.width, CGRectGetHeight(self.imageView.bounds)/imageSize.height);
        CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
        CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(self.imageView.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(self.imageView.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
        
        if ( CGRectContainsPoint(imageFrame, tappedPoint)) {
            self.currentPosition = tappedPoint;
            
            [self removeCurrentFrameView];
            [self addCurrentFrameView];
            
            self.saveButton.hidden = NO;
        }
    }
}

- (void)goToTappedViewLinkedImage:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.viewUnderImage];
    UIView *tappedView = [self.viewUnderImage hitTest:point withEvent:nil];
    
    NSString *imageToGoName = [self.linkedImage imageToGo:tappedView.tag];
    
    [self removeStoredViews];
    
    if ([self.delegate respondsToSelector:@selector(getLinkedImageModelByName:)]) {
        LinkedImage *receivedImage = [self.delegate getLinkedImageModelByName:imageToGoName];
        
        [self.linkedImage setNext:receivedImage];
        [receivedImage setPrev:self.linkedImage];
        [receivedImage copyHomeImageFromImage:self.linkedImage];
        
        [self changeMainImageTo:receivedImage];
    }
}

- (void)showChangesForTappedView:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.viewUnderImage];
    UIView *tappedView = [self.viewUnderImage hitTest:point withEvent:nil];
    
    if (tappedView != self.currentView) {
        
        [self.currentView removeFromSuperview];
        self.currentView = tappedView;
        self.currentPosition = CGPointMake(tappedView.frame.origin.x + kTagViewToOriginX, tappedView.frame.origin.y + kTagViewToOriginY);
        
        [self showActionSheet];
    }
}

- (void)addCurrentFrameView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.currentPosition.x - kTagViewToOriginX, self.currentPosition.y - kTagViewToOriginY, kTagViewWidth, kTagViewHeight)];
    view.backgroundColor = [UIColor clearColor];
    
    view.layer.borderWidth = 2.0;
    view.layer.borderColor = [[UIColor colorWithRed:36.0/255.0 green:179.0/255.0 blue:255.0/255.0 alpha:1.0] CGColor];
    
    self.currentView = view;
    
    [self.viewUnderImage addSubview:view];
}

- (void)removeCurrentFrameView
{
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        self.currentView = nil;
    }
}

- (void)showZones
{
    NSInteger tag = 0;
    
    for (NSDictionary *link in [self.linkedImage links]){
        
        float x = [[link valueForKey:kx] floatValue];
        float y = [[link valueForKey:ky] floatValue];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x - kTagViewToOriginX, y - kTagViewToOriginY, kTagViewWidth, kTagViewHeight)];
        view.backgroundColor = [UIColor clearColor];
        
        view.layer.borderWidth = 2.0;
        view.layer.borderColor = [[UIColor colorWithRed:36.0/255.0 green:179.0/255.0 blue:255.0/255.0 alpha:1.0] CGColor];
        view.tag = tag;
        tag++;
        view.userInteractionEnabled = YES;
        
        [self.storedViews addObject:view];
        
        [self.viewUnderImage addSubview:view];
    }
}

#pragma mark - Actions

- (IBAction)backButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillGoBack)]) {
        [self.delegate imageDetailViewControllerWillGoBack];
    }
}

- (IBAction)editButtonAction:(id)sender
{
    self.editButton.selected = !self.editButton.selected;
    
    if (self.editButton.selected) {
        [self launchBottomBarAnimationWithValue:kDefineBottomBarNotHiddenConstant];
    } else {
        [self launchBottomBarAnimationWithValue:kDefineBottomBarHiddenConstant];
    }
    
    self.saveButton.hidden = YES;
    
    [self removeCurrentFrameView];
}

- (IBAction)saveButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillGoBack)]) {
        [self.delegate imageDetailViewControllerSaveActionAndCGPoint:self.currentPosition];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)sender
{
    if (sender == self.imageTapRecognizer) {
        [self addNewTappedView:sender];
    } else if (sender == self.viewTapRecognizer) {
       if (self.editButton.selected) {
           [self showChangesForTappedView:sender];
       } else {
          [self goToTappedViewLinkedImage:sender];
       }
   }
}

- (IBAction)prevImageAction:(id)sender
{
    [self changeMainImageTo:[self.linkedImage getPrev]];
}

- (IBAction)nextImageAction:(id)sender
{
    [self changeMainImageTo:[self.linkedImage getNext]];
}

- (IBAction)homeImageAction:(id)sender
{
    [self changeMainImageTo:[self.linkedImage getHomeImage]];
    if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerResetNavigationInfo)]) {
        [self.delegate imageDetailViewControllerResetNavigationInfo];
    }
    [self.linkedImage setHome:self.linkedImage];
    [self setPrevNextButton];
}

#pragma mark - Animations

- (void)launchBottomBarAnimationWithValue:(CGFloat)value
{
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:.6
                     animations:^{
                         self.constraintBottomBarBottom.constant = value == kDefineBottomBarNotHiddenConstant ? kDefineBottomBarHiddenConstant : kDefineBottomBarNotHiddenConstant;
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark - Alert

- (void)showActionSheet
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Changes" message:@"Select changes" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"Change link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerChangeLinkOfImage:andViewTag:)]) {
                                           [self.delegate imageDetailViewControllerChangeLinkOfImage:self.linkedImage andViewTag:self.currentView.tag];
                                       }
                                   }];
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove link" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       [self removeSelectedLink];
                                   }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                   {
                                       self.currentView = nil;
                                       self.currentPosition = CGPointMake(0, 0);
                                       self.editButton.selected = !self.editButton.selected;
                                       self.saveButton.hidden = YES;
                                       [self launchBottomBarAnimationWithValue:kDefineBottomBarHiddenConstant];
                                   }];
    
    [alertController addAction:changeAction];
    [alertController addAction:removeAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
