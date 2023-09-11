// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Terrain"
{
	Properties
	{
		[HideInInspector]_Mask2("_Mask2", 2D) = "white" {}
		[HideInInspector]_Mask0("_Mask0", 2D) = "white" {}
		[HideInInspector]_Mask1("_Mask1", 2D) = "white" {}
		[HideInInspector]_Mask3("_Mask3", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Control("Control", 2D) = "white" {}
		_Specular1("Specular1", Color) = (0,0,0,0)
		_Specular0("Specular0", Color) = (0,0,0,0)
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
		_Normal1("Normal1", 2D) = "bump" {}
		_shine("shine", 2D) = "white" {}
		_shinesize("shine size", Float) = 0
		_Color0("Shine Color", Color) = (0,0,0,0)
		_JitterNoiseSize("Jitter Noise Size", Float) = 0
		_TimeScaleShine("TimeScale Shine", Float) = 0
		_GrassWindNormalScale("GrassWindNormalScale", Range( 0 , 1)) = 0.4
		_NormalScale0("NormalScale0", Range( 0 , 1)) = 0
		_Softness("Softness", Range( 0 , 50)) = 0
		_NormalScale1("NormalScale1", Range( 0 , 1)) = 0
		_Level("Level", Range( 0 , 1)) = 0
		_Splat0("Splat0", 2D) = "white" {}
		_CliffShadow("Cliff Shadow", Color) = (0,0,0,0)
		_CliffTiling("Cliff Tiling", Vector) = (0,0,0,0)
		_CliffTex("Cliff Tex", 2D) = "white" {}
		_TriPlanarFalloff("TriPlanar Falloff", Range( 0 , 20)) = 10
		_test("test", Range( 0 , 100)) = 0
		_Texture1("Texture 1", 2D) = "white" {}
		_TerrainHolesTexture("TerrainHolesTexture", 2D) = "white" {}
		_pathSteps("path Steps", Float) = 0
		_testest("testest", Float) = 0
		_Blendstr("Blendstr", Float) = 0
		_GrassNormalSize("Grass Normal Size", Float) = 0
		_Pathnoisescale("Path noise scale", Float) = 0
		_CliffScale("Cliff Scale", Float) = 0
		_cliffblendstr("cliff blendstr", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest-100" "IsEmissive" = "true"  "SplatCount"="4" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd
		#pragma multi_compile_local __ _ALPHATEST_ON
		#pragma shader_feature_local _MASKMAP
		#define ASE_USING_SAMPLING_MACROS 1
		#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex.SampleLevel(samplerTex,coord, lod)
		#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex.SampleBias(samplerTex,coord,bias)
		#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex.SampleGrad(samplerTex,coord,ddx,ddy)
		#else//ASE Sampling Macros
		#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
		#define SAMPLE_TEXTURE2D_LOD(tex,samplerTex,coord,lod) tex2Dlod(tex,float4(coord,0,lod))
		#define SAMPLE_TEXTURE2D_BIAS(tex,samplerTex,coord,bias) tex2Dbias(tex,float4(coord,0,bias))
		#define SAMPLE_TEXTURE2D_GRAD(tex,samplerTex,coord,ddx,ddy) tex2Dgrad(tex,coord,ddx,ddy)
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
			float3 worldPos;
			float4 screenPosition;
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

		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask2);
		SamplerState sampler_Mask2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask0);
		SamplerState sampler_Mask0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask1);
		SamplerState sampler_Mask1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask3);
		SamplerState sampler_Mask3;
		uniform float4 _MaskMapRemapScale0;
		uniform float4 _MaskMapRemapOffset2;
		uniform float4 _MaskMapRemapScale2;
		uniform float4 _MaskMapRemapScale1;
		uniform float4 _MaskMapRemapOffset1;
		uniform float4 _MaskMapRemapScale3;
		uniform float4 _MaskMapRemapOffset3;
		uniform float4 _MaskMapRemapOffset0;
		#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
			sampler2D _TerrainHeightmapTexture;//ASE Terrain Instancing
			sampler2D _TerrainNormalmapTexture;//ASE Terrain Instancing
		#endif//ASE Terrain Instancing
		UNITY_INSTANCING_BUFFER_START( Terrain )//ASE Terrain Instancing
			UNITY_DEFINE_INSTANCED_PROP( float4, _TerrainPatchInstanceData )//ASE Terrain Instancing
		UNITY_INSTANCING_BUFFER_END( Terrain)//ASE Terrain Instancing
		CBUFFER_START( UnityTerrain)//ASE Terrain Instancing
			#ifdef UNITY_INSTANCING_ENABLED//ASE Terrain Instancing
				float4 _TerrainHeightmapRecipSize;//ASE Terrain Instancing
				float4 _TerrainHeightmapScale;//ASE Terrain Instancing
			#endif//ASE Terrain Instancing
		CBUFFER_END//ASE Terrain Instancing
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Control);
		uniform float4 _Control_ST;
		SamplerState sampler_Control;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal0);
		uniform float _Pathnoisescale;
		SamplerState sampler_Normal0;
		uniform float _Blendstr;
		uniform float _testest;
		uniform float _pathSteps;
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
		uniform float _Level;
		uniform float _cliffblendstr;
		uniform float _Softness;
		uniform float _test;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Dither);
		float4 _Dither_TexelSize;
		SamplerState sampler_Dither;
		uniform float _GrassNormalSize;
		uniform float _NormalScale0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Texture0);
		SamplerState sampler_Texture0;
		uniform float _GrassWindNormalScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Texture1);
		SamplerState sampler_Texture1;
		uniform float2 _CliffTiling;
		uniform float _CliffScale;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		SamplerState sampler_Normal1;
		uniform float _NormalScale1;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_TerrainHolesTexture);
		uniform float4 _TerrainHolesTexture_ST;
		SamplerState sampler_TerrainHolesTexture;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _Steps;
		uniform float _ShadowLevel;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_CliffTex);
		SamplerState sampler_CliffTex;
		uniform float _TriPlanarFalloff;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat0);
		uniform float4 _Splat0_ST;
		SamplerState sampler_Splat0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat1);
		uniform float4 _Splat1_ST;
		SamplerState sampler_Splat1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Albedo);
		uniform float4 _Albedo_ST;
		SamplerState sampler_Albedo;
		uniform float4 _Specular0;
		uniform float4 _CliffShadow;
		uniform float4 _Specular1;
		uniform float _Cutoff = 0.5;


		void ApplyMeshModification( inout appdata_full v )
		{
			#if defined(UNITY_INSTANCING_ENABLED) && !defined(SHADER_API_D3D11_9X)
				float2 patchVertex = v.vertex.xy;
				float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);
				
				float4 uvscale = instanceData.z * _TerrainHeightmapRecipSize;
				float4 uvoffset = instanceData.xyxy * uvscale;
				uvoffset.xy += 0.5f * _TerrainHeightmapRecipSize.xy;
				float2 sampleCoords = (patchVertex.xy * uvscale.xy + uvoffset.xy);
				
				float hm = UnpackHeightmap(tex2Dlod(_TerrainHeightmapTexture, float4(sampleCoords, 0, 0)));
				v.vertex.xz = (patchVertex.xy + instanceData.xy) * _TerrainHeightmapScale.xz * instanceData.z;
				v.vertex.y = hm * _TerrainHeightmapScale.y;
				v.vertex.w = 1.0f;
				
				v.texcoord.xy = (patchVertex.xy * uvscale.zw + uvoffset.zw);
				v.texcoord3 = v.texcoord2 = v.texcoord1 = v.texcoord;
				
				#ifdef TERRAIN_INSTANCED_PERPIXEL_NORMAL
					v.normal = float3(0, 1, 0);
					//data.tc.zw = sampleCoords;
				#else
					float3 nor = tex2Dlod(_TerrainNormalmapTexture, float4(sampleCoords, 0, 0)).xyz;
					v.normal = 2.0f * nor - 1.0f;
				#endif
			#endif
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


		inline float DitherNoiseTex( float4 screenPos, UNITY_DECLARE_TEX2D_NOSAMPLER(noiseTexture), SamplerState samplernoiseTexture, float4 noiseTexelSize )
		{
			float dither = SAMPLE_TEXTURE2D_LOD( noiseTexture, samplernoiseTexture, screenPos.xy * _ScreenParams.xy * noiseTexelSize.xy, 0 ).g;
			float ditherRate = noiseTexelSize.x * noiseTexelSize.y;
			dither = ( 1 - ditherRate ) * dither + ditherRate;
			return dither;
		}


		float3 PerturbNormal107_g3( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		inline float3 TriplanarSampling812( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSampling734( UNITY_DECLARE_TEX2D_NOSAMPLER(topTexMap), SamplerState samplertopTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = SAMPLE_TEXTURE2D( topTexMap, samplertopTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			ApplyMeshModification(v);;
			float localCalculateTangentsStandard16_g4 = ( 0.0 );
			{
			v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) );
			v.tangent.w = -1;
			}
			v.vertex.xyz += localCalculateTangentsStandard16_g4;
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
			float2 uv_TerrainHolesTexture = i.uv_texcoord * _TerrainHolesTexture_ST.xy + _TerrainHolesTexture_ST.zw;
			float IsPointLight76 = _WorldSpaceLightPos0.w;
			float temp_output_209_0 = ( _LightGradientSize * 0.5 );
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode596 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float3 ase_worldPos = i.worldPos;
			float2 appendResult517 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 AppendedWorldPos857 = appendResult517;
			float4 tex2DNode862 = SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, ( AppendedWorldPos857 * _Pathnoisescale ) );
			float HeightMask861 = saturate(pow(max( (((tex2DNode862.a*tex2DNode596.g)*4)+(tex2DNode596.g*2)), 0 ),_Blendstr));
			float4 appendResult859 = (float4(tex2DNode596.r , HeightMask861 , tex2DNode596.b , tex2DNode596.a));
			float4 Control621 = ( floor( ( appendResult859 * _testest ) ) / _pathSteps );
			float3 surf_pos107_g3 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g3 = ase_worldNormal;
			float GrassCutoff892 = HeightMask861;
			float height107_g3 = ( 1.0 - GrassCutoff892 );
			float scale107_g3 = 10.0;
			float3 localPerturbNormal107_g3 = PerturbNormal107_g3( surf_pos107_g3 , surf_norm107_g3 , height107_g3 , scale107_g3 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g3 = mul( ase_worldToTangent, localPerturbNormal107_g3);
			float3 temp_output_893_40 = worldToTangentDir42_g3;
			float2 temp_output_901_0 = ( appendResult517 * _GrassNormalSize );
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
			float GrassDivision916 = tex2DNode862.a;
			float temp_output_695_0 = abs( ase_worldNormal.y );
			float temp_output_781_0 = ( temp_output_695_0 - _Level );
			float HeightMask915 = saturate(pow(((GrassDivision916*temp_output_781_0)*4)+(temp_output_781_0*2),_cliffblendstr));
			float temp_output_747_0 = saturate( ( floor( ( HeightMask915 * _Softness ) ) / _test ) );
			float CliffBlendSteps744 = pow( temp_output_747_0 , 0.3 );
			float4 Shine564 = saturate( ( ( ( dither554 * _Color0 ) - WindScroll533 ) * CliffBlendSteps744 ) );
			float2 CliffTiling813 = _CliffTiling;
			float3 triplanar812 = TriplanarSampling812( _Texture1, sampler_Texture1, ase_worldPos, ase_worldNormal, 10.0, CliffTiling813, _CliffScale, 0 );
			float3 tanTriplanarNormal812 = mul( ase_worldToTangent, triplanar812 );
			float temp_output_703_0 = ( 1.0 - CliffBlendSteps744 );
			float CliffBoundaries844 = temp_output_703_0;
			float3 lerpResult802 = lerp( BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, temp_output_901_0 ), _NormalScale0 ) , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, Shine564.rg ), _GrassWindNormalScale ) ) , tanTriplanarNormal812 , CliffBoundaries844);
			float4 weightedBlendVar606 = Control621;
			float3 weightedAvg606 = ( ( weightedBlendVar606.x*BlendNormals( ( temp_output_893_40 + lerpResult802 ) , lerpResult802 ) + weightedBlendVar606.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, appendResult517 ), _NormalScale1 ) + weightedBlendVar606.z*float3( 0,0,0 ) + weightedBlendVar606.w*float3( 0,0,0 ) )/( weightedBlendVar606.x + weightedBlendVar606.y + weightedBlendVar606.z + weightedBlendVar606.w ) );
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
			float temp_output_126_0 = ( floor( ( saturate( ( ( _PointLightAttenuationBoost * IsPointLight76 * ase_lightAtten ) * temp_output_192_0 ) ) * _Steps ) ) / _Steps );
			float temp_output_181_0 = ( ( ( ase_lightAtten * ( 1.0 - IsPointLight76 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( temp_output_192_0 * _Steps * ( 1.0 - IsPointLight76 ) ) ) / _Steps ) );
			float dither275 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float temp_output_283_0 = ( temp_output_181_0 * smoothstepResult205 );
			dither275 = step( dither275, temp_output_283_0 );
			float temp_output_224_0 = ( 1.0 - ( temp_output_126_0 + (( temp_output_181_0 >= 0.0 && temp_output_181_0 <= 1.0 ) ? dither275 :  temp_output_181_0 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 triplanar734 = TriplanarSampling734( _CliffTex, sampler_CliffTex, ase_worldPos, ase_worldNormal, _TriPlanarFalloff, _CliffTiling, 1.0, 0 );
			float4 CliffUvs724 = ( triplanar734 * CliffBoundaries844 );
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float4 tex2DNode693 = SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 );
			float4 temp_output_706_0 = ( CliffBlendSteps744 * tex2DNode693 );
			float4 temp_output_707_0 = ( ( CliffUvs724 * temp_output_703_0 ) + temp_output_706_0 );
			float4 Splat0Albedo847 = temp_output_707_0;
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float4 weightedBlendVar617 = Control621;
			float4 weightedAvg617 = ( ( weightedBlendVar617.x*Splat0Albedo847 + weightedBlendVar617.y*SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) + weightedBlendVar617.z*float4( 0,0,0,0 ) + weightedBlendVar617.w*float4( 0,0,0,0 ) )/( weightedBlendVar617.x + weightedBlendVar617.y + weightedBlendVar617.z + weightedBlendVar617.w ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode285 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
			float4 temp_cast_14 = (temp_output_224_0).xxxx;
			float4 weightedBlendVar604 = Control621;
			float4 weightedAvg604 = ( ( weightedBlendVar604.x*( ( _Specular0 * CliffBlendSteps744 ) + ( _CliffShadow * CliffBoundaries844 ) ) + weightedBlendVar604.y*_Specular1 + weightedBlendVar604.z*float4( 0,0,0,0 ) + weightedBlendVar604.w*float4( 0,0,0,0 ) )/( weightedBlendVar604.x + weightedBlendVar604.y + weightedBlendVar604.z + weightedBlendVar604.w ) );
			float dither292 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float cameraDepthFade293 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 5.0);
			float clampResult294 = clamp( cameraDepthFade293 , 1.0 , 20.0 );
			dither292 = step( dither292, ( clampResult294 * tex2DNode285 ).r );
			float4 temp_output_257_0 = ( ( ( ( 1.0 - temp_output_224_0 ) * ase_lightColor ) * ( weightedAvg617 * tex2DNode285 ) ) + ( ( min( temp_cast_14 , weightedAvg604 ) * ( 1.0 - IsPointLight76 ) ) * dither292 ) );
			c.rgb = temp_output_257_0.rgb;
			c.a = 1;
			clip( SAMPLE_TEXTURE2D( _TerrainHolesTexture, sampler_TerrainHolesTexture, uv_TerrainHolesTexture ).r - _Cutoff );
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
			float4 tex2DNode596 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float3 ase_worldPos = i.worldPos;
			float2 appendResult517 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 AppendedWorldPos857 = appendResult517;
			float4 tex2DNode862 = SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, ( AppendedWorldPos857 * _Pathnoisescale ) );
			float HeightMask861 = saturate(pow(max( (((tex2DNode862.a*tex2DNode596.g)*4)+(tex2DNode596.g*2)), 0 ),_Blendstr));
			float4 appendResult859 = (float4(tex2DNode596.r , HeightMask861 , tex2DNode596.b , tex2DNode596.a));
			float4 Control621 = ( floor( ( appendResult859 * _testest ) ) / _pathSteps );
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
			float GrassDivision916 = tex2DNode862.a;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float temp_output_695_0 = abs( ase_worldNormal.y );
			float temp_output_781_0 = ( temp_output_695_0 - _Level );
			float HeightMask915 = saturate(pow(((GrassDivision916*temp_output_781_0)*4)+(temp_output_781_0*2),_cliffblendstr));
			float temp_output_747_0 = saturate( ( floor( ( HeightMask915 * _Softness ) ) / _test ) );
			float CliffBlendSteps744 = pow( temp_output_747_0 , 0.3 );
			float4 Shine564 = saturate( ( ( ( dither554 * _Color0 ) - WindScroll533 ) * CliffBlendSteps744 ) );
			float4 weightedBlendVar632 = Control621;
			float4 weightedAvg632 = ( ( weightedBlendVar632.x*Shine564 + weightedBlendVar632.y*float4( 0,0,0,0 ) + weightedBlendVar632.z*float4( 0,0,0,0 ) + weightedBlendVar632.w*float4( 0,0,0,0 ) )/( weightedBlendVar632.x + weightedBlendVar632.y + weightedBlendVar632.z + weightedBlendVar632.w ) );
			float dither349 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 surf_pos107_g3 = ase_worldPos;
			float3 surf_norm107_g3 = ase_worldNormal;
			float GrassCutoff892 = HeightMask861;
			float height107_g3 = ( 1.0 - GrassCutoff892 );
			float scale107_g3 = 10.0;
			float3 localPerturbNormal107_g3 = PerturbNormal107_g3( surf_pos107_g3 , surf_norm107_g3 , height107_g3 , scale107_g3 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g3 = mul( ase_worldToTangent, localPerturbNormal107_g3);
			float3 temp_output_893_40 = worldToTangentDir42_g3;
			float2 temp_output_901_0 = ( appendResult517 * _GrassNormalSize );
			float2 CliffTiling813 = _CliffTiling;
			float3 triplanar812 = TriplanarSampling812( _Texture1, sampler_Texture1, ase_worldPos, ase_worldNormal, 10.0, CliffTiling813, _CliffScale, 0 );
			float3 tanTriplanarNormal812 = mul( ase_worldToTangent, triplanar812 );
			float temp_output_703_0 = ( 1.0 - CliffBlendSteps744 );
			float CliffBoundaries844 = temp_output_703_0;
			float3 lerpResult802 = lerp( BlendNormals( UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, temp_output_901_0 ), _NormalScale0 ) , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Texture0, sampler_Texture0, Shine564.rg ), _GrassWindNormalScale ) ) , tanTriplanarNormal812 , CliffBoundaries844);
			float4 weightedBlendVar606 = Control621;
			float3 weightedAvg606 = ( ( weightedBlendVar606.x*BlendNormals( ( temp_output_893_40 + lerpResult802 ) , lerpResult802 ) + weightedBlendVar606.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, appendResult517 ), _NormalScale1 ) + weightedBlendVar606.z*float3( 0,0,0 ) + weightedBlendVar606.w*float3( 0,0,0 ) )/( weightedBlendVar606.x + weightedBlendVar606.y + weightedBlendVar606.z + weightedBlendVar606.w ) );
			float3 normal259 = weightedAvg606;
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV118 = dot( mul(ase_tangentToWorldFast,normal259), ase_worldViewDir );
			float fresnelNode118 = ( 0.0 + _RimScale * pow( 1.0 - fresnelNdotV118, _RimPower ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			dither349 = step( dither349, ( fresnelNode118 * ase_vertex3Pos.y ) );
			float RimWrap195 = dither349;
			float4 weightedBlendVar785 = Control621;
			float4 weightedAvg785 = ( ( weightedBlendVar785.x*( ( RimWrap195 * CliffBlendSteps744 ) * _RimColor ) + weightedBlendVar785.y*float4( 0,0,0,0 ) + weightedBlendVar785.z*float4( 0,0,0,0 ) + weightedBlendVar785.w*float4( 0,0,0,0 ) )/( weightedBlendVar785.x + weightedBlendVar785.y + weightedBlendVar785.z + weightedBlendVar785.w ) );
			o.Emission = ( weightedAvg632 + weightedAvg785 ).rgb;
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
		UsePass "Hidden/Nature/Terrain/Utilities/PICKING"
		UsePass "Hidden/Nature/Terrain/Utilities/SELECTION"
	}

	Dependency "BaseMapShader"="ASESampleShaders/SimpleTerrainBase"
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;856;-267.2945,-1519.693;Inherit;False;1256.986;1127.603;Comment;8;621;848;859;861;864;892;897;898;Splat Albedos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;855;1934.3,-2309.222;Inherit;False;3118.837;1257.122;;34;698;775;703;844;807;847;747;777;776;779;697;744;693;706;707;810;811;853;804;806;803;782;781;695;805;694;917;915;918;921;924;927;933;934;Separate Grass and Cliffs Based on Height, kind of;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;854;2000.996,-3132.592;Inherit;False;1423.409;629.2375;Triplanar Cliff Texture;8;736;734;738;737;813;704;724;845;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;852;1937.615,-819.8509;Inherit;False;2299.882;423.7303;;14;789;790;555;556;549;553;554;545;550;551;492;493;557;564;Rolling Plains Shine;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;850;427.8499,-84.77435;Inherit;False;1072.207;550.8865;Comment;11;786;785;345;787;346;788;344;552;632;849;633;Splat Layer Rim Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-3084.854,-1002.593;Inherit;False;1379.942;546.2153;;12;198;199;78;171;181;180;179;178;77;172;201;307;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-2874.975,-976.7225;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;3;118;114;112;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4454.801,-570.1647;Inherit;False;1025.107;587.7744;Basic lighting;5;5;7;6;131;262;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3285.258,-2905.049;Inherit;False;Property;_RimPower;Rim Power;32;0;Create;True;0;0;0;False;0;False;5;7.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3314.258,-2999.049;Inherit;False;Property;_RimScale;Rim Scale;35;0;Create;True;0;0;0;False;0;False;1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;8;206;211;209;207;208;205;186;38;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;2;76;75;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;7;106;105;102;101;100;98;97;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2443.691,-1389.961;Inherit;False;888.2502;342.3433;;1;200;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1768.84,307.8115;Inherit;False;932.1631;425.7859;Directional Light Only;4;224;251;88;235;Shadow Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-257.9323,423.9716;Inherit;False;464.8;298.7;Material Color;1;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FresnelNode;118;-3018.471,-2998.382;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-2836.169,-2393.839;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;349;-2515.753,-2236.347;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3378.499,-3616.521;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;515;-5871.882,1796.59;Inherit;False;2185.108;805.0172;Comment;19;534;533;531;530;529;528;527;526;525;524;523;522;521;520;519;518;516;558;560;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;520;-5654.798,2404.663;Inherit;False;Property;_WindJitter;Wind Jitter;39;0;Create;True;0;0;0;False;0;False;0;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;524;-5368.009,2394.606;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-5146.776,2320.19;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;518;-5389.722,1992.938;Inherit;False;Property;_NoiseSize;Noise Size;34;0;Create;True;0;0;0;False;0;False;0.1;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;519;-5529.324,2090.413;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;516;-5821.882,2096.156;Inherit;False;Property;_WindScroll;Wind Scroll;37;0;Create;True;0;0;0;False;0;False;0;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;528;-4782.957,2288.485;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;527;-4946.522,2197.894;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;558;-5198.799,2216.535;Inherit;False;Property;_JitterNoiseSize;Jitter Noise Size;49;0;Create;True;0;0;0;False;0;False;0;5.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;530;-4564.03,2258.288;Inherit;True;Property;_TextureSample2;Texture Sample 0;33;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;529;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;560;-4334.411,2102.76;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;529;-4649.171,1784.246;Inherit;True;Property;_WindNoiseTex;Wind Noise Tex;33;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;522;-5207.722,1876.938;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;526;-4881.083,1879.503;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;574;-5618.909,2651.862;Inherit;False;Property;_TimeScaleShine;TimeScale Shine;50;0;Create;True;0;0;0;False;0;False;0;7.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;576;-4936.536,2745.059;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;523;-5217.722,2050.013;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;579;-5142.251,2680.301;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;521;-5382.465,2257.4;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;591;-3400.714,-2323.332;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-3125.263,-2302.279;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;534;-5665.233,1874.339;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;531;-4242.678,1846.59;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;533;-3910.771,1851.807;Inherit;False;WindScroll;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2392.995,-2603.417;Inherit;False;RimWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;838;-5564.182,338.4482;Inherit;True;Property;_TextureSample0;Texture Sample 0;47;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WeightedBlendNode;785;1083.28,255.4232;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;896.0922,264.9341;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;346;567.2485,259.1119;Inherit;False;Property;_RimColor;Rim Color;43;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1070908,0.1132075,0.01228195,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;552;1348.055,231.4811;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;840;949.0087,1307.822;Inherit;True;Property;_TerrainHolesTexture;TerrainHolesTexture;67;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;842;1194.695,1301.323;Inherit;True;Property;_TextureSample1;Texture Sample 1;49;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;786;893.0095,138.9729;Inherit;False;621;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;787;734.9463,157.8412;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;788;477.8501,162.1891;Inherit;False;744;CliffBlendSteps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;483.5477,73.26781;Inherit;False;195;RimWrap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WeightedBlendNode;632;1156.2,76.56541;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;849;932.7203,46.34718;Inherit;False;564;Shine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;633;933.9108,-34.77438;Inherit;False;621;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;789;3583.222,-700.7632;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;790;3341.185,-620.0794;Inherit;False;744;CliffBlendSteps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;555;3236.317,-711.8951;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;556;3095.727,-601.2332;Inherit;False;533;WindScroll;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;549;3070.91,-714.3611;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;553;2837.946,-603.121;Inherit;False;Property;_Color0;Shine Color;48;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.509434,0.4445532,0.4445532,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;554;2852.511,-719.6421;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;545;2528.88,-769.851;Inherit;True;Property;_shine;shine;46;0;Create;True;0;0;0;False;0;False;-1;None;82aaf027903b047d7af1e568e3864879;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;550;2372.595,-743.1219;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;551;2183.863,-766.1518;Inherit;False;Property;_shinesize;shine size;47;0;Create;True;0;0;0;False;0;False;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;492;2219.555,-643.8298;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;493;1987.615,-649.9985;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;557;3833.745,-624.658;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;564;4013.495,-565.5793;Inherit;False;Shine;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;736;2128.656,-3082.592;Inherit;True;Property;_CliffTex;Cliff Tex;59;0;Create;True;0;0;0;False;0;False;None;31d5a2d79390ab542a81a6699a999758;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TriplanarNode;734;2456.721,-2978.906;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;10;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;738;2050.996,-2845.065;Inherit;False;Property;_TriPlanarFalloff;TriPlanar Falloff;60;0;Create;True;0;0;0;False;0;False;10;3;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;813;2392.073,-2757.141;Inherit;False;CliffTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;704;2927.683,-2785.981;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;845;2676.786,-2618.353;Inherit;True;844;CliffBoundaries;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;703;4030.845,-1323.544;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;777;3456.84,-1372.024;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;776;3263.764,-1400.406;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;779;3019.825,-1405.419;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;810;4497.296,-1956.059;Inherit;False;2;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;811;4180.762,-2063.226;Inherit;False;Property;_compare;compare;66;0;Create;True;0;0;0;False;0;False;0.490566,0.490566,0.490566,0;0.754717,0.754717,0.754717,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;806;2279.367,-1876.042;Inherit;False;Property;_Triplanarnoisefalloff;Triplanar noise falloff;63;0;Create;True;0;0;0;False;0;False;0;0.59;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;782;3001.026,-1676.804;Inherit;False;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;805;2238.927,-2259.223;Inherit;False;Property;_Triplanarnoisetiling;Triplanar noise tiling;64;0;Create;True;0;0;0;False;0;False;0,0;0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldNormalVector;694;1984.301,-1751.952;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;621;396.0953,-1144.012;Inherit;False;Control;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WeightedBlendNode;606;-4710.366,283.9543;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;614;-5239.047,-255.8383;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;589;-5550.067,-192.889;Inherit;True;Property;_NormalMap1;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;c78e565eaf65cb1428fac66341a4a8bc;bd4806d82731a422ea0b106e0524d364;True;0;True;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;585;-5958.867,-50.38889;Inherit;False;Property;_GrassWindNormalScale;GrassWindNormalScale;51;0;Create;True;0;0;0;False;0;False;0.4;0.098;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;-5948.884,-145.7652;Inherit;False;564;Shine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;503;-6204.021,-256.4218;Inherit;True;Property;_Texture0;Texture 0;44;0;Create;True;0;0;0;False;0;False;None;5259d0042c9854375b96305b6256ecfd;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;792;-6333.035,111.648;Inherit;True;Property;_Texture1;Texture 1;62;0;Create;True;0;0;0;False;0;False;None;77d2caeaa8d084f4886293bee579cb56;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;831;-5924.415,306.8196;Inherit;True;Property;_Normal1;Normal1;45;0;Create;True;0;0;0;False;0;False;None;None;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;620;-5923.089,504.2187;Inherit;False;Property;_NormalScale1;NormalScale1;54;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;624;-4942.488,29.6903;Inherit;False;621;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4477.095,281.5753;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;857;-5141.589,1551.459;Inherit;False;AppendedWorldPos;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;862;-617.6578,-1570.101;Inherit;True;Property;_TextureSample3;Texture Sample 3;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;612;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;864;-152.2053,-615.1548;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;866;-633.1455,-574.2267;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;868;-104.4673,-427.3958;Inherit;False;Property;_testest;testest;69;0;Create;True;0;0;0;False;0;False;0;3.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;865;-423.6076,-392.1408;Inherit;False;Property;_pathSteps;path Steps;68;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WeightedBlendNode;617;266.7139,-140.3398;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FloorOpNode;863;-361.3678,-574.0468;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;892;114.5753,-1245.067;Inherit;False;GrassCutoff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;895;-4918.694,-425.8885;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;894;-6467.833,-661.9692;Inherit;False;892;GrassCutoff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;896;-6281.168,-431.3802;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;897;3.104496,-1437.943;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;898;-232.717,-1441.266;Inherit;False;Property;_NormalPwr;Normal Pwr;71;0;Create;True;0;0;0;False;0;False;0;2E+07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;899;-5081.724,-527.2292;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;615;-5932.251,-363.6439;Inherit;False;Property;_NormalScale0;NormalScale0;52;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;901;-5894.946,1069.964;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;902;-6196.759,1191.345;Inherit;False;Property;_GrassNormalSize;Grass Normal Size;72;0;Create;True;0;0;0;False;0;False;0;4.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;612;-5556.252,-415.3725;Inherit;True;Property;_Normal0;Normal0;30;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;517;-5431.512,1673.681;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;903;-5517.322,1167.376;Inherit;False;GrassNormalTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;858;-999.3807,-1700.266;Inherit;False;903;GrassNormalTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;904;-5730.61,-796.4128;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;905;-1147.236,-1545.449;Inherit;False;857;AppendedWorldPos;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;906;-922.6881,-1516.085;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;907;-1117.872,-1410.72;Inherit;False;Property;_Pathnoisescale;Path noise scale;73;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;900;-4785.976,-198.656;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;802;-4993.375,116.0966;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;909;-1862.31,-112.6421;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;911;-5737.122,-538.0125;Inherit;False;Normal Reconstruct Z;-1;;2;63ba85b764ae0c84ab3d698b86364ae9;0;1;1;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;893;-6037.174,-719.2634;Inherit;False;Normal From Height;-1;;3;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;10;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;913;-6159.113,328.2705;Inherit;False;Property;_Clifffalloff;Cliff falloff;75;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;914;-6135.844,458.3277;Inherit;False;Property;_CliffWorldPos;Cliff World Pos;76;0;Create;True;0;0;0;False;0;False;0,0,0;0.1,0.1,0.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;737;2137.119,-2747.451;Inherit;False;Property;_CliffTiling;Cliff Tiling;58;0;Create;True;0;0;0;False;0;False;0,0;0,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;727;-5183.723,259.2365;Inherit;False;844;CliffBoundaries;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;873;-631.3823,-960.4532;Inherit;False;Property;_Blendstr;Blendstr;70;0;Create;True;0;0;0;False;0;False;0;4.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;616;-188.1616,-167.2345;Inherit;True;Property;_Splat1;Splat1;29;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;859;-23.10967,-1062.884;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;916;-400.5519,-1746.642;Inherit;False;GrassDivision;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HeightMapBlendNode;861;-236.4913,-1241.244;Inherit;False;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;724;3317.455,-2825.047;Inherit;False;CliffUvs;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;917;3210.53,-2091.994;Inherit;False;916;GrassDivision;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;918;3152.892,-1994.627;Inherit;False;744;CliffBlendSteps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;921;3290.011,-1837.119;Inherit;False;Property;_cliffblendstr;cliff blendstr;77;0;Create;True;0;0;0;False;0;False;0;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;698;2588.669,-1294.333;Inherit;False;Property;_Softness;Softness;53;0;Create;True;0;0;0;False;0;False;0;20.4;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;775;3085.667,-1167.1;Inherit;False;Property;_test;test;61;0;Create;True;0;0;0;False;0;False;0;2;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;697;2223.352,-1450.457;Inherit;False;Property;_Level;Level;55;0;Create;True;0;0;0;False;0;False;0;0.917;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HeightMapBlendNode;915;3496.924,-2034.839;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;807;4670.176,-1891.681;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;844;4287.356,-1274.485;Inherit;False;CliffBoundaries;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;912;-6090.88,242.7704;Inherit;False;Property;_CliffScale;Cliff Scale;74;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;922;-5901.983,85.7011;Inherit;False;744;CliffBlendSteps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;812;-5637.112,103.9093;Inherit;True;Spherical;World;True;Top Texture 2;_TopTexture2;white;0;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;10;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;814;-5939.505,169.8163;Inherit;False;813;CliffTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;853;4021.694,-1771.07;Inherit;False;724;CliffUvs;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;747;3652.48,-1432.126;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;695;2203.301,-1737.552;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;781;2657.034,-1675.234;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;924;2441.101,-1697.368;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;707;4454.915,-1740.313;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;927;4243.45,-1526.146;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;706;4063.292,-1683.159;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;744;3830.363,-1467.816;Inherit;False;CliffBlendSteps;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;933;3893.938,-1327.261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;934;3706.627,-1598.598;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;935;1166.186,867.0062;Inherit;False;Four Splats First Pass Terrain;0;;4;37452fdfb732e1443b7e39720d05b708;2,102,1,85,0;7;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;201;FLOAT;0;False;62;FLOAT;0;False;7;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;200;FLOAT;19;FLOAT3;17
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;938;1213.449,1187.702;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;940;652.2782,1053.395;Inherit;False;unity_FogColor;0;1;COLOR;0
Node;AmplifyShaderEditor.FogParamsNode;939;636.2108,862.5936;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;941;963.5865,961.0071;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;804;2227.615,-2113.27;Inherit;True;Property;_TriplanarNoise;TriplanarNoise;65;0;Create;True;0;0;0;False;0;False;None;5259d0042c9854375b96305b6256ecfd;True;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;693;3599.461,-1851.408;Inherit;True;Property;_Splat0;Splat0;56;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;803;2573.199,-2026.35;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;847;4829.135,-1874.035;Inherit;False;Splat0Albedo;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;848;75.39084,-649.4763;Inherit;False;847;Splat0Albedo;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-3809.853,-359.9905;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-4102.828,-294.5135;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-2742.111,890.9663;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-5113.211,-1705.717;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;31;0;Create;True;0;0;0;False;0;False;1;3.2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-5099.51,-1562.309;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;100;-5080.172,-1436.925;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4825.77,-1646.348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-5177.416,-1320.394;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;98;-4960.516,-1316.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-4734.148,-1366.108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;209;-3676.961,-1291.98;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3919.807,-1517.473;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;38;0;Create;True;0;0;0;False;0;False;0;0.673;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3471.961,-1306.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-3471.961,-1418.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-3537.574,-1617.438;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3910.961,-1389.98;Inherit;False;Property;_LightGradientSize;Light Gradient Size;40;0;Create;True;0;0;0;False;0;False;0;0.332;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;205;-3242.402,-1528.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-3810.594,-1602.487;Inherit;False;131;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3558.947,-1044.954;Inherit;False;Property;_Steps;Steps;28;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-2933.699,-688.1385;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-3148.323,-1110.628;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-3146.294,-621.6992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;201;-2792.03,-539.9255;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;204;-2453.22,-1130.1;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2952.729,-912.865;Inherit;False;Property;_ShadowLevel;Shadow Level;36;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;77;-2933.024,-811.8263;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-2166.34,-973.9299;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;-2411.345,-942.8238;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1932.782,-848.1438;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;279;-1668.683,-769.3216;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-2577.656,-719.138;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-2752.036,-689.2536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;179;-2358.228,-714.7131;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;180;-2224.747,-716.9331;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-2282.69,-1803.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;200;-2163.449,-1292.32;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-948.3862,-473.6724;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-2306.889,-291.6578;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;275;-2030.313,-107.5996;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;280;-2436.133,-94.60346;Inherit;True;Property;_Dither;Dither;41;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2167.517,219.5637;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.OneMinusNode;224;-1476.488,294.8124;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;251;-1252.113,285.0775;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;594;-2123.739,475.2457;Inherit;False;Property;_Specular0;Specular0;27;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;718;-1865.398,602.8344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;719;-2163.768,818.6385;Inherit;False;Property;_CliffShadow;Cliff Shadow;57;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4107936,0.3325472,0.4433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;720;-1806.148,848.4796;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;598;-2080.103,1055.64;Inherit;False;Property;_Specular1;Specular1;26;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;721;-1525.996,1094.123;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;625;-1592.318,743.5659;Inherit;False;621;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WeightedBlendNode;604;-1394.086,833.284;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;235;-1003.207,714.0432;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1542.474,1440.095;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;232;-1250.855,1238.667;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-961.9585,928.7074;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;255;-673.2963,576.7527;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-454.0071,446.9763;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-8.421171,468.2562;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;41.63611,1031.19;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;248.9555,794.0004;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;285;-447.682,804.0729;Inherit;True;Property;_Albedo;Albedo;42;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-584.3527,1239.109;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;293;-980.1703,1503.753;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;294;-644.3625,1517.31;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;292;-456.4587,1557.525;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-701.2247,1717.931;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-2473.733,-1798.936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;745;-2055.323,715.1757;Inherit;False;744;CliffBlendSteps;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;846;-1958.241,974.6647;Inherit;False;844;CliffBoundaries;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3632.485,-340.7137;Inherit;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;596;-910.2156,-1293.672;Inherit;True;Property;_Control;Control;25;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;100;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-143.3204,1074.516;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;908;-984.4979,-97.5014;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1643.523,869.9178;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Terrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;-100;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;24;-1;-1;-1;1;SplatCount=4;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;;-1;0;False;;0;0;0;True;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;75;-2982.111,874.9663;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4365.571,-444.9472;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-4060.873,-492.3528;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-2707.082,-1596.179;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;125;-1872.61,-1480.1;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2055.125,-1508.934;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-1701.216,-1485.729;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;88;-1704.781,316.8311;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;118;0;469;0
WireConnection;118;2;114;0
WireConnection;118;3;112;0
WireConnection;349;0;592;0
WireConnection;349;1;347;0
WireConnection;524;0;520;0
WireConnection;525;0;576;0
WireConnection;525;1;524;0
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
WireConnection;531;0;529;0
WireConnection;533;0;560;0
WireConnection;195;0;349;0
WireConnection;838;0;831;0
WireConnection;838;1;517;0
WireConnection;838;5;620;0
WireConnection;785;0;786;0
WireConnection;785;1;345;0
WireConnection;345;0;787;0
WireConnection;345;1;346;0
WireConnection;552;0;632;0
WireConnection;552;1;785;0
WireConnection;842;0;840;0
WireConnection;787;0;344;0
WireConnection;787;1;788;0
WireConnection;632;0;633;0
WireConnection;632;1;849;0
WireConnection;789;0;555;0
WireConnection;789;1;790;0
WireConnection;555;0;549;0
WireConnection;555;1;556;0
WireConnection;549;0;554;0
WireConnection;549;1;553;0
WireConnection;554;0;545;0
WireConnection;545;1;550;0
WireConnection;550;0;551;0
WireConnection;550;1;492;0
WireConnection;492;0;493;1
WireConnection;492;1;493;3
WireConnection;557;0;789;0
WireConnection;564;0;557;0
WireConnection;734;0;736;0
WireConnection;734;3;737;0
WireConnection;734;4;738;0
WireConnection;813;0;737;0
WireConnection;704;0;734;0
WireConnection;704;1;845;0
WireConnection;703;0;744;0
WireConnection;777;0;776;0
WireConnection;777;1;775;0
WireConnection;776;0;779;0
WireConnection;779;0;915;0
WireConnection;779;1;698;0
WireConnection;810;0;706;0
WireConnection;810;1;811;0
WireConnection;810;2;693;0
WireConnection;810;3;707;0
WireConnection;782;0;781;0
WireConnection;782;1;803;0
WireConnection;621;0;864;0
WireConnection;606;0;624;0
WireConnection;606;1;900;0
WireConnection;606;2;838;0
WireConnection;614;0;612;0
WireConnection;614;1;589;0
WireConnection;589;0;503;0
WireConnection;589;1;568;0
WireConnection;589;5;585;0
WireConnection;259;0;606;0
WireConnection;857;0;517;0
WireConnection;862;1;906;0
WireConnection;864;0;863;0
WireConnection;864;1;865;0
WireConnection;866;0;859;0
WireConnection;866;1;868;0
WireConnection;617;0;621;0
WireConnection;617;1;848;0
WireConnection;617;2;616;0
WireConnection;863;0;866;0
WireConnection;892;0;861;0
WireConnection;895;0;893;40
WireConnection;895;1;802;0
WireConnection;896;0;894;0
WireConnection;897;0;861;0
WireConnection;897;1;898;0
WireConnection;899;0;893;40
WireConnection;899;1;802;0
WireConnection;901;0;517;0
WireConnection;901;1;902;0
WireConnection;612;1;901;0
WireConnection;612;5;615;0
WireConnection;517;0;534;1
WireConnection;517;1;534;3
WireConnection;903;0;901;0
WireConnection;904;0;893;40
WireConnection;906;0;905;0
WireConnection;906;1;907;0
WireConnection;900;0;895;0
WireConnection;900;1;802;0
WireConnection;802;0;614;0
WireConnection;802;1;812;0
WireConnection;802;2;727;0
WireConnection;909;0;283;0
WireConnection;911;1;893;0
WireConnection;893;20;896;0
WireConnection;859;0;596;1
WireConnection;859;1;861;0
WireConnection;859;2;596;3
WireConnection;859;3;596;4
WireConnection;916;0;862;4
WireConnection;861;0;862;4
WireConnection;861;1;596;2
WireConnection;861;2;873;0
WireConnection;724;0;704;0
WireConnection;915;0;917;0
WireConnection;915;1;781;0
WireConnection;915;2;921;0
WireConnection;807;0;707;0
WireConnection;844;0;703;0
WireConnection;812;0;792;0
WireConnection;812;8;912;0
WireConnection;812;3;814;0
WireConnection;747;0;777;0
WireConnection;695;0;694;2
WireConnection;781;0;695;0
WireConnection;781;1;697;0
WireConnection;924;0;695;0
WireConnection;707;0;927;0
WireConnection;707;1;706;0
WireConnection;927;0;853;0
WireConnection;927;1;703;0
WireConnection;706;0;744;0
WireConnection;706;1;693;0
WireConnection;744;0;934;0
WireConnection;933;0;747;0
WireConnection;934;0;747;0
WireConnection;938;0;939;1
WireConnection;938;1;257;0
WireConnection;803;0;804;0
WireConnection;803;3;805;0
WireConnection;803;4;806;0
WireConnection;847;0;707;0
WireConnection;5;0;6;0
WireConnection;5;1;7;0
WireConnection;76;0;75;2
WireConnection;105;0;101;0
WireConnection;105;1;102;0
WireConnection;105;2;100;0
WireConnection;98;0;97;0
WireConnection;106;0;100;0
WireConnection;106;1;98;0
WireConnection;209;0;206;0
WireConnection;208;0;211;0
WireConnection;208;1;209;0
WireConnection;207;0;211;0
WireConnection;207;1;209;0
WireConnection;38;0;186;0
WireConnection;205;0;38;0
WireConnection;205;1;208;0
WireConnection;205;2;207;0
WireConnection;203;0;123;0
WireConnection;202;0;123;0
WireConnection;201;0;202;0
WireConnection;204;0;203;0
WireConnection;78;0;106;0
WireConnection;78;1;171;0
WireConnection;171;0;172;0
WireConnection;171;1;77;0
WireConnection;181;0;78;0
WireConnection;181;1;180;0
WireConnection;279;0;181;0
WireConnection;279;3;275;0
WireConnection;279;4;181;0
WireConnection;178;0;192;0
WireConnection;178;1;201;0
WireConnection;178;2;198;0
WireConnection;198;0;199;0
WireConnection;179;0;178;0
WireConnection;180;0;179;0
WireConnection;180;1;201;0
WireConnection;122;0;193;0
WireConnection;200;0;204;0
WireConnection;175;0;126;0
WireConnection;175;1;279;0
WireConnection;283;0;181;0
WireConnection;283;1;205;0
WireConnection;275;0;283;0
WireConnection;275;1;280;0
WireConnection;295;0;280;0
WireConnection;224;0;88;0
WireConnection;251;0;224;0
WireConnection;718;0;594;0
WireConnection;718;1;745;0
WireConnection;720;0;719;0
WireConnection;720;1;846;0
WireConnection;721;0;718;0
WireConnection;721;1;720;0
WireConnection;604;0;625;0
WireConnection;604;1;721;0
WireConnection;604;2;598;0
WireConnection;235;0;224;0
WireConnection;235;1;604;0
WireConnection;232;0;231;0
WireConnection;233;0;235;0
WireConnection;233;1;232;0
WireConnection;256;0;251;0
WireConnection;256;1;255;0
WireConnection;3;0;256;0
WireConnection;3;1;286;0
WireConnection;257;0;3;0
WireConnection;257;1;290;0
WireConnection;286;0;617;0
WireConnection;286;1;285;0
WireConnection;291;0;294;0
WireConnection;291;1;285;0
WireConnection;294;0;293;0
WireConnection;292;0;291;0
WireConnection;292;1;296;0
WireConnection;193;0;105;0
WireConnection;193;1;192;0
WireConnection;131;0;5;0
WireConnection;290;0;233;0
WireConnection;290;1;292;0
WireConnection;908;0;126;0
WireConnection;908;1;181;0
WireConnection;0;2;552;0
WireConnection;0;10;842;0
WireConnection;0;13;257;0
WireConnection;0;11;935;17
WireConnection;6;0;262;0
WireConnection;192;1;205;0
WireConnection;125;0;124;0
WireConnection;124;0;122;0
WireConnection;124;1;200;0
WireConnection;126;0;125;0
WireConnection;126;1;200;0
WireConnection;88;0;175;0
ASEEND*/
//CHKSM=9D05727C650640499FFB4685488F88F4C4AAC38E