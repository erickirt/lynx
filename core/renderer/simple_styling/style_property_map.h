// Copyright 2025 The Lynx Authors. All rights reserved.
// Licensed under the Apache License Version 2.0 that can be found in the
// LICENSE file in the root directory of this source tree.
#ifndef CORE_RENDERER_SIMPLE_STYLING_STYLE_PROPERTY_MAP_H_
#define CORE_RENDERER_SIMPLE_STYLING_STYLE_PROPERTY_MAP_H_

#include "core/renderer/css/css_property.h"

namespace lynx::style {
class StylePropertyMap {
 public:
  explicit StylePropertyMap(const tasm::StyleMap& style_map)
      : style_map_(style_map) {}
  ~StylePropertyMap() = default;
  void SetProperty(const tasm::CSSPropertyID id, const tasm::CSSValue& value) {
    style_map_[id] = value;
  }

  auto begin() { return style_map_.begin(); }
  auto end() { return style_map_.end(); }
  const tasm::StyleMap& GetStyleMap() { return style_map_; }

 private:
  tasm::StyleMap style_map_;
};
}  // namespace lynx::style
#endif  // CORE_RENDERER_SIMPLE_STYLING_STYLE_PROPERTY_MAP_H_
