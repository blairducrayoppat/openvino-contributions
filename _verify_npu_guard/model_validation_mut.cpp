// MUTANT copy of model_validation.cpp: predicate weakened to is_dynamic() only
// (drops the upper-bound check). Used to prove the unit test detects the mutation
// (the AllowsBoundedDynamicInput case must flip to FAIL).

#include "model_validation.hpp"

#include <cstddef>
#include <string>

#include "openvino/core/dimension.hpp"
#include "openvino/core/except.hpp"
#include "openvino/core/interval.hpp"
#include "openvino/core/partial_shape.hpp"
#include "openvino/op/parameter.hpp"
#include "openvino/op/result.hpp"

namespace intel_npu {

namespace {

[[noreturn]] void throw_unbounded_dimension(const std::string& node_role,
                                            const std::string& node_name,
                                            size_t dimension_index) {
    OPENVINO_THROW("NPU does not support models with unbounded dynamic dimensions. ",
                   node_role,
                   " '",
                   node_name,
                   "' has dimension [",
                   dimension_index,
                   "] with no finite upper bound (upper bound is INT64_MAX). ",
                   "Please reshape the model to use static shapes before compiling for the NPU device:\n",
                   "    model.reshape({<static_shape>})\n",
                   "See: https://docs.openvino.ai/2026/openvino-workflow/"
                   "running-inference/changing-input-shape.html");
}

void check_partial_shape(const ov::PartialShape& shape, const std::string& node_role, const std::string& node_name) {
    if (shape.rank().is_dynamic()) {
        return;
    }
    for (size_t i = 0; i < shape.size(); ++i) {
        const auto& dimension = shape[i];
        if (dimension.is_dynamic()) {  // MUTANT: dropped "&& !dimension.get_interval().has_upper_bound()"
            throw_unbounded_dimension(node_role, node_name, i);
        }
    }
}

}  // namespace

void validate_no_unbounded_dynamic_dimensions(const std::shared_ptr<const ov::Model>& model) {
    if (!model->is_dynamic()) {
        return;
    }

    for (const auto& parameter : model->get_parameters()) {
        check_partial_shape(parameter->get_partial_shape(), "Parameter", parameter->get_friendly_name());
    }

    for (const auto& result : model->get_results()) {
        const auto source = result->input_value(0);
        check_partial_shape(result->get_input_partial_shape(0), "Output", source.get_node()->get_friendly_name());
    }
}

}  // namespace intel_npu
