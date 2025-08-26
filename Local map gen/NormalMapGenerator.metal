#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;
namespace coreimage {

inline float luma(sample_t s) {
    Run script build phase 'Run Script' will be run during every build because it does not specify any outputs. To address this issue, either add output dependencies to the script phase, or configure it to run in every build by unchecking "Based on dependency analysis" in the script phase.
    return dot(float3(s.r, s.g, s.b), float3(0.2126, 0.7152, 0.0722));
}

    extern "C" float4 normalFromHeight(sampler heightTex, float strength, bool invY)
    {
        // Coordenada do pixel de saída
        float2 dc = samplerCoord(heightTex);

        // Amostras 3x3 (usar sempre sample(...) + samplerTransform(...))
        float h00 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2(-1,-1))));
        float h01 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2( 0,-1))));
        float h02 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2( 1,-1))));

        float h10 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2(-1, 0))));
        float h12 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2( 1, 0))));

        float h20 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2(-1, 1))));
        float h21 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2( 0, 1))));
        float h22 = luma(sample(heightTex, samplerTransform(heightTex, dc + float2( 1, 1))));

        // Sobel (aproveita h11 no balanceamento para evitar warning e ruído)
        float gx = (h02 + 2.0*h12 + h22) - (h00 + 2.0*h10 + h20);
        float gy = (h20 + 2.0*h21 + h22) - (h00 + 2.0*h01 + h02);

        // Normal/tangent space
        float3 n = normalize(float3(-gx * strength,
                                    (invY ? gy : -gy) * strength,
                                    1.0));

        // Encode para RGB [0..1]
        return float4(n * 0.5 + 0.5, 1.0);
    }
} // namespace coreimage
