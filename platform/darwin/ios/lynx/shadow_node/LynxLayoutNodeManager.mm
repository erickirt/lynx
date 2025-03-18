// Copyright 2025 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

#import <Foundation/Foundation.h>
#import <Lynx/LynxCustomMeasureDelegate+Internal.h>
#import <Lynx/LynxLayoutNode.h>
#import <Lynx/LynxLayoutNodeManager.h>
#import <Lynx/LynxMeasureFuncDarwin.h>

#import "LynxMeasureFuncDarwin.h"

#include "lynx/core/public/layout_node_manager.h"

using namespace lynx::tasm;

@interface LynxLayoutNodeManager ()

- (void)checkIfThreadWrong:(NSInteger)sign methodName:(NSString *)name;

- (void)reportBehaviorMightChanged:(NSInteger)sign methodName:(NSString *)name;

@end

@implementation LynxLayoutNodeManager {
  LayoutNodeManager *_layout_node_manager;
  NSRunLoop *_layoutRunLoop;
  id<LayoutThreadMonitor> _layoutThreadErrorCallback;
}

- (instancetype)initWithNativePtr:(void *)nativePtr
        layoutThreadErrorCallback:(id<LayoutThreadMonitor>)callback {
  self = [super init];
  if (self) {
    _layout_node_manager = static_cast<LayoutNodeManager *>(nativePtr);
    _layoutThreadErrorCallback = callback;
    _layoutRunLoop = nil;
  }
  return self;
}

- (void)initLayoutRunLoop {
  if (_layoutRunLoop == nil) {
    _layoutRunLoop = [NSRunLoop currentRunLoop];
  }
}

- (void)detachNativePtr {
  _layout_node_manager = nullptr;
}

- (LynxFlexDirection)getFlexDirection:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return LynxFlexDirectionRow;
  }
  [self checkIfThreadWrong:sign methodName:@"getFlexDirection"];
  return (LynxFlexDirection)_layout_node_manager->GetFlexDirection((int32_t)sign);
}

// Now only supports computed length, length with auto and percentage will be 0
- (CGFloat)getMarginLeft:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMarginLeft"];
  return _layout_node_manager->GetMarginLeft((int32_t)sign);
}

- (CGFloat)getMarginRight:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMarginRight"];
  return _layout_node_manager->GetMarginRight((int32_t)sign);
}

- (CGFloat)getMarginTop:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMarginTop"];
  return _layout_node_manager->GetMarginTop((int32_t)sign);
}

- (CGFloat)getMarginBottom:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMarginBottom"];
  return _layout_node_manager->GetMarginBottom((int32_t)sign);
}

- (CGFloat)getPaddingLeft:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getPaddingLeft"];
  return _layout_node_manager->GetPaddingLeft((int32_t)sign);
}

- (CGFloat)getPaddingRight:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getPaddingRight"];
  return _layout_node_manager->GetPaddingRight((int32_t)sign);
}

- (CGFloat)getPaddingTop:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getPaddingTop"];
  return _layout_node_manager->GetPaddingTop((int32_t)sign);
}

- (CGFloat)getPaddingBottom:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getPaddingBottom"];
  return _layout_node_manager->GetPaddingBottom((int32_t)sign);
}

- (CGFloat)getWidth:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getWidth"];
  return _layout_node_manager->GetWidth((int32_t)sign);
}

- (CGFloat)getHeight:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getHeight"];
  return _layout_node_manager->GetHeight((int32_t)sign);
}

- (CGFloat)getMinWidth:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMinWidth"];
  return _layout_node_manager->GetMinWidth((int32_t)sign);
}
// if max-width is not set, return LayoutNodeStyle::UNDEFINED_MAX_SIZE
- (CGFloat)getMaxWidth:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMaxWidth"];
  return _layout_node_manager->GetMaxWidth((int32_t)sign);
}

- (CGFloat)getMinHeight:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMinHeight"];
  return _layout_node_manager->GetMinHeight((int32_t)sign);
}
// if max-height is not set, return LayoutNodeStyle::UNDEFINED_MAX_SIZE
- (CGFloat)getMaxHeigh:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return 0.0;
  }
  [self checkIfThreadWrong:sign methodName:@"getMaxHeigh"];
  return _layout_node_manager->GetMaxHeight((int32_t)sign);
}

