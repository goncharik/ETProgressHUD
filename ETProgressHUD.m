//
//  ETProgressHUD.m
//  ContinueDownloadExample
//
//  Created by Zhenia on 12/26/12.
//  Copyright (c) 2012 Tulusha.com. All rights reserved.
//

#import "ETProgressHUD.h"
#import "ETCircledProgressView.h"
#import <QuartzCore/QuartzCore.h>


static CGFloat const ETProgressHUDRingRadius    = 21;
static CGFloat const ETProgressHUDRingThickness = 8;

#define ETDegreesToRadians(x) (M_PI * x / 180.0)

@interface ETProgressHUD ()

#pragma mark - Ring animation properties

@property (nonatomic, strong) CAShapeLayer *backgroundRingLayer;
@property (nonatomic, strong) ETCircledProgressView *circledIndicator;

- (void)show;
- (void)hideAfterDelay;
- (void)hide;
- (void)hidden;
- (void)showSpinner;

- (void)updateCircledProgressIndicator;

- (void)setProperRotation;
- (void)setProperRotation:(BOOL)animated;

@end

@implementation ETProgressHUD

@synthesize centerMessageLabel, subMessageLabel;
@synthesize spinner;

static ETProgressHUD *currentHUD = nil;

+ (ETProgressHUD *)currentHUD
{
    if (currentHUD == nil)
    {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];

        CGFloat width = 160;
        CGFloat height = 160;
        CGRect centeredFrame = CGRectMake(round(keyWindow.bounds.size.width/2 - width/2),
                round(keyWindow.bounds.size.height/2 - height/2),
                width,
                height);

        currentHUD = [[ETProgressHUD alloc] initWithFrame:centeredFrame];

        currentHUD.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        currentHUD.backgroundColor = [UIColor clearColor];
        currentHUD.opaque = NO;
        currentHUD.alpha = 0;

        currentHUD.userInteractionEnabled = NO;
        currentHUD.autoresizesSubviews = YES;
        currentHUD.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;

        [currentHUD setProperRotation:NO];

        [[NSNotificationCenter defaultCenter] addObserver:currentHUD
                                                 selector:@selector(setProperRotation)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }

    return currentHUD;
}

#pragma mark - Deallocation and Initialization

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Creating Message

- (void)show
{
    if ([self superview] != [[UIApplication sharedApplication] keyWindow])
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];

    self.alpha = 1;

    [UIView commitAnimations];
}

- (void)hideAfterDelay
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.6];
}

- (void)hide
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hidden)];

    self.alpha = 0;

    [UIView commitAnimations];
}

- (void)persist
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.1];

    self.alpha = 1;

    [UIView commitAnimations];
}

- (void)hidden
{
    if (self.alpha > 0)
        return;

    [currentHUD removeFromSuperview];
    currentHUD = nil;
}

- (void)setCenterMessage:(NSString *)message
{
    if (message == nil && centerMessageLabel != nil)
        self.centerMessageLabel = nil;

    else if (message != nil)
    {
        if (centerMessageLabel == nil)
        {
            self.centerMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,round(self.bounds.size.height/2-50/2),self.bounds.size.width-24,50)];
            centerMessageLabel.backgroundColor = [UIColor clearColor];
            centerMessageLabel.opaque = NO;
            centerMessageLabel.textColor = [UIColor whiteColor];
            centerMessageLabel.font = [UIFont boldSystemFontOfSize:40];
            centerMessageLabel.textAlignment = UITextAlignmentCenter;
            centerMessageLabel.shadowColor = [UIColor darkGrayColor];
            centerMessageLabel.shadowOffset = CGSizeMake(1,1);
            centerMessageLabel.adjustsFontSizeToFitWidth = YES;

            [self addSubview:centerMessageLabel];
        }

        centerMessageLabel.text = message;
    }
}

- (void)setSubMessage:(NSString *)message
{
    if (message == nil && subMessageLabel != nil)
        self.subMessageLabel = nil;

    else if (message != nil)
    {
        if (subMessageLabel == nil)
        {
            self.subMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,self.bounds.size.height-45,self.bounds.size.width-24,30)];
            subMessageLabel.backgroundColor = [UIColor clearColor];
            subMessageLabel.opaque = NO;
            subMessageLabel.textColor = [UIColor whiteColor];
            subMessageLabel.font = [UIFont boldSystemFontOfSize:17];
            subMessageLabel.textAlignment = UITextAlignmentCenter;
            subMessageLabel.shadowColor = [UIColor darkGrayColor];
            subMessageLabel.shadowOffset = CGSizeMake(1,1);
            subMessageLabel.adjustsFontSizeToFitWidth = YES;

            [self addSubview:subMessageLabel];
        }

        subMessageLabel.text = message;
    }
}

