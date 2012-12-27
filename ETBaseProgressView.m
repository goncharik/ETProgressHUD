//
//  ETBaseProgressView.m
//  ContinueDownloadExample
//
//  Created by Zhenia on 12/27/12.
//  Copyright (c) 2012 Tulusha.com. All rights reserved.
//

#import "ETBaseProgressView.h"

@implementation ETBaseProgressView

- (void)dealloc {
    [self unregisterFromKVO];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
        [self registerForKVO];
    }
    return self;
}


#pragma mark - Accessors

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeyPaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeyPaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeyPaths {
    return [NSArray arrayWithObjects:@"progressTintColor", @"backgroundTintColor", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

@end
