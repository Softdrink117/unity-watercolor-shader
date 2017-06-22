Shader "Hidden/waterColor_pp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		// Remappable Saturation Range
		_LowThreshold("Low Threshold", Range(0,0.99)) = 0.0
		_HighThreshold("High Threshold", Range(0.01, 1.0)) = 1.0

		[Toggle(DEBUG_SELECTION)] _DebugSelection("Debug - View Selection", Float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma shader_feature DEBUG_SELECTION
			
			#include "UnityCG.cginc"


			// HSB conversion code adapted from https://www.laurivan.com/rgb-to-hsv-to-rgb-for-shaders/
			float3 rgb2hsv(fixed3 c){
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	            float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	            float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

	            float d = q.x - min(q.w, q.y);
	            float e = 1.0e-10;
	            return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
			
			// Properties -----------------------------------------------------------------------------
			sampler2D _MainTex;

			half _LowThreshold;
			half _HighThreshold;


			// Fragment -------------------------------------------------------------------------------
			fixed4 frag (v2f_img i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				//col = 1 - col;

				fixed3 hsv = rgb2hsv(col);
				// Remap saturation based on low and high threshold values
				hsv.y = (hsv.y - _LowThreshold) / (_HighThreshold - _LowThreshold) * (1.0 - 0.0) + 0.0;
				// Debug display - render only the selection region
				#ifdef DEBUG_SELECTION
					col.xyz = hsv.y;
					return col;
				#endif

				return col;
			}
			ENDCG
		}
	}
}