- (void)setMeasureFuncWithSign:(NSInteger)sign LayoutNode:(LynxLayoutNode *)layoutNode {
  if (_layout_node_manager == nullptr) {
    return;
  }
  if ([NSRunLoop currentRunLoop] != _layoutRunLoop) {
    if (@available(iOS 10.0, *)) {
      __weak typeof(self) weakSelf = self;
      [_layoutRunLoop performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setMeasureFuncWithSign:sign LayoutNode:layoutNode];
      }];
      [self reportBehaviorMightChanged:sign methodName:@"SetMeasureFunc"];
    }
  } else {
    _layout_node_manager->SetMeasureFunc((int32_t)sign,
                                         std::make_unique<LynxMeasureFuncDarwin>(layoutNode));
  }
}

- (void)markDirtyAndRequestLayout:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return;
  }
  if ([NSRunLoop currentRunLoop] != _layoutRunLoop) {
    if (@available(iOS 10.0, *)) {
      __weak typeof(self) weakSelf = self;
      [_layoutRunLoop performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf markDirtyAndRequestLayout:sign];
      }];
      [self reportBehaviorMightChanged:sign methodName:@"MarkDirtyAndRequestLayout"];
    }
  } else {
    _layout_node_manager->MarkDirtyAndRequestLayout((int32_t)sign);
  }
}

- (void)markDirtyAndForceLayout:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return;
  }
  if ([NSRunLoop currentRunLoop] != _layoutRunLoop) {
    if (@available(iOS 10.0, *)) {
      __weak typeof(self) weakSelf = self;
      [_layoutRunLoop performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf markDirtyAndForceLayout:sign];
      }];
      [self reportBehaviorMightChanged:sign methodName:@"markDirtyAndForceLayout"];
    }
  } else {
    _layout_node_manager->MarkDirtyAndForceLayout((int32_t)sign);
  }
}

- (bool)isDirty:(NSInteger)sign {
  if (_layout_node_manager == nullptr) {
    return false;
  }
  [self checkIfThreadWrong:sign methodName:@"isDirty"];
  return _layout_node_manager->IsDirty((int32_t)sign);
}

- (MeasureResult)measureWithSign:(NSInteger)sign
                    MeasureParam:(MeasureParam *)param
                  MeasureContext:(MeasureContext *)context {
  if (_layout_node_manager == nullptr) {
    return MeasureResult();
  }
  [self checkIfThreadWrong:sign methodName:@"UpdateMeasureByPlatform"];
  LayoutResult size = _layout_node_manager->UpdateMeasureByPlatform(
      (int32_t)sign, param.width, (int32_t)param.widthMode, param.height, (int32_t)param.heightMode,
      context.finalMeasure);
  MeasureResult result;
  result.size = CGSizeMake(size.width_, size.height_);
  result.baseline = size.baseline_;
  return result;
}

- (void)alignWithSign:(NSInteger)sign
           AlignParam:(AlignParam *)param
         AlignContext:(AlignContext *)context {
  if (_layout_node_manager == nullptr) {
    return;
  }
  if ([NSRunLoop currentRunLoop] != _layoutRunLoop) {
    if (@available(iOS 10.0, *)) {
      __weak typeof(self) weakSelf = self;
      [_layoutRunLoop performBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf alignWithSign:sign AlignParam:param AlignContext:context];
      }];
    }
    [self reportBehaviorMightChanged:sign methodName:@"AlignmentByPlatform"];
  } else {
    _layout_node_manager->AlignmentByPlatform((int32_t)sign, param.topOffset, param.leftOffset);
  }
}

- (void)checkIfThreadWrong:(NSInteger)sign methodName:(NSString *)name {
  if ([NSRunLoop currentRunLoop] != _layoutRunLoop) {
    [_layoutThreadErrorCallback reportThreadErrorWithSign:sign methodName:name];
  }
}

- (void)reportBehaviorMightChanged:(NSInteger)sign methodName:(NSString *)name {
  [_layoutThreadErrorCallback reportBehaviorMightChangedWithSing:sign methodName:name];
}

@end
