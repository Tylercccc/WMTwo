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
		[IntRange]_Stepping("Stepping", Range( 2 , 10)) = 0
		_DepthDistance("Depth Distance", Float) = 0
		_PremultiplyBlend("PremultiplyBlend", Float) = 0
		_Scale("Scale", Float) = 0
		_Float2("Float 2", Float) = 0
		_Float3("Float 2", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend One OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha vertex:vertexDataFunc 
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

		uniform float _Float2;
		uniform float _Float3;
		uniform float _Scale;
		uniform float4 _OuterColorBase;
		uniform float _OuterColorBlend;
		uniform float4 _OuterColorTop;
		uniform float4 _InnerColor;
		uniform sampler2D _NoisePrimary;
		uniform float _Noise1Speed;
		uniform float _Noise1Scale;
		uniform float _Noise1Speed1;
		uniform float _Noise2Scale;
		uniform sampler2D _FireMask;
		uniform float4 _FireMask_ST;
		uniform float _Stepping;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _DepthDistance;
		uniform float _PremultiplyBlend;
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


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 appendResult178 = (float3((v.texcoord.xy.y*_Float2 + _Float3) , 0.0 , 0.0));
			float3 temp_output_192_0 = mul( UNITY_MATRIX_V, float4( float3(0,0,1) , 0.0 ) ).xyz;
			float3 normalizeResult182 = normalize( ( mul( float4( cross( appendResult178 , temp_output_192_0 ) , 0.0 ), unity_ObjectToWorld ).xyz * _Scale ) );
			v.vertex.xyz += normalizeResult182;
			v.vertex.w = 1;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen93 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither93 = Dither4x4Bayer( fmod(clipScreen93.x, 4), fmod(clipScreen93.y, 4) );
			float2 appendResult13 = (float2(0.0 , _Noise1Speed));
			float2 panner7 = ( 1.0 * _Time.y * appendResult13 + ( _Noise1Scale * i.uv_texcoord ));
			float2 appendResult14 = (float2(0.0 , _Noise1Speed1));
			float2 panner8 = ( 1.0 * _Time.y * appendResult14 + ( i.uv_texcoord * _Noise2Scale ));
			float2 uv_FireMask = i.uv_texcoord * _FireMask_ST.xy + _FireMask_ST.zw;
			float4 tex2DNode20 = tex2D( _FireMask, uv_FireMask );
			float4 temp_output_21_0 = ( ( ( tex2D( _NoisePrimary, panner7 ) * tex2D( _NoisePrimary, panner8 ) ) + tex2DNode20 ) * tex2DNode20 );
			float screenDepth85 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth85 = abs( ( screenDepth85 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _DepthDistance ) );
			dither93 = step( dither93, ( ( temp_output_21_0 * distanceDepth85 ) + _PremultiplyBlend ).r );
			float4 temp_cast_2 = (_OpacityStep).xxxx;
			c.rgb = 0;
			c.a = saturate( dither93 );
			c.rgb *= c.a;
			clip( step( temp_cast_2 , temp_output_21_0 ).r - _Cutoff );
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
			o.Emission = ( floor( ( ( ( ( _OuterColorBase * ( 1.0 - dither57 ) ) + ( dither57 * _OuterColorTop ) ) + ( _InnerColor * temp_output_21_0 ) ) * _Stepping ) ) / _Stepping ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19202
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1748.776,845.9422;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1439.517,749.1674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1441.621,915.3669;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1750.409,1007.692;Inherit;False;Property;_Noise2Scale;Noise 2 Scale;3;0;Create;True;0;0;0;False;0;False;0.4;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1744.35,702.4637;Inherit;False;Property;_Noise1Scale;Noise 1 Scale;2;0;Create;True;0;0;0;False;0;False;0.2;-1.5;0;0;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.OneMinusNode;43;802.422,166.0189;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1101.249,291.2032;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;1103.941,145.8279;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;814.5367,-38.58327;Inherit;False;Property;_OuterColorBase;Outer Color Base;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.544676,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;47;1359.694,225.2459;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;49;595.128,417.7335;Inherit;False;Property;_OuterColorTop;Outer Color Top;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0.6128168,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;1754.834,508.3867;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-133.6491,151.1905;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;41;517.4655,153.3612;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;107.7175,355.6319;Inherit;False;Property;_OuterColorBlend;Outer Color Blend;11;0;Create;True;0;0;0;False;0;False;0;0.667;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;57;775.5281,248.0067;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;2139.642,476.127;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;60;2402.326,483.04;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;61;2501.122,573.8545;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;1852.805,617.588;Inherit;False;Property;_Stepping;Stepping;12;1;[IntRange];Create;True;0;0;0;False;0;False;0;3;2;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;1035.421,879.7985;Inherit;False;Property;_OpacityStep;Opacity Step;7;0;Create;True;0;0;0;False;0;False;0;0.048;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;1703.189,826.9122;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;1402.145,908.5464;Inherit;False;Property;_PremultiplyBlend;PremultiplyBlend;14;0;Create;True;0;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;724.3154,848.8118;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;32;1016.247,528.5277;Inherit;False;Property;_InnerColor;Inner Color;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.9644862,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;1295.192,661.7043;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;84;592.5465,1377.174;Inherit;False;Property;_DepthDistance;Depth Distance;13;0;Create;True;0;0;0;False;0;False;0;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2185.746,678.2161;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;3;1;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.DepthFade;85;788.1309,1331.026;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;8.24;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;1075.288,1162.865;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;2208.945,1654.887;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;2571.369,1669.031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;102;2476.044,1982.09;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;2721.781,1963.323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;97;2392.808,1669.03;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;105;2608.495,2133.995;Inherit;False;Property;_Float0;Float 0;16;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;2348.611,1444.504;Inherit;False;Property;_PushForward;Push Forward;15;0;Create;True;0;0;0;False;0;False;0;-0.5;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;95;1850.056,1674.334;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;103;1827.052,2117.7;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;25;1851.744,944.3887;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;89;2009.729,833.7098;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;93;1477.739,1276;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;1316.146,2538.061;Inherit;False;Property;_Float1;Float 1;17;0;Create;True;0;0;0;False;0;False;0;11.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;165;1068.662,2147.976;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BillboardNode;110;2040.746,1886.936;Inherit;False;Cylindrical;False;False;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;1587.95,2349.038;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;1616.72,1468.718;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;94;1881.155,1508.709;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;172;2987.777,1726.628;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;173;2571.21,2432.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;100;2721.633,1811.706;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;174;1753.206,2070.64;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;2932.287,855.1425;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;2,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;3128.752,847.3661;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;178;3266.753,858.3661;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;3468.753,889.3662;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;181;3639.753,878.3662;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;183;4033.754,1059.366;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;184;3885.753,1145.366;Inherit;False;Property;_Scale;Scale;18;0;Create;True;0;0;0;False;0;False;0;-6.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;3575.598,1211.252;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;187;3352.19,1291.601;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;175;2675.199,831.3839;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceViewDirHlpNode;190;2774.279,1063.039;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewMatrixNode;180;3142.753,1002.366;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.NormalizeNode;182;3893.335,933.8182;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;193;4301.849,1288.792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;3309.278,1126.942;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;191;3209.279,1374.125;Inherit;False;Constant;_Vector0;Vector 0;21;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;185;2979.473,1196.699;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;2391.922,1248.487;Inherit;False;Property;_Float2;Float 2;19;0;Create;True;0;0;0;False;0;False;0;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;2727.036,1424.862;Inherit;False;Property;_Float3;Float 2;20;0;Create;True;0;0;0;False;0;False;0;-0.38;0;0;0;1;FLOAT;0
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
WireConnection;43;0;57;0
WireConnection;44;0;57;0
WireConnection;44;1;49;0
WireConnection;45;0;46;0
WireConnection;45;1;43;0
WireConnection;47;0;45;0
WireConnection;47;1;44;0
WireConnection;52;0;47;0
WireConnection;52;1;53;0
WireConnection;41;0;40;2
WireConnection;41;2;42;0
WireConnection;57;0;41;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;60;0;58;0
WireConnection;61;0;60;0
WireConnection;61;1;59;0
WireConnection;87;0;91;0
WireConnection;87;1;88;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;53;0;32;0
WireConnection;53;1;21;0
WireConnection;0;2;61;0
WireConnection;0;9;89;0
WireConnection;0;10;25;0
WireConnection;0;11;182;0
WireConnection;85;0;84;0
WireConnection;91;0;21;0
WireConnection;91;1;85;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;98;0;99;0
WireConnection;98;1;97;0
WireConnection;102;0;110;0
WireConnection;102;1;103;0
WireConnection;104;0;105;0
WireConnection;104;1;102;0
WireConnection;97;0;96;0
WireConnection;25;0;26;0
WireConnection;25;1;21;0
WireConnection;89;0;93;0
WireConnection;93;0;87;0
WireConnection;169;0;170;0
WireConnection;169;1;173;0
WireConnection;153;0;100;0
WireConnection;153;1;174;0
WireConnection;172;0;104;0
WireConnection;173;0;172;2
WireConnection;100;0;98;0
WireConnection;100;1;104;0
WireConnection;174;0;169;0
WireConnection;176;0;175;0
WireConnection;177;0;176;0
WireConnection;178;0;185;0
WireConnection;179;0;178;0
WireConnection;179;1;192;0
WireConnection;181;0;179;0
WireConnection;183;0;186;0
WireConnection;183;1;184;0
WireConnection;186;0;193;0
WireConnection;186;1;187;0
WireConnection;182;0;183;0
WireConnection;193;0;178;0
WireConnection;193;1;192;0
WireConnection;192;0;180;0
WireConnection;192;1;191;0
WireConnection;185;0;175;2
WireConnection;185;1;188;0
WireConnection;185;2;189;0
ASEEND*/
//CHKSM=3CF4D80A59A7518129984F49306F03AEF08983D9