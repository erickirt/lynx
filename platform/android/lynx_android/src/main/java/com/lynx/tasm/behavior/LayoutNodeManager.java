// Copyright 2024 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.
package com.lynx.tasm.behavior;

import android.os.Handler;
import android.os.Looper;

public class LayoutNodeManager {
  public static float UNDEFINED_MAX_SIZE = (float) 0x7FFFFFF;
  public static float UNDEFINED_MIN_SIZE = 0f;
  private long mNativePtr = 0;
  private Looper mLayoutLooper;
  private Handler mLayoutHandler;
  private LayoutThreadMonitor mLayoutThreadMonitor;

  public interface LayoutThreadMonitor {
    void reportThreadError(int id, String methodName);
    void reportBehaviorMightChanged(int id, String methodName);
  }

  public void setLayoutThreadMonitor(LayoutThreadMonitor layoutThreadMonitor) {
    mLayoutThreadMonitor = layoutThreadMonitor;
  }

  public void attachNativePtr(long mNativePtr) {
    this.mNativePtr = mNativePtr;
  }

  public void initLayoutHandler() {
    if (mLayoutLooper == null) {
      mLayoutLooper = Looper.myLooper();
      mLayoutHandler = new Handler(mLayoutLooper);
    }
  }

  public void detachNativePtr() {
    mNativePtr = 0;
  }

  public void setMeasureFunc(int id, Object shadowNode) {
    if (mNativePtr == 0) {
      return;
    }
    if (Looper.myLooper() != mLayoutLooper) {
      mLayoutHandler.post(() -> setMeasureFunc(id, shadowNode));
      reportBehaviorChanged(id, "setMeasureFunc");
    } else {
      nativeSetMeasureFunc(mNativePtr, id, shadowNode);
    }
  }

  public void markDirty(int id) {
    if (mNativePtr == 0) {
      return;
    }
    if (Looper.myLooper() != mLayoutLooper) {
      mLayoutHandler.post(() -> markDirty(id));
      reportBehaviorChanged(id, "markDirty");
    } else {
      nativeMarkDirty(mNativePtr, id);
    }
  }

  public boolean isDirty(int id) {
    if (mNativePtr == 0) {
      return false;
    }
    checkIfThreadError(id, "isDirty");
    return nativeIsDirty(mNativePtr, id);
  }

  // inline view methods
  public long measureNativeNode(
      int id, float width, int widthMode, float height, int heightMode, boolean finalMeasure) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "measureNativeNode");
    return nativeMeasureNativeNode(
        mNativePtr, id, width, widthMode, height, heightMode, finalMeasure);
  }

  public int[] measureNativeNodeReturnWithBaseline(
      int id, float width, int widthMode, float height, int heightMode, boolean finalMeasure) {
    if (mNativePtr == 0) {
      return new int[0];
    }
    checkIfThreadError(id, "measureNativeNodeReturnWithBaseline");
    return nativeMeasureNativeNodeReturnWithBaseline(
        mNativePtr, id, width, widthMode, height, heightMode, finalMeasure);
  }

  public void alignNativeNode(int id, float offset_top, float offset_left) {
    if (mNativePtr == 0) {
      return;
    }
    if (Looper.myLooper() != mLayoutLooper) {
      mLayoutHandler.post(() -> alignNativeNode(id, offset_top, offset_left));
      reportBehaviorChanged(id, "alignNativeNode");
    } else {
      nativeAlignNativeNode(mNativePtr, id, offset_top, offset_left);
    }
  }

  // Style relevant methods
  public int getFlexDirection(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getFlexDirection");
    return nativeGetFlexDirection(mNativePtr, id);
  }

  public float getWidth(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getWidth");
    return nativeGetWidth(mNativePtr, id);
  }

  public float getHeight(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getHeight");
    return nativeGetHeight(mNativePtr, id);
  }

  public float getMinWidth(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getMinWidth");
    return nativeGetMinWidth(mNativePtr, id);
  }

  public float getMaxWidth(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getMaxWidth");
    return nativeGetMaxWidth(mNativePtr, id);
  }

  public float getMinHeight(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getMinHeight");
    return nativeGetMinHeight(mNativePtr, id);
  }

  // if max-height is not set, return DEFAULT_MAX_HEIGHT
  public float getMaxHeight(int id) {
    if (mNativePtr == 0) {
      return 0;
    }
    checkIfThreadError(id, "getMaxHeight");
    return nativeGetMaxHeight(mNativePtr, id);
  }

  public int[] getPadding(int id) {
    if (mNativePtr == 0) {
      return new int[0]; // 默认值
    }
    checkIfThreadError(id, "getPadding");
    return nativeGetPadding(mNativePtr, id);
  }

  public int[] getMargin(int id) {
    if (mNativePtr == 0) {
      return new int[0]; // 默认值
    }
    checkIfThreadError(id, "getMargin");
    return nativeGetMargin(mNativePtr, id);
  }

  private void checkIfThreadError(int id, String methodName) {
    if (Looper.myLooper() != mLayoutLooper) {
      if (mLayoutThreadMonitor != null) {
        mLayoutThreadMonitor.reportThreadError(id, methodName);
      }
    }
  }

  private void reportBehaviorChanged(int id, String methodName) {
    if (mLayoutThreadMonitor != null) {
      mLayoutThreadMonitor.reportBehaviorMightChanged(id, methodName);
    }
  }

  private native void nativeSetMeasureFunc(long nativePtr, int id, Object shadowNode);
  private native void nativeMarkDirty(long nativePtr, int id);
  private native boolean nativeIsDirty(long nativePtr, int id);

  // inline view methods
  private native long nativeMeasureNativeNode(long nativePtr, int id, float width, int widthMode,
      float height, int heightMode, boolean finalMeasure);
  private native int[] nativeMeasureNativeNodeReturnWithBaseline(long nativePtr, int id,
      float width, int widthMode, float height, int heightMode, boolean finalMeasure);
  private native void nativeAlignNativeNode(
      long nativePtr, int id, float offset_top, float offset_left);

  // Style relevant methods
  private native int nativeGetFlexDirection(long nativePtr, int id);
  private native float nativeGetWidth(long nativePtr, int id);
  private native float nativeGetHeight(long nativePtr, int id);

  private native float nativeGetMinWidth(long nativePtr, int id);
  private native float nativeGetMaxWidth(long nativePtr, int id);
  private native float nativeGetMinHeight(long nativePtr, int id);

  private native float nativeGetMaxHeight(long nativePtr, int id);
  private native int[] nativeGetPadding(long nativePtr, int id);
  private native int[] nativeGetMargin(long nativePtr, int id);
}
