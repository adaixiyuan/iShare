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

#import "POPAnimationExtras.h"

#import "POPAnimationPrivate.h"
#import "POPMath.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN CGFloat UIAnimationDragCoefficient(); // UIKit private drag coeffient, use judiciously
#endif

CGFloat POPAnimationDragCoefficient()
{
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

@implementation CAAnimation (POPAnimationExtras)

- (void)pop_applyDragCoefficient
{
  CGFloat k = POPAnimationDragCoefficient();
  if (k != 0 && k != 1)
    self.speed = 1 / k;
}

@end

@implementation POPSpringAnimation (POPAnimationExtras)

static const CGFloat POPBouncy3NormalizationRange = 20.0;
static const CGFloat POPBouncy3NormalizationScale = 1.7;
static const CGFloat POPBouncy3BouncinessNormalizedMin = 0.0;
static const CGFloat POPBouncy3BouncinessNormalizedMax = 0.8;
static const CGFloat POPBouncy3SpeedNormalizedMin = 0.5;
static const CGFloat POPBouncy3SpeedNormalizedMax = 200;
static const CGFloat POPBouncy3FrictionInterpolationMax = 0.01;

+ (void)convertBounciness:(CGFloat)bounciness speed:(CGFloat)speed toTension:(CGFloat *)outTension friction:(CGFloat *)outFriction mass:(CGFloat *)outMass
{
  double b = normalize(bounciness / POPBouncy3NormalizationScale, 0, POPBouncy3NormalizationRange);
  b = project_normal(b, POPBouncy3BouncinessNormalizedMin, POPBouncy3BouncinessNormalizedMax);

  double s = normalize(speed / POPBouncy3NormalizationScale, 0, POPBouncy3NormalizationRange);

  CGFloat tension = project_normal(s, POPBouncy3SpeedNormalizedMin, POPBouncy3SpeedNormalizedMax);
  CGFloat friction = quadratic_out_interpolation(b, b3_nobounce(tension), POPBouncy3FrictionInterpolationMax);

  tension = POP_ANIMATION_TENSION_FOR_QC_TENSION(tension);
  friction = POP_ANIMATION_FRICTION_FOR_QC_FRICTION(friction);

  if (outTension) {
    *outTension = tension;
  }

  if (outFriction) {
    *outFriction = friction;
  }

  if (outMass) {
    *outMass = 1.0;
  }
}

+ (void)convertTension:(CGFloat)tension friction:(CGFloat)friction toBounciness:(CGFloat *)outBounciness speed:(CGFloat *)outSpeed
{
  // Convert to QC values, in which our calculations are done.
  CGFloat qcFriction = QC_FRICTION_FOR_POP_ANIMATION_FRICTION(friction);
  CGFloat qcTension = QC_TENSION_FOR_POP_ANIMATION_TENSION(tension);

  // Friction is a function of bounciness and tension, according to the following:
  // friction = quadratic_out_interpolation(b, b3_nobounce(tension), POPBouncy3FrictionInterpolationMax);
  // Solve for bounciness, given a tension and friction.

  CGFloat nobounceTension = b3_nobounce(qcTension);
  CGFloat bounciness1, bounciness2;

  quadratic_solve((nobounceTension - POPBouncy3FrictionInterpolationMax),      // a
                  2 * (POPBouncy3FrictionInterpolationMax - nobounceTension),  // b
                  (nobounceTension - qcFriction),                             // c
                  bounciness1,                                                // x1
                  bounciness2);                                               // x2


  // Choose the quadratic solution within the normalized bounciness range
  CGFloat projectedNormalizedBounciness = (bounciness2 < POPBouncy3BouncinessNormalizedMax) ? bounciness2 : bounciness1;
  CGFloat projectedNormalizedSpeed = qcTension;

  // Reverse projection + normalization
  CGFloat bounciness = ((POPBouncy3NormalizationRange * POPBouncy3NormalizationScale) / (POPBouncy3BouncinessNormalizedMax - POPBouncy3BouncinessNormalizedMin)) * (projectedNormalizedBounciness - POPBouncy3BouncinessNormalizedMin);
  CGFloat speed = ((POPBouncy3NormalizationRange * POPBouncy3NormalizationScale) / (POPBouncy3SpeedNormalizedMax - POPBouncy3SpeedNormalizedMin)) * (projectedNormalizedSpeed - POPBouncy3SpeedNormalizedMin);

  // Write back results
  if (outBounciness) {
    *outBounciness = bounciness;
  }

  if (outSpeed) {
    *outSpeed = speed;
  }
}

@end
