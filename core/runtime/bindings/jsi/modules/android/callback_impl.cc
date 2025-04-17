// Copyright 2019 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

#include "core/runtime/bindings/jsi/modules/android/callback_impl.h"

#include <string>
#include <utility>

#include "base/include/timer/time_utils.h"
#include "base/trace/native/trace_event.h"
#include "core/base/android/java_only_array.h"
#include "core/base/android/java_only_map.h"
#include "core/base/lynx_trace_categories.h"
#include "core/build/gen/CallbackImpl_jni.h"
#include "core/runtime/bindings/jsi/interceptor/android/request_interceptor_android.h"
#include "core/runtime/bindings/jsi/modules/android/lynx_module_android.h"
#include "core/runtime/bindings/jsi/modules/android/method_invoker.h"
#include "core/services/recorder/recorder_controller.h"
#include "lynx/core/value_wrapper/android/value_impl_android.h"

void Invoke(JNIEnv* env, jobject jcaller, jlong nativePtr, jobject array) {
  auto callbackWeakImpl =
      reinterpret_cast<std::weak_ptr<lynx::piper::ModuleCallbackAndroid>*>(
          nativePtr);
  auto callbackImpl = callbackWeakImpl->lock();
  if (callbackImpl == nullptr) {
    LOGE(
        "LynxModule, callback_impl, nativeInvoke, "
        "callbackImpl.lock() is a nullptr");
    return;
  }
  callbackImpl->SetArguments(
      lynx::base::android::ScopedGlobalJavaRef<jobject>(env, array));
  std::shared_ptr<lynx::piper::LynxModuleAndroid> callback_invoker =
      callbackImpl->callback_invoker_.lock();
  if (callback_invoker != nullptr) {
    callback_invoker->InvokeCallback(callbackImpl);
  } else {
    LOGE(
        "LynxModule, callback_impl, nativeInvoke, "
        "callbackImpl->callback_invoker_.lock() is a nullptr");
  }
}
void ReleaseNativePtr(JNIEnv* env, jobject jcaller, jlong nativePtr) {
  auto callbackWeakImpl =
      reinterpret_cast<std::weak_ptr<lynx::piper::ModuleCallbackAndroid>*>(
          nativePtr);
  delete callbackWeakImpl;
}

namespace lynx {
namespace piper {

static jclass jniClass;
static jmethodID ctor;

bool ModuleCallbackAndroid::RegisterJNI(JNIEnv* env) {
  jniClass = static_cast<jclass>(
      // NOLINTNEXTLINE
      env->NewGlobalRef(env->FindClass("com/lynx/jsbridge/CallbackImpl")));
  ctor = env->GetMethodID(jniClass, "<init>", "(J)V");
  return RegisterNativesImpl(env);
}

ModuleCallbackAndroid::CallbackPair ModuleCallbackAndroid::createCallbackImpl(
    int64_t callback_id, std::shared_ptr<LynxModuleAndroid> invoker,
    ModuleCallbackType type) {
  std::shared_ptr<ModuleCallbackAndroid> callback;
  // TODO(huzhanbo.luc): move this into request_interceptor
  switch (type) {
    case ModuleCallbackType::Base:
      callback = std::make_shared<ModuleCallbackAndroid>(callback_id, invoker);
      break;
    case ModuleCallbackType::Request:
    case ModuleCallbackType::Fetch:
      callback =
          std::make_shared<ModuleCallbackRequest>(callback_id, invoker, type);
      break;
  }
  auto weakCallback = new std::weak_ptr<ModuleCallbackAndroid>(callback);
  auto nativePtr = reinterpret_cast<jlong>(weakCallback);
  JNIEnv* env = base::android::AttachCurrentThread();
  jobject javaObj = env->NewObject(jniClass, ctor, nativePtr);
  ModuleCallbackAndroid::CallbackPair pair = std::make_pair(
      callback, base::android::ScopedGlobalJavaRef<jobject>(env, javaObj));
  env->DeleteLocalRef(javaObj);
  return pair;
}

void ModuleCallbackAndroid::SetArguments(
    base::android::ScopedGlobalJavaRef<jobject> obj) {
  arguments = obj;
  auto pub_array = std::make_shared<base::android::JavaOnlyArray>(arguments);
  SetArgs(std::make_unique<pub::ValueImplAndroid>(std::move(pub_array)));
};

ModuleCallbackAndroid::ModuleCallbackAndroid(
    int64_t callback_id, std::shared_ptr<LynxModuleAndroid> callback_invoker)
    : ModuleCallback(callback_id), callback_invoker_(callback_invoker) {}
}  // namespace piper
}  // namespace lynx
