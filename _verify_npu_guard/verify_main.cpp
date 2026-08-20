// Standalone verification harness for intel_npu::validate_no_unbounded_dynamic_dimensions().
// Compiles the REAL helper (model_validation.cpp) against the installed OpenVINO runtime and
// runs the same three cases as the gtest unit test. No device required.

#include <iostream>
#include <memory>
#include <string>

#include "model_validation.hpp"
#include "openvino/core/dimension.hpp"
#include "openvino/core/model.hpp"
#include "openvino/core/partial_shape.hpp"
#include "openvino/op/parameter.hpp"
#include "openvino/op/result.hpp"

using intel_npu::validate_no_unbounded_dynamic_dimensions;

static std::shared_ptr<ov::Model> make_model(const ov::PartialShape& shape, const std::string& name) {
    auto p = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, shape);
    p->set_friendly_name(name);
    auto r = std::make_shared<ov::op::v0::Result>(p);
    return std::make_shared<ov::Model>(ov::ResultVector{r}, ov::ParameterVector{p});
}

int main() {
    int failures = 0;

    // [1] Unbounded dynamic input must throw with an actionable message.
    {
        auto m = make_model({1, ov::Dimension::dynamic(), 64}, "test_input");
        bool threw = false;
        std::string msg;
        try {
            validate_no_unbounded_dynamic_dimensions(m);
        } catch (const ov::Exception& e) {
            threw = true;
            msg = e.what();
        }
        bool ok = threw && msg.find("unbounded dynamic dimensions") != std::string::npos &&
                  msg.find("test_input") != std::string::npos && msg.find("model.reshape") != std::string::npos;
        std::cout << "[1] RejectsUnboundedDynamicInput: " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++failures;
            std::cout << "    threw=" << threw << " msg=\"" << msg << "\"\n";
        } else {
            std::cout << "    message: " << msg.substr(0, msg.find('\n')) << " ...\n";
        }
    }

    // [2] Bounded dynamic input (finite upper bound) must NOT throw.
    {
        auto m = make_model({1, ov::Dimension(1, 512), 64}, "test_input_bounded");
        bool threw = false;
        std::string msg;
        try {
            validate_no_unbounded_dynamic_dimensions(m);
        } catch (const ov::Exception& e) {
            threw = true;
            msg = e.what();
        }
        bool ok = !threw;
        std::cout << "[2] AllowsBoundedDynamicInput: " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++failures;
            std::cout << "    unexpected throw: \"" << msg << "\"\n";
        }
    }

    // [3] Fully static model must NOT throw.
    {
        auto m = make_model({1, 3, 64}, "test_input_static");
        bool threw = false;
        try {
            validate_no_unbounded_dynamic_dimensions(m);
        } catch (...) {
            threw = true;
        }
        bool ok = !threw;
        std::cout << "[3] AllowsFullyStaticModel: " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++failures;
        }
    }

    std::cout << (failures == 0 ? "RESULT: ALL PASS\n" : "RESULT: FAILURES\n");
    return failures == 0 ? 0 : 1;
}
