// Copyright 2021 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>
#include <Lynx/LynxView.h>
#import <LynxDevtool/TestBenchActionManager.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestBenchViewClient : NSObject <LynxViewLifecycle, LynxResourceFetcher>
@property(nonatomic, weak) TestBenchActionManager* manager;
@end

NS_ASSUME_NONNULL_END
