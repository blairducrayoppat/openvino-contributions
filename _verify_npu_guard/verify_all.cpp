// Authoritative proxy: mirrors all six committed gtest cases in unbounded_dynamic_shape.cpp 1:1
// (same models, same substring assertions), compiled against the real OpenVINO runtime.

#include <iostream>
#include <memory>
#include <string>

#include "model_validation.hpp"
#include "openvino/core/dimension.hpp"
#include "openvino/core/model.hpp"
#include "openvino/core/partial_shape.hpp"
#include "openvino/op/parameter.hpp"
#include "openvino/op/range.hpp"
#include "openvino/op/result.hpp"

using intel_npu::validate_no_unbounded_dynamic_dimensions;

static int g_fail = 0;
static void check(const char* name, bool ok, const std::string& detail = "") {
    std::cout << (ok ? "PASS  " : "FAIL  ") << name << "\n";
    if (!ok) {
        ++g_fail;
        if (!detail.empty())
            std::cout << "      " << detail << "\n";
    }
}
static bool has(const std::string& s, const char* sub) {
    return s.find(sub) != std::string::npos;
}
static std::shared_ptr<ov::op::v0::Parameter> param(const ov::PartialShape& s, const std::string& n) {
    auto p = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, s);
    p->set_friendly_name(n);
    return p;
}
static std::shared_ptr<ov::Model> single(const ov::PartialShape& s, const std::string& n) {
    auto p = param(s, n);
    return std::make_shared<ov::Model>(ov::ResultVector{std::make_shared<ov::op::v0::Result>(p)},
                                       ov::ParameterVector{p});
}
static std::string thrown(const std::shared_ptr<ov::Model>& m, bool& t) {
    t = false;
    try {
        validate_no_unbounded_dynamic_dimensions(m);
    } catch (const ov::Exception& e) {
        t = true;
        return e.what();
    }
    return "";
}

int main() {
    bool t;
    std::string m;

    // 1. RejectsUnboundedDynamicInput
    m = thrown(single({1, ov::Dimension::dynamic(), 64}, "test_input"), t);
    check("RejectsUnboundedDynamicInput",
          t && has(m, "unbounded dynamic dimensions") && has(m, "Parameter") && has(m, "test_input") && has(m, "[1]") &&
              has(m, "model.reshape"),
          m);

    // 2. ReportsOffendingParameterInMultiInputModel
    {
        auto s = param({4, 8, 2}, "static_input");
        auto u = param({4, 8, ov::Dimension::dynamic()}, "unbounded_input");
        auto model = std::make_shared<ov::Model>(ov::ResultVector{std::make_shared<ov::op::v0::Result>(s),
                                                                  std::make_shared<ov::op::v0::Result>(u)},
                                                 ov::ParameterVector{s, u});
        m = thrown(model, t);
        check("ReportsOffendingParameterInMultiInputModel",
              t && has(m, "unbounded_input") && has(m, "[2]") && !has(m, "static_input"), m);
    }

    // 3. RejectsUnboundedDynamicOutput (Range -> unbounded 1-D output)
    {
        auto a = param({}, "start"), b = param({}, "stop"), c = param({}, "step");
        auto range = std::make_shared<ov::op::v4::Range>(a, b, c, ov::element::f32);
        range->set_friendly_name("range_node");
        auto model = std::make_shared<ov::Model>(ov::ResultVector{std::make_shared<ov::op::v0::Result>(range)},
                                                 ov::ParameterVector{a, b, c});
        m = thrown(model, t);
        check("RejectsUnboundedDynamicOutput",
              t && has(m, "unbounded dynamic dimensions") && has(m, "Output") && has(m, "range_node"), m);
    }

    // 4. AllowsBoundedDynamicInput
    m = thrown(single({1, ov::Dimension(1, 512), 64}, "test_input_bounded"), t);
    check("AllowsBoundedDynamicInput", !t, m);

    // 5. AllowsFullyStaticModel
    m = thrown(single({1, 3, 64}, "test_input_static"), t);
    check("AllowsFullyStaticModel", !t, m);

    // 6. AllowsDynamicRankParameter
    m = thrown(single(ov::PartialShape::dynamic(), "dynamic_rank_input"), t);
    check("AllowsDynamicRankParameter", !t, m);

    std::cout << (g_fail == 0 ? "\nRESULT: ALL 6 PASS\n" : "\nRESULT: FAILURES\n");
    return g_fail == 0 ? 0 : 1;
}
