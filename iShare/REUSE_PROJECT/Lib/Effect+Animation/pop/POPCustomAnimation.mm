/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "POPCustomAnimation.h"
#import "POPAnimationInternal.h"

@interface POPCustomAnimation ()
@property (nonatomic, copy) POPCustomAnimationBlock animate;
@end

@implementation POPCustomAnimation

+ (instancetype)animationWithBlock:(BOOL(^)(id target, POPCustomAnimation *))block
{
  POPCustomAnimation *b = [[self alloc] _init];
  b.animate = block;
  return b;
}

- (id)_init
{
  self = [super _init];
  if (nil != self) {
    _state->type = kPOPAnimationCustom;
  }
  return self;
}

- (CFTimeInterval)beginTime
{
  POPAnimationState *s = POPAnimationGetState(self);
  return s->startTime > 0 ? s->startTime : s->beginTime;
}

- (BOOL)_advance:(id)object currentTime:(CFTimeInterval)currentTime elapsedTime:(CFTimeInterval)elapsedTime
{
  _currentTime = currentTime;
  _elapsedTime = elapsedTime;
  return _animate(object, self);
}

- (void)_appendDescription:(NSMutableString *)s debug:(BOOL)debug
{
  [s appendFormat:@"; elapsedTime = %f; currentTime = %f;", _elapsedTime, _currentTime];
}

@end
