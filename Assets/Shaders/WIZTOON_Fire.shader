// Made with Amplify Shader Editor v1.9.2.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Fire"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_NoisePrimary("Noise Primary", 2D) = "white" {}
		_Noise1Scale("Noise 1 Scale", Float) = 0.2
		_Noise2Scale("Noise 2 Scale", Float) = 0.4
		_Noise1Speed("Noise 1 Speed", Float) = -0.3
		_Noise1Speed1("Noise 1 Speed", Float) = -1
		_FireMask("Fire Mask", 2D) = "white" {}
		_OpacityStep("Opacity Step", Range( 0 , 1)) = 0
		_OuterColorTop("Outer Color Top", Color) = (0,0,0,0)
		_OuterColorBase("Outer Color Base", Color) = (0,0,0,0)
		_InnerColor("Inner Color", Color) = (0,0,0,0)
		_OuterColorBlend("Outer Color Blend", Range( 0 , 1)) = 0
		_Stepping("Stepping", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 screenPosition;
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _OuterColorBase;
		uniform float _OuterColorBlend;
		uniform float4 _OuterColorTop;
		uniform sampler2D _NoisePrimary;
		uniform float _Noise1Speed;
		uniform float _Noise1Scale;
		uniform float _Noise1Speed1;
		uniform float _Noise2Scale;
		uniform sampler2D _FireMask;
		uniform float4 _FireMask_ST;
		uniform float4 _InnerColor;
		uniform float _Stepping;
		uniform float _OpacityStep;
		uniform float _Cutoff = 0.5;


		inline float Dither8x8Bayer( int x, int y )
		{
			const float dither[ 64 ] = {
				 1, 49, 13, 61,  4, 52, 16, 64,
				33, 17, 45, 29, 36, 20, 48, 32,
				 9, 57,  5, 53, 12, 60,  8, 56,
				41, 25, 37, 21, 44, 28, 40, 24,
				 3, 51, 15, 63,  2, 50, 14, 62,
				35, 19, 47, 31, 34, 18, 46, 30,
				11, 59,  7, 55, 10, 58,  6, 54,
				43, 27, 39, 23, 42, 26, 38, 22};
			int r = y * 8 + x;
			return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 temp_cast_1 = (_OpacityStep).xxxx;
			float2 appendResult13 = (float2(0.0 , _Noise1Speed));
			float2 panner7 = ( 1.0 * _Time.y * appendResult13 + ( _Noise1Scale * i.uv_texcoord ));
			float2 appendResult14 = (float2(0.0 , _Noise1Speed1));
			float2 panner8 = ( 1.0 * _Time.y * appendResult14 + ( i.uv_texcoord * _Noise2Scale ));
			float2 uv_FireMask = i.uv_texcoord * _FireMask_ST.xy + _FireMask_ST.zw;
			float4 tex2DNode20 = tex2D( _FireMask, uv_FireMask );
			float4 temp_output_21_0 = ( ( ( tex2D( _NoisePrimary, panner7 ) * tex2D( _NoisePrimary, panner8 ) ) + tex2DNode20 ) * tex2DNode20 );
			c.rgb = 0;
			c.a = 1;
			clip( step( temp_cast_1 , temp_output_21_0 ).r - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen57 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither57 = Dither8x8Bayer( fmod(clipScreen57.x, 8), fmod(clipScreen57.y, 8) );
			float smoothstepResult41 = smoothstep( 0.0 , _OuterColorBlend , i.uv_texcoord.y);
			dither57 = step( dither57, smoothstepResult41 );
			float2 appendResult13 = (float2(0.0 , _Noise1Speed));
			float2 panner7 = ( 1.0 * _Time.y * appendResult13 + ( _Noise1Scale * i.uv_texcoord ));
			float2 appendResult14 = (float2(0.0 , _Noise1Speed1));
			float2 panner8 = ( 1.0 * _Time.y * appendResult14 + ( i.uv_texcoord * _Noise2Scale ));
			float2 uv_FireMask = i.uv_texcoord * _FireMask_ST.xy + _FireMask_ST.zw;
			float4 tex2DNode20 = tex2D( _FireMask, uv_FireMask );
			float4 temp_output_21_0 = ( ( ( tex2D( _NoisePrimary, panner7 ) * tex2D( _NoisePrimary, panner8 ) ) + tex2DNode20 ) * tex2DNode20 );
			o.Emission = ( floor( ( ( ( ( ( _OuterColorBase * ( 1.0 - dither57 ) ) + ( dither57 * _OuterColorTop ) ) * ( 1.0 - temp_output_21_0 ) ) + ( _InnerColor * temp_output_21_0 ) ) * _Stepping ) ) / _Stepping ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float2 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xyzw = customInputData.screenPosition;
				o.customPack2.xy = customInputData.uv_texcoord;
				o.customPack2.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.screenPosition = IN.customPack1.xyzw;
				surfIN.uv_texcoord = IN.customPack2.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1748.776,845.9422;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1439.517,749.1674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1441.621,915.3669;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1750.409,1007.692;Inherit;False;Property;_Noise2Scale;Noise 2 Scale;3;0;Create;True;0;0;0;False;0;False;0.4;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1744.35,702.4637;Inherit;False;Property;_Noise1Scale;Noise 1 Scale;2;0;Create;True;0;0;0;False;0;False;0.2;-1.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-1460.409,1130.692;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;13;-1458.191,558.3008;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1701.048,564.7673;Inherit;False;Property;_Noise1Speed;Noise 1 Speed;4;0;Create;True;0;0;0;False;0;False;-0.3;1.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1723.048,1204.767;Inherit;False;Property;_Noise1Speed1;Noise 1 Speed;5;0;Create;True;0;0;0;False;0;False;-1;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;8;-1152.654,1023.699;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;7;-1135.665,713.8004;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;5;-254.6068,925.274;Inherit;True;Property;_TextureSample1;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;4;-799.6067,841.274;Inherit;True;Property;_NoisePrimary;Noise Primary;1;0;Create;True;0;0;0;False;0;False;3eda0c4754885564f9df920405499055;32fddf230a08b458eb79f98aa76322e9;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;3;-258.2018,693.7272;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;103.7824,807.8574;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;447.1971,850.1356;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;20;180.5508,1085.035;Inherit;True;Property;_FireMask;Fire Mask;6;0;Create;True;0;0;0;False;0;False;-1;None;e9dd706e40ee245478372d7130ccd106;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;698.3065,1212.827;Inherit;False;Property;_OpacityStep;Opacity Step;7;0;Create;True;0;0;0;False;0;False;0;0.172;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;25;879.8472,941.1055;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;457.5739,651.118;Inherit;False;Property;_InnerFlameStep;Inner Flame Step;8;0;Create;True;0;0;0;False;0;False;0;0.431;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;32;1009.456,1089.391;Inherit;False;Property;_InnerColor;Inner Color;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9644862,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;33;1371.374,637.4042;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;24;793.1621,768.8387;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;28;940.6761,680.5956;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;1115.904,543.0344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;1153.567,769.0281;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;43;802.422,166.0189;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1101.249,291.2032;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;1103.941,145.8279;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;814.5367,-38.58327;Inherit;False;Property;_OuterColorBase;Outer Color Base;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.544676,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;1359.694,225.2459;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;49;595.128,417.7335;Inherit;False;Property;_OuterColorTop;Outer Color Top;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0.6941175,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;50;884.3199,575.0211;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;51;724.8356,1033.755;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;1505.801,467.1731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;1754.834,508.3867;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;1399.98,1091.361;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;588.1595,851.0439;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-133.6491,151.1905;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;41;517.4655,153.3612;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;107.7175,355.6319;Inherit;False;Property;_OuterColorBlend;Outer Color Blend;12;0;Create;True;0;0;0;False;0;False;0;0.862;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;57;775.5281,248.0067;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2185.746,678.2161;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;2139.642,476.127;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;1909.218,480.7358;Inherit;False;Property;_Stepping;Stepping;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;60;2402.326,483.04;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;61;2632.751,616.6863;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
WireConnection;9;0;11;0
WireConnection;9;1;6;0
WireConnection;10;0;6;0
WireConnection;10;1;12;0
WireConnection;14;1;16;0
WireConnection;13;1;15;0
WireConnection;8;0;10;0
WireConnection;8;2;14;0
WireConnection;7;0;9;0
WireConnection;7;2;13;0
WireConnection;5;0;4;0
WireConnection;5;1;8;0
WireConnection;3;0;4;0
WireConnection;3;1;7;0
WireConnection;17;0;3;0
WireConnection;17;1;5;0
WireConnection;18;0;17;0
WireConnection;18;1;20;0
WireConnection;25;0;26;0
WireConnection;25;1;21;0
WireConnection;33;0;29;0
WireConnection;33;1;30;0
WireConnection;24;0;27;0
WireConnection;24;1;21;0
WireConnection;28;0;24;0
WireConnection;29;1;28;0
WireConnection;30;0;24;0
WireConnection;30;1;32;0
WireConnection;43;0;57;0
WireConnection;44;0;57;0
WireConnection;44;1;49;0
WireConnection;45;0;46;0
WireConnection;45;1;43;0
WireConnection;47;0;45;0
WireConnection;47;1;44;0
WireConnection;51;0;21;0
WireConnection;48;0;47;0
WireConnection;48;1;51;0
WireConnection;52;0;48;0
WireConnection;52;1;53;0
WireConnection;53;0;32;0
WireConnection;53;1;21;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;41;0;40;2
WireConnection;41;2;42;0
WireConnection;57;0;41;0
WireConnection;0;2;61;0
WireConnection;0;10;25;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;60;0;58;0
WireConnection;61;0;60;0
WireConnection;61;1;59;0
ASEEND*/
//CHKSM=46D793BD6A3280092F9B48A16312CD6445A1BD0C