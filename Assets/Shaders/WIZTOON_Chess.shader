// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Chess"
{
	Properties
	{
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		_ShadowColor("Shadow Color", Color) = (0,0,0,0)
		_NormalStr("Normal Str", Range( 0 , 1)) = 0
		_NormalStr1("Normal Str", Range( 0 , 1)) = 0
		_RimPower1("Rim Power", Float) = 5
		_Normal("Normal", 2D) = "bump" {}
		_RimScale1("Rim Scale", Float) = 1
		_Normal1("MicroNormal", 2D) = "bump" {}
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_Rim("Rim", Color) = (0,0,0,0)
		_RimAmt("RimAmt", Float) = 0
		_Albedo("Albedo", 2D) = "white" {}
		_AlbedoTint("AlbedoTint", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#endif//ASE Sampling Macros

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float4 screenPosition;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float _RimScale1;
		uniform float _RimPower1;
		uniform float _RimAmt;
		uniform float4 _Rim;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal);
		uniform float4 _Normal_ST;
		SamplerState sampler_Normal;
		uniform float _NormalStr;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		uniform float4 _Normal1_ST;
		SamplerState sampler_Normal1;
		uniform float _NormalStr1;
		uniform float _Steps;
		uniform float _ShadowLevel;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Albedo);
		uniform float4 _Albedo_ST;
		SamplerState sampler_Albedo;
		uniform float4 _AlbedoTint;
		uniform float4 _ShadowColor;


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
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
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
			float IsPointLight483 = _WorldSpaceLightPos0.w;
			float PointLightAttenuation454 = ( _PointLightAttenuationBoost * IsPointLight483 * ase_lightAtten );
			float temp_output_438_0 = ( _LightGradientSize * 0.5 );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 normal259 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal, sampler_Normal, uv_Normal ), _NormalStr );
			float2 uv_Normal1 = i.uv_texcoord * _Normal1_ST.xy + _Normal1_ST.zw;
			float3 MicroNormals517 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Normal1 ), _NormalStr1 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult422 = dot( (WorldNormalVector( i , BlendNormals( normal259 , MicroNormals517 ) )) , ase_worldlightDir );
			float NdotL421 = dotResult422;
			float smoothstepResult436 = smoothstep( ( _LightGradientMidLevel - temp_output_438_0 ) , ( _LightGradientMidLevel + temp_output_438_0 ) , (NdotL421*0.5 + 0.5));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_488_0 = ( ( ( floor( ( saturate( ( PointLightAttenuation454 * smoothstepResult436 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight483 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult436 * _Steps * ( 1.0 - IsPointLight483 ) ) ) / _Steps ) ) ) * ase_lightColor );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode509 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
			float4 Albedo510 = ( tex2DNode509 * _AlbedoTint );
			float4 ShadowColor506 = _ShadowColor;
			c.rgb = ( ( temp_output_488_0 * Albedo510 ) + ( ( ( 1.0 - ( ( floor( ( saturate( ( PointLightAttenuation454 * smoothstepResult436 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight483 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult436 * _Steps * ( 1.0 - IsPointLight483 ) ) ) / _Steps ) ) ) ) * ShadowColor506 ) * ( 1.0 - IsPointLight483 ) ) ).rgb;
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
			o.Normal = float3(0,0,1);
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen502 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither502 = Dither4x4Bayer( fmod(clipScreen502.x, 4), fmod(clipScreen502.y, 4) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV532 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode532 = ( 0.0 + _RimScale1 * pow( 1.0 - fresnelNdotV532, _RimPower1 ) );
			dither502 = step( dither502, fresnelNode532 );
			float RimWrap503 = dither502;
			o.Emission = ( RimWrap503 * _RimAmt * _Rim ).rgb;
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
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xyzw = customInputData.screenPosition;
				o.customPack2.xy = customInputData.uv_texcoord;
				o.customPack2.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
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
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;2;261;259;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;622.9008,439.6371;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Chess;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;417;-698.4264,115.2746;Inherit;False;751.4393;422.4538;Comment;4;488;481;480;511;Multiplies lit areas with albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;418;-2032.79,42.67264;Inherit;False;100;100; sat ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;419;-2164.813,-276.4873;Inherit;False;564.9662;532.2659;Comment;1;418;Dithering;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;420;-5408.933,-1099.204;Inherit;False;1045.97;441.7339;Basic lighting;6;487;424;423;422;421;520;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;421;-4583.83,-869.7521;Inherit;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;422;-4763.987,-889.0291;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;423;-5015.006,-1021.391;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;424;-5056.962,-823.5522;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;425;-5414.339,-2188.507;Inherit;False;528.8752;183;;2;483;482;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;426;-5409.328,-1891.784;Inherit;False;609.5977;695.7705;;8;454;433;432;431;430;429;428;427;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;427;-5335.124,-1841.786;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;0;0;Create;True;0;0;0;False;0;False;1;5.937022;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;430;-5047.683,-1782.418;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;433;-4956.062,-1502.177;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;434;-4154.609,-1716.054;Inherit;False;977.7146;495.7445;;8;486;485;440;439;438;437;436;435;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;435;-4104.609,-1566.089;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;1;0;Create;True;0;0;0;False;0;False;0;0.321;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;436;-3427.197,-1577.512;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;437;-3655.314,-1328.266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;438;-3857.441,-1310.39;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-4104.392,-1438.595;Inherit;False;Property;_LightGradientSize;Light Gradient Size;2;0;Create;True;0;0;0;False;0;False;0;0.573;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;440;-3656.753,-1438.828;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;441;-2928.834,-1009.213;Inherit;False;1379.942;546.2153;;11;484;471;453;452;451;450;449;448;447;446;445;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;442;-3402.926,-1051.574;Inherit;False;Property;_Steps;Steps;10;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;443;-2992.302,-1117.249;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;444;-2990.273,-628.3218;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;445;-2636.01,-546.5485;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;446;-2796.708,-919.4855;Inherit;False;Property;_ShadowLevel;Shadow Level;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;447;-2777.003,-818.4489;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;448;-2255.325,-949.4442;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;449;-1776.763,-854.7656;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;450;-2421.637,-725.7613;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;451;-2596.017,-695.8762;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;452;-2202.208,-721.3363;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;453;-2068.727,-723.5564;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;455;-2991.676,-1748.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;456;-2943.676,-1761.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;457;-3017.677,-1563.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;458;-3004.677,-1596.049;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;459;-3014.429,-1505.16;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;460;-2451.214,-1440.1;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;461;-2484.668,-1469.843;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;462;-3013.584,-1918.021;Inherit;False;454;PointLightAttenuation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;463;-2740.902,-1813.302;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;464;-2529.22,-1807.894;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;465;-2243.884,-1732.631;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;466;-2060.047,-1722.054;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;467;-2311.921,-1580.211;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;468;-2604.55,-1109.882;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;469;-2338.488,-1159.945;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;470;-2361.989,-1102.141;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;472;-1880.653,-1598.823;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;473;-1060.034,-775.0298;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;474;-1142.708,-1547.314;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;475;-1088.573,-1481.147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;476;-4279.942,-1191.738;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;477;-2707.999,-1178.855;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;478;-1104.399,-867.7137;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;479;-1534.314,312.3329;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;480;-648.4264,328.8358;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;481;-181.9875,165.351;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;482;-5366.339,-2140.507;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;483;-5126.341,-2124.507;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;485;-3705.107,-1673.246;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;486;-3995.392,-1651.102;Inherit;False;421;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;488;-431.5857,165.2746;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;489;87.62592,219.2051;Inherit;False;Property;_Rim;Rim;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.995283,0.995283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;490;91.23297,123.922;Inherit;False;503;RimWrap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;492;176.299,726.2755;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;493;-161.8647,691.9666;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;494;-406.9826,902.4374;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;497;-1106.342,699.6516;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;499;-3382.845,762.4432;Inherit;False;Property;_RimScale;Rim Scale;13;0;Create;True;0;0;0;False;0;False;1;53.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;500;-3349.627,892.9944;Inherit;False;Property;_RimPower;Rim Power;12;0;Create;True;0;0;0;False;0;False;5;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;501;-3087.057,659.0804;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;502;-2744.576,722.7289;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;503;-2709.777,1012.611;Inherit;False;RimWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;-694.5624,977.4653;Inherit;False;483;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;506;-1046.791,274.3768;Inherit;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;507;489.4987,288.4997;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;491;3.986276,51.56535;Inherit;False;Property;_RimAmt;RimAmt;15;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;505;-1231.033,36.53715;Inherit;False;Property;_ShadowColor;Shadow Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.3393697,0.2222766,0.4245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;508;-1214.557,409.6664;Inherit;True;Property;_Albedo;Albedo;16;0;Create;True;0;0;0;False;0;False;None;cda94444b78ff43198bc1de18d6843b5;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;498;-3545.994,622.8668;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;511;-339.9595,468.7434;Inherit;False;510;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-2008.573,-985.2546;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;454;-4852.323,-1782.767;Inherit;False;PointLightAttenuation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;-5321.422,-1699.983;Inherit;False;483;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;429;-5302.084,-1572.995;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;432;-5180.824,-1468.925;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;431;-5399.329,-1456.463;Inherit;False;483;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;513;-563.4778,784.6848;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;512;-998.1145,954.7598;Inherit;False;Property;_AlbedoTint;AlbedoTint;17;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;261;-4524.59,616.6649;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;None;28e203d0a7b5448c3855490dbed07449;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;416;-4743.831,835.5604;Inherit;True;Property;_Normal;Normal;7;0;Create;True;0;0;0;False;0;False;None;432db2c172716475f8f9f0fc993d3330;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;287;-5110.281,696.2872;Inherit;False;Property;_NormalStr;Normal Str;4;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;-2489.31,1116.671;Inherit;False;Property;_NormalStr1;Normal Str;5;0;Create;True;0;0;0;False;0;False;0;0.108;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;518;-2177.144,986.0177;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;514;-1903.619,1037.048;Inherit;True;Property;_NormalMap1;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;None;28e203d0a7b5448c3855490dbed07449;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;515;-2122.86,1255.944;Inherit;True;Property;_Normal1;MicroNormal;9;0;Create;True;0;0;0;False;0;False;None;c78e565eaf65cb1428fac66341a4a8bc;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;517;-1581.968,1056.104;Inherit;False;MicroNormals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4202.939,635.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;484;-2777.678,-694.761;Inherit;False;483;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;487;-5319.703,-973.9858;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;519;-5442.009,-814.9907;Inherit;False;517;MicroNormals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;520;-5182.156,-853.5331;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;525;-3896.329,1038.423;Inherit;False;1067.878;672.6326;;9;534;533;532;531;530;529;528;527;526;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;526;-3846.329,1532.055;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;527;-3817.615,1361.675;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;528;-3541.943,1484.196;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;530;-3353.66,1483.283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;532;-3367.193,1089.09;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;533;-3195.241,1485.101;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;534;-2997.453,1427.986;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;531;-3662.98,1088.423;Inherit;False;Property;_RimScale1;Rim Scale;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;529;-3633.98,1182.423;Inherit;False;Property;_RimPower1;Rim Power;6;0;Create;True;0;0;0;False;0;False;5;5.89;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;496;-927.6464,840.7073;Inherit;False;506;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;-703.3595,702.2103;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;510;-409.3284,601.3913;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;509;-894.7396,466.7566;Inherit;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;536;-395.6913,503.864;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;535;-584.9851,577.3211;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;0;2;507;0
WireConnection;0;13;492;0
WireConnection;421;0;422;0
WireConnection;422;0;423;0
WireConnection;422;1;424;0
WireConnection;423;0;520;0
WireConnection;430;0;427;0
WireConnection;430;1;428;0
WireConnection;430;2;429;0
WireConnection;433;0;429;0
WireConnection;433;1;432;0
WireConnection;436;0;485;0
WireConnection;436;1;437;0
WireConnection;436;2;440;0
WireConnection;437;0;435;0
WireConnection;437;1;438;0
WireConnection;438;0;439;0
WireConnection;440;0;435;0
WireConnection;440;1;438;0
WireConnection;443;0;442;0
WireConnection;444;0;442;0
WireConnection;445;0;444;0
WireConnection;448;0;446;0
WireConnection;448;1;447;0
WireConnection;449;0;471;0
WireConnection;449;1;453;0
WireConnection;450;0;460;0
WireConnection;450;1;445;0
WireConnection;450;2;451;0
WireConnection;451;0;484;0
WireConnection;452;0;450;0
WireConnection;453;0;452;0
WireConnection;453;1;445;0
WireConnection;455;0;458;0
WireConnection;456;0;455;0
WireConnection;457;0;436;0
WireConnection;458;0;457;0
WireConnection;459;0;436;0
WireConnection;460;0;461;0
WireConnection;461;0;459;0
WireConnection;463;0;462;0
WireConnection;463;1;456;0
WireConnection;464;0;463;0
WireConnection;465;0;464;0
WireConnection;465;1;467;0
WireConnection;466;0;465;0
WireConnection;467;0;469;0
WireConnection;468;0;443;0
WireConnection;469;0;470;0
WireConnection;470;0;468;0
WireConnection;472;0;466;0
WireConnection;472;1;467;0
WireConnection;473;0;478;0
WireConnection;473;1;449;0
WireConnection;474;0;472;0
WireConnection;475;0;474;0
WireConnection;476;0;433;0
WireConnection;477;0;476;0
WireConnection;478;0;475;0
WireConnection;479;0;473;0
WireConnection;481;0;488;0
WireConnection;481;1;511;0
WireConnection;483;0;482;2
WireConnection;485;0;486;0
WireConnection;488;0;479;0
WireConnection;488;1;480;0
WireConnection;492;0;481;0
WireConnection;492;1;493;0
WireConnection;493;0;495;0
WireConnection;493;1;494;0
WireConnection;494;0;504;0
WireConnection;497;0;479;0
WireConnection;501;0;498;0
WireConnection;501;2;499;0
WireConnection;501;3;500;0
WireConnection;502;0;532;0
WireConnection;503;0;502;0
WireConnection;506;0;505;0
WireConnection;507;0;490;0
WireConnection;507;1;491;0
WireConnection;507;2;489;0
WireConnection;471;0;477;0
WireConnection;471;1;448;0
WireConnection;454;0;430;0
WireConnection;432;0;431;0
WireConnection;513;0;509;0
WireConnection;513;1;512;0
WireConnection;261;0;416;0
WireConnection;261;5;287;0
WireConnection;514;0;515;0
WireConnection;514;5;516;0
WireConnection;517;0;514;0
WireConnection;259;0;261;0
WireConnection;520;0;487;0
WireConnection;520;1;519;0
WireConnection;528;0;527;0
WireConnection;528;1;526;0
WireConnection;530;0;528;0
WireConnection;532;2;531;0
WireConnection;532;3;529;0
WireConnection;533;0;530;0
WireConnection;534;0;532;0
WireConnection;534;1;533;0
WireConnection;495;0;497;0
WireConnection;495;1;496;0
WireConnection;510;0;513;0
WireConnection;509;0;508;0
WireConnection;536;0;509;1
WireConnection;536;1;509;2
WireConnection;536;2;509;3
WireConnection;536;3;535;0
WireConnection;535;0;509;4
WireConnection;535;1;488;0
ASEEND*/
//CHKSM=6364C3BBDC8C8AF48CF1266D81B1A601351422F9