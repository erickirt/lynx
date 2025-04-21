// Copyright 2025 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

#ifndef CORE_BASE_TRACE_TRACE_EVENT_DEF_H_
#define CORE_BASE_TRACE_TRACE_EVENT_DEF_H_

#include "core/base/lynx_trace_categories.h"

#if ENABLE_TRACE_PERFETTO || ENABLE_TRACE_SYSTRACE
/**
 * @trace_description: Load the Lynx bundle.
 */
static constexpr const char* const LYNX_ENGINE_LOAD_TEMPLATE =
    "LynxEngine::LoadTemplate";
/**
 * @trace_description: Load the Lynx bundle with templateBundle. Reference:
 * @link{https://lynxjs.org/api/lynx-native-api/template-bundle.html}
 */
static constexpr const char* const LYNX_ENGINE_LOAD_TEMPLATE_BUNDLE =
    "LynxEngine::LoadTemplateBundle";
/**
 * @trace_description: Execute the @args{module_name}.@args{method} method on
 * the background scripting thread (historically known as "JS Thread").
 */
static constexpr const char* const CALL_JS_FUNCTION = "CallJSFunction";
/**
 * @trace_description: Start a pipeline. Pipeline trigger is
 * @args{pipeline_origin}. About Lynx pipeline:
 * @link{https://lynxjs.org/api/lynx-api/performance-api/performance-entry/pipeline-entry.html}
 */
static constexpr const char* const TIMING_PIPELINE_START =
    "Timing::OnPipelineStart";
/**
 * @trace_description: Send reporting tasks, such as Timing reports and
 * LongTask detection reports, to the asynchronous thread.
 */
static constexpr const char* const EVENT_TRACKER_FLUSH = "EventTracker::Flush";

/**
 * @trace_description: Synchronously execute UI operations, such as creating
 * platform ui.
 */
static constexpr const char* const UI_OPERATION_QUEUE_FLUSH =
    "LynxUIOperationQueue.Flush";

/**
 * @trace_description: Execute the platform ui operations, such as creating,
 * inserting, updating, and deleting platform ui.
 */
static constexpr const char* const UI_OPERATION_QUEUE_EXECUTE =
    "LynxUIOperationQueue::ExecuteOperation";

/**
 * @trace_description: Execute UI operations, such as creating
 * platform ui.
 */
static constexpr const char* const UI_OPERATION_ASYNC_QUEUE_FLUSH =
    "LynxUIOperationAsyncQueue::FlushInterval";

static constexpr const char* const THREAD_MERGER_CONSTRUCTOR =
    "ThreadMerger::ThreadMerger";
static constexpr const char* const THREAD_MERGER_DECONSTRUCTOR =
    "ThreadMerger::~ThreadMerger";
static constexpr const char* const MESSAGE_LOOP_ANDROID_VASYNC_FLUSH_TASKS =
    "MessageLoopAndroidVSync::FlushTasks";
static constexpr const char* const VSYNC_MONITOR_DARWIN_ON_MAIN_DISPLAY =
    "LynxVSyncPulse::onMainDisplay";

#endif  // #if ENABLE_TRACE_PERFETTO || ENABLE_TRACE_SYSTRACE

#endif  // CORE_BASE_TRACE_TRACE_EVENT_DEF_H_
