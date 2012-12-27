//
//  ETBaseProgressView.h
//  ContinueDownloadExample
//
//  Created by Zhenia on 12/27/12.
//  Copyright (c) 2012 Tulusha.com. All rights reserved.
//



@interface ETBaseProgressView : UIView {
    CGFloat _progress;
}

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *backgroundTintColor;

@property (nonatomic, getter=progress, setter=setProgress:) CGFloat progress;

@end
