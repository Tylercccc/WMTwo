// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Terrain"
{
	Properties
	{
		_Control("Control", 2D) = "white" {}
		_Specular1("Specular1", Color) = (0,0,0,0)
		_Specular0("Specular0", Color) = (0,0,0,0)
		_Normal1("Normal1", 2D) = "white" {}
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_Splat1("Splat1", 2D) = "white" {}
		_Normal0("Normal0", 2D) = "white" {}
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_RimPower("Rim Power", Float) = 5
		_WindNoiseTex("Wind Noise Tex", 2D) = "bump" {}
		_NoiseSize("Noise Size", Range( 0 , 1)) = 0.1
		_RimScale("Rim Scale", Float) = 1
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_WindScroll("Wind Scroll", Range( 0 , 1)) = 0
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_WindJitter("Wind Jitter", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		_Dither("Dither", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_Texture0("Texture 0", 2D) = "bump" {}
		_shine("shine", 2D) = "white" {}
		_shinesize("shine size", Float) = 0
		_Color0("Shine Color", Color) = (0,0,0,0)
		_JitterNoiseSize("Jitter Noise Size", Float) = 0
		_TimeScaleShine("TimeScale Shine", Float) = 0
		_GrassWindNormalScale("GrassWindNormalScale", Range( 0 , 1)) = 0.4
		_NormalScale0("NormalScale0", Range( 0 , 1)) = 0
		_NormalScale1("NormalScale1", Range( 0 , 1)) = 0
		_TerrainSteps("TerrainSteps", Range( 0 , 5)) = 0.25
		_Splat0("Splat0", 2D) = "white" {}
		_cliff("cliff", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" "IsEmissive" = "true"  }
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
			float2 uv_texcoord;
			float4 screenPosition;
			float3 worldPos;
			INTERNAL_DATA
			float3 worldNormal;
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

		UNITY_DECLARE_TEX2D_NOSAMPLER(_Control);
		uniform float4 _Control_ST;
		SamplerState sampler_Control;
		uniform float _TerrainSteps;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_shine);
		uniform float _shinesize;
		SamplerState sampler_shine;
		uniform float4 _Color0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WindNoiseTex);
		uniform float _WindScroll;
		uniform float _TimeScaleShine;
		uniform float _NoiseSize;
		SamplerState sampler_WindNoiseTex;
		uniform float _WindJitter;
		uniform float _JitterNoiseSize;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Dither);
		float4 _Dither_TexelSize;
		SamplerState sampler_Dither;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal0);
		SamplerState sampler_Normal0;
		uniform float _NormalScale0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Texture0);
		SamplerState sampler_Texture0;
		uniform float _GrassWindNormalScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		uniform float4 _Normal1_ST;
		SamplerState sampler_Normal1;
		uniform float _NormalScale1;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _Steps;
		uniform float _ShadowLevel;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_cliff);
		SamplerState sampler_cliff;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat0);
		SamplerState sampler_Splat0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat1);
		uniform float4 _Splat1_ST;
		SamplerState sampler_Splat1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Albedo);
		uniform float4 _Albedo_ST;
		SamplerState sampler_Albedo;
		uniform float4 _Specular0;
		uniform float4 _Specular1;


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
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 temp_cast_6 = (_TerrainSteps).xxxx;
			float4 normalizeResult631 = normalize( ( 1.0 - step( SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control ) , temp_cast_6 ) ) );
			float4 Control621 = normalizeResult631;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult517 = (float2(ase_worldPos.x , ase_worldPos.z));
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen554 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither554 = Dither4x4Bayer( fmod(clipScreen554.x, 4), fmod(clipScreen554.y, 4) );
			float4 appendResult492 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			dither554 = step( dither554, SAMPLE_TEXTURE2D( _shine, sampler_shine, ( _shinesize * appendResult492 ).xy ).r );
			float mulTime521 = _Time.y * 5.0;
			float temp_output_576_0 = ( floor( mulTime521 ) / _TimeScaleShine );
			float2 temp_output_522_0 = ( appendResult517 * _NoiseSize );
			float2 panner526 = ( ( (0.0 + (_WindScroll - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * temp_output_576_0 ) * float2( 1,0 ) + temp_output_522_0);
			float2 panner528 = ( ( temp_output_576_0 * (0.0 + (_WindJitter - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) ) * float2( 1,1 ) + ( temp_output_522_0 * _JitterNoiseSize ));
			float4 WindScroll533 = ( float4( pow( UnpackNormal( SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner526 ) ) , 1.5 ) , 0.0 ) + SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner528 ) );
			float4 temp_output_557_0 = saturate( ( ( dither554 * _Color0 ) - WindScroll533 ) );
			float4 Shine564 = temp_output_557_0;
			float2 uv_Normal1 = i.uv_texcoord * _Normal1_ST.xy + _Normal1_ST.zw;
			float4 weightedBlendVar606 = Control621;
			float3 weightedAvg606 = ( ( weightedBlendVar606.x*BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, appendResult517 ), _NormalScale0 ) , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, Shine564.rg ), _GrassWindNormalScale ) ) + weightedBlendVar606.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Normal1 ), _NormalScale1 ) + weightedBlendVar606.z*float3( 0,0,0 ) + weightedBlendVar606.w*float3( 0,0,0 ) )/( weightedBlendVar606.x + weightedBlendVar606.y + weightedBlendVar606.z + weightedBlendVar606.w ) );
			float3 normal259 = weightedAvg606;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5 = dot( (WorldNormalVector( i , normal259 )) , ase_worldlightDir );
			float NdotL131 = dotResult5;
			float smoothstepResult205 = smoothstep( ( _LightGradientMidLevel - temp_output_209_0 ) , ( _LightGradientMidLevel + temp_output_209_0 ) , (NdotL131*0.5 + 0.5));
			float temp_output_192_0 = ( 0.0 + smoothstepResult205 );
			float temp_output_181_0 = ( ( ( ase_lightAtten * ( 1.0 - IsPointLight76 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( temp_output_192_0 * _Steps * ( 1.0 - IsPointLight76 ) ) ) / _Steps ) );
			float dither275 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			dither275 = step( dither275, ( temp_output_181_0 * smoothstepResult205 ) );
			float temp_output_224_0 = ( 1.0 - ( ( floor( ( saturate( ( ( _PointLightAttenuationBoost * IsPointLight76 * ase_lightAtten ) * temp_output_192_0 ) ) * _Steps ) ) / _Steps ) + (( temp_output_181_0 >= 0.0 && temp_output_181_0 <= 1.0 ) ? dither275 :  temp_output_181_0 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			ase_vertexNormal = normalize( ase_vertexNormal );
			float4 appendResult675 = (float4(ase_vertexNormal.y , ase_vertexNormal.z , 0.0 , 0.0));
			float4 appendResult674 = (float4(ase_vertexNormal.x , ase_vertexNormal.z , 0.0 , 0.0));
			float4 appendResult672 = (float4(ase_vertexNormal.x , ase_vertexNormal.y , 0.0 , 0.0));
			float3 weightedBlendVar681 = ase_vertexNormal;
			float4 weightedAvg681 = ( ( weightedBlendVar681.x*SAMPLE_TEXTURE2D( _cliff, sampler_cliff, appendResult675.xy ) + weightedBlendVar681.y*SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, appendResult674.xy ) + weightedBlendVar681.z*SAMPLE_TEXTURE2D( _cliff, sampler_cliff, appendResult672.xy ) )/( weightedBlendVar681.x + weightedBlendVar681.y + weightedBlendVar681.z ) );
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float4 weightedBlendVar617 = Control621;
			float4 weightedAvg617 = ( ( weightedBlendVar617.x*weightedAvg681 + weightedBlendVar617.y*SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) + weightedBlendVar617.z*float4( 0,0,0,0 ) + weightedBlendVar617.w*float4( 0,0,0,0 ) )/( weightedBlendVar617.x + weightedBlendVar617.y + weightedBlendVar617.z + weightedBlendVar617.w ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode285 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
			float4 temp_cast_14 = (temp_output_224_0).xxxx;
			float4 weightedBlendVar604 = Control621;
			float4 weightedAvg604 = ( ( weightedBlendVar604.x*_Specular0 + weightedBlendVar604.y*_Specular1 + weightedBlendVar604.z*float4( 0,0,0,0 ) + weightedBlendVar604.w*float4( 0,0,0,0 ) )/( weightedBlendVar604.x + weightedBlendVar604.y + weightedBlendVar604.z + weightedBlendVar604.w ) );
			float dither292 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float cameraDepthFade293 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 5.0);
			float clampResult294 = clamp( cameraDepthFade293 , 1.0 , 20.0 );
			dither292 = step( dither292, ( clampResult294 * tex2DNode285 ).r );
			c.rgb = ( ( ( ( 1.0 - temp_output_224_0 ) * ase_lightColor ) * ( weightedAvg617 * tex2DNode285 ) ) + ( ( min( temp_cast_14 , weightedAvg604 ) * ( 1.0 - IsPointLight76 ) ) * dither292 ) ).rgb;
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
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 temp_cast_0 = (_TerrainSteps).xxxx;
			float4 normalizeResult631 = normalize( ( 1.0 - step( SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control ) , temp_cast_0 ) ) );
			float4 Control621 = normalizeResult631;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen554 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither554 = Dither4x4Bayer( fmod(clipScreen554.x, 4), fmod(clipScreen554.y, 4) );
			float3 ase_worldPos = i.worldPos;
			float4 appendResult492 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			dither554 = step( dither554, SAMPLE_TEXTURE2D( _shine, sampler_shine, ( _shinesize * appendResult492 ).xy ).r );
			float mulTime521 = _Time.y * 5.0;
			float temp_output_576_0 = ( floor( mulTime521 ) / _TimeScaleShine );
			float2 appendResult517 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_522_0 = ( appendResult517 * _NoiseSize );
			float2 panner526 = ( ( (0.0 + (_WindScroll - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * temp_output_576_0 ) * float2( 1,0 ) + temp_output_522_0);
			float2 panner528 = ( ( temp_output_576_0 * (0.0 + (_WindJitter - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) ) * float2( 1,1 ) + ( temp_output_522_0 * _JitterNoiseSize ));
			float4 WindScroll533 = ( float4( pow( UnpackNormal( SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner526 ) ) , 1.5 ) , 0.0 ) + SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner528 ) );
			float4 temp_output_557_0 = saturate( ( ( dither554 * _Color0 ) - WindScroll533 ) );
			float4 weightedBlendVar632 = Control621;
			float4 weightedAvg632 = ( ( weightedBlendVar632.x*temp_output_557_0 + weightedBlendVar632.y*float4( 0,0,0,0 ) + weightedBlendVar632.z*float4( 0,0,0,0 ) + weightedBlendVar632.w*float4( 0,0,0,0 ) )/( weightedBlendVar632.x + weightedBlendVar632.y + weightedBlendVar632.z + weightedBlendVar632.w ) );
			float dither349 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float4 Shine564 = temp_output_557_0;
			float2 uv_Normal1 = i.uv_texcoord * _Normal1_ST.xy + _Normal1_ST.zw;
			float4 weightedBlendVar606 = Control621;
			float3 weightedAvg606 = ( ( weightedBlendVar606.x*BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, appendResult517 ), _NormalScale0 ) , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, Shine564.rg ), _GrassWindNormalScale ) ) + weightedBlendVar606.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Normal1 ), _NormalScale1 ) + weightedBlendVar606.z*float3( 0,0,0 ) + weightedBlendVar606.w*float3( 0,0,0 ) )/( weightedBlendVar606.x + weightedBlendVar606.y + weightedBlendVar606.z + weightedBlendVar606.w ) );
			float3 normal259 = weightedAvg606;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV118 = dot( mul(ase_tangentToWorldFast,normal259), ase_worldViewDir );
			float fresnelNode118 = ( 0.0 + _RimScale * pow( 1.0 - fresnelNdotV118, _RimPower ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			dither349 = step( dither349, ( fresnelNode118 * ase_vertex3Pos.y ) );
			float RimWrap195 = dither349;
			o.Emission = ( weightedAvg632 + ( RimWrap195 * _RimColor ) ).rgb;
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
				float3 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
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
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.screenPosition;
				o.customPack1.z = customInputData.eyeDepth;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.screenPosition = IN.customPack2.xyzw;
				surfIN.eyeDepth = IN.customPack1.z;
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
Node;AmplifyShaderEditor.CommentaryNode;307;-2675.733,-887.3652;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;3;118;114;112;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4290.296,-456.7152;Inherit;False;1025.107;587.7744;Basic lighting;4;5;7;6;131;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3285.258,-2905.049;Inherit;False;Property;_RimPower;Rim Power;8;0;Create;True;0;0;0;False;0;False;5;21.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3314.258,-2999.049;Inherit;False;Property;_RimScale;Rim Scale;11;0;Create;True;0;0;0;False;0;False;1;2.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;8;206;211;209;207;208;205;186;38;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;2;76;75;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;209;-3676.961,-1291.98;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3919.807,-1517.473;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;14;0;Create;True;0;0;0;False;0;False;0;0.673;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3471.961,-1306.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-3471.961,-1418.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;7;106;105;102;101;100;98;97;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-5113.211,-1705.717;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;7;0;Create;True;0;0;0;False;0;False;1;3.2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2885.612,-913.2354;Inherit;False;1379.942;546.2153;;11;198;199;78;171;181;180;179;178;77;172;201;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-5099.51,-1562.309;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3359.705,-955.5967;Inherit;False;Property;_Steps;Steps;4;1;[IntRange];Create;True;0;0;0;False;0;False;5;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;100;-5080.172,-1436.925;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-2734.457,-598.7814;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-2949.081,-1021.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4825.77,-1646.348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-2947.052,-532.3419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;201;-2592.788,-450.5684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-2552.794,-599.8965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;204;-2253.978,-1040.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-5177.416,-1320.394;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2443.691,-1389.961;Inherit;False;888.2502;342.3433;;4;126;125;124;200;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;122;-2251.612,-1704.403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-4960.516,-1316.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;200;-2132.371,-1192.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2753.487,-823.5073;Inherit;False;Property;_ShadowLevel;Shadow Level;12;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;77;-2733.782,-722.4692;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-4734.148,-1366.108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;125;-1849.533,-1316.652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;180;-2025.505,-627.576;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-1670.139,-1317.281;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1768.84,307.8115;Inherit;False;932.1631;425.7859;Directional Light Only;4;224;251;88;235;Shadow Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-19.37829,440.4236;Inherit;False;464.8;298.7;Material Color;1;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;0;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-2378.414,-629.7809;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;179;-2157.167,-625.356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;75;-2982.111,874.9663;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-2742.111,890.9663;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;224;-1445.411,394.2598;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;251;-1221.036,384.5249;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-961.9585,928.7074;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;88;-1673.704,416.2784;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;255;-673.2963,576.7527;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;230.1328,484.7082;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;106.1416,789.8001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-271.8002,1213.358;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;285;-447.682,804.0729;Inherit;True;Property;_Albedo;Albedo;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-584.3527,1239.109;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;292;-456.4587,1557.525;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-701.2247,1717.931;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1967.098,-884.5726;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;-2212.103,-853.4663;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1733.54,-758.7867;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-3537.574,-1617.438;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3910.961,-1389.98;Inherit;False;Property;_LightGradientSize;Light Gradient Size;16;0;Create;True;0;0;0;False;0;False;0;0.332;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;205;-3242.402,-1528.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-3810.594,-1602.487;Inherit;False;131;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;279;-1469.441,-679.9645;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-454.0071,446.9763;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2136.439,319.0111;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;275;-1999.236,-8.152191;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-2275.811,-192.2104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;280;-2405.055,4.84398;Inherit;True;Property;_Dither;Dither;17;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2392.995,-2603.417;Inherit;False;RimWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;118;-3018.471,-2998.382;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-2836.169,-2393.839;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;349;-2515.753,-2236.347;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;41.63611,1031.19;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;293;-980.1703,1503.753;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;294;-644.3625,1517.31;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2023.048,-1319.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-2676.004,-1496.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-2442.655,-1699.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-693.7272,-214.5242;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3378.499,-3616.521;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-4182.831,-376.0671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-4204.932,-118.6672;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;5;-3948.828,-272.0672;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3774.34,-227.2643;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4626.501,-331.4977;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;232;-1250.855,1238.667;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;492;750.7205,1778.893;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;493;557.0078,2021.875;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-3781.107,620.3472;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;515;-5871.882,1796.59;Inherit;False;2185.108;805.0172;Comment;19;534;533;531;530;529;528;527;526;525;524;523;522;521;520;519;518;516;558;560;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-5654.798,2404.663;Inherit;False;Property;_WindJitter;Wind Jitter;15;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;524;-5368.009,2394.606;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-5146.776,2320.19;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;-5389.722,1992.938;Inherit;False;Property;_NoiseSize;Noise Size;10;0;Create;True;0;0;0;False;0;False;0.1;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;346;-63.98357,192.0286;Inherit;False;Property;_RimColor;Rim Color;19;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2778425,0.2924528,0.03724635,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;434.6189,388.2189;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;545;367.1279,54.65058;Inherit;True;Property;_shine;shine;21;0;Create;True;0;0;0;False;0;False;-1;None;82aaf027903b047d7af1e568e3864879;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;344;105.6548,87.75449;Inherit;False;195;RimWrap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;550;842.1348,1189.511;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;551;594.7067,1157.677;Inherit;False;Property;_shinesize;shine size;22;0;Create;True;0;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;549;847.5302,111.5257;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;554;662.0939,117.2327;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;555;1098.094,122.2327;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;556;875.094,381.2327;Inherit;False;533;WindScroll;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;557;1250.094,253.2327;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;519;-5529.324,2090.413;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;-5821.882,2096.156;Inherit;False;Property;_WindScroll;Wind Scroll;13;0;Create;True;0;0;0;False;0;False;0;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;528;-4782.957,2288.485;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;527;-4946.522,2197.894;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;558;-5198.799,2216.535;Inherit;False;Property;_JitterNoiseSize;Jitter Noise Size;24;0;Create;True;0;0;0;False;0;False;0;5.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;530;-4564.03,2258.288;Inherit;True;Property;_TextureSample2;Texture Sample 0;9;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;529;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;560;-4334.411,2102.76;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;529;-4649.171,1784.246;Inherit;True;Property;_WindNoiseTex;Wind Noise Tex;9;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;553;587.0939,239.2478;Inherit;False;Property;_Color0;Shine Color;23;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.509434,0.4445532,0.4445532,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;522;-5207.722,1876.938;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;526;-4881.083,1879.503;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;574;-5618.909,2651.862;Inherit;False;Property;_TimeScaleShine;TimeScale Shine;25;0;Create;True;0;0;0;False;0;False;0;7.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;576;-4936.536,2745.059;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;523;-5217.722,2050.013;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;579;-5142.251,2680.301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;521;-5382.465,2257.4;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;591;-3400.714,-2323.332;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-3125.263,-2302.279;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;235;-1003.207,714.0432;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1542.474,1440.095;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WeightedBlendNode;604;-1394.086,833.284;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;598;-1962.967,929.7949;Inherit;False;Property;_Specular1;Specular1;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;594;-1965.918,743.6865;Inherit;False;Property;_Specular0;Specular0;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WeightedBlendNode;606;-4938.515,274.8283;Inherit;False;5;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WeightedBlendNode;617;554.2601,-489.7333;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;596;-778.9888,-1041.649;Inherit;True;Property;_Control;Control;0;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;625;-1592.318,743.5659;Inherit;False;621;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;630;-646.2712,-507.3401;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;631;-448.5319,-338.3301;Inherit;False;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;552;958.6873,503.0906;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;614;-5184.914,10.66188;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;612;-5536.326,-222.3659;Inherit;True;Property;_Normal0;Normal0;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;589;-5544.755,27.3201;Inherit;True;Property;_NormalMap1;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;c78e565eaf65cb1428fac66341a4a8bc;bd4806d82731a422ea0b106e0524d364;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;615;-5999.894,-186.7563;Inherit;False;Property;_NormalScale0;NormalScale0;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;620;-5973.035,360.3865;Inherit;False;Property;_NormalScale1;NormalScale1;28;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;613;-5524.691,272.5958;Inherit;True;Property;_Normal1;Normal1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;503;-5950.013,124.5902;Inherit;True;Property;_Texture0;Texture 0;20;0;Create;True;0;0;0;False;0;False;None;5259d0042c9854375b96305b6256ecfd;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;568;-5957.212,43.6999;Inherit;False;564;Shine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;534;-5665.233,1874.339;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;517;-5424.712,1689.548;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;585;-5981.769,-64.96311;Inherit;False;Property;_GrassWindNormalScale;GrassWindNormalScale;26;0;Create;True;0;0;0;False;0;False;0.4;0.263;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;1411.908,587.8496;Inherit;False;Shine;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WeightedBlendNode;632;1164.899,603.021;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;633;879.3306,604.9774;Inherit;False;621;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;533;-3910.771,1851.807;Inherit;False;WindScroll;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;531;-4242.678,1846.59;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;624;-5145.129,-132.0384;Inherit;False;621;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;628;-548.9171,-643.5346;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;623;-818.3987,-727.8853;Inherit;False;Property;_TerrainSteps;TerrainSteps;29;0;Create;True;0;0;0;False;0;False;0.25;0.49;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;621;-195.7012,-1102.811;Inherit;False;Control;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;616;-292.8549,-173.9107;Inherit;True;Property;_Splat1;Splat1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;675;450.0922,-701.2454;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1004.913,-913.8269;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;676;805.9766,-859.0363;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;678;763.355,-696.3004;Inherit;False;Constant;_Float0;Float 0;31;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WeightedBlendNode;681;1325.639,-1092.446;Inherit;False;5;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;672;431.7769,-1094.709;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;683;199.6832,-1089.909;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;684;828.4511,-1072.383;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;685;646.6119,-956.2686;Inherit;False;Constant;_Float1;Float 1;33;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;669;-36.1237,-837.804;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;686;-65.14555,-628.9395;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;665;548.3265,-1489.346;Inherit;True;Property;_Splat0;Splat0;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;682;908.8196,-1520.344;Inherit;True;Property;_cliff;cliff;31;0;Create;True;0;0;0;False;0;False;-1;None;71ee2865e455142fb9a3cd6e3ef3fc51;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;680;745.9042,-1247.86;Inherit;True;Property;_TextureSample0;Texture Sample 0;31;0;Create;True;0;0;0;False;0;False;-1;None;8d928a03c9a6d8445a56096a84efd563;True;0;False;white;Auto;False;Instance;682;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;674;446.554,-869.2915;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
WireConnection;209;0;206;0
WireConnection;208;0;211;0
WireConnection;208;1;209;0
WireConnection;207;0;211;0
WireConnection;207;1;209;0
WireConnection;203;0;123;0
WireConnection;105;0;101;0
WireConnection;105;1;102;0
WireConnection;105;2;100;0
WireConnection;202;0;123;0
WireConnection;201;0;202;0
WireConnection;198;0;199;0
WireConnection;204;0;203;0
WireConnection;122;0;193;0
WireConnection;98;0;97;0
WireConnection;200;0;204;0
WireConnection;106;0;100;0
WireConnection;106;1;98;0
WireConnection;125;0;124;0
WireConnection;180;0;179;0
WireConnection;180;1;201;0
WireConnection;126;0;125;0
WireConnection;126;1;200;0
WireConnection;178;0;192;0
WireConnection;178;1;201;0
WireConnection;178;2;198;0
WireConnection;179;0;178;0
WireConnection;76;0;75;2
WireConnection;224;0;88;0
WireConnection;251;0;224;0
WireConnection;233;0;235;0
WireConnection;233;1;232;0
WireConnection;88;0;175;0
WireConnection;3;0;256;0
WireConnection;3;1;286;0
WireConnection;286;0;617;0
WireConnection;286;1;285;0
WireConnection;290;0;233;0
WireConnection;290;1;292;0
WireConnection;291;0;294;0
WireConnection;291;1;285;0
WireConnection;292;0;291;0
WireConnection;292;1;296;0
WireConnection;78;0;106;0
WireConnection;78;1;171;0
WireConnection;171;0;172;0
WireConnection;171;1;77;0
WireConnection;181;0;78;0
WireConnection;181;1;180;0
WireConnection;38;0;186;0
WireConnection;205;0;38;0
WireConnection;205;1;208;0
WireConnection;205;2;207;0
WireConnection;279;0;181;0
WireConnection;279;3;275;0
WireConnection;279;4;181;0
WireConnection;256;0;251;0
WireConnection;256;1;255;0
WireConnection;295;0;280;0
WireConnection;275;0;283;0
WireConnection;275;1;280;0
WireConnection;283;0;181;0
WireConnection;283;1;205;0
WireConnection;195;0;349;0
WireConnection;118;0;469;0
WireConnection;118;2;114;0
WireConnection;118;3;112;0
WireConnection;349;0;592;0
WireConnection;349;1;347;0
WireConnection;257;0;3;0
WireConnection;257;1;290;0
WireConnection;294;0;293;0
WireConnection;124;0;122;0
WireConnection;124;1;200;0
WireConnection;192;1;205;0
WireConnection;193;0;105;0
WireConnection;193;1;192;0
WireConnection;175;0;126;0
WireConnection;175;1;279;0
WireConnection;6;0;262;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;131;0;5;0
WireConnection;232;0;231;0
WireConnection;492;0;493;1
WireConnection;492;1;493;3
WireConnection;259;0;606;0
WireConnection;524;0;520;0
WireConnection;525;0;576;0
WireConnection;525;1;524;0
WireConnection;345;0;344;0
WireConnection;345;1;346;0
WireConnection;545;1;550;0
WireConnection;550;0;551;0
WireConnection;550;1;492;0
WireConnection;549;0;554;0
WireConnection;549;1;553;0
WireConnection;554;0;545;0
WireConnection;555;0;549;0
WireConnection;555;1;556;0
WireConnection;557;0;555;0
WireConnection;519;0;516;0
WireConnection;528;0;527;0
WireConnection;528;1;525;0
WireConnection;527;0;522;0
WireConnection;527;1;558;0
WireConnection;530;1;528;0
WireConnection;560;0;531;0
WireConnection;560;1;530;0
WireConnection;529;1;526;0
WireConnection;522;0;517;0
WireConnection;522;1;518;0
WireConnection;526;0;522;0
WireConnection;526;1;523;0
WireConnection;576;0;579;0
WireConnection;576;1;574;0
WireConnection;523;0;519;0
WireConnection;523;1;576;0
WireConnection;579;0;521;0
WireConnection;592;0;118;0
WireConnection;592;1;591;2
WireConnection;235;0;224;0
WireConnection;235;1;604;0
WireConnection;604;0;625;0
WireConnection;604;1;594;0
WireConnection;604;2;598;0
WireConnection;606;0;624;0
WireConnection;606;1;614;0
WireConnection;606;2;613;0
WireConnection;617;0;621;0
WireConnection;617;1;681;0
WireConnection;617;2;616;0
WireConnection;630;0;628;0
WireConnection;631;0;630;0
WireConnection;552;0;632;0
WireConnection;552;1;345;0
WireConnection;614;0;612;0
WireConnection;614;1;589;0
WireConnection;612;1;517;0
WireConnection;612;5;615;0
WireConnection;589;0;503;0
WireConnection;589;1;568;0
WireConnection;589;5;585;0
WireConnection;613;5;620;0
WireConnection;517;0;534;1
WireConnection;517;1;534;3
WireConnection;564;0;557;0
WireConnection;632;0;633;0
WireConnection;632;1;557;0
WireConnection;533;0;560;0
WireConnection;531;0;529;0
WireConnection;628;0;596;0
WireConnection;628;1;623;0
WireConnection;621;0;631;0
WireConnection;675;0;669;2
WireConnection;675;1;669;3
WireConnection;0;2;552;0
WireConnection;0;13;257;0
WireConnection;681;0;669;0
WireConnection;681;1;680;0
WireConnection;681;2;665;0
WireConnection;681;3;682;0
WireConnection;672;0;669;1
WireConnection;672;1;669;2
WireConnection;683;0;669;0
WireConnection;684;0;683;0
WireConnection;684;1;685;0
WireConnection;665;1;674;0
WireConnection;682;1;672;0
WireConnection;680;1;675;0
WireConnection;674;0;669;1
WireConnection;674;1;669;3
ASEEND*/
//CHKSM=7681B535F610DF33266AF9BF7E8CF91E6A947A0D