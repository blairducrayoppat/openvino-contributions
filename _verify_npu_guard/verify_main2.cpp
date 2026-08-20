// Verify the NEW test constructions exercise the intended branches before adding them to the gtest:
//  A) multi-parameter: offending param name + dimension index reported, static param not named
//  B) unbounded OUTPUT via Range: "Output" role + producing-node name reported (result branch)
//  C) dynamic-rank parameter: early-return, no throw

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

static std::string run(const std::shared_ptr<ov::Model>& m, bool& threw) {
    threw = false;
    try {
        validate_no_unbounded_dynamic_dimensions(m);
    } catch (const ov::Exception& e) {
        threw = true;
        return e.what();
    }
    return "";
}

int main() {
    int fail = 0;

    // A) multi-parameter, one static + one unbounded at index 2
    {
        auto p_static = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape{4, 8, 2});
        p_static->set_friendly_name("static_input");
        auto p_unb =
            std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape{4, 8, ov::Dimension::dynamic()});
        p_unb->set_friendly_name("unbounded_input");
        auto r0 = std::make_shared<ov::op::v0::Result>(p_static);
        auto r1 = std::make_shared<ov::op::v0::Result>(p_unb);
        auto m = std::make_shared<ov::Model>(ov::ResultVector{r0, r1}, ov::ParameterVector{p_static, p_unb});
        bool t;
        auto msg = run(m, t);
        bool ok = t && msg.find("unbounded_input") != std::string::npos && msg.find("[2]") != std::string::npos &&
                  msg.find("static_input") == std::string::npos;
        std::cout << "[A] multi-param names offending param + index [2]: " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++fail;
            std::cout << "    threw=" << t << " msg=\"" << msg << "\"\n";
        }
    }

    // B) static scalar params -> Range -> unbounded output (exercises the Result branch)
    {
        auto start = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape{});
        auto stop = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape{});
        auto step = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape{});
        start->set_friendly_name("start");
        stop->set_friendly_name("stop");
        step->set_friendly_name("step");
        auto range = std::make_shared<ov::op::v4::Range>(start, stop, step, ov::element::f32);
        range->set_friendly_name("my_range");
        auto r = std::make_shared<ov::op::v0::Result>(range);
        auto m = std::make_shared<ov::Model>(ov::ResultVector{r}, ov::ParameterVector{start, stop, step});
        std::cout << "    range out is_dynamic=" << range->get_output_partial_shape(0).is_dynamic()
                  << " shape=" << range->get_output_partial_shape(0) << "\n";
        bool t;
        auto msg = run(m, t);
        bool ok = t && msg.find("Output") != std::string::npos && msg.find("my_range") != std::string::npos;
        std::cout << "[B] unbounded output via Range names Output + producer: " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++fail;
            std::cout << "    threw=" << t << " msg=\"" << msg << "\"\n";
        }
    }

    // C) dynamic-rank parameter -> early-return, no throw
    {
        auto p = std::make_shared<ov::op::v0::Parameter>(ov::element::f32, ov::PartialShape::dynamic());
        p->set_friendly_name("dyn_rank");
        auto r = std::make_shared<ov::op::v0::Result>(p);
        auto m = std::make_shared<ov::Model>(ov::ResultVector{r}, ov::ParameterVector{p});
        bool t;
        auto msg = run(m, t);
        bool ok = !t;
        std::cout << "[C] dynamic-rank allowed (no throw): " << (ok ? "PASS" : "FAIL") << "\n";
        if (!ok) {
            ++fail;
            std::cout << "    unexpected msg=\"" << msg << "\"\n";
        }
    }

    std::cout << (fail == 0 ? "NEWCASES: ALL PASS\n" : "NEWCASES: FAILURES\n");
    return fail == 0 ? 0 : 1;
}
