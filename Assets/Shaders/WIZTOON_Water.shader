// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Water"
{
	Properties
	{
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_Normal2("Normal2", 2D) = "bump" {}
		_WaterNormal("Water Normal", 2D) = "bump" {}
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_NormalScale("Normal Scale", Float) = 0
		_ShalowColor("Shalow Color", Color) = (1,1,1,0)
		_WaterDepth("Water Depth", Float) = 0
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
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
		_ripple_step("ripple_step", Range( 0 , 1)) = 0
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
			float3 worldPos;
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

		uniform sampler2D _Normal2;
		uniform half _Float0;
		uniform half _refreactsteps;
		uniform float _NormalScale;
		uniform sampler2D _WaterNormal;
		uniform sampler2D _GlobalEffectRT;
		uniform half3 _Position;
		uniform half _OrthographicCamSize;
		uniform half _Displacement;
		uniform half4 _Watertint;
		uniform half _ripple_step;
		uniform half4 _FoamColor;
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
		uniform half _foamdepthfade;
		uniform float _FoamDepth;
		uniform float _FoamFalloff;
		uniform half _foamsteps;
		uniform sampler2D _Foam;
		uniform half2 _Foamtiling;
		uniform half _s;
		uniform half _test;
		uniform half _PointLightAttenuationBoost;
		uniform half _Steps;


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
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half4 appendResult591 = (half4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			half4 appendResult593 = (half4(_Position.x , _Position.z , 0.0 , 0.0));
			half Ripples600 = tex2Dlod( _GlobalEffectRT, float4( ( ( ( appendResult591 - appendResult593 ) / ( _OrthographicCamSize * 2.0 ) ) + 0.5 ).xy, 0, 0.0) ).b;
			half3 normal259 = ( BlendNormals( UnpackScaleNormal( tex2Dlod( _Normal2, float4( panner419, 0, 1.0) ), _NormalScale ) , UnpackScaleNormal( tex2Dlod( _WaterNormal, float4( panner420, 0, 1.0) ), _NormalScale ) ) + Ripples600 );
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
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 ase_worldPos = i.worldPos;
			half4 appendResult591 = (half4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			half4 appendResult593 = (half4(_Position.x , _Position.z , 0.0 , 0.0));
			half Ripples600 = tex2D( _GlobalEffectRT, ( ( ( appendResult591 - appendResult593 ) / ( _OrthographicCamSize * 2.0 ) ) + 0.5 ).xy ).b;
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
			half3 normal259 = ( BlendNormals( UnpackScaleNormal( tex2D( _Normal2, panner419 ), _NormalScale ) , UnpackScaleNormal( tex2D( _WaterNormal, panner420 ), _NormalScale ) ) + Ripples600 );
			half eyeDepth28_g1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half2 temp_output_20_0_g1 = ( (normal259).xy * ( _Distortion / max( i.eyeDepth , 0.1 ) ) * saturate( ( eyeDepth28_g1 - i.eyeDepth ) ) );
			half eyeDepth2_g1 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( half4( temp_output_20_0_g1, 0.0 , 0.0 ) + ase_screenPosNorm ).xy ));
			half2 temp_output_32_0_g1 = (( half4( ( temp_output_20_0_g1 * saturate( ( eyeDepth2_g1 - i.eyeDepth ) ) ), 0.0 , 0.0 ) + ase_screenPosNorm )).xy;
			half2 temp_output_1_0_g1 = ( ( floor( ( temp_output_32_0_g1 * (_CameraDepthTexture_TexelSize).zw ) ) + 0.5 ) * (_CameraDepthTexture_TexelSize).xy );
			float4 screenColor458 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,temp_output_1_0_g1);
			half4 lerpResult459 = lerp( lerpResult449 , saturate( screenColor458 ) , temp_output_446_0);
			float2 uv_TexCoord492 = i.uv_texcoord * _Foamtiling;
			half2 panner495 = ( 1.0 * _Time.y * float2( -0.01,0.01 ) + uv_TexCoord492);
			half temp_output_498_0 = ( saturate( ( floor( pow( ( 0.0 + _FoamDepth ) , _FoamFalloff ) ) / _foamsteps ) ) * tex2D( _Foam, panner495 ).r );
			float screenDepth505 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half distanceDepth505 = abs( ( screenDepth505 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( _foamdepthfade * temp_output_498_0 ) ) );
			half temp_output_545_0 = ( 1.0 - distanceDepth505 );
			half4 temp_output_619_0 = ( ( saturate( ( 1.0 - step( Ripples600 , _ripple_step ) ) ) * _FoamColor ) + ( lerpResult459 + ( saturate( ( temp_output_545_0 > 0.3 ? ( step( temp_output_545_0 , _s ) * saturate( ( floor( ( temp_output_498_0 * _test ) ) / _foamsteps ) ) ) : 0.0 ) ) * _FoamColor ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			half4 ase_lightColor = 0;
			#else //aselc
			half4 ase_lightColor = _LightColor0;
			#endif //aselc
			half IsPointLight565 = _WorldSpaceLightPos0.w;
			half4 PointLight578 = ( floor( ( ( ase_lightColor * saturate( ( ( _PointLightAttenuationBoost * IsPointLight565 * ase_lightAtten ) + ( ase_lightAtten * ( 1.0 - IsPointLight565 ) ) ) ) ) * _Steps ) ) / _Steps );
			half4 temp_output_621_0 = saturate( PointLight578 );
			c.rgb = ( temp_output_619_0 * temp_output_621_0 ).rgb;
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
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;1;259;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4202.939,635.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;416;-5556.146,1076.123;Inherit;False;1281.603;457.1994;Blend panning normals to fake noving ripples;7;423;422;421;420;419;418;417;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-5177.546,1363.221;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;0;False;0;False;0;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;423;-4449.543,1278.922;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;421;-4876.545,1344.322;Inherit;True;Property;_WaterNormal;Water Normal;1;0;Create;True;0;0;0;False;0;False;-1;None;c78e565eaf65cb1428fac66341a4a8bc;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;432;-5457.684,2051.365;Inherit;False;843.903;553.8391;Screen depth difference to get intersection and fading effect with terrain and objects;5;437;436;435;434;433;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;433;-5414.827,2131.204;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;443;-4101.583,1890.563;Float;False;Property;_DeepColor;Deep Color;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2971698,0.6733906,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;445;-3859.182,1979.764;Float;False;Property;_ShalowColor;Shalow Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.2783019,0.6091777,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;446;-3653.587,2211.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;447;-3555.09,1953.481;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;448;-3553.19,2046.081;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;449;-3343.582,2087.365;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;622.9008,439.6371;Half;False;True;-1;4;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;462;261.6738,217.1814;Inherit;False;Property;_Watertint;Water tint;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;434;-5414.683,2298.865;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;435;-5187.683,2104.365;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;417;-5506.146,1153.422;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;470;-5702.961,1300.054;Inherit;False;Property;_refreactsteps;refreact steps;11;0;Create;True;0;0;0;False;0;False;0;24;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;466;-5633.232,1617.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;467;-5333.317,1473.493;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;420;-5231.146,1238.622;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0.04;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;419;-5233.446,1124.407;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.03,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;471;-5846.468,1623.348;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;472;-5712.078,1494.699;Inherit;False;Property;_Float0;Float 0;14;0;Create;True;0;0;0;False;0;False;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;458;-343.7294,919.8429;Float;False;Global;_WaterGrab;WaterGrab;-1;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;483;-1207.767,1003.649;Inherit;False;Sai_DepthMaskedRefraction;-1;;1;bb954a2a716624fed8b85e64959850f3;2,40,0,103,0;2;35;FLOAT3;0,0,0;False;37;FLOAT;0.02;False;1;FLOAT2;38
Node;AmplifyShaderEditor.RangedFloatNode;452;-1439.647,1173.904;Float;False;Property;_Distortion;Distortion;8;0;Create;True;0;0;0;False;0;False;0.5;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;484;-3980.134,2479.743;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;487;-3702.907,2452.007;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;-3951.742,2720.06;Inherit;False;Property;_DitherDepth;Dither Depth;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;489;-1217.752,2099.232;Inherit;False;1083.102;484.2006;Foam controls and texture;9;498;497;496;495;494;493;492;491;490;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1096.051,2223.132;Float;False;Property;_FoamDepth;Foam Depth;13;0;Create;True;0;0;0;False;0;False;0;3.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-915.8494,2149.232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;492;-1167.752,2396.633;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;493;-905.2504,2285.032;Float;False;Property;_FoamFalloff;Foam Falloff;15;0;Create;True;0;0;0;False;0;False;0;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;494;-731.0498,2158.132;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;495;-947.0486,2416.832;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.01,0.01;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;497;-509.8487,2206.132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;422;-4889.446,1134.422;Inherit;True;Property;_Normal2;Normal2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;504;-1217.635,2641.278;Inherit;False;Property;_Foamtiling;Foam tiling;18;0;Create;True;0;0;0;False;0;False;0,0;3,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;513;112.8671,757.9426;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;515;134.3433,1010.884;Inherit;False;Property;_Displacement;Displacement;20;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;149.4731,1502.328;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;244.6349,903.9972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-228.3755,1944.643;Inherit;False;Property;_foamdepthfade;foam depth fade;19;0;Create;True;0;0;0;False;0;False;0;-0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;501;438.1416,2256.907;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;-298.5065,2310.249;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;500;299.8668,2603.334;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;542;-86.02277,2639.02;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-284.3555,2649.823;Inherit;False;Property;_test;test;21;0;Create;True;0;0;0;False;0;False;0;4.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;550;-291.769,2839.879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;551;-63.78341,2933.145;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;548;634.6291,2480.725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;444;-3859.888,2189.881;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-4040.283,2228.864;Float;False;Property;_WaterFalloff;Water Falloff;7;0;Create;True;0;0;0;False;0;False;0;-1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;-4036.088,2103.481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-4214.159,2240.276;Float;False;Property;_WaterDepth;Water Depth;5;0;Create;True;0;0;0;False;0;False;0;1.67;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;464;-4202.739,2380.116;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;463;-4331.841,2365.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-4400.226,2582.292;Inherit;False;Property;_Depthsteps;Depth steps;10;0;Create;True;0;0;0;False;0;False;0;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;437;-4741.509,2194.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-4950.284,2187.349;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;90.62681,2076.889;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;505;306.4586,2077.939;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;502;147.9153,2397.845;Inherit;False;Property;_foamsteps;foam steps;17;0;Create;True;0;0;0;False;0;False;0;2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;553;857.0134,2161.56;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;672.8892,2069.499;Inherit;False;Property;_s;s;22;0;Create;True;0;0;0;False;0;False;0;10.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;854.1097,2453.01;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;545;596.8235,2150.306;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;459;-1504.995,2087.115;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;562;-979.7932,1828.173;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;563;-3627.864,838.2031;Inherit;False;528.8752;183;;2;565;564;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;564;-3579.864,886.2034;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;565;-3339.864,902.2034;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;566;-2989.093,819.65;Inherit;False;936.9688;707.0591;;9;573;572;571;570;569;568;567;574;575;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-2914.888,869.65;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;6;0;Create;True;0;0;0;False;0;False;1;3.78;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;-2901.187,1013.058;Inherit;False;565;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;569;-2881.849,1138.442;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;-2627.447,929.019;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-2979.093,1254.973;Inherit;False;565;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;572;-2762.193,1258.556;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;573;-2535.825,1209.259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;-2318.184,1125.094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;-2173.077,1299.502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;577;-1889.839,1291.13;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;576;-2072.619,1140.442;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;581;-1693.163,1349.307;Inherit;False;888.2502;342.3433;;4;585;584;583;582;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;584;-919.6096,1421.987;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;585;-1381.844,1546.396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;590;-3140.404,314.9966;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;591;-2928.622,331.1325;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;593;-3309.831,181.8763;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;592;-2688.602,371.4719;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;595;-2825.755,611.4918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;594;-2545.395,486.4394;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;596;-2353.782,506.6095;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;598;-2072.943,399.7094;Inherit;True;Property;_TextureSample0;Texture Sample 0;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;600;-1635.534,519.6509;Inherit;False;Ripples;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;597;-2613.972,684.103;Inherit;False;Constant;_Float1;Float 1;27;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;587;-3580.032,132.7867;Inherit;False;Global;_Position;_Position;24;0;Create;True;0;0;0;False;0;False;0,0,0;-193.35,47.99,-226.52;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;589;-3501.912,542.4119;Inherit;False;Global;_OrthographicCamSize;_OrthographicCamSize;26;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;599;-2428.972,133.538;Inherit;True;Global;_GlobalEffectRT;GlobalEffectRT;25;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;602;42.41667,1743.49;Inherit;False;600;Ripples;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;559;1104.648,2228.182;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;496;-676.5046,2371.432;Inherit;True;Property;_Foam;Foam;12;0;Create;True;0;0;0;False;0;False;-1;None;2a2d71ee416d3c844adfa1a053ea32f4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;509;818.1746,1826.923;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;610;631.3865,1866.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-106.6952,1873.026;Inherit;False;Property;_ripple_step;ripple_step;24;0;Create;True;0;0;0;False;0;False;0;0.392;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;611;278.2368,1812.9;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;612;415.4452,1922.566;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;557;1018.922,1852.692;Inherit;False;Property;_FoamColor;Foam Color;23;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;618;1313.147,1742.476;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;944.3687,1642.761;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-2001.882,1783.163;Inherit;False;Property;_Steps;Steps;2;1;[IntRange];Create;True;0;0;0;False;0;False;5;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;579;191.2078,1158.465;Inherit;False;578;PointLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;-1272.52,1419.782;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;619;653.3218,1352.964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;763.1365,939.3486;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;621;452.3575,996.3546;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;583;-1099.005,1422.616;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;626;861.2595,1249.019;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;630;1063.987,1154.712;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-1629.441,1024.048;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;578;-643.0464,1334.994;Inherit;False;PointLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;631;-4043.35,1361.746;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-4250.899,1452.634;Inherit;False;600;Ripples;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;259;0;631;0
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
WireConnection;0;13;580;0
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
WireConnection;497;0;551;0
WireConnection;422;1;419;0
WireConnection;422;5;418;0
WireConnection;499;0;459;0
WireConnection;499;1;556;0
WireConnection;514;0;513;0
WireConnection;514;1;515;0
WireConnection;501;0;500;0
WireConnection;501;1;502;0
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
WireConnection;544;0;553;0
WireConnection;544;1;548;0
WireConnection;545;0;505;0
WireConnection;459;0;449;0
WireConnection;459;1;562;0
WireConnection;459;2;446;0
WireConnection;562;0;458;0
WireConnection;565;0;564;2
WireConnection;570;0;567;0
WireConnection;570;1;568;0
WireConnection;570;2;569;0
WireConnection;572;0;571;0
WireConnection;573;0;569;0
WireConnection;573;1;572;0
WireConnection;574;0;570;0
WireConnection;574;1;573;0
WireConnection;575;0;574;0
WireConnection;577;0;576;0
WireConnection;577;1;575;0
WireConnection;584;0;583;0
WireConnection;584;1;585;0
WireConnection;585;0;586;0
WireConnection;591;0;590;1
WireConnection;591;1;590;3
WireConnection;593;0;587;1
WireConnection;593;1;587;3
WireConnection;592;0;591;0
WireConnection;592;1;593;0
WireConnection;595;0;589;0
WireConnection;594;0;592;0
WireConnection;594;1;595;0
WireConnection;596;0;594;0
WireConnection;596;1;597;0
WireConnection;598;0;599;0
WireConnection;598;1;596;0
WireConnection;600;0;598;3
WireConnection;559;0;545;0
WireConnection;559;2;544;0
WireConnection;496;1;495;0
WireConnection;509;0;559;0
WireConnection;610;0;612;0
WireConnection;611;0;602;0
WireConnection;611;1;613;0
WireConnection;612;0;611;0
WireConnection;618;0;610;0
WireConnection;618;1;557;0
WireConnection;556;0;509;0
WireConnection;556;1;557;0
WireConnection;582;0;577;0
WireConnection;582;1;585;0
WireConnection;619;0;618;0
WireConnection;619;1;499;0
WireConnection;580;0;619;0
WireConnection;580;1;621;0
WireConnection;621;0;579;0
WireConnection;583;0;582;0
WireConnection;626;0;619;0
WireConnection;630;0;626;0
WireConnection;630;1;621;0
WireConnection;578;0;584;0
WireConnection;631;0;423;0
WireConnection;631;1;632;0
ASEEND*/
//CHKSM=03C74B56B37CEF0EAA0A575ABC05C84C87F6E2BE