// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Terrain_New"
{
	Properties
	{
		[HideInInspector]_Mask2("_Mask2", 2D) = "white" {}
		[HideInInspector]_Mask0("_Mask0", 2D) = "white" {}
		[HideInInspector]_Mask1("_Mask1", 2D) = "white" {}
		[HideInInspector]_Mask3("_Mask3", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector]_Control("Control", 2D) = "white" {}
		[HideInInspector]_Splat0("Splat0", 2D) = "white" {}
		[HideInInspector]_Normal0("Normal0", 2D) = "bump" {}
		[HideInInspector]_Splat1("Splat1", 2D) = "white" {}
		[HideInInspector]_Normal1("Normal1", 2D) = "bump" {}
		[HideInInspector]_Splat2("Splat2", 2D) = "white" {}
		[HideInInspector]_Normal2("Normal2", 2D) = "bump" {}
		[HideInInspector]_Splat3("Splat3", 2D) = "white" {}
		[HideInInspector]_Normal3("Normal3", 2D) = "bump" {}
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		[HideInInspector]_Specular1("Specular1", Color) = (0,0,0,0)
		[HideInInspector]_Specular2("Specular2", Color) = (0,0,0,0)
		[HideInInspector]_Specular3("Specular3", Color) = (0,0,0,0)
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		[HideInInspector]_Specular0("Specular0", Color) = (0.9056604,0.08116765,0.08116765,0)
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_NormalScale2("NormalScale2", Range( 0 , 1)) = 0
		_NormalScale0("NormalScale0", Range( 0 , 1)) = 0
		_NormalScale1("NormalScale1", Range( 0 , 1)) = 0
		_NormalScale3("NormalScale3", Range( 0 , 1)) = 0
		_layer2Div("layer2Div", Float) = 0
		_layer0Div("layer0Div", Float) = 0
		_layer1Div("layer1Div", Float) = 0
		_Layer0NoiseDivSize("Layer0NoiseDivSize", Vector) = (0,0,0,0)
		_Layer1NoiseDivSize("Layer1NoiseDivSize", Vector) = (0,0,0,0)
		_Layer2NoiseDivSize("Layer2NoiseDivSize", Vector) = (0,0,0,0)
		_Layer3NoiseDivSize("Layer3NoiseDivSize", Vector) = (0,0,0,0)
		_Rim0("Rim0", Vector) = (0,0,0,0)
		_Rim1("Rim1", Vector) = (0,0,0,0)
		_Rim2("Rim2", Vector) = (0,0,0,0)
		_Rim3("Rim3", Vector) = (0,0,0,0)
		_RimColor0("RimColor0", Color) = (0,0,0,0)
		_RimColor1("RimColor1", Color) = (0,0,0,0)
		_RimColor2("RimColor2", Color) = (0,0,0,0)
		_RimColor3("RimColor3", Color) = (0,0,0,0)
		_TerrainHolesTexture("TerrainHolesTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest-100" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
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
			float4 screenPosition;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
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

		uniform float4 _MaskMapRemapScale0;
		uniform float4 _MaskMapRemapScale2;
		uniform float4 _MaskMapRemapScale1;
		uniform float4 _MaskMapRemapOffset1;
		uniform float4 _MaskMapRemapScale3;
		uniform float4 _MaskMapRemapOffset3;
		uniform float4 _MaskMapRemapOffset2;
		uniform float4 _MaskMapRemapOffset0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask2);
		SamplerState sampler_Mask2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask0);
		SamplerState sampler_Mask0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask1);
		SamplerState sampler_Mask1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask3);
		SamplerState sampler_Mask3;
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
		uniform float2 _Layer0NoiseDivSize;
		uniform float2 _Layer1NoiseDivSize;
		uniform float2 _Layer2NoiseDivSize;
		uniform float2 _Layer3NoiseDivSize;
		uniform float4 _RimColor0;
		uniform float4 _RimColor1;
		uniform float4 _RimColor2;
		uniform float4 _RimColor3;
		uniform float2 _Rim0;
		uniform float2 _Rim1;
		uniform float2 _Rim2;
		uniform float2 _Rim3;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_TerrainHolesTexture);
		uniform float4 _TerrainHolesTexture_ST;
		SamplerState sampler_TerrainHolesTexture;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _layer0Div;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal0);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat0);
		uniform float4 _Splat0_ST;
		SamplerState sampler_Normal0;
		uniform float _NormalScale0;
		uniform float _layer1Div;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat1);
		uniform float4 _Splat1_ST;
		SamplerState sampler_Normal1;
		uniform float _NormalScale1;
		uniform float _layer2Div;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal2);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat2);
		uniform float4 _Splat2_ST;
		SamplerState sampler_Normal2;
		uniform float _NormalScale2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal3);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat3);
		uniform float4 _Splat3_ST;
		SamplerState sampler_Normal3;
		uniform float _NormalScale3;
		uniform float _Steps;
		uniform float _ShadowLevel;
		SamplerState sampler_Splat0;
		SamplerState sampler_Splat1;
		SamplerState sampler_Splat2;
		SamplerState sampler_Splat3;
		uniform float4 _Specular0;
		uniform float4 _Specular1;
		uniform float4 _Specular2;
		uniform float4 _Specular3;
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


		float3 PerturbNormal107_g9( float3 surf_pos, float3 surf_norm, float height, float scale )
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


		float3 PerturbNormal107_g10( float3 surf_pos, float3 surf_norm, float height, float scale )
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


		float3 PerturbNormal107_g11( float3 surf_pos, float3 surf_norm, float height, float scale )
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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			ApplyMeshModification(v);;
			float localCalculateTangentsStandard165 = ( 0.0 );
			{
			v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) );
			v.tangent.w = -1;
			}
			float3 temp_cast_0 = (localCalculateTangentsStandard165).xxx;
			v.vertex.xyz += temp_cast_0;
			v.vertex.w = 1;
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
			float2 uv_TerrainHolesTexture = i.uv_texcoord * _TerrainHolesTexture_ST.xy + _TerrainHolesTexture_ST.zw;
			float IsPointLight28 = _WorldSpaceLightPos0.w;
			float PointLightAttenuation106 = ( _PointLightAttenuationBoost * IsPointLight28 * ase_lightAtten );
			float temp_output_39_0 = ( _LightGradientSize * 0.5 );
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode222 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float2 uv_TexCoord400 = i.uv_texcoord * _Layer0NoiseDivSize;
			float2 uv_TexCoord674 = i.uv_texcoord * _Layer1NoiseDivSize;
			float2 uv_TexCoord744 = i.uv_texcoord * _Layer2NoiseDivSize;
			float2 uv_TexCoord747 = i.uv_texcoord * _Layer3NoiseDivSize;
			float4 appendResult742 = (float4(SAMPLE_TEXTURE2D( _Mask0, sampler_Mask0, uv_TexCoord400 ).r , SAMPLE_TEXTURE2D( _Mask1, sampler_Mask1, uv_TexCoord674 ).g , SAMPLE_TEXTURE2D( _Mask2, sampler_Mask2, uv_TexCoord744 ).b , SAMPLE_TEXTURE2D( _Mask3, sampler_Mask3, uv_TexCoord747 ).a));
			float temp_output_351_0 = ( tex2DNode222.r / (appendResult742).x );
			float EdgeNoise0724 = temp_output_351_0;
			float temp_output_676_0 = ( tex2DNode222.g / (appendResult742).y );
			float EdgeNoise1732 = temp_output_676_0;
			float temp_output_752_0 = ( tex2DNode222.b / (appendResult742).z );
			float EdgeNoise2755 = temp_output_752_0;
			float temp_output_759_0 = ( tex2DNode222.a / (appendResult742).w );
			float EdgeNoise3762 = temp_output_759_0;
			float temp_output_593_0 = step( 0.1 , ( ( ( EdgeNoise0724 - EdgeNoise1732 ) - EdgeNoise2755 ) - EdgeNoise3762 ) );
			float ctrlR607 = temp_output_593_0;
			float temp_output_597_0 = step( 0.1 , ( ( ( EdgeNoise1732 - temp_output_593_0 ) - EdgeNoise2755 ) - EdgeNoise3762 ) );
			float ctrlG608 = temp_output_597_0;
			float temp_output_601_0 = step( 0.1 , ( ( ( EdgeNoise2755 - temp_output_597_0 ) - temp_output_593_0 ) - EdgeNoise3762 ) );
			float ctrlB609 = temp_output_601_0;
			float temp_output_605_0 = step( 0.1 , ( ( ( EdgeNoise3762 - temp_output_597_0 ) - temp_output_601_0 ) - temp_output_593_0 ) );
			float ctrlA610 = temp_output_605_0;
			float4 appendResult586 = (float4(ctrlR607 , ctrlG608 , ctrlB609 , ctrlA610));
			float4 Control122 = appendResult586;
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g9 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g9 = ase_worldNormal;
			float4 color457 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float EdgeNormal0723 = ( temp_output_351_0 / _layer0Div );
			float HeightMask456 = saturate(pow(((color457.r*EdgeNormal0723)*4)+(EdgeNormal0723*2),1.0));
			float height107_g9 = HeightMask456;
			float scale107_g9 = 150.0;
			float3 localPerturbNormal107_g9 = PerturbNormal107_g9( surf_pos107_g9 , surf_norm107_g9 , height107_g9 , scale107_g9 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g9 = mul( ase_worldToTangent, localPerturbNormal107_g9);
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float3 surf_pos107_g10 = ase_worldPos;
			float3 surf_norm107_g10 = ase_worldNormal;
			float4 color738 = IsGammaSpace() ? float4(0,0,0,1) : float4(0,0,0,1);
			float EdgeNormal1733 = ( temp_output_676_0 / _layer1Div );
			float HeightMask736 = saturate(pow(((color738.r*( EdgeNormal1733 - EdgeNoise2755 ))*4)+(( EdgeNormal1733 - EdgeNoise2755 )*2),1.0));
			float height107_g10 = HeightMask736;
			float scale107_g10 = 50.0;
			float3 localPerturbNormal107_g10 = PerturbNormal107_g10( surf_pos107_g10 , surf_norm107_g10 , height107_g10 , scale107_g10 );
			float3 worldToTangentDir42_g10 = mul( ase_worldToTangent, localPerturbNormal107_g10);
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float3 surf_pos107_g11 = ase_worldPos;
			float3 surf_norm107_g11 = ase_worldNormal;
			float4 color767 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float EdgeNormal2756 = ( temp_output_752_0 / _layer2Div );
			float HeightMask768 = saturate(pow(((color767.r*( EdgeNoise1732 - EdgeNormal2756 ))*4)+(( EdgeNoise1732 - EdgeNormal2756 )*2),1.0));
			float height107_g11 = HeightMask768;
			float scale107_g11 = 150.0;
			float3 localPerturbNormal107_g11 = PerturbNormal107_g11( surf_pos107_g11 , surf_norm107_g11 , height107_g11 , scale107_g11 );
			float3 worldToTangentDir42_g11 = mul( ase_worldToTangent, localPerturbNormal107_g11);
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float3 tex2DNode22 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal3, sampler_Normal3, uv_Splat3 ), _NormalScale3 );
			float4 weightedBlendVar23 = Control122;
			float3 weightedBlend23 = ( weightedBlendVar23.x*BlendNormals( worldToTangentDir42_g9 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, uv_Splat0 ), _NormalScale0 ) ) + weightedBlendVar23.y*BlendNormals( worldToTangentDir42_g10 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Splat1 ), _NormalScale1 ) ) + weightedBlendVar23.z*BlendNormals( worldToTangentDir42_g11 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal2, sampler_Normal2, uv_Splat2 ), _NormalScale2 ) ) + weightedBlendVar23.w*tex2DNode22 );
			float3 Normals25 = weightedBlend23;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult11 = dot( (WorldNormalVector( i , Normals25 )) , ase_worldlightDir );
			float NdotL10 = dotResult11;
			float smoothstepResult45 = smoothstep( ( _LightGradientMidLevel - temp_output_39_0 ) , ( _LightGradientMidLevel + temp_output_39_0 ) , (NdotL10*0.5 + 0.5));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 tex2DNode5 = SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 );
			float4 weightedBlendVar1 = Control122;
			float4 weightedAvg1 = ( ( weightedBlendVar1.x*SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 ) + weightedBlendVar1.y*tex2DNode5 + weightedBlendVar1.z*SAMPLE_TEXTURE2D( _Splat2, sampler_Splat2, uv_Splat2 ) + weightedBlendVar1.w*SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, uv_Splat3 ) )/( weightedBlendVar1.x + weightedBlendVar1.y + weightedBlendVar1.z + weightedBlendVar1.w ) );
			float4 Albedos126 = weightedAvg1;
			float4 weightedBlendVar89 = Control122;
			float4 weightedAvg89 = ( ( weightedBlendVar89.x*_Specular0 + weightedBlendVar89.y*_Specular1 + weightedBlendVar89.z*_Specular2 + weightedBlendVar89.w*_Specular3 )/( weightedBlendVar89.x + weightedBlendVar89.y + weightedBlendVar89.z + weightedBlendVar89.w ) );
			float4 ShadowColor129 = weightedAvg89;
			float4 temp_output_97_0 = ( ( ( ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight28 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult45 * _Steps * ( 1.0 - IsPointLight28 ) ) ) / _Steps ) ) ) * ase_lightColor ) * Albedos126 ) + ( ( ( 1.0 - ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight28 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult45 * _Steps * ( 1.0 - IsPointLight28 ) ) ) / _Steps ) ) ) ) * ShadowColor129 ) * ( 1.0 - IsPointLight28 ) ) );
			c.rgb = temp_output_97_0.rgb;
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
			float4 tex2DNode222 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float2 uv_TexCoord400 = i.uv_texcoord * _Layer0NoiseDivSize;
			float2 uv_TexCoord674 = i.uv_texcoord * _Layer1NoiseDivSize;
			float2 uv_TexCoord744 = i.uv_texcoord * _Layer2NoiseDivSize;
			float2 uv_TexCoord747 = i.uv_texcoord * _Layer3NoiseDivSize;
			float4 appendResult742 = (float4(SAMPLE_TEXTURE2D( _Mask0, sampler_Mask0, uv_TexCoord400 ).r , SAMPLE_TEXTURE2D( _Mask1, sampler_Mask1, uv_TexCoord674 ).g , SAMPLE_TEXTURE2D( _Mask2, sampler_Mask2, uv_TexCoord744 ).b , SAMPLE_TEXTURE2D( _Mask3, sampler_Mask3, uv_TexCoord747 ).a));
			float temp_output_351_0 = ( tex2DNode222.r / (appendResult742).x );
			float EdgeNoise0724 = temp_output_351_0;
			float temp_output_676_0 = ( tex2DNode222.g / (appendResult742).y );
			float EdgeNoise1732 = temp_output_676_0;
			float temp_output_752_0 = ( tex2DNode222.b / (appendResult742).z );
			float EdgeNoise2755 = temp_output_752_0;
			float temp_output_759_0 = ( tex2DNode222.a / (appendResult742).w );
			float EdgeNoise3762 = temp_output_759_0;
			float temp_output_593_0 = step( 0.1 , ( ( ( EdgeNoise0724 - EdgeNoise1732 ) - EdgeNoise2755 ) - EdgeNoise3762 ) );
			float ctrlR607 = temp_output_593_0;
			float temp_output_597_0 = step( 0.1 , ( ( ( EdgeNoise1732 - temp_output_593_0 ) - EdgeNoise2755 ) - EdgeNoise3762 ) );
			float ctrlG608 = temp_output_597_0;
			float temp_output_601_0 = step( 0.1 , ( ( ( EdgeNoise2755 - temp_output_597_0 ) - temp_output_593_0 ) - EdgeNoise3762 ) );
			float ctrlB609 = temp_output_601_0;
			float temp_output_605_0 = step( 0.1 , ( ( ( EdgeNoise3762 - temp_output_597_0 ) - temp_output_601_0 ) - temp_output_593_0 ) );
			float ctrlA610 = temp_output_605_0;
			float4 appendResult586 = (float4(ctrlR607 , ctrlG608 , ctrlB609 , ctrlA610));
			float4 Control122 = appendResult586;
			float4 weightedBlendVar809 = Control122;
			float4 weightedAvg809 = ( ( weightedBlendVar809.x*_RimColor0 + weightedBlendVar809.y*_RimColor1 + weightedBlendVar809.z*_RimColor2 + weightedBlendVar809.w*_RimColor3 )/( weightedBlendVar809.x + weightedBlendVar809.y + weightedBlendVar809.z + weightedBlendVar809.w ) );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen819 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither819 = Dither4x4Bayer( fmod(clipScreen819.x, 4), fmod(clipScreen819.y, 4) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 weightedBlendVar801 = Control122;
			float2 weightedAvg801 = ( ( weightedBlendVar801.x*_Rim0 + weightedBlendVar801.y*_Rim1 + weightedBlendVar801.z*_Rim2 + weightedBlendVar801.w*_Rim3 )/( weightedBlendVar801.x + weightedBlendVar801.y + weightedBlendVar801.z + weightedBlendVar801.w ) );
			float2 break808 = weightedAvg801;
			float fresnelNdotV793 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode793 = ( 0.0 + break808.x * pow( 1.0 - fresnelNdotV793, break808.y ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult789 = dot( ase_worldViewDir , ase_worldlightDir );
			dither819 = step( dither819, ( fresnelNode793 * saturate( -dotResult789 ) ) );
			float4 RimWrap795 = ( weightedAvg809 * dither819 );
			float4 temp_output_797_0 = RimWrap795;
			o.Emission = temp_output_797_0.rgb;
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
			#pragma target 3.5
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
				float2 customPack1 : TEXCOORD1;
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
Node;AmplifyShaderEditor.CommentaryNode;148;726.5488,601.1151;Inherit;False;751.4393;422.4538;Comment;4;94;95;96;133;Multiplies lit areas with albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-3731.646,709.2673;Inherit;False;1031.701;1051.666;Comment;7;80;86;127;128;88;89;129;Splat Specular (Shadow Cols);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-4942.581,676.2258;Inherit;False;1029.55;1142.421;Comment;6;1;7;6;3;247;838;Splat Albedos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;9;-3983.954,-613.3629;Inherit;False;1045.97;441.7339;Basic lighting;5;14;13;12;11;10;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-6334.721,1786.871;Inherit;False;1206.452;1116.543;Comment;10;25;124;19;23;20;21;22;459;740;640;Splat Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-3989.361,-1702.666;Inherit;False;528.8752;183;;2;28;27;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-3984.349,-1405.943;Inherit;False;609.5977;695.7705;;7;36;35;34;33;32;31;30;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2729.631,-1230.213;Inherit;False;977.7146;495.7445;;8;42;44;39;41;43;46;45;40;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1503.862,-523.3729;Inherit;False;1379.942;546.2153;;11;64;63;62;61;59;58;57;56;55;53;50;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WeightedBlendNode;89;-3194.785,1244.896;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2923.947,1291.196;Inherit;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-3681.646,759.2673;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;80;-3645.082,1007.099;Inherit;False;Property;_Specular0;Specular0;43;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.9056604,0.08116765,0.08116765,0;0.6973284,0.4009434,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;86;-3637.275,1189.766;Inherit;False;Property;_Specular1;Specular1;39;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;127;-3634.132,1367.31;Inherit;False;Property;_Specular2;Specular2;40;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;0.09090912,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;128;-3627.156,1553.933;Inherit;False;Property;_Specular3;Specular3;41;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-4870.953,1593.782;Inherit;True;Property;_Splat3;Splat3;34;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;170;-7917.453,-944.7587;Inherit;False;1210.908;2784.683;;21;574;591;592;594;595;596;598;599;602;600;603;604;649;725;734;737;738;764;765;779;780;Mask Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;199;-8057.888,1936.37;Inherit;False;917.8029;677.2048;;1;544;Compute Masks;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;216;-6072.746,-437.8346;Inherit;False;1473.57;484.0052;Comment;0;Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;3;-4901.5,951.0812;Inherit;True;Property;_Splat0;Splat0;26;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;133;1014.808,908.5688;Inherit;True;126;Albedos;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-4878.64,801.896;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;19;-6284.722,2048.353;Inherit;True;Property;_Normal0;Normal0;27;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-6636.238,2675.738;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-6646.406,2039.162;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;-6673.807,2166.552;Inherit;False;Property;_NormalScale0;NormalScale0;47;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-6672.362,2576.874;Inherit;False;Property;_NormalScale2;NormalScale2;45;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-6666.584,2797.928;Inherit;False;Property;_NormalScale3;NormalScale3;50;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-6641.89,2451.63;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WeightedBlendNode;1;-4166.876,1180.65;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-4880.565,1371.486;Inherit;True;Property;_Splat2;Splat2;31;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-5321.025,2278.332;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;20;-6282.395,2262.27;Inherit;True;Property;_Normal1;Normal1;29;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;496;-10541.83,2874.229;Inherit;False;2185.108;805.0172;Comment;23;519;518;517;516;515;514;513;512;511;510;509;508;507;506;505;504;503;502;501;500;499;498;497;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;498;-10210.88,3183.527;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;500;-10513.51,2920.74;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;501;-10251.76,2953.087;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;502;-10034.07,2954.577;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;503;-10296.01,3061.888;Inherit;False;Property;_NoiseSize;Noise Size;58;0;Create;True;0;0;0;False;0;False;0.1;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;504;-9697.003,2943.24;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-9823.753,3085.436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-10196.15,3501.418;Inherit;False;Property;_WindJitter;Wind Jitter;60;0;Create;True;0;0;0;False;0;False;0;0.682;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;507;-10183.42,3374.352;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;508;-10319.62,3365.202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;509;-10501.93,3361.107;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;-10450.47,3451.46;Inherit;False;Property;_TimeScaleShine;TimeScale Shine;65;0;Create;True;0;0;0;False;0;False;0;150;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-9553.908,3094.804;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;512;-9452.904,3272.284;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;513;-9754.051,3193.383;Inherit;False;Property;_JitterNoiseSize;Jitter Noise Size;64;0;Create;True;0;0;0;False;0;False;0;4.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;-9679.438,3363.073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;515;-9907.621,3480.934;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;516;-8851.715,3187.035;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;517;-8934.749,2919.804;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;519;-10512.98,3177.745;Inherit;False;Property;_WindScroll;Wind Scroll;59;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;520;-10522.64,3786.254;Inherit;False;2299.882;423.7303;;12;534;533;532;531;530;529;528;527;526;525;524;523;Rolling Plains Shine;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;-9223.94,3894.21;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;526;-9622.312,4002.983;Inherit;False;Property;_Color1;Shine Color;63;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4509345,0.4716981,0.3448736,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;527;-9607.747,3886.463;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;528;-9931.378,3836.254;Inherit;True;Property;_shine;shine;61;0;Create;True;0;0;0;False;0;False;-1;None;82aaf027903b047d7af1e568e3864879;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;529;-10087.66,3862.983;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;530;-10276.39,3839.953;Inherit;False;Property;_shinesize;shine size;62;0;Create;True;0;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;531;-10240.7,3962.275;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;532;-10472.64,3956.106;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;534;-8446.763,4037.483;Inherit;False;Shine;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-9400.347,3880.744;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;533;-8823.134,3906.216;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;-9364.53,4004.871;Inherit;True;499;WindScroll;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;551;-7270.246,2760.424;Inherit;False;Property;_Float2;Float 2;66;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;555;-6965.838,2810.151;Inherit;False;Property;_Float3;Float 3;67;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;547;-6872.088,2500.504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;153;-7213.367,2178.038;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-7088.293,2579.278;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;561;-7044.265,2723.942;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;549;-7217.477,2332.161;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;544;-7929.497,2324.338;Inherit;True;499;WindScroll;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3158.852,-383.9119;Inherit;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-3339.009,-403.1888;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-3590.028,-535.551;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;13;-3631.983,-337.7119;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;30;-3910.145,-1355.945;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;36;0;Create;True;0;0;0;False;0;False;1;7;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-3896.444,-1212.537;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;32;-3877.106,-1087.154;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3622.704,-1296.577;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-3974.35,-970.622;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-3757.45,-967.0389;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-3531.083,-1016.336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2679.631,-1080.248;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;37;0;Create;True;0;0;0;False;0;False;0;0.494;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-2002.226,-1091.671;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-2230.345,-842.4246;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;39;-2432.469,-824.5485;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2679.414,-952.7539;Inherit;False;Property;_LightGradientSize;Light Gradient Size;38;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-2231.784,-952.9869;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1977.955,-565.7338;Inherit;False;Property;_Steps;Steps;42;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;51;-1567.331,-631.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;52;-1565.302,-142.4816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;53;-1211.038,-60.70807;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1371.736,-433.6453;Inherit;False;Property;_ShadowLevel;Shadow Level;44;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;56;-1352.031,-332.6086;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;58;-830.3528,-463.6039;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-351.7891,-368.9254;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-996.6652,-239.921;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;-1171.045,-210.036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;63;-777.2358,-235.496;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-643.7543,-237.7161;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-3427.345,-1296.926;Inherit;False;PointLightAttenuation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;108;-1566.704,-1262.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;110;-1518.704,-1275.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;109;-1592.705,-1077.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;111;-1579.705,-1110.208;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;113;-1589.458,-1019.319;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;112;-1026.242,-954.2589;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;114;-1059.696,-984.0021;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-1588.613,-1432.18;Inherit;False;106;PointLightAttenuation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1315.93,-1327.461;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-1104.248,-1322.053;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-818.9117,-1246.79;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;70;-635.0744,-1236.213;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;68;-886.9489,-1094.37;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;115;-1179.578,-624.0409;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;54;-913.515,-674.1039;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;116;-937.0161,-616.2999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-592.9143,-477.6829;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;71;-455.6792,-1112.982;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;364.9399,-289.1895;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;118;282.266,-1061.473;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;336.4008,-995.306;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;135;-2854.965,-705.8971;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;136;-1283.027,-693.014;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;138;320.5749,-381.8734;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;94;776.5488,814.6766;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;1242.987,651.1915;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;27;-3941.361,-1654.666;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-3701.362,-1638.666;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1352.706,-208.9208;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;43;-2280.138,-1187.405;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-2570.417,-1165.261;Inherit;False;10;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-3894.724,-488.1456;Inherit;False;25;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;165;989.6788,302.3776;Float;False;v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) )@$v.tangent.w = -1@;1;Call;0;CalculateTangentsStandard;True;False;0;;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;993.389,651.1151;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;1601.274,1212.116;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;1263.11,1177.807;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;151;1017.992,1388.278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;731.5048,1199.352;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;78;318.6324,1185.492;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;77;-46.35186,707.4709;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-118.4783,916.3269;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;526.994,1329.373;Inherit;False;129;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;586;-5973.82,113.4169;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;609;-6377.791,193.0247;Inherit;False;ctrlB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;610;-6372.47,347.6327;Inherit;False;ctrlA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;607;-6380.451,-78.83662;Inherit;False;ctrlR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;608;-6373.469,55.79989;Inherit;False;ctrlG;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-6879.332,-429.0336;Inherit;False;Constant;_Float6;Float 6;42;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;596;-6836.133,-113.1253;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;605;-6713.303,142.3843;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;518;-9319.118,2910.921;Inherit;True;Property;_WindNoiseTex;Wind Noise Tex;57;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;647;-4734.073,2280.801;Inherit;True;Property;_DirtDivNoise1;Dirt Div Noise;68;0;Create;True;0;0;0;False;0;False;-1;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;648;-5041.451,2275.439;Inherit;False;0;647;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;574;-7099.886,-248.7722;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;594;-7146.578,-146.3151;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;698;-12659.88,-2267.578;Inherit;False;1210.908;2784.683;;18;720;719;718;717;716;715;714;713;708;707;706;705;704;703;702;701;700;699;Mask Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;497;-9233.977,3328.355;Inherit;True;Property;_TextureSample2;Texture Sample 0;24;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;499;-8580.718,2929.446;Inherit;False;WindScroll;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;699;-12165.62,-1126.51;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;700;-12616.94,-1105.143;Inherit;False;Global;_MaskMapRemapScale0;_MaskMapRemapScale0;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;701;-12190.35,-1361.563;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;702;-12616.94,-705.1423;Inherit;False;Global;_MaskMapRemapScale2;_MaskMapRemapScale2;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;703;-11992.01,-1266.289;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;704;-12616.94,-897.1423;Inherit;False;Global;_MaskMapRemapScale1;_MaskMapRemapScale1;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;705;-12635.8,-1743.777;Inherit;False;Global;_MaskMapRemapOffset1;_MaskMapRemapOffset1;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;706;-12616.94,-513.1422;Inherit;False;Global;_MaskMapRemapScale3;_MaskMapRemapScale3;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;707;-12639.19,-1339.79;Inherit;False;Global;_MaskMapRemapOffset3;_MaskMapRemapOffset3;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;713;-12640.12,-1541.407;Inherit;False;Global;_MaskMapRemapOffset2;_MaskMapRemapOffset2;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;714;-11824.31,-1266.289;Inherit;False;defaultOcclusion;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;715;-12327.49,151.2057;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;716;-12553.49,144.2057;Inherit;False;Global;_LayerHasMask1;_LayerHasMask1;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;717;-12120.49,167.2057;Inherit;False;layerHasMask;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;718;-12564.49,320.2064;Inherit;False;Global;_LayerHasMask3;_LayerHasMask3;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;719;-12551.49,234.2054;Inherit;False;Global;_LayerHasMask2;_LayerHasMask2;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;720;-12566.49,64.20567;Inherit;False;Global;_LayerHasMask0;_LayerHasMask0;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;708;-12646.62,-1943.234;Inherit;False;Global;_MaskMapRemapOffset0;_MaskMapRemapOffset0;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;725;-7211.895,-580.2189;Inherit;False;724;EdgeNoise0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SummedBlendNode;23;-5507.592,2172.52;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-5313.432,1829.239;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BlendNormalsNode;459;-5683.846,1872.148;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;738;-7071.856,1358.322;Inherit;False;Constant;_Color3;Color 0;34;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;162;-6678.303,2340.208;Inherit;False;Property;_NormalScale1;NormalScale1;48;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;554;-6905.138,2279.409;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;734;-7493.796,-663.2297;Inherit;False;732;EdgeNoise1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;591;-6949.766,-246.7613;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;592;-6811.992,-232.6192;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;595;-6992.723,-118.1472;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;603;-7072.499,114.594;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;740;-5890.512,2066.459;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.HeightMapBlendNode;645;-5786.369,3076.429;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;644;-5432.33,3106.982;Inherit;False;Normal From Height;-1;;8;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;100;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.HeightMapBlendNode;768;-6791.688,3183.814;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-5613.275,418.3384;Inherit;False;Control;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;750;-8902.641,-1643.006;Inherit;False;FLOAT;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;751;-8896.467,-1526.123;Inherit;False;FLOAT;1;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;757;-8875.882,-1416.376;Inherit;False;FLOAT;2;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;674;-10012.97,-1737.434;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;742;-9176.347,-1490.056;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;612;-8260.528,-2030.592;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;466;-8363.574,-1903.398;Inherit;False;Property;_layer0Div;layer0Div;53;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;351;-8527.703,-2147.26;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;724;-8347.91,-2144.83;Inherit;False;EdgeNoise0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;676;-8570.83,-1745.297;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;732;-8381.88,-1749.553;Inherit;False;EdgeNoise1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;677;-8417.898,-1657.705;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;678;-8560.717,-1565.571;Inherit;False;Property;_layer1Div;layer1Div;56;0;Create;True;0;0;0;False;0;False;0;0.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;733;-8219.207,-1648.108;Inherit;False;EdgeNormal1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;754;-8518.045,-1251.926;Inherit;False;Property;_layer2Div;layer2Div;52;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;752;-8523.974,-1389.846;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;753;-8347.996,-1318.244;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;755;-8335.544,-1408.129;Inherit;False;EdgeNoise2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;761;-8574.184,-949.1165;Inherit;False;Property;_layer3Div;layer3Div;51;0;Create;True;0;0;0;False;0;False;0;1.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;723;-8107.447,-2032.887;Inherit;False;EdgeNormal0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;744;-10004.9,-1378.998;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;675;-9764.776,-1949.957;Inherit;True;Property;_GrassDivNoise;GrassDivNoise;43;0;Create;True;0;0;0;False;0;False;710;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;758;-8876.035,-1314.071;Inherit;False;FLOAT;3;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;746;-9755.715,-1176.504;Inherit;True;Property;_GrassDivNoise2;GrassDivNoise;43;0;Create;True;0;0;0;False;0;False;712;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;743;-9778.711,-1519.833;Inherit;True;Property;_GrassDivNoise1;GrassDivNoise;43;0;Create;True;0;0;0;False;0;False;711;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;747;-10025.38,-1035.667;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;731;-10236.77,-1740.256;Inherit;False;Property;_Layer1NoiseDivSize;Layer1NoiseDivSize;70;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;745;-10255.01,-1361.319;Inherit;False;Property;_Layer2NoiseDivSize;Layer2NoiseDivSize;71;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;748;-10264.68,-1007.964;Inherit;False;Property;_Layer3NoiseDivSize;Layer3NoiseDivSize;72;0;Create;True;0;0;0;False;0;False;0,0;2,2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;726;-10266,-2144.41;Inherit;False;Property;_Layer0NoiseDivSize;Layer0NoiseDivSize;69;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;400;-10011.75,-2157.608;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;569;-9763.23,-2250.318;Inherit;True;Property;_CliffDivNoise;CliffDivNoise;42;0;Create;True;0;0;0;False;0;False;709;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;709;-10279.72,-2346.978;Inherit;True;Property;_Mask0;_Mask0;49;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;710;-10243.84,-1947.801;Inherit;True;Property;_Mask1;_Mask1;55;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;711;-10234.69,-1584.439;Inherit;True;Property;_Mask2;_Mask2;46;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;712;-10267.27,-1220.441;Inherit;True;Property;_Mask3;_Mask3;54;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;756;-8136.445,-1323.913;Inherit;False;EdgeNormal2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;771;-5871.587,2854.21;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;764;-7499.113,-531.8763;Inherit;False;755;EdgeNoise2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;598;-7203.104,-3.873085;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;599;-7025.941,-4.483487;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;600;-6875.791,-14.10605;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;602;-7240.688,116.3326;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;604;-6893.409,124.393;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;665;-6036.735,3159.914;Inherit;False;Constant;_Color2;Color 2;39;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;461;-5579.28,1587.336;Inherit;False;Normal From Height;-1;;9;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;150;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.HeightMapBlendNode;456;-5842.757,1450.685;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HeightMapBlendNode;736;-6771.93,1452.898;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;457;-6142.683,1356.109;Inherit;False;Constant;_Color0;Color 0;34;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;765;-7538.946,-319.1303;Inherit;False;762;EdgeNoise3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;737;-7123.603,1570.606;Inherit;False;733;EdgeNormal1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;779;-7122.19,1665.97;Inherit;False;755;EdgeNoise2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;780;-6850.179,1638.495;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;782;-6803.219,463.069;Inherit;False;733;EdgeNormal1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;783;-6501.269,434.9486;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;640;-5332.692,2596.388;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;767;-7024.222,3028.44;Inherit;False;Constant;_Color4;Color 2;39;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-6274.26,2483.686;Inherit;True;Property;_Normal2;Normal2;33;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-6283.171,2710.452;Inherit;True;Property;_Normal3;Normal3;35;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;784;-8331.101,-809.0579;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;785;-8496.427,-733.4756;Inherit;False;Property;_pullback;pullback;73;0;Create;True;0;0;0;False;0;False;0;2.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;760;-8327.055,-985.7759;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;762;-8276.348,-1083.403;Inherit;False;EdgeNoise3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;759;-8591.497,-1094.453;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;766;-5876.382,3359.183;Inherit;False;763;EdgeNormal3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;739;-6508.453,1589.549;Inherit;False;Normal From Height;-1;;10;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;50;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;735;-6116.122,1582.131;Inherit;False;723;EdgeNormal0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;763;-8122.936,-974.8349;Inherit;False;EdgeNormal3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;597;-6667.501,-111.5239;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;222;-9053.048,-1023.291;Inherit;True;Property;_Control;Control;25;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;770;-6437.649,3214.367;Inherit;False;Normal From Height;-1;;11;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;150;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;593;-6627.748,-230.2304;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;601;-6677.407,17.89463;Inherit;False;2;0;FLOAT;0.1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;786;-998.4384,1922.404;Inherit;False;1067.878;672.6326;;8;796;794;792;791;790;789;788;787;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;787;-948.438,2416.037;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;788;-919.7242,2245.657;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;789;-644.0516,2368.178;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;791;-455.769,2367.265;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;794;-297.3498,2369.083;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;796;-99.56189,2311.968;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;535;-26.94754,-712.1866;Inherit;True;534;Shine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;797;733.6109,-725.555;Inherit;False;795;RimWrap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;799;715.337,-542.4302;Inherit;False;Property;_RimColor;RimColor;74;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2641509,0.2641509,0.2641509,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;800;934.1491,-657.5948;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;798;1178.298,-558.5533;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;802;-818.26,1741.132;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;790;-851.0889,2050.405;Inherit;False;Property;_RimPower;Rim Power;30;0;Create;True;0;0;0;False;0;False;5;7.63;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WeightedBlendNode;801;-597.26,1783.132;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;792;-855.0889,1962.404;Inherit;False;Property;_RimScale;Rim Scale;32;0;Create;True;0;0;0;False;0;False;1;21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;804;-1065.26,1787.132;Inherit;False;Property;_Rim0;Rim0;75;0;Create;True;0;0;0;False;0;False;0,0;0.28,1.92;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;805;-1067.26,1923.132;Inherit;False;Property;_Rim1;Rim1;76;0;Create;True;0;0;0;False;0;False;0,0;8.78,11.09;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;806;-1066.26,2048.132;Inherit;False;Property;_Rim2;Rim2;77;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;807;-1073.26,2177.132;Inherit;False;Property;_Rim3;Rim3;78;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;808;-390.26,1824.132;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FresnelNode;793;-207.0236,1759.071;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;811;-623.2249,1680.189;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;810;112.3131,1718.827;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;812;-534.5012,1674.465;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;813;25.02231,1690.206;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WeightedBlendNode;809;461.7369,1875.064;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;795;813.4268,2307.987;Inherit;False;RimWrap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;818;565.7495,2290.686;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;814;114.3876,1444.774;Inherit;False;Property;_RimColor0;RimColor0;79;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.254717,0.254717,0.254717,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;815;119.92,1662.796;Inherit;False;Property;_RimColor1;RimColor1;80;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2810996,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;816;136.0104,1948.44;Inherit;False;Property;_RimColor2;RimColor2;81;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;817;144.5962,2165.535;Inherit;False;Property;_RimColor3;RimColor3;82;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;819;163.5232,2420.864;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1386.358,-15.11673;Float;False;True;-1;3;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Terrain_New;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;-100;False;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;24;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;;-1;0;False;;0;0;0;True;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;769;-7055.576,3371.939;Inherit;False;756;EdgeNormal2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;778;-7052.815,3501.149;Inherit;False;732;EdgeNoise1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;777;-6800.642,3435.055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;820;-6425.059,3572.766;Inherit;False;dirtShading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-3905.311,1248.637;Inherit;False;Albedos;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;822;1590.835,1518.689;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;823;930.9901,1690.194;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;825;1320.068,1544.929;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;824;1071.73,1551.974;Inherit;False;129;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;827;1980.828,1598.617;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;828;704.0204,1647.148;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;829;2011.276,1309.206;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;821;1306.237,1432.607;Inherit;False;820;dirtShading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;831;1592.958,1682.563;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;832;1765.264,1678.831;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;830;2326.774,547.6815;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-5305.598,1042.42;Inherit;True;Property;_Splat1;Splat1;28;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;835;-5271.773,1302.294;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;838;-4877.696,1200.213;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;839;896.3901,48.1123;Inherit;True;Property;_TextureSample1;Texture Sample 1;49;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;840;650.7039,54.61133;Inherit;True;Property;_TerrainHolesTexture;TerrainHolesTexture;83;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;842;742.9424,-204.7735;Inherit;False;Four Splats First Pass Terrain;0;;2;37452fdfb732e1443b7e39720d05b708;2,102,1,85,0;7;59;FLOAT4;0,0,0,0;False;60;FLOAT4;0,0,0,0;False;61;FLOAT3;0,0,0;False;57;FLOAT;0;False;58;FLOAT;0;False;201;FLOAT;0;False;62;FLOAT;0;False;7;FLOAT4;0;FLOAT3;14;FLOAT;56;FLOAT;45;FLOAT;200;FLOAT;19;FLOAT;17
Node;AmplifyShaderEditor.GetLocalVarNode;843;568.2878,-109.5074;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
WireConnection;89;0;88;0
WireConnection;89;1;80;0
WireConnection;89;2;86;0
WireConnection;89;3;127;0
WireConnection;89;4;128;0
WireConnection;129;0;89;0
WireConnection;19;1;152;0
WireConnection;19;5;161;0
WireConnection;1;0;247;0
WireConnection;1;1;3;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;1;4;7;0
WireConnection;25;0;23;0
WireConnection;20;1;153;0
WireConnection;20;5;162;0
WireConnection;498;0;519;0
WireConnection;501;0;500;1
WireConnection;501;1;500;3
WireConnection;502;0;501;0
WireConnection;502;1;503;0
WireConnection;504;0;502;0
WireConnection;504;1;505;0
WireConnection;505;0;498;0
WireConnection;505;1;507;0
WireConnection;507;0;508;0
WireConnection;507;1;510;0
WireConnection;508;0;509;0
WireConnection;511;0;502;0
WireConnection;511;1;513;0
WireConnection;512;0;511;0
WireConnection;512;1;514;0
WireConnection;514;0;507;0
WireConnection;514;1;515;0
WireConnection;515;0;506;0
WireConnection;516;0;517;0
WireConnection;516;1;497;0
WireConnection;517;0;518;0
WireConnection;523;0;525;0
WireConnection;523;1;524;0
WireConnection;527;0;528;0
WireConnection;528;1;529;0
WireConnection;529;0;530;0
WireConnection;529;1;531;0
WireConnection;531;0;532;1
WireConnection;531;1;532;3
WireConnection;534;0;533;0
WireConnection;525;0;527;0
WireConnection;525;1;526;0
WireConnection;533;0;523;0
WireConnection;547;0;554;0
WireConnection;547;1;561;0
WireConnection;560;0;549;0
WireConnection;560;1;551;0
WireConnection;561;0;560;0
WireConnection;549;0;544;0
WireConnection;10;0;11;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;12;0;14;0
WireConnection;33;0;30;0
WireConnection;33;1;31;0
WireConnection;33;2;32;0
WireConnection;35;0;34;0
WireConnection;36;0;32;0
WireConnection;36;1;35;0
WireConnection;45;0;43;0
WireConnection;45;1;41;0
WireConnection;45;2;42;0
WireConnection;41;0;40;0
WireConnection;41;1;39;0
WireConnection;39;0;44;0
WireConnection;42;0;40;0
WireConnection;42;1;39;0
WireConnection;51;0;49;0
WireConnection;52;0;49;0
WireConnection;53;0;52;0
WireConnection;58;0;55;0
WireConnection;58;1;56;0
WireConnection;59;0;57;0
WireConnection;59;1;64;0
WireConnection;61;0;112;0
WireConnection;61;1;53;0
WireConnection;61;2;62;0
WireConnection;62;0;50;0
WireConnection;63;0;61;0
WireConnection;64;0;63;0
WireConnection;64;1;53;0
WireConnection;106;0;33;0
WireConnection;108;0;111;0
WireConnection;110;0;108;0
WireConnection;109;0;45;0
WireConnection;111;0;109;0
WireConnection;113;0;45;0
WireConnection;112;0;114;0
WireConnection;114;0;113;0
WireConnection;66;0;107;0
WireConnection;66;1;110;0
WireConnection;67;0;66;0
WireConnection;69;0;67;0
WireConnection;69;1;68;0
WireConnection;70;0;69;0
WireConnection;68;0;54;0
WireConnection;115;0;51;0
WireConnection;54;0;116;0
WireConnection;116;0;115;0
WireConnection;57;0;136;0
WireConnection;57;1;58;0
WireConnection;71;0;70;0
WireConnection;71;1;68;0
WireConnection;72;0;138;0
WireConnection;72;1;59;0
WireConnection;118;0;71;0
WireConnection;117;0;118;0
WireConnection;135;0;36;0
WireConnection;136;0;135;0
WireConnection;138;0;117;0
WireConnection;96;0;95;0
WireConnection;96;1;133;0
WireConnection;28;0;27;2
WireConnection;43;0;46;0
WireConnection;95;0;77;0
WireConnection;95;1;94;0
WireConnection;97;0;96;0
WireConnection;97;1;149;0
WireConnection;149;0;141;0
WireConnection;149;1;151;0
WireConnection;151;0;150;0
WireConnection;141;0;78;0
WireConnection;141;1;130;0
WireConnection;78;0;77;0
WireConnection;77;0;72;0
WireConnection;586;0;607;0
WireConnection;586;1;608;0
WireConnection;586;2;609;0
WireConnection;586;3;610;0
WireConnection;609;0;601;0
WireConnection;610;0;605;0
WireConnection;607;0;593;0
WireConnection;608;0;597;0
WireConnection;596;0;595;0
WireConnection;596;1;765;0
WireConnection;605;0;649;0
WireConnection;605;1;604;0
WireConnection;518;1;504;0
WireConnection;647;1;648;0
WireConnection;574;0;725;0
WireConnection;574;1;734;0
WireConnection;594;0;734;0
WireConnection;594;1;593;0
WireConnection;497;1;512;0
WireConnection;499;0;516;0
WireConnection;699;0;700;2
WireConnection;699;1;704;2
WireConnection;699;2;702;2
WireConnection;699;3;706;2
WireConnection;701;0;708;2
WireConnection;701;1;705;2
WireConnection;701;2;713;2
WireConnection;701;3;707;2
WireConnection;703;0;701;0
WireConnection;703;1;699;0
WireConnection;714;0;703;0
WireConnection;715;0;720;0
WireConnection;715;1;716;0
WireConnection;715;2;719;0
WireConnection;715;3;718;0
WireConnection;717;0;715;0
WireConnection;23;0;124;0
WireConnection;23;1;459;0
WireConnection;23;2;740;0
WireConnection;23;3;771;0
WireConnection;23;4;22;0
WireConnection;459;0;461;40
WireConnection;459;1;19;0
WireConnection;554;0;153;0
WireConnection;554;1;555;0
WireConnection;591;0;574;0
WireConnection;591;1;764;0
WireConnection;592;0;591;0
WireConnection;592;1;765;0
WireConnection;595;0;594;0
WireConnection;595;1;764;0
WireConnection;603;0;602;0
WireConnection;603;1;601;0
WireConnection;740;0;739;40
WireConnection;740;1;20;0
WireConnection;645;0;767;0
WireConnection;645;1;766;0
WireConnection;644;20;645;0
WireConnection;768;0;767;0
WireConnection;768;1;777;0
WireConnection;122;0;586;0
WireConnection;750;0;742;0
WireConnection;751;0;742;0
WireConnection;757;0;742;0
WireConnection;674;0;731;0
WireConnection;742;0;569;1
WireConnection;742;1;675;2
WireConnection;742;2;743;3
WireConnection;742;3;746;4
WireConnection;612;0;351;0
WireConnection;612;1;466;0
WireConnection;351;0;222;1
WireConnection;351;1;750;0
WireConnection;724;0;351;0
WireConnection;676;0;222;2
WireConnection;676;1;751;0
WireConnection;732;0;676;0
WireConnection;677;0;676;0
WireConnection;677;1;678;0
WireConnection;733;0;677;0
WireConnection;752;0;222;3
WireConnection;752;1;757;0
WireConnection;753;0;752;0
WireConnection;753;1;754;0
WireConnection;755;0;752;0
WireConnection;723;0;612;0
WireConnection;744;0;745;0
WireConnection;675;0;710;0
WireConnection;675;1;674;0
WireConnection;758;0;742;0
WireConnection;746;0;712;0
WireConnection;746;1;747;0
WireConnection;743;0;711;0
WireConnection;743;1;744;0
WireConnection;747;0;748;0
WireConnection;400;0;726;0
WireConnection;569;0;709;0
WireConnection;569;1;400;0
WireConnection;756;0;753;0
WireConnection;771;0;770;40
WireConnection;771;1;21;0
WireConnection;598;0;764;0
WireConnection;598;1;597;0
WireConnection;599;0;598;0
WireConnection;599;1;593;0
WireConnection;600;0;599;0
WireConnection;600;1;765;0
WireConnection;602;0;765;0
WireConnection;602;1;597;0
WireConnection;604;0;603;0
WireConnection;604;1;593;0
WireConnection;461;20;456;0
WireConnection;456;0;457;0
WireConnection;456;1;735;0
WireConnection;736;0;738;0
WireConnection;736;1;780;0
WireConnection;780;0;737;0
WireConnection;780;1;779;0
WireConnection;783;0;605;0
WireConnection;640;0;644;40
WireConnection;640;1;22;0
WireConnection;21;1;154;0
WireConnection;21;5;163;0
WireConnection;22;1;155;0
WireConnection;22;5;164;0
WireConnection;784;0;785;0
WireConnection;784;1;759;0
WireConnection;760;0;759;0
WireConnection;760;1;761;0
WireConnection;762;0;759;0
WireConnection;759;0;222;4
WireConnection;759;1;758;0
WireConnection;739;20;736;0
WireConnection;763;0;760;0
WireConnection;597;0;649;0
WireConnection;597;1;596;0
WireConnection;770;20;768;0
WireConnection;593;0;649;0
WireConnection;593;1;592;0
WireConnection;601;0;649;0
WireConnection;601;1;600;0
WireConnection;789;0;788;0
WireConnection;789;1;787;0
WireConnection;791;0;789;0
WireConnection;794;0;791;0
WireConnection;796;0;793;0
WireConnection;796;1;794;0
WireConnection;800;0;797;0
WireConnection;798;0;800;0
WireConnection;798;1;799;0
WireConnection;801;0;802;0
WireConnection;801;1;804;0
WireConnection;801;2;805;0
WireConnection;801;3;806;0
WireConnection;801;4;807;0
WireConnection;808;0;801;0
WireConnection;793;2;808;0
WireConnection;793;3;808;1
WireConnection;811;0;802;0
WireConnection;810;0;813;0
WireConnection;812;0;811;0
WireConnection;813;0;812;0
WireConnection;809;0;810;0
WireConnection;809;1;814;0
WireConnection;809;2;815;0
WireConnection;809;3;816;0
WireConnection;809;4;817;0
WireConnection;795;0;818;0
WireConnection;818;0;809;0
WireConnection;818;1;819;0
WireConnection;819;0;796;0
WireConnection;0;2;797;0
WireConnection;0;10;842;19
WireConnection;0;13;97;0
WireConnection;0;11;165;0
WireConnection;777;0;778;0
WireConnection;777;1;769;0
WireConnection;820;0;768;0
WireConnection;126;0;1;0
WireConnection;822;0;825;2
WireConnection;822;1;821;0
WireConnection;823;0;828;0
WireConnection;825;0;824;0
WireConnection;827;2;822;0
WireConnection;829;0;97;0
WireConnection;829;1;822;0
WireConnection;831;0;821;0
WireConnection;831;1;823;0
WireConnection;832;0;831;0
WireConnection;832;1;822;0
WireConnection;830;0;829;0
WireConnection;838;0;5;0
WireConnection;838;1;835;0
WireConnection;839;0;840;0
WireConnection;842;59;843;0
WireConnection;842;62;839;0
ASEEND*/
//CHKSM=3E9686140D4F2A545D3F3642C6D5412B1EE04B1F