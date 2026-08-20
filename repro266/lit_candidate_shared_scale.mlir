// RUN: vpux-opt --split-input-file --init-compiler="platform=%platform%" --unroll-group-quantize --mlir-print-debuginfo %s | FileCheck %s
// REQUIRES: platform-NPU3720 || platform-NPU4000 || platform-NPU5010

// Two DynamicDequantize ops share one scale (%SCALE). UnrollGroupQuantize unrolls each, slicing the
// shared scale in both. The produced slices must carry distinct, consumer-tagged locations; otherwise
// StopLocationVerifierPass fails with "Found N duplicated names".

!qElemType = !quant.uniform<i4:f16, 1.000000e+00>

// CHECK-LABEL: @SharedScaleTwoConsumers
func.func @SharedScaleTwoConsumers(%data0: tensor<2x1536x128x!qElemType>, %data1: tensor<2x1536x128x!qElemType>,
                                   %scale: tensor<2x1536x1xf16>, %act0: tensor<1x256xf16>, %act1: tensor<1x256xf16>)
        -> (tensor<1x1536xf16>, tensor<1x1536xf16>) {
    %0 = IE.DynamicDequantize(%data0, %scale) {dstElemType = f16} : tensor<2x1536x128x!qElemType>, tensor<2x1536x1xf16> -> tensor<2x1536x128xf16> loc("dq_A")
    %1 = IE.Transpose(%0) {order_value = affine_map<(d0, d1, d2) -> (d1, d0, d2)>} : tensor<2x1536x128xf16> -> tensor<1536x2x128xf16> loc("tr_A")
    %2 = IE.AffineReshape(%1) {dim_mapping = [[0], [1], [1]], shape_value = [1536, 256]} : tensor<1536x2x128xf16> -> tensor<1536x256xf16> loc("rs_A")
    %3 = IE.FullyConnected(%act0, %2) : tensor<1x256xf16>, tensor<1536x256xf16> -> tensor<1x1536xf16> loc("fc_A")

    %4 = IE.DynamicDequantize(%data1, %scale) {dstElemType = f16} : tensor<2x1536x128x!qElemType>, tensor<2x1536x1xf16> -> tensor<2x1536x128xf16> loc("dq_B")
    %5 = IE.Transpose(%4) {order_value = affine_map<(d0, d1, d2) -> (d1, d0, d2)>} : tensor<2x1536x128xf16> -> tensor<1536x2x128xf16> loc("tr_B")
    %6 = IE.AffineReshape(%5) {dim_mapping = [[0], [1], [1]], shape_value = [1536, 256]} : tensor<1536x2x128xf16> -> tensor<1536x256xf16> loc("rs_B")
    %7 = IE.FullyConnected(%act1, %6) : tensor<1x256xf16>, tensor<1536x256xf16> -> tensor<1x1536xf16> loc("fc_B")

    return %3, %7 : tensor<1x1536xf16>, tensor<1x1536xf16>
}
