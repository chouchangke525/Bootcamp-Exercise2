//
//  ViewController.m
//  TrimTheTree
//
//  Created by T. Andrew Binkowski on 11/10/12.
//  Copyright (c) 2012 T. Andrew Binkowski. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSArray *ornamentImages;
@end

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
    
}
@end
