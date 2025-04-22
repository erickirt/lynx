// Copyright 2025 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.

#include "core/renderer/simple_styling/style_object.h"

#include <mutex>
#include <utility>

#include "core/renderer/simple_styling/simple_style_node.h"

namespace lynx::style {

void StyleObject::BindToElement(SimpleStyleNode* element) {
  elements_.emplace_back(element);
}

void StyleObject::UnbindFromElement(SimpleStyleNode* element) {
  if (const auto it = std::find(elements_.begin(), elements_.end(), element);
      it != elements_.end()) {
    elements_.erase(it);
  }
}

void StyleObject::ResetElement(SimpleStyleNode* element) const {
  std::for_each(
      style_map_->begin(), style_map_->end(),
      [element](const auto& pair) { element->ResetSimpleStyle(pair.first); });
}

void StyleObject::FromBinary() {
  std::call_once(decode_flag_, [this]() { DecodeImmediately(); });
}

lepus::RefType StyleObject::GetRefType() const {
  return lepus::RefType::kStyleObject;
}

void StyleObject::DecodeImmediately() {
  const auto decoder = creator_(data_, length_);
  tasm::StyleMap attr;
  decoder->DecodeStyleObject(attr, range_);
  style_map_ = std::make_unique<StylePropertyMap>(attr);
}

void StyleObject::UpdateStyleMap(const tasm::StyleMap& style_map) {
  std::for_each(style_map.begin(), style_map.end(), [this](const auto& pair) {
    style_map_->SetProperty(pair.first, pair.second);
  });
  for (auto* element : elements_) {
    element->UpdateSimpleStyles(style_map);
  }
}
}  // namespace lynx::style
