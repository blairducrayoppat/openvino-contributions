// On-device check: compile an unbounded-dynamic model for the real NPU and print the error.
// Before the plugin rebuild -> opaque compiler error. After -> the guard's actionable message.
#include <iostream>
#include <memory>
#include <string>

#include "openvino/core/model.hpp"
#include "openvino/core/partial_shape.hpp"
#include "openvino/op/parameter.hpp"
#include "openvino/op/result.hpp"
#include "openvino/runtime/core.hpp"

int main() {
    ov::Core core;
    auto devs = core.get_available_devices();
    bool npu = false;
    for (auto& d : devs)
        if (d == "NPU")
            npu = true;
    std::cout << "NPU available: " << (npu ? "yes" : "no") << "\n";
    if (!npu) {
        std::cout << "NO NPU -> abort\n";
        return 2;
    }

    auto p = std::make_shared<ov::op::v0::Parameter>(ov::element::f32,
                                                     ov::PartialShape{1, ov::Dimension::dynamic(), 64});
    p->set_friendly_name("input_ids");
    auto r = std::make_shared<ov::op::v0::Result>(p);
    auto model = std::make_shared<ov::Model>(ov::ResultVector{r}, ov::ParameterVector{p});

    try {
        auto cm = core.compile_model(model, "NPU");
        std::cout << "RESULT: compiled OK (UNEXPECTED for an unbounded model)\n";
        return 1;
    } catch (const std::exception& e) {
        std::cout << "RESULT: compile_model threw ->\n" << e.what() << "\n";
        return 0;
    }
}
