"""
Build two tiny, matched-size synthetic models for OVMS #4428 GenAI-level reproduction:

  A) "hybrid"   - Qwen3NextConfig (real transformers architecture class behind Qwen3.6,
                  Gated DeltaNet linear-attention layers interleaved with full-attention
                  layers at the real 4:1 ratio) - matches the crashing model family's
                  architecture class.
  B) "standard" - Qwen3Config (dense, standard SDPA full-attention only, no MoE, no
                  linear-attention layers) - the architecture class mzegla asked to
                  compare against ("older, standard SDPA models").

Both are random-initialized (not pretrained) at matched hidden_size/layer count/head
count so the ONLY architectural variable between the two is attention type - this
isolates the "does block-manager flow differ by attention type" question mzegla asked,
rather than conflating it with model scale or quality.

Both reuse the real Qwen3-Next tokenizer (downloaded, not the pretrained weights) so
tokenization/vocab is real and identical across both models.
"""
import os
import sys
from transformers import AutoTokenizer, AutoModelForCausalLM
from transformers.models.qwen3_next.configuration_qwen3_next import Qwen3NextConfig
from transformers.models.qwen3.configuration_qwen3 import Qwen3Config

OUT_ROOT = os.path.join(os.path.dirname(__file__), "models")
os.makedirs(OUT_ROOT, exist_ok=True)

print("Downloading Qwen3-Next tokenizer (tokenizer only, not weights)...")
tok = AutoTokenizer.from_pretrained("Qwen/Qwen3-Next-80B-A3B-Instruct")
vocab_size = len(tok)
print("tokenizer vocab size:", vocab_size)

COMMON = dict(
    vocab_size=vocab_size,
    hidden_size=128,
    intermediate_size=256,
    num_hidden_layers=8,
    num_attention_heads=4,
    num_key_value_heads=2,
    head_dim=32,
    max_position_embeddings=8192,
    tie_word_embeddings=True,
)

def build_hybrid():
    cfg = Qwen3NextConfig(
        **COMMON,
        linear_conv_kernel_dim=4,
        linear_key_head_dim=32,
        linear_value_head_dim=32,
        linear_num_key_heads=4,
        linear_num_value_heads=8,
        full_attention_interval=4,   # real Qwen3.6 ratio: every 4th layer is full attention
        # MoE disabled (num_experts=0 -> dense Qwen3NextMLP on every layer, identical
        # FFN shape to the "standard" model below). This isolates attention-type
        # (linear-attention+full-attention hybrid vs. plain full-attention) as the
        # ONLY architectural variable between the two models, and also sidesteps a
        # separate, unrelated finding from this session: the GPU plugin in this
        # OpenVINO GenAI build does not implement the MOE(extension) op used by
        # Qwen3NextSparseMoeBlock ("Operation: ...mlp/aten::add/Add of type
        # MOE(extension) is not supported" on intel_gpu) - MoE would have made the
        # hybrid model GPU-untestable for a reason unrelated to KV-cache/block-manager.
        num_experts=0,
    )
    print("hybrid layer_types:", cfg.layer_types)
    model = AutoModelForCausalLM.from_config(cfg)
    n_params = sum(p.numel() for p in model.parameters())
    print("hybrid model params:", n_params)
    out_dir = os.path.join(OUT_ROOT, "tiny-qwen3next-hybrid")
    model.save_pretrained(out_dir)
    tok.save_pretrained(out_dir)
    return out_dir, cfg.layer_types, n_params

def build_standard():
    cfg = Qwen3Config(**COMMON)
    model = AutoModelForCausalLM.from_config(cfg)
    n_params = sum(p.numel() for p in model.parameters())
    print("standard model params:", n_params)
    out_dir = os.path.join(OUT_ROOT, "tiny-qwen3-standard")
    model.save_pretrained(out_dir)
    tok.save_pretrained(out_dir)
    return out_dir, n_params

if __name__ == "__main__":
    h_dir, h_layers, h_params = build_hybrid()
    s_dir, s_params = build_standard()
    print("HYBRID_DIR", h_dir)
    print("HYBRID_LAYER_TYPES", h_layers)
    print("HYBRID_PARAMS", h_params)
    print("STANDARD_DIR", s_dir)
    print("STANDARD_PARAMS", s_params)