- (void)showSpinner
{
    if (spinner == nil)
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

        spinner.frame = CGRectMake(round(self.bounds.size.width/2 - spinner.frame.size.width/2),
                round(self.bounds.size.height/2 - spinner.frame.size.height/2),
                spinner.frame.size.width,
                spinner.frame.size.height);
        spinner.hidesWhenStopped = YES;
        [self addSubview:spinner];
    }

    [spinner startAnimating];
}

#pragma mark - Display HUD

- (void)displayActivity:(NSString *)m
{
    [self setSubMessage:m];
    [self showSpinner];

    [centerMessageLabel removeFromSuperview];
    centerMessageLabel = nil;

    if ([self superview] == nil)
        [self show];
    else
        [self persist];
}

- (void)displayCircledProgressWithMessage:(NSString *)message
{
    [self setSubMessage:message];

    [self setProgress:0];

    [centerMessageLabel removeFromSuperview];
    centerMessageLabel = nil;

    if ([self superview] == nil)
        [self show];
    else
        [self persist];
}

- (void)dismissWithSuccess:(NSString *)m
{
    [spinner stopAnimating];
    [self setProgress:-1];

    [self setCenterMessage:@"✓"];
    [self setSubMessage:m];

    if ([self superview] == nil)
        [self show];
    else
        [self persist];

    [self hideAfterDelay];
}

- (void)dismissWithError:(NSString *)m
{
    [spinner stopAnimating];
    [self setProgress:-1];

    [self setCenterMessage:@"✘"];
    [self setSubMessage:m];

    if ([self superview] == nil)
        [self show];
    else
        [self persist];

    [self hideAfterDelay];
}

#pragma mark - Ring Progress Indicator

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateCircledProgressIndicator];
}

- (void)updateCircledProgressIndicator {
    [spinner removeFromSuperview];
    spinner = nil;

    if(_progress >= 0) {
        [self.spinner stopAnimating];
        self.circledIndicator.progress = _progress;
    }
    else {
        [self cancelCircledIndicatorAnimation];
        [self.spinner startAnimating];
    }
}

#pragma mark -
#pragma mark Ring progress animation Helpers

- (ETCircledProgressView *)circledIndicator {
    if(!_circledIndicator) {
        CGRect frame = self.bounds;
        frame.size.width -= 110;
        frame.size.height -= 110;
        frame.origin.x = 55;
        frame.origin.y = 40;
        _circledIndicator = [[ETCircledProgressView alloc] initWithFrame:frame];
        [self addSubview:_circledIndicator];
    }
    return _circledIndicator;
}

- (void)cancelCircledIndicatorAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.layer removeAllAnimations];

    if (_circledIndicator.superview) {
        [_circledIndicator removeFromSuperview];
    }
    _circledIndicator = nil;

    [CATransaction commit];
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);

    if (self.dimBackground) {

        size_t locationsCount = 2;
        CGFloat locations[2] = {0.0f, 1.0f};
        CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
        CGColorSpaceRelease(colorSpace);

        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
    }

    CGContextSetFillColorWithColor(context, self.color.CGColor);

    // Center HUD
    CGRect boxRect = self.bounds;
    float radius = 10.0f;

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);

    UIGraphicsPopContext();
}

#pragma mark -
#pragma mark Rotation

- (void)setProperRotation
{
    [self setProperRotation:YES];
}

- (void)setProperRotation:(BOOL)animated
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (animated)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    }

    if (orientation == UIDeviceOrientationPortraitUpsideDown)
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ETDegreesToRadians(180));

    else if (orientation == UIDeviceOrientationLandscapeLeft)
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ETDegreesToRadians(90));

    else if (orientation == UIDeviceOrientationLandscapeRight)
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ETDegreesToRadians(-90));

    else if (orientation == UIDeviceOrientationPortrait)
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, ETDegreesToRadians(0));

    if (animated)
        [UIView commitAnimations];
}


@end