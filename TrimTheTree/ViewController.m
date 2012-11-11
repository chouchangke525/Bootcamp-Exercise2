//
//  ViewController.m
//  TrimTheTree
//
//  Created by T. Andrew Binkowski on 11/10/12.
//  Copyright (c) 2012 T. Andrew Binkowski. All rights reserved.
//

#import "ViewController.h"

// Class Extension (Private) ///////////////////////////////////////////////////
@interface ViewController ()
@property (strong, nonatomic) NSArray *ornamentImages;
// Class extension methods (note they do not have to be explicitly defined, compiler will identify them)
- (void)addGestureRecognizersToOrnament:(UIView *)piece;
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer;
@end

// Class ///////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _ornamentImages = @[@"ornament_red", @"ornament_blue", @"ornament_purple"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Gesture Handling

/*******************************************************************************
 * @method          tapToAddOrnament
 * @abstract        Action for single tap gesture recognizer
 * @description     Add an UIImage to the parentview
 ******************************************************************************/
- (IBAction)tapToAddOrnament:(UITapGestureRecognizer *)sender
{
    NSLog(@">>>> Single Tap from %@",sender);
    UIView *tree = sender.view;
    
    CGPoint locationInView = [sender locationInView:[tree superview]];
    NSLog(@"\ntap location: x:%5.2f y:%5.2f",locationInView.x,locationInView.y);
    
    // Select a random image from our array
    int randomIndex = arc4random()%3;
    
    UIImage *image = [UIImage imageNamed:[self.ornamentImages objectAtIndex:randomIndex]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    // Scale the image down, so it is not pixelated when we scale it up
    imageView.transform = CGAffineTransformScale(imageView.transform, 0.25, 0.25);
    imageView.center = locationInView;
    imageView.userInteractionEnabled = YES;
    [tree addSubview:imageView];
    
    [self addGestureRecognizersToOrnament:imageView];
    
}

/*******************************************************************************
 * @method          addGestureToOrnament:
 * @abstract        Add gestures to the added ornament to detect rotation, translation, and scaling
 * @description     <# Description #>
 ******************************************************************************/
- (void)addGestureRecognizersToOrnament:(UIView *)piece
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
}

/*******************************************************************************
 * @method      panPiece:
 * @abstract    <# abstract #>
 * @description shift the piece's center by the pan amount
 *              reset the gesture recognizer's translation to {0, 0} after applying so the next
 *              callback is a delta from the current position
 *******************************************************************************/
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    [[piece superview] bringSubviewToFront:piece];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

/*******************************************************************************
 * @method      rotatePiece:
 * @abstract    <# abstract #>
 * @description rotate the piece by the current rotation
 *              reset the gesture recognizer's rotation to 0 after applying so
 *              the next callback is a delta from the current rotation
 *******************************************************************************/
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

/*******************************************************************************
 * @method      scalePiece
 * @abstract
 * @description Scale the piece by the current scale; reset the gesture recognizer's
 *              rotation to 0 after applying so the next callback is a delta from the current scale
 *******************************************************************************/
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

@end
