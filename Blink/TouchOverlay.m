////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2018 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

#import "TouchOverlay.h"

@interface TouchOverlay () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@end

@implementation TouchOverlay
{
  
  UITapGestureRecognizer *_twoFingerTapGestureRecognizer;
  UIPinchGestureRecognizer *_pinchGestureRecognizer;
  UILongPressGestureRecognizer *_longPressGestureRecognizer;
  
  UIScrollView *_pagedScrollView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    // Interactive dismiss keyboard
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    self.alwaysBounceVertical = NO;
    self.alwaysBounceHorizontal = NO;
    self.delaysContentTouches = NO;
    
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    // We want only two fingers
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.directionalLockEnabled = YES;
    
    _oneFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleOneFingerTap:)];
    _oneFingerTapGestureRecognizer.numberOfTouchesRequired = 1;
    _oneFingerTapGestureRecognizer.delegate = self;
    
    _twoFingerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTwoFingerTap:)];
    _twoFingerTapGestureRecognizer.numberOfTapsRequired = 1;
    _twoFingerTapGestureRecognizer.numberOfTouchesRequired = 2;
    _twoFingerTapGestureRecognizer.delegate = self;
    
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePinch:)];
    
    _pinchGestureRecognizer.delegate = self;
    [_pinchGestureRecognizer shouldRequireFailureOfGestureRecognizer:self.panGestureRecognizer];
    
    // The goal of this gesture recognizer is two guard long press selection.
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    _longPressGestureRecognizer.numberOfTouchesRequired = 1;
    _longPressGestureRecognizer.delegate = self;
    [_oneFingerTapGestureRecognizer requireGestureRecognizerToFail:_longPressGestureRecognizer];
  }
  
  return self;
}

- (void)_resetOtherInteractions
{
  // Make recognizers and scroll view to forget of their current touches
  _oneFingerTapGestureRecognizer.enabled = NO;
  _twoFingerTapGestureRecognizer.enabled = NO;
  _longPressGestureRecognizer.enabled = NO;
  self.panGestureRecognizer.enabled = NO;
  _pagedScrollView.scrollEnabled = NO;
  
  
  _oneFingerTapGestureRecognizer.enabled = YES;
  _twoFingerTapGestureRecognizer.enabled = YES;
  _longPressGestureRecognizer.enabled = YES;
  self.panGestureRecognizer.enabled = NO;
  _pagedScrollView.scrollEnabled = YES;
}

- (void)attachPageViewController:(UIPageViewController *)ctrl
{
  // Need to find that scrollview
  if ([ctrl.view.subviews.firstObject isKindOfClass:[UIScrollView class]]) {
    _pagedScrollView = (UIScrollView *)ctrl.view.subviews.firstObject;
    _pagedScrollView.directionalLockEnabled = YES;
  } else {
    _pagedScrollView = nil;
  }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
  // We pass hit test to super view.
  UIView *res = [super hitTest:point withEvent:event];
  
  if (res == self) {
    CGRect rect = self.bounds;
    // Top right corner (Control panel on ipads ios 12)
    if (point.y <= 20 && point.x >= rect.size.width - 80) {
      return self;
    }
    return nil;
  }
  
  return res;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGSize contentSize = self.bounds.size;
  contentSize.height += 1000;
  self.contentSize = contentSize;
}

- (void)didMoveToSuperview
{
  if (self.superview) {
    [self.superview addGestureRecognizer:self.panGestureRecognizer];
    [self.superview addGestureRecognizer:_oneFingerTapGestureRecognizer];
    [self.superview addGestureRecognizer:_twoFingerTapGestureRecognizer];
    [self.superview addGestureRecognizer:_pinchGestureRecognizer];
    [self.superview addGestureRecognizer:_longPressGestureRecognizer];
  }
}

- (void)_handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
  
}

- (void)_handleOneFingerTap:(UITapGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateRecognized) {
    [_touchDelegate touchOverlay:self onOneFingerTap:recognizer];
  }
}

- (void)_handleTwoFingerTap:(UITapGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStateRecognized) {
    [_touchDelegate touchOverlay:self onTwoFingerTap:recognizer];
  }
}

- (void)_handlePinch:(UIPinchGestureRecognizer *)recognizer
{
  if (recognizer.state == UIGestureRecognizerStatePossible) {
    return;
  }
  
  CGFloat dScale = 1.0 - recognizer.scale;
  if (ABS(dScale) > 0.05) {
    [_touchDelegate touchOverlay:self onPinch:recognizer];
    [self _resetOtherInteractions];
    self.scrollEnabled = NO;
    self.scrollEnabled = YES;
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
  // The NO / YES process makes it forget about previous events and avoids collisions.
  _pinchGestureRecognizer.enabled = NO;
  _pinchGestureRecognizer.enabled = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
  // The NO / YES process makes it forget about previous events and avoids collisions.
  _pinchGestureRecognizer.enabled = NO;
  _pinchGestureRecognizer.enabled = YES;
  [self _resetOtherInteractions];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  
  // We should start all our recognizers
  return YES;
}

- (void)dealloc
{
  self.delegate = nil;
  _pagedScrollView = nil;
}

@end
