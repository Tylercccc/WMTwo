// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Water"
{
	Properties
	{
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_ShalowColor("Shalow Color", Color) = (1,1,1,0)
		_WaterDepth("Water Depth", Float) = 0
		_WaterFalloff("Water Falloff", Float) = 0
		_Distortion("Distortion", Float) = 0.5
		_Watertint("Water tint", Color) = (0,0,0,0)
		_Depthsteps("Depth steps", Float) = 0
		_refreactsteps("refreact steps", Range( 0 , 200)) = 0
		_Foam("Foam", 2D) = "white" {}
		_FoamDepth("Foam Depth", Float) = 0
		_Float0("Float 0", Float) = 0
		_FoamFalloff("Foam Falloff", Float) = 0
		_DitherDepth("Dither Depth", Range( 0 , 1)) = 0
		_foamsteps("foam steps", Float) = 0
		_Foamtiling("Foam tiling", Vector) = (0,0,0,0)
		_foamdepthfade("foam depth fade", Float) = 0
		_Displacement("Displacement", Float) = 0
		_test("test", Float) = 0
		_s("s", Float) = 0
		_FoamColor("Foam Color", Color) = (0,0,0,0)
		_refractionmult("refraction mult", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf StandardCustomLighting keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPosition;
			float2 uv_texcoord;
			float eyeDepth;
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

		uniform sampler2D _WaterNormal;
		uniform half _Float0;
		uniform half _refreactsteps;
		uniform float _NormalScale;
		uniform half _Displacement;
		uniform half4 _Watertint;
		uniform float4 _DeepColor;
		uniform float4 _ShalowColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform half _Depthsteps;
		uniform float _WaterDepth;
		uniform float _WaterFalloff;
		uniform half _DitherDepth;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _Distortion;
		uniform half _refractionmult;
		uniform half _foamdepthfade;
		uniform float _FoamDepth;
		uniform float _FoamFalloff;
		uniform half _foamsteps;
		uniform sampler2D _Foam;
		uniform half2 _Foamtiling;
		uniform half _s;
		uniform half _test;
		uniform half4 _FoamColor;


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
			half mulTime471 = _Time.y * _Float0;
			half temp_output_467_0 = ( floor( mulTime471 ) / _refreactsteps );
			half2 panner419 = ( temp_output_467_0 * float2( -0.03,0 ) + v.texcoord.xy);
			half2 panner420 = ( temp_output_467_0 * float2( 0.04,0.04 ) + v.texcoord.xy);
			half3 normal259 = BlendNormals( UnpackScaleNormal( tex2Dlod( _WaterNormal, float4( panner419, 0, 1.0) ), _NormalScale ) , UnpackScaleNormal( tex2Dlod( _WaterNormal, float4( panner420, 0, 1.0) ), _NormalScale ) );
			v.vertex.xyz += ( normal259 * _Displacement );
			v.vertex.w = 1;
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half eyeDepth435 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half temp_output_444_0 = pow( ( ( floor( abs( ( eyeDepth435 - ase_screenPos.w ) ) ) / _Depthsteps ) + _WaterDepth ) , _WaterFalloff );
			half2 clipScreen484 = ase_screenPosNorm.xy * _ScreenParams.xy;
			half dither484 = Dither4x4Bayer( fmod(clipScreen484.x, 4), fmod(clipScreen484.y, 4) );
			dither484 = step( dither484, temp_output_444_0 );
			half temp_output_446_0 = saturate( ( temp_output_444_0 < _DitherDepth ? dither484 : temp_output_444_0 ) );
			half4 lerpResult449 = lerp( _DeepColor , _ShalowColor , temp_output_446_0);
			half mulTime471 = _Time.y * _Float0;
			half temp_output_467_0 = ( floor( mulTime471 ) / _refreactsteps );
			half2 panner419 = ( temp_output_467_0 * float2( -0.03,0 ) + i.uv_texcoord);
			half2 panner420 = ( temp_output_467_0 * float2( 0.04,0.04 ) + i.uv_texcoord);
			half3 normal259 = BlendNormals( UnpackScaleNormal( tex2D( _WaterNormal, panner419 ), _NormalScale ) , UnpackScaleNormal( tex2D( _WaterNormal, panner420 ), _NormalScale ) );
			half eyeDepth28_g1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half2 temp_output_20_0_g1 = ( (normal259).xy * ( _Distortion / max( i.eyeDepth , 0.1 ) ) * saturate( ( eyeDepth28_g1 - i.eyeDepth ) ) );
			half eyeDepth2_g1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( half4( temp_output_20_0_g1, 0.0 , 0.0 ) + ase_screenPosNorm ).xy ));
			half2 temp_output_32_0_g1 = (( half4( ( temp_output_20_0_g1 * saturate( ( eyeDepth2_g1 - i.eyeDepth ) ) ), 0.0 , 0.0 ) + ase_screenPosNorm )).xy;
			half2 temp_output_1_0_g1 = ( ( floor( ( temp_output_32_0_g1 * (_CameraDepthTexture_TexelSize).zw ) ) + 0.5 ) * (_CameraDepthTexture_TexelSize).xy );
			float4 screenColor458 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_1_0_g1);
			half4 lerpResult459 = lerp( lerpResult449 , saturate( ( screenColor458 * _refractionmult ) ) , temp_output_446_0);
			float2 uv_TexCoord492 = i.uv_texcoord * _Foamtiling;
			half2 panner495 = ( 1.0 * _Time.y * float2( -0.01,0.01 ) + uv_TexCoord492);
			half temp_output_498_0 = ( saturate( ( floor( pow( ( 0.0 + _FoamDepth ) , _FoamFalloff ) ) / _foamsteps ) ) * tex2D( _Foam, panner495 ).r );
			float screenDepth505 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half distanceDepth505 = abs( ( screenDepth505 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( _foamdepthfade * temp_output_498_0 ) ) );
			half temp_output_545_0 = ( 1.0 - distanceDepth505 );
			half temp_output_544_0 = ( step( temp_output_545_0 , _s ) * saturate( ( floor( ( temp_output_498_0 * _test ) ) / _foamsteps ) ) );
			c.rgb = ( ( lerpResult459 + ( saturate( ( temp_output_545_0 > 0.3 ? temp_output_544_0 : 0.0 ) ) * _FoamColor ) ) + float4( 0,0,0,0 ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Albedo = _Watertint.rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;450;-4267.783,1840.563;Inherit;False;1106.2;503.3005;Comment;10;440;441;442;443;444;445;446;447;448;449;Cepth Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-2675.733,-887.3652;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;0;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4290.296,-456.7152;Inherit;False;1025.107;587.7744;Basic lighting;0;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;0;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;0;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;0;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2885.612,-913.2354;Inherit;False;1379.942;546.2153;;0;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2443.691,-1389.961;Inherit;False;888.2502;342.3433;;0;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1768.84,307.8115;Inherit;False;932.1631;425.7859;Directional Light Only;0;Shadow Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-19.37829,440.4236;Inherit;False;464.8;298.7;Material Color;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;1;259;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4202.939,635.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;416;-5556.146,1076.123;Inherit;False;1281.603;457.1994;Blend panning normals to fake noving ripples;7;423;422;421;420;419;418;417;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-5177.546,1363.221;Float;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;0;False;0;False;0;4.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;423;-4449.543,1278.922;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;421;-4876.545,1344.322;Inherit;True;Property;_WaterNormal;Water Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;c78e565eaf65cb1428fac66341a4a8bc;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;432;-5457.684,2051.365;Inherit;False;843.903;553.8391;Screen depth difference to get intersection and fading effect with terrain and objects;5;437;436;435;434;433;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;433;-5414.827,2131.204;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;443;-4101.583,1890.563;Float;False;Property;_DeepColor;Deep Color;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2971698,0.6733906,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;445;-3859.182,1979.764;Float;False;Property;_ShalowColor;Shalow Color;3;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.2783019,0.6091777,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;446;-3653.587,2211.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;447;-3555.09,1953.481;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;448;-3553.19,2046.081;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;449;-3343.582,2087.365;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;451;-2804.089,1746.938;Inherit;False;985.6011;418.6005;Get screen color for refraction and disturbe it with normals;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;622.9008,439.6371;Half;False;True;-1;4;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;462;261.6738,217.1814;Inherit;False;Property;_Watertint;Water tint;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;434;-5414.683,2298.865;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;435;-5187.683,2104.365;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;417;-5506.146,1153.422;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;470;-5702.961,1300.054;Inherit;False;Property;_refreactsteps;refreact steps;9;0;Create;True;0;0;0;False;0;False;0;3;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;466;-5633.232,1617.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;467;-5333.317,1473.493;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;420;-5231.146,1238.622;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0.04;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;419;-5233.446,1124.407;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.03,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;471;-5846.468,1623.348;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;472;-5712.078,1494.699;Inherit;False;Property;_Float0;Float 0;12;0;Create;True;0;0;0;False;0;False;0;3.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;458;-343.7294,919.8429;Float;False;Global;_WaterGrab;WaterGrab;-1;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;483;-1207.767,1003.649;Inherit;False;Sai_DepthMaskedRefraction;-1;;1;bb954a2a716624fed8b85e64959850f3;2,40,0,103,0;2;35;FLOAT3;0,0,0;False;37;FLOAT;0.02;False;1;FLOAT2;38
Node;AmplifyShaderEditor.GetLocalVarNode;460;-1629.441,1024.048;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;452;-1439.647,1173.904;Float;False;Property;_Distortion;Distortion;6;0;Create;True;0;0;0;False;0;False;0.5;0.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;484;-3980.134,2479.743;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;487;-3702.907,2452.007;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;-3951.742,2720.06;Inherit;False;Property;_DitherDepth;Dither Depth;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;489;-1217.752,2099.232;Inherit;False;1083.102;484.2006;Foam controls and texture;9;498;497;496;495;494;493;492;491;490;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1096.051,2223.132;Float;False;Property;_FoamDepth;Foam Depth;11;0;Create;True;0;0;0;False;0;False;0;3.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-915.8494,2149.232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;492;-1167.752,2396.633;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;493;-905.2504,2285.032;Float;False;Property;_FoamFalloff;Foam Falloff;13;0;Create;True;0;0;0;False;0;False;0;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;494;-731.0498,2158.132;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;495;-947.0486,2416.832;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.01,0.01;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;496;-678.2495,2371.432;Inherit;True;Property;_Foam;Foam;10;0;Create;True;0;0;0;False;0;False;-1;None;2a2d71ee416d3c844adfa1a053ea32f4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;497;-509.8487,2206.132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;422;-4889.446,1134.422;Inherit;True;Property;_Normal2;Normal2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;421;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;504;-1217.635,2641.278;Inherit;False;Property;_Foamtiling;Foam tiling;16;0;Create;True;0;0;0;False;0;False;0,0;1.5,1.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;509;732.6758,1837.392;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;112.8671,757.9426;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;515;134.3433,1010.884;Inherit;False;Property;_Displacement;Displacement;18;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;149.4731,1502.328;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;534;463.2893,1267.483;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;244.6349,903.9972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-228.3755,1944.643;Inherit;False;Property;_foamdepthfade;foam depth fade;17;0;Create;True;0;0;0;False;0;False;0;-0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;501;438.1416,2256.907;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;547;1279.517,2658.775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;-298.5065,2310.249;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;500;299.8668,2603.334;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;542;-86.02277,2639.02;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-284.3555,2649.823;Inherit;False;Property;_test;test;19;0;Create;True;0;0;0;False;0;False;0;3.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;550;-291.769,2839.879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;551;-63.78341,2933.145;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;548;634.6291,2480.725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;444;-3859.888,2189.881;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-4040.283,2228.864;Float;False;Property;_WaterFalloff;Water Falloff;5;0;Create;True;0;0;0;False;0;False;0;-1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;-4036.088,2103.481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-4214.159,2240.276;Float;False;Property;_WaterDepth;Water Depth;4;0;Create;True;0;0;0;False;0;False;0;1.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;464;-4202.739,2380.116;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;463;-4331.841,2365.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-4400.226,2582.292;Inherit;False;Property;_Depthsteps;Depth steps;8;0;Create;True;0;0;0;False;0;False;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;437;-4741.509,2194.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-4950.284,2187.349;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;90.62681,2076.889;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;505;306.4586,2077.939;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;502;147.9153,2397.845;Inherit;False;Property;_foamsteps;foam steps;15;0;Create;True;0;0;0;False;0;False;0;2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;553;857.0134,2161.56;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;672.8892,2069.499;Inherit;False;Property;_s;s;20;0;Create;True;0;0;0;False;0;False;0;4.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;985.1777,1704.861;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;557;981.5674,1919.672;Inherit;False;Property;_FoamColor;Foam Color;21;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;558;1395.268,2115.843;Inherit;True;Property;_Dither;Dither;22;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DitheringNode;555;1139.921,2112.458;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;546;1122.549,2324.326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;854.1097,2453.01;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;545;596.8235,2150.306;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;559;991.2317,2275.294;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;459;-1504.995,2087.115;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-627.2277,1646.463;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;562;-979.7932,1828.173;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;561;-933.5555,1733.47;Inherit;False;Property;_refractionmult;refraction mult;23;0;Create;True;0;0;0;False;0;False;0;2;0;5;0;1;FLOAT;0
WireConnection;259;0;423;0
WireConnection;423;0;422;0
WireConnection;423;1;421;0
WireConnection;421;1;420;0
WireConnection;421;5;418;0
WireConnection;446;0;487;0
WireConnection;447;0;443;0
WireConnection;448;0;445;0
WireConnection;449;0;447;0
WireConnection;449;1;448;0
WireConnection;449;2;446;0
WireConnection;0;0;462;0
WireConnection;0;13;534;0
WireConnection;0;11;514;0
WireConnection;435;0;433;0
WireConnection;466;0;471;0
WireConnection;467;0;466;0
WireConnection;467;1;470;0
WireConnection;420;0;417;0
WireConnection;420;1;467;0
WireConnection;419;0;417;0
WireConnection;419;1;467;0
WireConnection;471;0;472;0
WireConnection;458;0;483;38
WireConnection;483;35;460;0
WireConnection;483;37;452;0
WireConnection;484;0;444;0
WireConnection;487;0;444;0
WireConnection;487;1;488;0
WireConnection;487;2;484;0
WireConnection;487;3;444;0
WireConnection;491;1;490;0
WireConnection;492;0;504;0
WireConnection;494;0;491;0
WireConnection;494;1;493;0
WireConnection;495;0;492;0
WireConnection;496;1;495;0
WireConnection;497;0;551;0
WireConnection;422;1;419;0
WireConnection;422;5;418;0
WireConnection;509;0;559;0
WireConnection;499;0;459;0
WireConnection;499;1;556;0
WireConnection;534;0;499;0
WireConnection;514;0;513;0
WireConnection;514;1;515;0
WireConnection;501;0;500;0
WireConnection;501;1;502;0
WireConnection;547;0;545;0
WireConnection;498;0;497;0
WireConnection;498;1;496;1
WireConnection;500;0;542;0
WireConnection;542;0;498;0
WireConnection;542;1;549;0
WireConnection;550;0;494;0
WireConnection;551;0;550;0
WireConnection;551;1;502;0
WireConnection;548;0;501;0
WireConnection;444;0;442;0
WireConnection;444;1;441;0
WireConnection;442;0;464;0
WireConnection;442;1;440;0
WireConnection;464;0;463;0
WireConnection;464;1;465;0
WireConnection;463;0;437;0
WireConnection;437;0;436;0
WireConnection;436;0;435;0
WireConnection;436;1;434;4
WireConnection;512;0;506;0
WireConnection;512;1;498;0
WireConnection;505;0;512;0
WireConnection;553;0;545;0
WireConnection;553;1;554;0
WireConnection;556;0;509;0
WireConnection;556;1;557;0
WireConnection;555;0;546;0
WireConnection;555;1;558;0
WireConnection;546;0;547;0
WireConnection;546;1;544;0
WireConnection;544;0;553;0
WireConnection;544;1;548;0
WireConnection;545;0;505;0
WireConnection;559;0;545;0
WireConnection;559;2;544;0
WireConnection;459;0;449;0
WireConnection;459;1;562;0
WireConnection;459;2;446;0
WireConnection;560;0;458;0
WireConnection;560;1;561;0
WireConnection;562;0;560;0
ASEEND*/
//CHKSM=14C9F41A94461B53824A1A588841ADCDFB9B7173