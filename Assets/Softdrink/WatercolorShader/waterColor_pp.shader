Shader "Hidden/waterColor_pp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_NoiseScaleOffset("Noise Scale Offset", Vector) = (1.0,1.0,0.0,0.0)

		// Deflection settings
		_Deflection ("Deflection", Vector) = (0.5,0.5,0.0,0.0)

		_Radius ("Blur Radius", Float) = 5.0

		_STime ("Time", Float) = 0.0

		// Evolution settings
		_SpeedX ("Evolution Speed X", Float) = 0.01
		_SpeedY ("Evolution Speed Y", Float) = 0.01

		// Offsets
		_Scale ("Noise Scale", Vector) = (0.1, 0.1, 0.0, 0.0)
		_Offset1 ("First Order Offset", Vector) = (1.8, 2.1, 3.6, 4.2)
		_Offset2 ("Second Order Offset", Vector) = (2.4, 1.9, 3.7, 2.9)

		// Remappable Saturation Range
		_LowThreshold ("Low Threshold", Range(0,0.99)) = 0.0
		_HighThreshold ("High Threshold", Range(0.01, 1.0)) = 1.0

		[Toggle(DEBUG_SELECTION)] _DebugSelection ("Debug - View Selection", Float) = 0
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

			// Properties -----------------------------------------------------------------------------
			sampler2D _MainTex;
			sampler2D _NoiseTex;
			half4 _NoiseScaleOffset;
			half4 _MainTex_TexelSize;

			float _Deflection;

			float _Radius;

			float _STime;

			float _SpeedX;
			float _SpeedY;

			float4 _Scale;
			float4 _Offset1;
			float4 _Offset2;

			half _LowThreshold;
			half _HighThreshold;

			// Custom functions -----------------------------------------------------------------------

			// HSB conversion code adapted from https://www.laurivan.com/rgb-to-hsv-to-rgb-for-shaders/
			float3 rgb2hsv(fixed3 c){
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	            float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
	            float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

	            float d = q.x - min(q.w, q.y);
	            float e = 1.0e-10;
	            return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			// Inspired by the commentary of @gordonnl/the-ocean wind waker analysis
			float2 calcOffset(fixed2 pos){
				pos = pos * _Scale;
				return float2((sin(pos.x + _STime * _SpeedX) + 
						   	sin(pos.x * _Offset1.x + _STime * _SpeedX * _Offset1.y) +
						   	sin(pos.x * _Offset1.z + _STime * _SpeedX * _Offset1.w))/3.0, 
							(sin(pos.y + _STime * _SpeedY) + 
							sin(pos.y * _Offset2.x + _STime * _SpeedY * _Offset2.y) + 
							sin(pos.y * _Offset2.z + _STime * _SpeedY * _Offset2.w))/3.0);
			}
			
			


			// Fragment -------------------------------------------------------------------------------
			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 uv = i.uv;
				fixed4 col = tex2D(_MainTex, uv);

				float4 sum = float4(0.0, 0.0, 0.0, 0.0);

				fixed3 hsv = rgb2hsv(col);
				// Remap saturation based on low and high threshold values
				hsv.y = (hsv.y - _LowThreshold) / (_HighThreshold - _LowThreshold) * (1.0 - 0.0) + 0.0;
				// Debug display - render only the selection region
				#ifdef DEBUG_SELECTION
					col.xyz = hsv.y;
					return col;
				#endif

				// Resample UVs based on the sampled selection
				uv = uv + (calcOffset(uv) * _Deflection * hsv.y);

				col = tex2D(_MainTex, uv);

				//col *= tex2D(_NoiseTex, (uv * _NoiseScaleOffset.xy) + _NoiseScaleOffset.zw);



				// Blur radius, in pixels
				float blur = _Radius / _MainTex_TexelSize.z * hsv.y;

				fixed2 step = fixed2(1, 0);

				sum += tex2D(_MainTex, float2(uv.x - 4.0*blur*step.x, uv.y - 4.0*blur*step.y)) * 0.0162162162 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 3.0*blur*step.x, uv.y - 3.0*blur*step.y)) * 0.0540540541 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 2.0*blur*step.x, uv.y - 2.0*blur*step.y)) * 0.1216216216 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 1.0*blur*step.x, uv.y - 1.0*blur*step.y)) * 0.1945945946 / 2;

                sum += tex2D(_MainTex, float2(uv.x, uv.y)) * 0.2270270270 / 2;

                sum += tex2D(_MainTex, float2(uv.x + 1.0*blur*step.x, uv.y + 1.0*blur*step.y)) * 0.1945945946 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 2.0*blur*step.x, uv.y + 2.0*blur*step.y)) * 0.1216216216 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 3.0*blur*step.x, uv.y + 3.0*blur*step.y)) * 0.0540540541 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 4.0*blur*step.x, uv.y + 4.0*blur*step.y)) * 0.0162162162 / 2;

                step = fixed2(0, 1);

                sum += tex2D(_MainTex, float2(uv.x - 4.0*blur*step.x, uv.y - 4.0*blur*step.y)) * 0.0162162162 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 3.0*blur*step.x, uv.y - 3.0*blur*step.y)) * 0.0540540541 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 2.0*blur*step.x, uv.y - 2.0*blur*step.y)) * 0.1216216216 / 2;
                sum += tex2D(_MainTex, float2(uv.x - 1.0*blur*step.x, uv.y - 1.0*blur*step.y)) * 0.1945945946 / 2;

                sum += tex2D(_MainTex, float2(uv.x, uv.y)) * 0.2270270270 / 2;

                sum += tex2D(_MainTex, float2(uv.x + 1.0*blur*step.x, uv.y + 1.0*blur*step.y)) * 0.1945945946 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 2.0*blur*step.x, uv.y + 2.0*blur*step.y)) * 0.1216216216 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 3.0*blur*step.x, uv.y + 3.0*blur*step.y)) * 0.0540540541 / 2;
                sum += tex2D(_MainTex, float2(uv.x + 4.0*blur*step.x, uv.y + 4.0*blur*step.y)) * 0.0162162162 / 2;

                sum *= tex2D(_NoiseTex, (uv * _NoiseScaleOffset.xy) + _NoiseScaleOffset.zw);
                return float4(sum.rgb, 1);

				return col;
			}
			ENDCG
		}
	}
}
