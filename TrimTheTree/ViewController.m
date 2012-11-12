//
//  ViewController.m
//  TrimTheTree
//
//  Created by T. Andrew Binkowski on 11/10/12.
//  Copyright (c) 2012 T. Andrew Binkowski. All rights reserved.
//

// TODO: Animate the star, photo picker, AlertView

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

// Class Extension (Private) ///////////////////////////////////////////////////
@interface ViewController ()
@property (strong, nonatomic) NSArray *ornamentImages;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

// Class extension methods (note they do not have to be explicitly defined, compiler will identify them)
- (void)addGestureRecognizersToOrnament:(UIView *)piece;
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)playSoundEffect:(NSString*)soundName;
@end

// Class ///////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _ornamentImages = @[@"ornament_red", @"ornament_blue", @"ornament_purple"];
    
    [self playBackgroundMusic];
    //[self animate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
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
    
    // Play sound when adding ornament
    [self playSoundEffect:@"Tink"];
}

/*******************************************************************************
 * @method          addGestureToOrnament:
 * @abstract        Add gestures to the added ornament to detect rotation, translation, and scaling
 * @description      
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

#pragma mark - Shake Detection
/*******************************************************************************
 * @method      canBecomeFirstResponder
 * @abstract    To receive motion events, the responder object that is to handle them must be the first responder.
 * @description
 *******************************************************************************/
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

/*******************************************************************************
 * @method          motionEnded:withEvent
 * @abstract
 * @description     
 ******************************************************************************/
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventTypeMotion && event.type == UIEventSubtypeMotionShake) {
        NSLog(@"%@ motionEnded", [NSDate date]);
        
        // Get the tree view (tag==100)
        UIView *tree = [self.view viewWithTag:100];
        // Remove all subviews (the ornaments) 
        for (UIView *subview in [tree subviews]) {
            [subview removeFromSuperview];
        }
        
        // Play a sound effect
        [self playSoundEffect:@"Cartoon Boing"];
    }
 }
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {}

#pragma mark - Sound Effect
/*******************************************************************************
 * @method          playSoundEffect
 * @abstract        Play a short sound when an ornament is added
 * @description     <# Description #>
 ******************************************************************************/
- (void)playSoundEffect:(NSString*)soundName
{
    NSLog(@">>> Play sound named: %@",soundName);
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"caf"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

/*******************************************************************************
 * @method      playBackgroundMusic
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)playBackgroundMusic
{
    NSError *error;
    NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:@"01 Jingle Bells" ofType:@"m4a"];
    NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
    
    _backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    [self.backgroundMusic prepareToPlay];
    [self.backgroundMusic play];
}

@end
