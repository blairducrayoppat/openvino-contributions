!qElemType = !quant.uniform<u4:f16, 1.000000e+00>

func.func @SharedScaleTwoConsumers(%data0: tensor<2x1536x128x!qElemType>, %data1: tensor<2x1536x128x!qElemType>,
                                   %scale: tensor<2x1536x1xf16>, %act0: tensor<1x256xf16>, %act1: tensor<1x256xf16>)
        -> (tensor<1x1536xf16>, tensor<1x1536xf16>) {
    %0 = IE.DynamicDequantize(%data0, %scale) {dstElemType = f16} : tensor<2x1536x128x!qElemType>, tensor<2x1536x1xf16> -> tensor<2x1536x128xf16> loc(fused<{name = "weight_dq", type = "DynamicDequantize"}>["weight_dq"])
    %1 = IE.Transpose(%0) {order_value = affine_map<(d0, d1, d2) -> (d1, d0, d2)>} : tensor<2x1536x128xf16> -> tensor<1536x2x128xf16>
    %2 = IE.AffineReshape(%1) {dim_mapping = [[0], [1], [1]], shape_value = [1536, 256]} : tensor<1536x2x128xf16> -> tensor<1536x256xf16>
    %3 = IE.FullyConnected(%act0, %2) : tensor<1x256xf16>, tensor<1536x256xf16> -> tensor<1x1536xf16>

    %4 = IE.DynamicDequantize(%data1, %scale) {dstElemType = f16} : tensor<2x1536x128x!qElemType>, tensor<2x1536x1xf16> -> tensor<2x1536x128xf16> loc(fused<{name = "matmul_dq", type = "DynamicDequantize"}>["matmul_dq"])
    %5 = IE.Transpose(%4) {order_value = affine_map<(d0, d1, d2) -> (d1, d0, d2)>} : tensor<2x1536x128xf16> -> tensor<1536x2x128xf16>
    %6 = IE.AffineReshape(%5) {dim_mapping = [[0], [1], [1]], shape_value = [1536, 256]} : tensor<1536x2x128xf16> -> tensor<1536x256xf16>
    %7 = IE.FullyConnected(%act1, %6) : tensor<1x256xf16>, tensor<1536x256xf16> -> tensor<1x1536xf16>

    return %3, %7 : tensor<1x1536xf16>, tensor<1x1536xf16>
}
