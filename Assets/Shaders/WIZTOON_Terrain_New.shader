// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Terrain_New"
{
	Properties
	{
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
		_Float0("Float 0", Float) = 0
		_float20("float20", Float) = 0
		_TextureSample2("Texture Sample 0", 2D) = "bump" {}
		_Float1("Float 1", Float) = 0
		_float21("float 21", Float) = 0
		_WindNoiseTex("Wind Noise Tex", 2D) = "bump" {}
		_NoiseSize("Noise Size", Range( 0 , 1)) = 0.1
		_WindScroll("Wind Scroll", Range( 0 , 1)) = 0
		_WindJitter("Wind Jitter", Range( 0 , 1)) = 0
		_shine("shine", 2D) = "white" {}
		_shinesize("shine size", Float) = 0
		_Color1("Shine Color", Color) = (0,0,0,0)
		_JitterNoiseSize("Jitter Noise Size", Float) = 0
		_TimeScaleShine("TimeScale Shine", Float) = 0
		_Float2("Float 2", Float) = 5
		_Float3("Float 3", Float) = 0
		_GrassDivNoise("Grass Div Noise", 2D) = "white" {}
		_DirtDivNoise1("Dirt Div Noise", 2D) = "white" {}
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
		#pragma multi_compile_instancing
		#pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap forwardadd
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
		UNITY_DECLARE_TEX2D_NOSAMPLER(_shine);
		uniform float _shinesize;
		SamplerState sampler_shine;
		uniform float4 _Color1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_WindNoiseTex);
		uniform float _WindScroll;
		uniform float _TimeScaleShine;
		uniform float _NoiseSize;
		SamplerState sampler_WindNoiseTex;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_TextureSample2);
		uniform float _WindJitter;
		uniform float _JitterNoiseSize;
		SamplerState sampler_TextureSample2;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Control);
		uniform float4 _Control_ST;
		SamplerState sampler_Control;
		uniform float _Float0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_GrassDivNoise);
		uniform float4 _GrassDivNoise_ST;
		SamplerState sampler_GrassDivNoise;
		uniform float _Float1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal0);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat0);
		uniform float4 _Splat0_ST;
		SamplerState sampler_Normal0;
		uniform float _NormalScale0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat1);
		uniform float4 _Splat1_ST;
		uniform float _Float3;
		uniform float _Float2;
		SamplerState sampler_Normal1;
		uniform float _NormalScale1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal2);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat2);
		uniform float4 _Splat2_ST;
		SamplerState sampler_Normal2;
		uniform float _NormalScale2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_DirtDivNoise1);
		SamplerState sampler_DirtDivNoise1;
		uniform float _float20;
		uniform float _float21;
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


		float3 PerturbNormal107_g4( float3 surf_pos, float3 surf_norm, float height, float scale )
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


		float3 PerturbNormal107_g6( float3 surf_pos, float3 surf_norm, float height, float scale )
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
			float IsPointLight28 = _WorldSpaceLightPos0.w;
			float PointLightAttenuation106 = ( _PointLightAttenuationBoost * IsPointLight28 * ase_lightAtten );
			float temp_output_39_0 = ( _LightGradientSize * 0.5 );
			float4 temp_cast_4 = (0.1).xxxx;
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode222 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float4 temp_cast_5 = (tex2DNode222.r).xxxx;
			float4 temp_cast_6 = (_Float0).xxxx;
			float2 uv_GrassDivNoise = i.uv_texcoord * _GrassDivNoise_ST.xy + _GrassDivNoise_ST.zw;
			float4 tex2DNode569 = SAMPLE_TEXTURE2D( _GrassDivNoise, sampler_GrassDivNoise, uv_GrassDivNoise );
			float4 temp_output_612_0 = ( ( temp_cast_6 - ( tex2DNode222.g / tex2DNode569 ) ) / _Float1 );
			float4 temp_cast_7 = (tex2DNode222.b).xxxx;
			float4 temp_cast_8 = (tex2DNode222.a).xxxx;
			float4 temp_output_593_0 = step( temp_cast_4 , ( ( ( temp_cast_5 - temp_output_612_0 ) - temp_cast_7 ) - temp_cast_8 ) );
			float4 ctrlR607 = temp_output_593_0;
			float4 temp_cast_10 = (0.1).xxxx;
			float4 temp_cast_11 = (_Float0).xxxx;
			float4 temp_cast_12 = (0.1).xxxx;
			float4 temp_cast_13 = (tex2DNode222.r).xxxx;
			float4 temp_cast_14 = (_Float0).xxxx;
			float4 temp_cast_15 = (tex2DNode222.b).xxxx;
			float4 temp_cast_16 = (tex2DNode222.a).xxxx;
			float4 temp_cast_17 = (tex2DNode222.b).xxxx;
			float4 temp_cast_18 = (tex2DNode222.a).xxxx;
			float4 temp_output_597_0 = step( temp_cast_10 , ( ( ( temp_output_612_0 - temp_output_593_0 ) - temp_cast_17 ) - temp_cast_18 ) );
			float4 ctrlG608 = temp_output_597_0;
			float4 temp_cast_20 = (0.1).xxxx;
			float4 temp_cast_21 = (tex2DNode222.b).xxxx;
			float4 temp_cast_22 = (0.1).xxxx;
			float4 temp_cast_23 = (_Float0).xxxx;
			float4 temp_cast_24 = (0.1).xxxx;
			float4 temp_cast_25 = (tex2DNode222.r).xxxx;
			float4 temp_cast_26 = (_Float0).xxxx;
			float4 temp_cast_27 = (tex2DNode222.b).xxxx;
			float4 temp_cast_28 = (tex2DNode222.a).xxxx;
			float4 temp_cast_29 = (tex2DNode222.b).xxxx;
			float4 temp_cast_30 = (tex2DNode222.a).xxxx;
			float4 temp_cast_31 = (0.1).xxxx;
			float4 temp_cast_32 = (tex2DNode222.r).xxxx;
			float4 temp_cast_33 = (_Float0).xxxx;
			float4 temp_cast_34 = (tex2DNode222.b).xxxx;
			float4 temp_cast_35 = (tex2DNode222.a).xxxx;
			float4 temp_cast_36 = (tex2DNode222.a).xxxx;
			float4 temp_output_601_0 = step( temp_cast_20 , ( ( ( temp_cast_21 - temp_output_597_0 ) - temp_output_593_0 ) - temp_cast_36 ) );
			float4 ctrlB609 = temp_output_601_0;
			float4 temp_cast_38 = (0.1).xxxx;
			float4 temp_cast_39 = (tex2DNode222.a).xxxx;
			float4 temp_cast_40 = (0.1).xxxx;
			float4 temp_cast_41 = (_Float0).xxxx;
			float4 temp_cast_42 = (0.1).xxxx;
			float4 temp_cast_43 = (tex2DNode222.r).xxxx;
			float4 temp_cast_44 = (_Float0).xxxx;
			float4 temp_cast_45 = (tex2DNode222.b).xxxx;
			float4 temp_cast_46 = (tex2DNode222.a).xxxx;
			float4 temp_cast_47 = (tex2DNode222.b).xxxx;
			float4 temp_cast_48 = (tex2DNode222.a).xxxx;
			float4 temp_cast_49 = (0.1).xxxx;
			float4 temp_cast_50 = (tex2DNode222.b).xxxx;
			float4 temp_cast_51 = (0.1).xxxx;
			float4 temp_cast_52 = (_Float0).xxxx;
			float4 temp_cast_53 = (0.1).xxxx;
			float4 temp_cast_54 = (tex2DNode222.r).xxxx;
			float4 temp_cast_55 = (_Float0).xxxx;
			float4 temp_cast_56 = (tex2DNode222.b).xxxx;
			float4 temp_cast_57 = (tex2DNode222.a).xxxx;
			float4 temp_cast_58 = (tex2DNode222.b).xxxx;
			float4 temp_cast_59 = (tex2DNode222.a).xxxx;
			float4 temp_cast_60 = (0.1).xxxx;
			float4 temp_cast_61 = (tex2DNode222.r).xxxx;
			float4 temp_cast_62 = (_Float0).xxxx;
			float4 temp_cast_63 = (tex2DNode222.b).xxxx;
			float4 temp_cast_64 = (tex2DNode222.a).xxxx;
			float4 temp_cast_65 = (tex2DNode222.a).xxxx;
			float4 temp_cast_66 = (0.1).xxxx;
			float4 temp_cast_67 = (tex2DNode222.r).xxxx;
			float4 temp_cast_68 = (_Float0).xxxx;
			float4 temp_cast_69 = (tex2DNode222.b).xxxx;
			float4 temp_cast_70 = (tex2DNode222.a).xxxx;
			float4 ctrlA610 = step( temp_cast_38 , ( ( ( temp_cast_39 - temp_output_597_0 ) - temp_output_601_0 ) - temp_output_593_0 ) );
			float4 appendResult586 = (float4(ctrlR607.r , ctrlG608.r , ctrlB609.r , ctrlA610.r));
			float4 Control122 = appendResult586;
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g4 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g4 = ase_worldNormal;
			float4 color457 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float4 temp_cast_73 = (_Float0).xxxx;
			float4 grassDivNormal616 = temp_output_612_0;
			float HeightMask456 = saturate(pow(((color457.r*grassDivNormal616.r)*4)+(grassDivNormal616.r*2),0.25));
			float height107_g4 = HeightMask456;
			float scale107_g4 = -150.0;
			float3 localPerturbNormal107_g4 = PerturbNormal107_g4( surf_pos107_g4 , surf_norm107_g4 , height107_g4 , scale107_g4 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g4 = mul( ase_worldToTangent, localPerturbNormal107_g4);
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float mulTime509 = _Time.y * 5.0;
			float temp_output_507_0 = ( floor( mulTime509 ) / _TimeScaleShine );
			float2 appendResult501 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_502_0 = ( appendResult501 * _NoiseSize );
			float2 panner504 = ( ( (0.0 + (_WindScroll - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * temp_output_507_0 ) * float2( 1,0 ) + temp_output_502_0);
			float2 panner512 = ( ( temp_output_507_0 * (0.0 + (_WindJitter - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) ) * float2( 1,1 ) + ( temp_output_502_0 * _JitterNoiseSize ));
			float4 WindScroll499 = ( float4( pow( UnpackNormal( SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner504 ) ) , 1.5 ) , 0.0 ) + SAMPLE_TEXTURE2D( _TextureSample2, sampler_TextureSample2, panner512 ) );
			float3 worldToObj549 = mul( unity_WorldToObject, float4( WindScroll499.rgb, 1 ) ).xyz;
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float3 surf_pos107_g6 = ase_worldPos;
			float3 surf_norm107_g6 = ase_worldNormal;
			float4 temp_cast_80 = (_float20).xxxx;
			float HeightMask645 = saturate(pow(((SAMPLE_TEXTURE2D( _DirtDivNoise1, sampler_DirtDivNoise1, i.uv_texcoord ).r*( ( temp_cast_80 - ( tex2DNode222.g / tex2DNode569 ) ) / _float21 ).r)*4)+(( ( temp_cast_80 - ( tex2DNode222.g / tex2DNode569 ) ) / _float21 ).r*2),1.0));
			float height107_g6 = HeightMask645;
			float scale107_g6 = 3.0;
			float3 localPerturbNormal107_g6 = PerturbNormal107_g6( surf_pos107_g6 , surf_norm107_g6 , height107_g6 , scale107_g6 );
			float3 worldToTangentDir42_g6 = mul( ase_worldToTangent, localPerturbNormal107_g6);
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 weightedBlendVar23 = Control122;
			float3 weightedBlend23 = ( weightedBlendVar23.x*BlendNormals( worldToTangentDir42_g4 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, uv_Splat0 ), _NormalScale0 ) ) + weightedBlendVar23.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, ( float3( ( uv_Splat1 * _Float3 ) ,  0.0 ) + saturate( ( worldToObj549 * _Float2 ) ) ).xy ), _NormalScale1 ) + weightedBlendVar23.z*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal2, sampler_Normal2, uv_Splat2 ), _NormalScale2 ) + weightedBlendVar23.w*BlendNormals( worldToTangentDir42_g6 , UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal3, sampler_Normal3, uv_Splat3 ), _NormalScale3 ) ) );
			float3 Normals25 = weightedBlend23;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult11 = dot( (WorldNormalVector( i , Normals25 )) , ase_worldlightDir );
			float NdotL10 = dotResult11;
			float smoothstepResult45 = smoothstep( ( _LightGradientMidLevel - temp_output_39_0 ) , ( _LightGradientMidLevel + temp_output_39_0 ) , (NdotL10*0.5 + 0.5));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 weightedBlendVar1 = Control122;
			float4 weightedAvg1 = ( ( weightedBlendVar1.x*SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 ) + weightedBlendVar1.y*SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) + weightedBlendVar1.z*SAMPLE_TEXTURE2D( _Splat2, sampler_Splat2, uv_Splat2 ) + weightedBlendVar1.w*SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, uv_Splat3 ) )/( weightedBlendVar1.x + weightedBlendVar1.y + weightedBlendVar1.z + weightedBlendVar1.w ) );
			float4 Albedos126 = weightedAvg1;
			float4 weightedBlendVar89 = Control122;
			float4 weightedAvg89 = ( ( weightedBlendVar89.x*_Specular0 + weightedBlendVar89.y*_Specular1 + weightedBlendVar89.z*_Specular2 + weightedBlendVar89.w*_Specular3 )/( weightedBlendVar89.x + weightedBlendVar89.y + weightedBlendVar89.z + weightedBlendVar89.w ) );
			float4 ShadowColor129 = weightedAvg89;
			c.rgb = ( ( ( ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight28 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult45 * _Steps * ( 1.0 - IsPointLight28 ) ) ) / _Steps ) ) ) * ase_lightColor ) * Albedos126 ) + ( ( ( 1.0 - ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + ( ( ( ase_lightAtten * ( 1.0 - IsPointLight28 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult45 * _Steps * ( 1.0 - IsPointLight28 ) ) ) / _Steps ) ) ) ) * ShadowColor129 ) * ( 1.0 - IsPointLight28 ) ) ).rgb;
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
			float2 clipScreen527 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither527 = Dither4x4Bayer( fmod(clipScreen527.x, 4), fmod(clipScreen527.y, 4) );
			float3 ase_worldPos = i.worldPos;
			float4 appendResult531 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			dither527 = step( dither527, SAMPLE_TEXTURE2D( _shine, sampler_shine, ( _shinesize * appendResult531 ).xy ).r );
			float mulTime509 = _Time.y * 5.0;
			float temp_output_507_0 = ( floor( mulTime509 ) / _TimeScaleShine );
			float2 appendResult501 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_502_0 = ( appendResult501 * _NoiseSize );
			float2 panner504 = ( ( (0.0 + (_WindScroll - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) * temp_output_507_0 ) * float2( 1,0 ) + temp_output_502_0);
			float2 panner512 = ( ( temp_output_507_0 * (0.0 + (_WindJitter - 0.0) * (0.1 - 0.0) / (1.0 - 0.0)) ) * float2( 1,1 ) + ( temp_output_502_0 * _JitterNoiseSize ));
			float4 WindScroll499 = ( float4( pow( UnpackNormal( SAMPLE_TEXTURE2D( _WindNoiseTex, sampler_WindNoiseTex, panner504 ) ) , 1.5 ) , 0.0 ) + SAMPLE_TEXTURE2D( _TextureSample2, sampler_TextureSample2, panner512 ) );
			float4 Shine534 = saturate( ( ( dither527 * _Color1 ) - WindScroll499 ) );
			o.Emission = Shine534.rgb;
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
Node;AmplifyShaderEditor.CommentaryNode;145;-660.8116,661.3414;Inherit;False;605.6092;303;Comment;0;Applies Shadow Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;144;-148.9679,1063.848;Inherit;False;476.9345;314.1964;Comment;0;Dithers Mid-range Shadow Values;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;121;-739.8407,209.3531;Inherit;False;564.9662;532.2659;Comment;1;139;Dithering;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;139;-607.8173,528.5131;Inherit;False;100;100; sat ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-3731.646,709.2673;Inherit;False;1031.701;1051.666;Comment;7;80;86;127;128;88;89;129;Splat Specular (Shadow Cols);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-4942.581,676.2258;Inherit;False;1029.55;1142.421;Comment;6;1;7;6;5;3;247;Splat Albedos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;9;-3983.954,-613.3629;Inherit;False;1045.97;441.7339;Basic lighting;5;14;13;12;11;10;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-6334.721,1786.871;Inherit;False;1206.452;1116.543;Comment;9;25;124;19;23;20;21;22;640;645;Splat Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-3989.361,-1702.666;Inherit;False;528.8752;183;;2;28;27;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-3984.349,-1405.943;Inherit;False;609.5977;695.7705;;7;36;35;34;33;32;31;30;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2729.631,-1230.213;Inherit;False;977.7146;495.7445;;8;42;44;39;41;43;46;45;40;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;47;-1503.862,-523.3729;Inherit;False;1379.942;546.2153;;11;64;63;62;61;59;58;57;56;55;53;50;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WeightedBlendNode;89;-3194.785,1244.896;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2923.947,1291.196;Inherit;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-3681.646,759.2673;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;80;-3645.082,1007.099;Inherit;False;Property;_Specular0;Specular0;16;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.9056604,0.08116765,0.08116765,0;0.6973284,0.4009434,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;86;-3637.275,1189.766;Inherit;False;Property;_Specular1;Specular1;12;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;127;-3634.132,1367.31;Inherit;False;Property;_Specular2;Specular2;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;0.09090912,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;128;-3627.156,1553.933;Inherit;False;Property;_Specular3;Specular3;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-4887.775,1153.995;Inherit;True;Property;_Splat1;Splat1;3;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-4870.953,1593.782;Inherit;True;Property;_Splat3;Splat3;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1386.358,-15.11673;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Terrain_New;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;;-1;0;False;;0;0;0;True;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;170;-8069.495,-944.7587;Inherit;False;1210.908;2784.683;;24;222;574;591;592;594;595;596;598;599;602;569;351;464;466;612;611;600;603;604;657;658;659;660;661;Mask Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;199;-8057.888,1936.37;Inherit;False;917.8029;677.2048;;1;544;Compute Masks;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;216;-6072.746,-437.8346;Inherit;False;1473.57;484.0052;Comment;0;Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;3;-4901.5,951.0812;Inherit;True;Property;_Splat0;Splat0;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;133;1014.808,908.5688;Inherit;True;126;Albedos;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-4878.64,801.896;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;21;-6274.26,2483.686;Inherit;True;Property;_Normal2;Normal2;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-6263.093,2704.429;Inherit;True;Property;_Normal3;Normal3;8;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-6284.722,2048.353;Inherit;True;Property;_Normal0;Normal0;2;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-6636.238,2675.738;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-6646.406,2039.162;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;-6673.807,2166.552;Inherit;False;Property;_NormalScale0;NormalScale0;19;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-6673.808,2373.157;Inherit;False;Property;_NormalScale1;NormalScale1;20;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-6672.362,2576.874;Inherit;False;Property;_NormalScale2;NormalScale2;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-6666.584,2797.928;Inherit;False;Property;_NormalScale3;NormalScale3;21;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-6641.89,2451.63;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-3905.311,1248.637;Inherit;False;Albedos;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WeightedBlendNode;1;-4166.876,1180.65;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-4880.565,1371.486;Inherit;True;Property;_Splat2;Splat2;5;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;412;-4387.821,2779.438;Inherit;False;1067.878;672.6326;;0;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-5321.025,2278.332;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;459;-5312.749,1990.436;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;20;-6282.395,2262.27;Inherit;True;Property;_Normal1;Normal1;4;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;124;-6183.202,1922.014;Inherit;False;122;Control;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;496;-10541.83,2874.229;Inherit;False;2185.108;805.0172;Comment;23;519;518;517;516;515;514;513;512;511;510;509;508;507;506;505;504;503;502;501;500;499;498;497;Wind;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;498;-10210.88,3183.527;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;499;-8580.718,2929.446;Inherit;False;WindScroll;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;500;-10513.51,2920.74;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;501;-10251.76,2953.087;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;502;-10034.07,2954.577;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;503;-10296.01,3061.888;Inherit;False;Property;_NoiseSize;Noise Size;27;0;Create;True;0;0;0;False;0;False;0.1;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;504;-9697.003,2943.24;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;505;-9823.753,3085.436;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-10196.15,3501.418;Inherit;False;Property;_WindJitter;Wind Jitter;29;0;Create;True;0;0;0;False;0;False;0;0.682;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;507;-10183.42,3374.352;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;508;-10319.62,3365.202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;509;-10501.93,3361.107;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;510;-10450.47,3451.46;Inherit;False;Property;_TimeScaleShine;TimeScale Shine;34;0;Create;True;0;0;0;False;0;False;0;150;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;511;-9553.908,3094.804;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;512;-9452.904,3272.284;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;513;-9754.051,3193.383;Inherit;False;Property;_JitterNoiseSize;Jitter Noise Size;33;0;Create;True;0;0;0;False;0;False;0;4.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;-9679.438,3363.073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;515;-9907.621,3480.934;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;516;-8851.715,3187.035;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;517;-8934.749,2919.804;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;519;-10512.98,3177.745;Inherit;False;Property;_WindScroll;Wind Scroll;28;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;520;-10522.64,3786.254;Inherit;False;2299.882;423.7303;;12;534;533;532;531;530;529;528;527;526;525;524;523;Rolling Plains Shine;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;523;-9223.94,3894.21;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;526;-9622.312,4002.983;Inherit;False;Property;_Color1;Shine Color;32;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4509345,0.4716981,0.3448736,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;527;-9607.747,3886.463;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;528;-9931.378,3836.254;Inherit;True;Property;_shine;shine;30;0;Create;True;0;0;0;False;0;False;-1;None;82aaf027903b047d7af1e568e3864879;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;529;-10087.66,3862.983;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;530;-10276.39,3839.953;Inherit;False;Property;_shinesize;shine size;31;0;Create;True;0;0;0;False;0;False;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;531;-10240.7,3962.275;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;532;-10472.64,3956.106;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;534;-8446.763,4037.483;Inherit;False;Shine;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;525;-9400.347,3880.744;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;533;-8823.134,3906.216;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;524;-9364.53,4004.871;Inherit;True;499;WindScroll;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;551;-7270.246,2760.424;Inherit;False;Property;_Float2;Float 2;35;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;555;-6965.838,2810.151;Inherit;False;Property;_Float3;Float 3;36;0;Create;True;0;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;547;-6872.088,2500.504;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;153;-7213.367,2178.038;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;554;-6905.138,2279.409;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-7088.293,2579.278;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;561;-7044.265,2723.942;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;549;-7217.477,2332.161;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;544;-7929.497,2324.338;Inherit;True;499;WindScroll;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3158.852,-383.9119;Inherit;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-3339.009,-403.1888;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-3590.028,-535.551;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;13;-3631.983,-337.7119;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;30;-3910.145,-1355.945;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;9;0;Create;True;0;0;0;False;0;False;1;7;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-3896.444,-1212.537;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;32;-3877.106,-1087.154;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-3622.704,-1296.577;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-3974.35,-970.622;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-3757.45,-967.0389;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-3531.083,-1016.336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2679.631,-1080.248;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;10;0;Create;True;0;0;0;False;0;False;0;0.494;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-2002.226,-1091.671;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-2230.345,-842.4246;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;39;-2432.469,-824.5485;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-2679.414,-952.7539;Inherit;False;Property;_LightGradientSize;Light Gradient Size;11;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-2231.784,-952.9869;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1977.955,-565.7338;Inherit;False;Property;_Steps;Steps;15;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;51;-1567.331,-631.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;52;-1565.302,-142.4816;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;53;-1211.038,-60.70807;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1371.736,-433.6453;Inherit;False;Property;_ShadowLevel;Shadow Level;17;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.GetLocalVarNode;535;906.0379,-98.87848;Inherit;True;534;Shine;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;1601.274,1212.116;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;1263.11,1177.807;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;151;1017.992,1388.278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;731.5048,1199.352;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;78;318.6324,1185.492;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;77;-46.35186,707.4709;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-118.4783,916.3269;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;526.994,1329.373;Inherit;False;129;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SummedBlendNode;23;-5594.403,2258.71;Inherit;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;586;-5973.82,113.4169;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;609;-6377.791,193.0247;Inherit;False;ctrlB;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;610;-6372.47,347.6327;Inherit;False;ctrlA;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;607;-6380.451,-78.83662;Inherit;False;ctrlR;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;608;-6373.469,55.79989;Inherit;False;ctrlG;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;222;-8233.59,-135.2394;Inherit;True;Property;_Control;Control;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;640;-5719.019,2702.073;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;616;-6482.692,1288.517;Inherit;False;grassDivNormal;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;647;-4734.073,2280.801;Inherit;True;Property;_DirtDivNoise1;Dirt Div Noise;38;0;Create;True;0;0;0;False;0;False;-1;None;3eda0c4754885564f9df920405499055;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;648;-5041.451,2275.439;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;644;-5047.504,2596.235;Inherit;False;Normal From Height;-1;;6;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;3;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;649;-6879.332,-429.0336;Inherit;False;Constant;_Float6;Float 6;42;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;574;-7246.271,-235.5714;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;591;-7103.273,-235.8469;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;592;-6957.034,-234.6192;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;594;-7300.751,-118.6134;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;595;-7148.765,-116.1472;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;596;-6988.176,-113.1253;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;598;-7351.328,-6.418812;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;599;-7191.987,-3.21062;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;600;-7031.396,-3.777104;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;593;-6607.136,-232.1945;Inherit;False;2;0;FLOAT;0.1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;597;-6642.487,-108.5327;Inherit;False;2;0;FLOAT;0.1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;601;-6667.441,26.47285;Inherit;False;2;0;FLOAT;0.1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;603;-7224.541,114.594;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;602;-7381.275,113.7868;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;604;-7068.364,121.8473;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;605;-6713.303,142.3843;Inherit;False;2;0;FLOAT;0.1;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;518;-9319.118,2910.921;Inherit;True;Property;_WindNoiseTex;Wind Noise Tex;26;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;497;-9233.977,3333.457;Inherit;True;Property;_TextureSample2;Texture Sample 0;24;0;Create;True;0;0;0;False;0;False;-1;None;5259d0042c9854375b96305b6256ecfd;True;0;True;bump;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-5613.275,418.3384;Inherit;False;Control;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.HeightMapBlendNode;645;-5404.042,2497.457;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;457;-6013.365,1309.722;Inherit;False;Constant;_Color0;Color 0;34;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.HeightMapBlendNode;456;-5866.293,1471.828;Inherit;False;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;461;-5701.763,1600.659;Inherit;False;Normal From Height;-1;;4;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;-150;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;400;-8480.656,-834.8011;Inherit;False;0;569;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;569;-8165,-822.5926;Inherit;True;Property;_GrassDivNoise;Grass Div Noise;37;0;Create;True;0;0;0;False;0;False;-1;None;737606a54d1820743b1a2b4b990b7465;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;351;-7826.854,-800.6799;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;464;-7817.149,-681.3535;Inherit;False;Property;_Float0;Float 0;22;0;Create;True;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;611;-7651.72,-801.0151;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;466;-7542.593,-663.778;Inherit;False;Property;_Float1;Float 1;24;0;Create;True;0;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;612;-7369.348,-781.3655;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;657;-7901.742,-419.4787;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;659;-7726.608,-419.8139;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;661;-7444.236,-400.1643;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;658;-7892.037,-300.1524;Inherit;False;Property;_float20;float20;23;0;Create;True;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;660;-7617.48,-282.577;Inherit;False;Property;_float21;float 21;25;0;Create;True;0;0;0;False;0;False;0;-0.25;0;0;0;1;FLOAT;0
WireConnection;89;0;88;0
WireConnection;89;1;80;0
WireConnection;89;2;86;0
WireConnection;89;3;127;0
WireConnection;89;4;128;0
WireConnection;129;0;89;0
WireConnection;0;2;535;0
WireConnection;0;13;97;0
WireConnection;0;11;165;0
WireConnection;21;1;154;0
WireConnection;21;5;163;0
WireConnection;22;1;155;0
WireConnection;22;5;164;0
WireConnection;19;1;152;0
WireConnection;19;5;161;0
WireConnection;126;0;1;0
WireConnection;1;0;247;0
WireConnection;1;1;3;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;1;4;7;0
WireConnection;25;0;23;0
WireConnection;459;0;461;40
WireConnection;459;1;19;0
WireConnection;20;1;547;0
WireConnection;20;5;162;0
WireConnection;498;0;519;0
WireConnection;499;0;516;0
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
WireConnection;554;0;153;0
WireConnection;554;1;555;0
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
WireConnection;23;0;124;0
WireConnection;23;1;459;0
WireConnection;23;2;20;0
WireConnection;23;3;21;0
WireConnection;23;4;640;0
WireConnection;586;0;607;0
WireConnection;586;1;608;0
WireConnection;586;2;609;0
WireConnection;586;3;610;0
WireConnection;609;0;601;0
WireConnection;610;0;605;0
WireConnection;607;0;593;0
WireConnection;608;0;597;0
WireConnection;640;0;644;40
WireConnection;640;1;22;0
WireConnection;616;0;612;0
WireConnection;647;1;648;0
WireConnection;644;20;645;0
WireConnection;574;0;222;1
WireConnection;574;1;612;0
WireConnection;591;0;574;0
WireConnection;591;1;222;3
WireConnection;592;0;591;0
WireConnection;592;1;222;4
WireConnection;594;0;612;0
WireConnection;594;1;593;0
WireConnection;595;0;594;0
WireConnection;595;1;222;3
WireConnection;596;0;595;0
WireConnection;596;1;222;4
WireConnection;598;0;222;3
WireConnection;598;1;597;0
WireConnection;599;0;598;0
WireConnection;599;1;593;0
WireConnection;600;0;599;0
WireConnection;600;1;222;4
WireConnection;593;0;649;0
WireConnection;593;1;592;0
WireConnection;597;0;649;0
WireConnection;597;1;596;0
WireConnection;601;0;649;0
WireConnection;601;1;600;0
WireConnection;603;0;602;0
WireConnection;603;1;601;0
WireConnection;602;0;222;4
WireConnection;602;1;597;0
WireConnection;604;0;603;0
WireConnection;604;1;593;0
WireConnection;605;0;649;0
WireConnection;605;1;604;0
WireConnection;518;1;504;0
WireConnection;497;1;512;0
WireConnection;122;0;586;0
WireConnection;645;0;647;0
WireConnection;645;1;661;0
WireConnection;456;0;457;0
WireConnection;456;1;616;0
WireConnection;461;20;456;0
WireConnection;569;1;400;0
WireConnection;351;0;222;2
WireConnection;351;1;569;0
WireConnection;611;0;464;0
WireConnection;611;1;351;0
WireConnection;612;0;611;0
WireConnection;612;1;466;0
WireConnection;657;0;222;2
WireConnection;657;1;569;0
WireConnection;659;0;658;0
WireConnection;659;1;657;0
WireConnection;661;0;659;0
WireConnection;661;1;660;0
ASEEND*/
//CHKSM=A34423F4A83DE00617C600B43F284CB6FED8F8D4