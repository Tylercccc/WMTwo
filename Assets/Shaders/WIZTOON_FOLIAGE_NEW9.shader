// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_FOLIAGE_NEW9"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_ShadowColor1("Shadow Color", Color) = (0,0,0,0)
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_RimPower("Rim Power", Float) = 5
		_RimScale("Rim Scale", Float) = 1
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		_Dither("Dither", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_NormalTiling("Normal Tiling", Vector) = (0,0,0,0)
		_normalspeed("normal speed", Range( 0 , 1)) = 1
		_SphereRadius("SphereRadius", Float) = 0
		_SphereHardness("SphereHardness", Float) = 0
		_bendoffset("bend offset", Vector) = (0,0,0,0)
		[Toggle]_useUVcoords("useUVcoords", Range( 0 , 1)) = 0
		_WorldFrequency("World Frequency", Range( 0 , 1)) = 0
		_BendAmt("Bend Amt", Float) = 0
		_WindDirection("Wind Direction", Range( 0 , 6.21)) = 0
		_BottomGradientSize("Bottom Gradient Size", Range( 0 , 5)) = 0
		_GradientHeight("Gradient Height", Range( 1 , 5)) = 0
		_SecondaryFrequency("Secondary Frequency", Range( 0 , 10)) = 0
		_secondaryspeed("secondary speed", Vector) = (1,1,0,0)
		_timespeed("time speed", Float) = 0
		_bushtimesteps("bush time steps", Range( 0 , 20)) = 0
		_Squash("Squash", Vector) = (0,0,0,0)
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		_Tonedown("Tone down", Float) = 1
		_Texture0("Texture 0", 2D) = "bump" {}
		_Intersectradius("Intersectradius", Float) = 0
		_intersectnoisescale("intersectnoisescale", Float) = 0
		_intersectionnoise("intersection noise", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
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
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
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
			float3 worldPos;
			float4 screenPosition;
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float _WindDirection;
		uniform float _BottomGradientSize;
		uniform float _GradientHeight;
		uniform float _WorldFrequency;
		uniform float _timespeed;
		uniform float _bushtimesteps;
		uniform float _Tonedown;
		uniform float3 _BushPosition;
		uniform float3 _bendoffset;
		uniform float _SphereRadius;
		uniform float _SphereHardness;
		uniform float2 _secondaryspeed;
		uniform float _SecondaryFrequency;
		uniform float _BendAmt;
		uniform float3 _Squash;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Dither);
		float4 _Dither_TexelSize;
		SamplerState sampler_Dither;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Texture0);
		uniform float2 _NormalTiling;
		uniform float _useUVcoords;
		uniform float _normalspeed;
		SamplerState sampler_Texture0;
		uniform float _NormalScale;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _Steps;
		uniform float _ShadowLevel;
		uniform float _Intersectradius;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_intersectionnoise);
		uniform float _intersectnoisescale;
		SamplerState sampler_intersectionnoise;
		uniform float4 _Color;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Albedo);
		uniform float4 _Albedo_ST;
		SamplerState sampler_Albedo;
		uniform float4 _ShadowColor1;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
		}


		inline float DitherNoiseTex( float4 screenPos, UNITY_DECLARE_TEX2D_NOSAMPLER(noiseTexture), SamplerState samplernoiseTexture, float4 noiseTexelSize )
		{
			float dither = SAMPLE_TEXTURE2D_LOD( noiseTexture, samplernoiseTexture, screenPos.xy * _ScreenParams.xy * noiseTexelSize.xy, 0 ).g;
			float ditherRate = noiseTexelSize.x * noiseTexelSize.y;
			dither = ( 1 - ditherRate ) * dither + ditherRate;
			return dither;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			float smoothstepResult599 = smoothstep( 0.0 , _BottomGradientSize , ( _GradientHeight - ( 1.0 - ase_vertexNormal.y ) ));
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_648_0 = ( floor( ( _timespeed * _Time.y ) ) / _bushtimesteps );
			float3 worldToObj512 = mul( unity_WorldToObject, float4( _BushPosition, 1 ) ).xyz;
			float3 ase_parentObjectScale = (1.0/float3( length( unity_WorldToObject[ 0 ].xyz ), length( unity_WorldToObject[ 1 ].xyz ), length( unity_WorldToObject[ 2 ].xyz ) ));
			float3 temp_output_492_0 = ( ( ase_vertexNormal - ( worldToObj512 * _bendoffset ) ) / ( _SphereRadius / ase_parentObjectScale ) );
			float dotResult493 = dot( temp_output_492_0 , temp_output_492_0 );
			float sphereMask496 = pow( saturate( dotResult493 ) , _SphereHardness );
			float2 panner618 = ( temp_output_648_0 * _secondaryspeed + ase_vertexNormal.xy);
			float simplePerlin2D616 = snoise( panner618*_SecondaryFrequency );
			simplePerlin2D616 = simplePerlin2D616*0.5 + 0.5;
			float clampResult631 = clamp( simplePerlin2D616 , 0.5 , 1.0 );
			float temp_output_578_0 = ( ( ( ( smoothstepResult599 * ( ase_vertex3Pos.y * cos( ( ( ( ase_worldPos.x + ase_worldPos.z ) * _WorldFrequency ) + temp_output_648_0 ) ) ) ) * ( _Tonedown - saturate( sphereMask496 ) ) ) * clampResult631 ) * _BendAmt );
			float4 appendResult580 = (float4(temp_output_578_0 , 0.0 , temp_output_578_0 , 0.0));
			float4 break584 = mul( appendResult580, unity_ObjectToWorld );
			float4 appendResult585 = (float4(break584.x , 0 , break584.z , 0.0));
			float3 temp_cast_1 = (sphereMask496).xxx;
			float3 rotatedValue587 = RotateAroundAxis( float3( 0,0,0 ), ( ( appendResult585 + float4( ( temp_cast_1 - float3(1,1,1) ) , 0.0 ) ) + float4( (ase_vertexNormal*_Squash + 0.0) , 0.0 ) ).xyz, float3( 0,0,0 ), _WindDirection );
			float3 NewWind589 = rotatedValue587;
			v.vertex.xyz += NewWind589;
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
			float IsPointLight76 = _WorldSpaceLightPos0.w;
			float temp_output_209_0 = ( _LightGradientSize * 0.5 );
			float3 ase_worldPos = i.worldPos;
			float4 appendResult480 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 lerpResult567 = lerp( appendResult480 , float4( i.uv_texcoord, 0.0 , 0.0 ) , _useUVcoords);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float smoothstepResult599 = smoothstep( 0.0 , _BottomGradientSize , ( _GradientHeight - ( 1.0 - ase_vertexNormal.y ) ));
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_648_0 = ( floor( ( _timespeed * _Time.y ) ) / _bushtimesteps );
			float3 worldToObj512 = mul( unity_WorldToObject, float4( _BushPosition, 1 ) ).xyz;
			float3 ase_parentObjectScale = (1.0/float3( length( unity_WorldToObject[ 0 ].xyz ), length( unity_WorldToObject[ 1 ].xyz ), length( unity_WorldToObject[ 2 ].xyz ) ));
			float3 temp_output_492_0 = ( ( ase_vertexNormal - ( worldToObj512 * _bendoffset ) ) / ( _SphereRadius / ase_parentObjectScale ) );
			float dotResult493 = dot( temp_output_492_0 , temp_output_492_0 );
			float sphereMask496 = pow( saturate( dotResult493 ) , _SphereHardness );
			float2 panner618 = ( temp_output_648_0 * _secondaryspeed + ase_vertexNormal.xy);
			float simplePerlin2D616 = snoise( panner618*_SecondaryFrequency );
			simplePerlin2D616 = simplePerlin2D616*0.5 + 0.5;
			float clampResult631 = clamp( simplePerlin2D616 , 0.5 , 1.0 );
			float temp_output_578_0 = ( ( ( ( smoothstepResult599 * ( ase_vertex3Pos.y * cos( ( ( ( ase_worldPos.x + ase_worldPos.z ) * _WorldFrequency ) + temp_output_648_0 ) ) ) ) * ( _Tonedown - saturate( sphereMask496 ) ) ) * clampResult631 ) * _BendAmt );
			float4 appendResult580 = (float4(temp_output_578_0 , 0.0 , temp_output_578_0 , 0.0));
			float4 break584 = mul( appendResult580, unity_ObjectToWorld );
			float4 appendResult585 = (float4(break584.x , 0 , break584.z , 0.0));
			float3 temp_cast_13 = (sphereMask496).xxx;
			float3 rotatedValue587 = RotateAroundAxis( float3( 0,0,0 ), ( ( appendResult585 + float4( ( temp_cast_13 - float3(1,1,1) ) , 0.0 ) ) + float4( (ase_vertexNormal*_Squash + 0.0) , 0.0 ) ).xyz, float3( 0,0,0 ), _WindDirection );
			float3 NewWind589 = rotatedValue587;
			float3 normal259 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, ( ( float4( _NormalTiling, 0.0 , 0.0 ) * lerpResult567 ) + float4( ( NewWind589 * _normalspeed ) , 0.0 ) ).xy ), _NormalScale );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5 = dot( (WorldNormalVector( i , normal259 )) , ase_worldlightDir );
			float NdotL131 = dotResult5;
			float smoothstepResult205 = smoothstep( ( _LightGradientMidLevel - temp_output_209_0 ) , ( _LightGradientMidLevel + temp_output_209_0 ) , (NdotL131*0.5 + 0.5));
			float temp_output_192_0 = ( 0.0 + smoothstepResult205 );
			float temp_output_687_0 = ( sphereMask496 / _Intersectradius );
			float4 appendResult686 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float IntersectionNoiseUVs692 = clampResult631;
			float4 temp_cast_19 = (( IntersectionNoiseUVs692 * 0.2 )).xxxx;
			float4 temp_output_703_0 = ( appendResult686 - temp_cast_19 );
			float4 temp_output_685_0 = ( temp_output_687_0 + SAMPLE_TEXTURE2D( _intersectionnoise, sampler_intersectionnoise, ( temp_output_703_0 * _intersectnoisescale ).xy ) );
			float4 clampResult694 = clamp( temp_output_685_0 , float4( -1,0,0,0 ) , float4( 1,0,0,0 ) );
			float4 temp_output_181_0 = ( ( ( ase_lightAtten * ( 1.0 - IsPointLight76 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( temp_output_192_0 * _Steps * ( 1.0 - IsPointLight76 ) * clampResult694 ) ) / _Steps ) );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float dither275 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			dither275 = step( dither275, ( temp_output_181_0 * smoothstepResult205 ).r );
			float4 temp_cast_22 = (dither275).xxxx;
			float4 temp_output_224_0 = ( 1.0 - ( ( floor( ( saturate( ( ( _PointLightAttenuationBoost * IsPointLight76 * ase_lightAtten ) * temp_output_192_0 ) ) * _Steps ) ) / _Steps ) + (( temp_output_181_0 >= float4( 0,0,0,0 ) && temp_output_181_0 <= float4( 1,0,0,0 ) ) ? temp_cast_22 :  temp_output_181_0 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode285 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
			float dither292 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float cameraDepthFade293 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 5.0);
			float clampResult294 = clamp( cameraDepthFade293 , 1.0 , 20.0 );
			dither292 = step( dither292, ( clampResult294 * tex2DNode285 ).r );
			c.rgb = ( ( ( ( 1.0 - temp_output_224_0 ) * ase_lightColor ) * ( _Color * tex2DNode285 ) ) + ( ( min( temp_output_224_0 , _ShadowColor1 ) * ( 1.0 - IsPointLight76 ) ) * dither292 ) ).rgb;
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
			float dither349 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float4 appendResult480 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 lerpResult567 = lerp( appendResult480 , float4( i.uv_texcoord, 0.0 , 0.0 ) , _useUVcoords);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float smoothstepResult599 = smoothstep( 0.0 , _BottomGradientSize , ( _GradientHeight - ( 1.0 - ase_vertexNormal.y ) ));
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_648_0 = ( floor( ( _timespeed * _Time.y ) ) / _bushtimesteps );
			float3 worldToObj512 = mul( unity_WorldToObject, float4( _BushPosition, 1 ) ).xyz;
			float3 ase_parentObjectScale = (1.0/float3( length( unity_WorldToObject[ 0 ].xyz ), length( unity_WorldToObject[ 1 ].xyz ), length( unity_WorldToObject[ 2 ].xyz ) ));
			float3 temp_output_492_0 = ( ( ase_vertexNormal - ( worldToObj512 * _bendoffset ) ) / ( _SphereRadius / ase_parentObjectScale ) );
			float dotResult493 = dot( temp_output_492_0 , temp_output_492_0 );
			float sphereMask496 = pow( saturate( dotResult493 ) , _SphereHardness );
			float2 panner618 = ( temp_output_648_0 * _secondaryspeed + ase_vertexNormal.xy);
			float simplePerlin2D616 = snoise( panner618*_SecondaryFrequency );
			simplePerlin2D616 = simplePerlin2D616*0.5 + 0.5;
			float clampResult631 = clamp( simplePerlin2D616 , 0.5 , 1.0 );
			float temp_output_578_0 = ( ( ( ( smoothstepResult599 * ( ase_vertex3Pos.y * cos( ( ( ( ase_worldPos.x + ase_worldPos.z ) * _WorldFrequency ) + temp_output_648_0 ) ) ) ) * ( _Tonedown - saturate( sphereMask496 ) ) ) * clampResult631 ) * _BendAmt );
			float4 appendResult580 = (float4(temp_output_578_0 , 0.0 , temp_output_578_0 , 0.0));
			float4 break584 = mul( appendResult580, unity_ObjectToWorld );
			float4 appendResult585 = (float4(break584.x , 0 , break584.z , 0.0));
			float3 temp_cast_3 = (sphereMask496).xxx;
			float3 rotatedValue587 = RotateAroundAxis( float3( 0,0,0 ), ( ( appendResult585 + float4( ( temp_cast_3 - float3(1,1,1) ) , 0.0 ) ) + float4( (ase_vertexNormal*_Squash + 0.0) , 0.0 ) ).xyz, float3( 0,0,0 ), _WindDirection );
			float3 NewWind589 = rotatedValue587;
			float3 normal259 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, ( ( float4( _NormalTiling, 0.0 , 0.0 ) * lerpResult567 ) + float4( ( NewWind589 * _normalspeed ) , 0.0 ) ).xy ), _NormalScale );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV118 = dot( mul(ase_tangentToWorldFast,normal259), ase_worldViewDir );
			float fresnelNode118 = ( 0.0 + _RimScale * pow( 1.0 - fresnelNdotV118, _RimPower ) );
			dither349 = step( dither349, fresnelNode118 );
			float RimWrap195 = dither349;
			o.Emission = ( RimWrap195 * _RimColor ).rgb;
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
				float3 customPack2 : TEXCOORD2;
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
				o.customPack2.z = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack2.z;
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
Node;AmplifyShaderEditor.CommentaryNode;673;4478.147,832.4617;Inherit;False;465.3599;241.5649;????;0;LOOK AT THIS TMRW (STOP WIND BASED ON PLAYER POSITION MASK?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;651;2561.192,-15.60339;Inherit;False;4194.815;1508.157;Comment;51;569;570;571;572;573;575;579;591;581;582;584;586;585;599;597;604;598;588;576;577;580;606;618;628;616;632;631;603;622;578;587;640;639;642;643;574;645;646;647;648;596;649;668;671;672;676;677;678;673;692;696;WIND;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;650;-2969.379,1797.22;Inherit;False;1751.468;747.2209;Comment;15;491;492;494;495;511;493;490;489;565;564;517;512;504;505;496;Player Deform Bush;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;536;-1827.159,-644.2699;Inherit;False;100;100; f;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-2675.733,-887.3652;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2885.612,-913.2354;Inherit;False;1379.942;546.2153;;12;198;199;78;171;181;180;179;178;77;172;201;307;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;3;118;114;112;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4290.296,-456.7152;Inherit;False;1025.107;587.7744;Basic lighting;4;5;7;6;131;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-4182.831,-376.0671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-4204.932,-118.6672;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;112;-3285.258,-2905.049;Inherit;False;Property;_RimPower;Rim Power;4;0;Create;True;0;0;0;False;0;False;5;1.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3314.258,-2999.049;Inherit;False;Property;_RimScale;Rim Scale;5;0;Create;True;0;0;0;False;0;False;1;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;8;206;211;209;207;208;205;186;38;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-3948.828,-272.0672;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3774.34,-227.2643;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;2;76;75;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;209;-3676.961,-1291.98;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3919.807,-1517.473;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;7;0;Create;True;0;0;0;False;0;False;0;0.641;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3471.961,-1306.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-3471.961,-1418.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;7;106;105;102;101;100;98;97;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-5113.211,-1705.717;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;3;0;Create;True;0;0;0;False;0;False;1;2.68;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-5099.51,-1562.309;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3359.705,-955.5967;Inherit;False;Property;_Steps;Steps;1;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;100;-5080.172,-1436.925;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4825.77,-1646.348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-5177.416,-1320.394;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2443.691,-1389.961;Inherit;False;888.2502;342.3433;;4;126;125;124;200;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;98;-4960.516,-1316.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-4734.148,-1366.108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1768.84,307.8115;Inherit;False;932.1631;425.7859;Directional Light Only;4;224;251;88;235;Shadow Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-19.37829,440.4236;Inherit;False;464.8;298.7;Material Color;1;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;2;261;259;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;75;-2982.111,874.9663;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-2742.111,890.9663;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;224;-1445.411,394.2598;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;251;-1221.036,384.5249;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;235;-988.4199,625.3221;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-961.9585,928.7074;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1400.855,1302.276;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;88;-1673.704,416.2784;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;255;-673.2963,576.7527;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;230.1328,484.7082;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;106.1416,789.8001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-271.8002,1213.358;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;285;-447.682,804.0729;Inherit;True;Property;_Albedo;Albedo;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;230;-1422.968,945.3193;Inherit;False;Property;_ShadowColor1;Shadow Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2970363,0.7075472,0.3076191,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-584.3527,1239.109;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-250.9145,615.31;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5019608,0.8196079,0.3058824,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-3537.574,-1617.438;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3910.961,-1389.98;Inherit;False;Property;_LightGradientSize;Light Gradient Size;8;0;Create;True;0;0;0;False;0;False;0;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;205;-3242.402,-1528.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-3810.594,-1602.487;Inherit;False;131;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-454.0071,446.9763;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2136.439,319.0111;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;275;-1999.236,-8.152191;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-2275.811,-192.2104;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;280;-2405.055,4.84398;Inherit;True;Property;_Dither;Dither;9;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2392.995,-2603.417;Inherit;False;RimWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;321.7058,57.3531;Inherit;False;195;RimWrap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;448.3029,196.6428;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;346;709.5838,166.3893;Inherit;False;Property;_RimColor;Rim Color;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2659853,0.3301887,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;118;-3018.471,-2998.382;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-2836.169,-2393.839;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;349;-2515.753,-2236.347;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4626.501,-331.4977;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CameraDepthFade;293;-980.1703,1503.753;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;294;-644.3625,1517.31;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;232;-1158.111,1238.667;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3378.499,-3616.521;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;463;-4893.103,658.4679;Inherit;False;Property;_normalspeed;normal speed;13;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-2734.457,-598.7814;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-2949.081,-1021.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-2947.052,-532.3419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;201;-2592.788,-450.5684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-2552.794,-599.8965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;204;-2253.978,-1040.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-2251.612,-1704.403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;200;-2132.371,-1192.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2753.487,-823.5073;Inherit;False;Property;_ShadowLevel;Shadow Level;6;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;77;-2733.782,-722.4692;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;125;-1849.533,-1316.652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;180;-2025.505,-627.576;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-1670.139,-1317.281;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-2378.414,-629.7809;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;179;-2157.167,-625.356;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1967.098,-884.5726;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;-2212.103,-853.4663;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1733.54,-758.7867;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2023.048,-1319.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-2676.004,-1496.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-2442.655,-1699.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;279;-1469.441,-679.9645;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;468;-5054.526,130.7492;Inherit;False;Property;_NormalTiling;Normal Tiling;12;0;Create;True;0;0;0;False;0;False;0,0;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;462;-4746.507,525.1497;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;480;-4857.869,47.70409;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;481;-4721.981,276.4821;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4038.939,639.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-1023.29,-319.2087;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-701.2247,1717.931;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WorldPosInputsNode;479;-5322.096,-85.7949;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;566;-5121.532,-187.5374;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;567;-4795,-142.6018;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;568;-5142.502,-18.27999;Inherit;False;Property;_useUVcoords;useUVcoords;17;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1786.998,176.3287;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_FOLIAGE_NEW9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.DitheringNode;292;-331.2404,1517.277;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;644;-5117.828,446.1346;Inherit;False;589;NewWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;491;-2555.642,1847.22;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;492;-2213.058,1910.912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;494;-1880.448,1946.296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;495;-1691.142,1960.45;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;493;-2043.599,1963.127;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1967.156,2093.445;Inherit;False;Property;_SphereHardness;SphereHardness;15;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;565;-2202.353,2085.013;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;512;-2602.95,2360.441;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;504;-2858.104,2131.062;Inherit;False;Property;_bendoffset;bend offset;16;0;Create;True;0;0;0;False;0;False;0,0,0;4,4,4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;505;-2919.379,1864.503;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-1441.912,1961.048;Inherit;True;sphereMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;569;3247.576,193.36;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;570;3490.686,245.0024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;571;3665.851,348.6257;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;572;3324.851,396.6256;Inherit;False;Property;_WorldFrequency;World Frequency;18;0;Create;True;0;0;0;False;0;False;0;0.458;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;3854.851,423.6256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;575;3930.851,578.6256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;579;4144.851,773.6256;Inherit;False;Property;_BendAmt;Bend Amt;19;0;Create;True;0;0;0;False;0;False;0;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;591;4157.398,284.157;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;581;5326.877,616.4504;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;5522.877,415.4518;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;584;5701.877,427.4518;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector3Node;586;5685.877,228.4519;Inherit;False;Constant;_Vector0;Vector 0;34;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;585;5923.877,378.7389;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SmoothstepOpNode;599;4739.05,268.6552;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;597;4512.524,278.0522;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;604;4348.5,328.0622;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;598;4236.973,174.1116;Inherit;False;Property;_GradientHeight;Gradient Height;22;0;Create;True;0;0;0;False;0;False;0;1.5;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;588;5819.877,630.4504;Inherit;False;Property;_WindDirection;Wind Direction;20;0;Create;True;0;0;0;False;0;False;0;1.41;0;6.21;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;576;4098.841,538.9551;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;577;3970.851,293.6257;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;606;3340.433,818.4102;Inherit;False;Property;_SecondaryFrequency;Secondary Frequency;23;0;Create;True;0;0;0;False;0;False;0;9.47;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;618;3477.343,1179.642;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;616;4122.788,1206.497;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;632;2913.854,1146.926;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;631;4812.732,1168.196;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;622;3250.682,1331.554;Inherit;False;Property;_secondaryspeed;secondary speed;24;0;Create;True;0;0;0;False;0;False;1,1;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;578;5179.776,410.576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;640;6146.861,777.6182;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;639;5656.561,828.0914;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;642;6036.007,961.8125;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;643;5760.797,1110.504;Inherit;False;Constant;_Vector1;Vector 1;39;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TimeNode;574;2699.238,497.4879;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;645;2806.863,730.3485;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;646;2611.192,726.3142;Inherit;False;Property;_timespeed;time speed;25;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;647;2996.483,724.2972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;648;3133.655,728.3315;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;4480.182,34.39661;Inherit;False;Property;_BottomGradientSize;Bottom Gradient Size;21;0;Create;True;0;0;0;False;0;False;0;2.41;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;649;2783.494,882.8047;Inherit;False;Property;_bushtimesteps;bush time steps;26;0;Create;True;0;0;0;False;0;False;0;9.2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectScaleNode;564;-2438.885,2204.3;Inherit;False;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;489;-2479.976,2027.443;Inherit;False;Property;_SphereRadius;SphereRadius;14;0;Create;True;0;0;0;False;0;False;0;4.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-2265.027,2364.993;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;855.7325,700.2125;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;511;-2849.506,2343.92;Inherit;False;Global;_BushPosition;_BushPosition;31;0;Create;True;0;0;0;False;0;False;0,0,0;-185.1658,41.22021,-225.851;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;657;1275.171,838.7219;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;1293.145,717.5705;Inherit;False;589;NewWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;664;4868.971,1467.572;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;589;7010.365,520.806;Inherit;False;NewWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;587;6452.577,490.8055;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;668;6295.235,1183.763;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;653;5211.901,1479.288;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;669;5233.615,1737.668;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;667;4993.994,1675.785;Inherit;False;Property;_Squash;Squash;27;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;670;-4831.604,795.7223;Inherit;False;Property;_NormalScale;Normal Scale;28;0;Create;True;0;0;0;False;0;False;0;0.212;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;628;5243,756.3207;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;580;5385.563,381.4518;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;603;4705.482,494.9896;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;677;4509.67,753.0435;Inherit;False;Property;_Tonedown;Tone down;29;0;Create;True;0;0;0;False;0;False;1;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;676;4757.348,846.6436;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;678;4659.429,1029.524;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;671;4932.26,777.4774;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;672;4478.343,854.4024;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;679;-5213.146,687.7877;Inherit;True;Property;_Texture0;Texture 0;30;0;Create;True;0;0;0;False;0;False;None;bd4806d82731a422ea0b106e0524d364;False;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;261;-4519.871,616.6649;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;None;bd4806d82731a422ea0b106e0524d364;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;685;-2643.337,-167.3562;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;684;-2506.464,-238.154;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;682;-3224.094,-133.6436;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;465;-4593.635,424.2814;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;680;-3060.14,-288.0371;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;687;-2828.467,-285.5064;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;688;-3035.467,-172.5064;Inherit;False;Property;_Intersectradius;Intersectradius;31;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;689;-2778.467,-155.5063;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;691;-2791.042,151.2498;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;692;5022.848,684.2036;Inherit;False;IntersectionNoiseUVs;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;694;-2445.583,-124.3861;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;-1,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;695;-3006.283,462.5359;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.2;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;696;3340.644,596.363;Inherit;False;SteppedTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;697;-3272.43,457.1836;Inherit;False;696;SteppedTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;693;-2996.663,378.9453;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;686;-3022.466,51.15377;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;703;-2855.467,266.8336;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;690;-3359.854,243.2254;Inherit;False;692;IntersectionNoiseUVs;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;705;-3388.512,400.442;Inherit;False;Constant;_Float0;Float 0;33;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;706;-3249.512,322.442;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;681;-2651.943,263.633;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;704;-2810.633,538.7861;Inherit;False;Property;_intersectnoisescale;intersectnoisescale;32;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;708;-2405.512,487.442;Inherit;True;Property;_intersectionnoise;intersection noise;33;0;Create;True;0;0;0;False;0;False;-1;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;709;-2548.078,559.5137;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
WireConnection;6;0;262;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;131;0;5;0
WireConnection;209;0;206;0
WireConnection;208;0;211;0
WireConnection;208;1;209;0
WireConnection;207;0;211;0
WireConnection;207;1;209;0
WireConnection;105;0;101;0
WireConnection;105;1;102;0
WireConnection;105;2;100;0
WireConnection;98;0;97;0
WireConnection;106;0;100;0
WireConnection;106;1;98;0
WireConnection;76;0;75;2
WireConnection;224;0;88;0
WireConnection;251;0;224;0
WireConnection;235;0;224;0
WireConnection;235;1;230;0
WireConnection;233;0;235;0
WireConnection;233;1;232;0
WireConnection;88;0;175;0
WireConnection;3;0;256;0
WireConnection;3;1;286;0
WireConnection;286;0;2;0
WireConnection;286;1;285;0
WireConnection;290;0;233;0
WireConnection;290;1;292;0
WireConnection;291;0;294;0
WireConnection;291;1;285;0
WireConnection;38;0;186;0
WireConnection;205;0;38;0
WireConnection;205;1;208;0
WireConnection;205;2;207;0
WireConnection;256;0;251;0
WireConnection;256;1;255;0
WireConnection;295;0;280;0
WireConnection;275;0;283;0
WireConnection;275;1;280;0
WireConnection;283;0;181;0
WireConnection;283;1;205;0
WireConnection;195;0;349;0
WireConnection;345;0;344;0
WireConnection;345;1;346;0
WireConnection;118;0;469;0
WireConnection;118;2;114;0
WireConnection;118;3;112;0
WireConnection;349;0;118;0
WireConnection;349;1;347;0
WireConnection;294;0;293;0
WireConnection;232;0;231;0
WireConnection;203;0;123;0
WireConnection;202;0;123;0
WireConnection;201;0;202;0
WireConnection;198;0;199;0
WireConnection;204;0;203;0
WireConnection;122;0;193;0
WireConnection;200;0;204;0
WireConnection;125;0;124;0
WireConnection;180;0;179;0
WireConnection;180;1;201;0
WireConnection;126;0;125;0
WireConnection;126;1;200;0
WireConnection;178;0;192;0
WireConnection;178;1;201;0
WireConnection;178;2;198;0
WireConnection;178;3;694;0
WireConnection;179;0;178;0
WireConnection;78;0;106;0
WireConnection;78;1;171;0
WireConnection;171;0;172;0
WireConnection;171;1;77;0
WireConnection;181;0;78;0
WireConnection;181;1;180;0
WireConnection;124;0;122;0
WireConnection;124;1;200;0
WireConnection;192;1;205;0
WireConnection;193;0;105;0
WireConnection;193;1;192;0
WireConnection;279;0;181;0
WireConnection;279;3;275;0
WireConnection;279;4;181;0
WireConnection;462;0;644;0
WireConnection;462;1;463;0
WireConnection;480;0;479;1
WireConnection;480;1;479;3
WireConnection;481;0;468;0
WireConnection;481;1;567;0
WireConnection;259;0;261;0
WireConnection;175;0;126;0
WireConnection;175;1;279;0
WireConnection;567;0;480;0
WireConnection;567;1;566;0
WireConnection;567;2;568;0
WireConnection;0;2;345;0
WireConnection;0;13;257;0
WireConnection;0;11;590;0
WireConnection;292;0;291;0
WireConnection;292;1;296;0
WireConnection;491;0;505;0
WireConnection;491;1;517;0
WireConnection;492;0;491;0
WireConnection;492;1;565;0
WireConnection;494;0;493;0
WireConnection;495;0;494;0
WireConnection;495;1;490;0
WireConnection;493;0;492;0
WireConnection;493;1;492;0
WireConnection;565;0;489;0
WireConnection;565;1;564;0
WireConnection;512;0;511;0
WireConnection;496;0;495;0
WireConnection;570;0;569;1
WireConnection;570;1;569;3
WireConnection;571;0;570;0
WireConnection;571;1;572;0
WireConnection;573;0;571;0
WireConnection;573;1;648;0
WireConnection;575;0;573;0
WireConnection;582;0;580;0
WireConnection;582;1;581;0
WireConnection;584;0;582;0
WireConnection;585;0;584;0
WireConnection;585;1;586;2
WireConnection;585;2;584;2
WireConnection;599;0;597;0
WireConnection;599;2;596;0
WireConnection;597;0;598;0
WireConnection;597;1;604;0
WireConnection;604;0;591;2
WireConnection;576;0;577;2
WireConnection;576;1;575;0
WireConnection;618;0;632;0
WireConnection;618;2;622;0
WireConnection;618;1;648;0
WireConnection;616;0;618;0
WireConnection;616;1;606;0
WireConnection;631;0;616;0
WireConnection;578;0;628;0
WireConnection;578;1;579;0
WireConnection;640;0;585;0
WireConnection;640;1;642;0
WireConnection;642;0;639;0
WireConnection;642;1;643;0
WireConnection;645;0;646;0
WireConnection;645;1;574;2
WireConnection;647;0;645;0
WireConnection;648;0;647;0
WireConnection;648;1;649;0
WireConnection;517;0;512;0
WireConnection;517;1;504;0
WireConnection;257;0;3;0
WireConnection;257;1;290;0
WireConnection;589;0;587;0
WireConnection;587;1;588;0
WireConnection;587;3;668;0
WireConnection;668;0;640;0
WireConnection;668;1;653;0
WireConnection;653;0;664;0
WireConnection;653;1;667;0
WireConnection;628;0;671;0
WireConnection;628;1;631;0
WireConnection;580;0;578;0
WireConnection;580;2;578;0
WireConnection;603;0;599;0
WireConnection;603;1;576;0
WireConnection;676;0;677;0
WireConnection;676;1;678;0
WireConnection;678;0;672;0
WireConnection;671;0;603;0
WireConnection;671;1;676;0
WireConnection;261;0;679;0
WireConnection;261;1;465;0
WireConnection;261;5;670;0
WireConnection;685;0;687;0
WireConnection;685;1;708;0
WireConnection;684;0;685;0
WireConnection;465;0;481;0
WireConnection;465;1;462;0
WireConnection;687;0;680;0
WireConnection;687;1;688;0
WireConnection;689;0;687;0
WireConnection;691;0;686;0
WireConnection;691;1;690;0
WireConnection;692;0;631;0
WireConnection;694;0;685;0
WireConnection;695;0;686;0
WireConnection;695;1;697;0
WireConnection;696;0;648;0
WireConnection;693;0;690;0
WireConnection;686;0;682;1
WireConnection;686;1;682;3
WireConnection;703;0;686;0
WireConnection;703;1;706;0
WireConnection;706;0;690;0
WireConnection;706;1;705;0
WireConnection;681;0;703;0
WireConnection;681;1;704;0
WireConnection;708;1;709;0
WireConnection;709;0;703;0
WireConnection;709;1;704;0
ASEEND*/
//CHKSM=BA07E426F2B50E5DE386901E2EA2EB09D5CE1EDE