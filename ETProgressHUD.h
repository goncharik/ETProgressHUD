//
//  ETProgressHUD.h
//  ContinueDownloadExample
//
//  Created by Zhenia on 12/26/12.
//  Copyright (c) 2012 Tulusha.com. All rights reserved.
//


@interface ETProgressHUD : UIView
{
    UILabel *centerMessageLabel;
    UILabel *subMessageLabel;

    UIActivityIndicatorView *spinner;
}

@property (nonatomic, strong) UILabel *centerMessageLabel;
@property (nonatomic, strong) UILabel *subMessageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, readwrite) CGFloat progress;

@property(nonatomic, readwrite) BOOL dimBackground;

@property(nonatomic, strong) UIColor *color;

+ (ETProgressHUD *)currentHUD;

- (void)displayActivity:(NSString *)m;
- (void)displayCircledProgressWithMessage:(NSString *)message;

- (void)dismissWithSuccess:(NSString *)m;
- (void)dismissWithError:(NSString *)m;

- (void)setCenterMessage:(NSString *)message;
- (void)setSubMessage:(NSString *)message;

@end
