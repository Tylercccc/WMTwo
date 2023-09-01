// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_FOLIAGE_NEW9"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_ShadowColor1("Shadow Color", Color) = (0,0,0,0)
		_NormalMap("Normal Map", 2D) = "white" {}
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_RimPower("Rim Power", Float) = 5
		_RimScale("Rim Scale", Float) = 1
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		_Dither("Dither", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_Wind("Wind", Range( 0 , 10)) = 0
		_DisplacementSize("Displacement Size", Range( 0 , 6)) = 0
		_Timesteps("Time steps", Range( 0 , 69)) = 5
		_Freq("Freq", Float) = 0
		_WindNoiseScale("Wind Noise Scale", Float) = 0
		_windrotation("wind rotation", Vector) = (0,0,0,0)
		_BendDist("Bend Dist", Range( 0 , 20)) = 0
		_TimeScaleLeaves("TimeScale Leaves", Float) = 0
		_NormalTiling("Normal Tiling", Vector) = (0,0,0,0)
		_normalspeed("normal speed", Range( 0 , 1)) = 1
		_WindMulty("Wind Multy", Range( 0 , 6)) = 0
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0
		[Toggle]_useUVcoords("useUVcoords", Range( 0 , 1)) = 0
		_WorldFrequency("World Frequency", Range( 0 , 10)) = 0
		_DoesSomething("DoesSomething", Float) = 0
		_WindDirection("Wind Direction", Range( 0 , 360)) = 0
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
		uniform float _WorldFrequency;
		uniform float _DoesSomething;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Dither);
		float4 _Dither_TexelSize;
		SamplerState sampler_Dither;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_NormalMap);
		uniform float2 _NormalTiling;
		uniform float _useUVcoords;
		uniform float _TimeScaleLeaves;
		uniform float _Wind;
		uniform float _WindNoiseScale;
		uniform float _WindMulty;
		uniform float _DisplacementSize;
		uniform float3 _windrotation;
		uniform float _Freq;
		uniform float _Timesteps;
		uniform float _BendDist;
		uniform float _normalspeed;
		SamplerState sampler_NormalMap;
		uniform float _NormalScale;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _Steps;
		uniform float _ShadowLevel;
		uniform float4 _Color;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Albedo);
		uniform float4 _Albedo_ST;
		SamplerState sampler_Albedo;
		uniform float4 _ShadowColor1;


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_578_0 = ( ( ase_vertex3Pos.y * cos( ( ( ( ase_worldPos.x + ase_worldPos.z ) * _WorldFrequency ) + _Time.y ) ) ) * _DoesSomething );
			float4 appendResult580 = (float4(temp_output_578_0 , 0.0 , temp_output_578_0 , 0.0));
			float4 break584 = mul( appendResult580, unity_ObjectToWorld );
			float4 appendResult585 = (float4(break584.x , 1 , break584.z , 0.0));
			float3 rotatedValue587 = RotateAroundAxis( float3( 0,0,0 ), appendResult585.xyz, float3( 0,0,0 ), _WindDirection );
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
			float temp_output_459_0 = ( floor( ( _Time.y * _TimeScaleLeaves ) ) / _TimeScaleLeaves );
			float2 temp_cast_11 = (_Wind).xx;
			float2 panner358 = ( temp_output_459_0 * temp_cast_11 + ase_worldPos.xy);
			float simplePerlin2D357 = snoise( panner358*_WindNoiseScale );
			simplePerlin2D357 = simplePerlin2D357*0.5 + 0.5;
			float2 temp_cast_13 = (( _Wind * _WindMulty )).xx;
			float2 panner473 = ( temp_output_459_0 * temp_cast_13 + ase_worldPos.xy);
			float simplePerlin2D476 = snoise( panner473 );
			simplePerlin2D476 = simplePerlin2D476*0.5 + 0.5;
			float temp_output_350_0 = (ase_vertexNormal.y*( simplePerlin2D357 * simplePerlin2D476 ) + 0.0);
			float4 transform445 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 appendResult417 = (float4(( _windrotation.x + ( ( floor( ( ( sin( ( ( _Time.y * ( _Freq * frac( transform445 ) ) ) * 6.28318548202515 ) ) + float4( 0,0,0,0 ) ) * _Timesteps ) ) / _Timesteps ) * _BendDist ) ).x , _windrotation.y , _windrotation.z , 0.0));
			float4 temp_output_406_0 = ( ( temp_output_350_0 * _DisplacementSize ) * appendResult417 );
			float4 normals_moving408 = temp_output_406_0;
			float3 normal259 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, ( ( float4( _NormalTiling, 0.0 , 0.0 ) * lerpResult567 ) + ( normals_moving408 * _normalspeed ) ).xy ), _NormalScale );
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
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float dither275 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			dither275 = step( dither275, ( temp_output_181_0 * smoothstepResult205 ) );
			float temp_output_224_0 = ( 1.0 - ( ( floor( ( saturate( ( ( _PointLightAttenuationBoost * IsPointLight76 * ase_lightAtten ) * temp_output_192_0 ) ) * _Steps ) ) / _Steps ) + (( temp_output_181_0 >= 0.0 && temp_output_181_0 <= 1.0 ) ? dither275 :  temp_output_181_0 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode285 = SAMPLE_TEXTURE2D( _Albedo, sampler_Albedo, uv_Albedo );
			float4 temp_cast_17 = (temp_output_224_0).xxxx;
			float dither292 = DitherNoiseTex(ase_screenPosNorm, _Dither, sampler_Dither, _Dither_TexelSize);
			float cameraDepthFade293 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 5.0);
			float clampResult294 = clamp( cameraDepthFade293 , 1.0 , 20.0 );
			dither292 = step( dither292, ( clampResult294 * tex2DNode285 ).r );
			c.rgb = ( ( ( ( 1.0 - temp_output_224_0 ) * ase_lightColor ) * ( _Color * tex2DNode285 ) ) + ( ( min( temp_cast_17 , _ShadowColor1 ) * ( 1.0 - IsPointLight76 ) ) * dither292 ) ).rgb;
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
			float temp_output_459_0 = ( floor( ( _Time.y * _TimeScaleLeaves ) ) / _TimeScaleLeaves );
			float2 temp_cast_2 = (_Wind).xx;
			float2 panner358 = ( temp_output_459_0 * temp_cast_2 + ase_worldPos.xy);
			float simplePerlin2D357 = snoise( panner358*_WindNoiseScale );
			simplePerlin2D357 = simplePerlin2D357*0.5 + 0.5;
			float2 temp_cast_4 = (( _Wind * _WindMulty )).xx;
			float2 panner473 = ( temp_output_459_0 * temp_cast_4 + ase_worldPos.xy);
			float simplePerlin2D476 = snoise( panner473 );
			simplePerlin2D476 = simplePerlin2D476*0.5 + 0.5;
			float temp_output_350_0 = (ase_vertexNormal.y*( simplePerlin2D357 * simplePerlin2D476 ) + 0.0);
			float4 transform445 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 appendResult417 = (float4(( _windrotation.x + ( ( floor( ( ( sin( ( ( _Time.y * ( _Freq * frac( transform445 ) ) ) * 6.28318548202515 ) ) + float4( 0,0,0,0 ) ) * _Timesteps ) ) / _Timesteps ) * _BendDist ) ).x , _windrotation.y , _windrotation.z , 0.0));
			float4 temp_output_406_0 = ( ( temp_output_350_0 * _DisplacementSize ) * appendResult417 );
			float4 normals_moving408 = temp_output_406_0;
			float3 normal259 = UnpackScaleNormal( SAMPLE_TEXTURE2D( _NormalMap, sampler_NormalMap, ( ( float4( _NormalTiling, 0.0 , 0.0 ) * lerpResult567 ) + ( normals_moving408 * _normalspeed ) ).xy ), _NormalScale );
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
Node;AmplifyShaderEditor.CommentaryNode;536;-1827.159,-644.2699;Inherit;False;100;100; f;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-2675.733,-887.3652;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2885.612,-913.2354;Inherit;False;1379.942;546.2153;;12;198;199;78;171;181;180;179;178;77;172;201;307;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;3;118;114;112;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4290.296,-456.7152;Inherit;False;1025.107;587.7744;Basic lighting;4;5;7;6;131;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-4182.831,-376.0671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-4204.932,-118.6672;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;112;-3285.258,-2905.049;Inherit;False;Property;_RimPower;Rim Power;5;0;Create;True;0;0;0;False;0;False;5;1.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3314.258,-2999.049;Inherit;False;Property;_RimScale;Rim Scale;6;0;Create;True;0;0;0;False;0;False;1;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;8;206;211;209;207;208;205;186;38;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-3948.828,-272.0672;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3774.34,-227.2643;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;2;76;75;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;209;-3676.961,-1291.98;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3919.807,-1517.473;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;8;0;Create;True;0;0;0;False;0;False;0;0.641;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3471.961,-1306.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-3471.961,-1418.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;7;106;105;102;101;100;98;97;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-5113.211,-1705.717;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;4;0;Create;True;0;0;0;False;0;False;1;2.68;1;10;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.OneMinusNode;224;-1445.411,394.2598;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;251;-1221.036,384.5249;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;235;-988.4199,625.3221;Inherit;False;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-961.9585,928.7074;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;231;-1400.855,1302.276;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;88;-1673.704,416.2784;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;255;-673.2963,576.7527;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;230.1328,484.7082;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;106.1416,789.8001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;290;-271.8002,1213.358;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;285;-447.682,804.0729;Inherit;True;Property;_Albedo;Albedo;11;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;230;-1422.968,945.3193;Inherit;False;Property;_ShadowColor1;Shadow Color;2;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2970363,0.7075472,0.3076191,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-584.3527,1239.109;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;292;-456.4587,1557.525;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-250.9145,615.31;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.5019608,0.8196079,0.3058824,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-3537.574,-1617.438;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3910.961,-1389.98;Inherit;False;Property;_LightGradientSize;Light Gradient Size;9;0;Create;True;0;0;0;False;0;False;0;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;205;-3242.402,-1528.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-3810.594,-1602.487;Inherit;False;131;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-454.0071,446.9763;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2136.439,319.0111;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;275;-1999.236,-8.152191;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-2275.811,-192.2104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;280;-2405.055,4.84398;Inherit;True;Property;_Dither;Dither;10;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2392.995,-2603.417;Inherit;False;RimWrap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;344;321.7058,57.3531;Inherit;False;195;RimWrap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;448.3029,196.6428;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;346;709.5838,166.3893;Inherit;False;Property;_RimColor;Rim Color;12;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2659853,0.3301887,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;118;-3018.471,-2998.382;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;347;-2836.169,-2393.839;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;349;-2515.753,-2236.347;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;41.63611,1031.19;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;367;845.8458,2369.367;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;607.0334,2270.378;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;369;377.3895,2520.1;Inherit;False;Property;_Timesteps;Time steps;15;0;Create;True;0;0;0;False;0;False;5;10.5;0;69;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;396;-15.07534,1551.233;Inherit;False;Property;_WindNoiseScale;Wind Noise Scale;17;0;Create;True;0;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;377;418.4689,2273.193;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;368;1082.376,2297.281;Inherit;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;5;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;417;1507.233,1603.939;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;419;1307.337,2455.24;Inherit;False;Property;_BendDist;Bend Dist;20;0;Create;True;0;0;0;False;0;False;0;0.03;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;422;1567.963,2287.574;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;416;1342.478,1865.384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;425;1800.728,1851.358;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;359;-645.1862,2238.979;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;392;165.6788,2290.315;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TauNode;393;-200.375,2405.857;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;441;21.00043,2452.749;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FractNode;446;-408.4739,2891.403;Inherit;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;445;-709.9005,2615.709;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;1263.332,1230.721;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;423;1840.37,1633.169;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4626.501,-331.4977;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CameraDepthFade;293;-980.1703,1503.753;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;294;-644.3625,1517.31;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;404;988.6412,1519.986;Inherit;False;Property;_windrotation;wind rotation;18;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;424;1569.113,1911.9;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;453;897.5895,1171.258;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;360;1121.36,1365.361;Inherit;False;Property;_DisplacementSize;Displacement Size;14;0;Create;True;0;0;0;False;0;False;0;3.07;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;361;1086.4,1210.914;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;458;-283.4191,2190.793;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;459;-131.4075,2155.026;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;12;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;460;-813.7806,2044.721;Inherit;False;Property;_TimeScaleLeaves;TimeScale Leaves;21;0;Create;True;0;0;0;False;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;408;1300.192,800.864;Inherit;False;normals_moving;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;232;-1158.111,1238.667;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;414;-589.4601,1982.169;Inherit;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3378.499,-3616.521;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;463;-4893.103,658.4679;Inherit;False;Property;_normalspeed;normal speed;23;0;Create;True;0;0;0;False;0;False;1;0.219;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;379;46.97829,1280.855;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;350;585.4799,1341.862;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;358;-28.44758,1779.301;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;474;326.4888,2106.714;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;475;-0.8907113,2172.804;Inherit;False;Property;_WindMulty;Wind Multy;24;0;Create;True;0;0;0;False;0;False;0;3.39;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;357;291.9331,1580.444;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;478;-337.3943,1910.197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;-56.47223,2296.199;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;447;-308.9667,2520.135;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-494.8929,2467.843;Inherit;False;Property;_Freq;Freq;16;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-2734.457,-598.7814;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-2949.081,-1021.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-2947.052,-532.3419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;201;-2592.788,-450.5684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-2552.794,-599.8965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;204;-2253.978,-1040.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-2251.612,-1704.403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;200;-2132.371,-1192.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2753.487,-823.5073;Inherit;False;Property;_ShadowLevel;Shadow Level;7;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;77;-2733.782,-722.4692;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;125;-1849.533,-1316.652;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;180;-2025.505,-627.576;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-1670.139,-1317.281;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-2378.414,-629.7809;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;179;-2157.167,-625.356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1967.098,-884.5726;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;171;-2212.103,-853.4663;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-1733.54,-758.7867;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;124;-2023.048,-1319.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;192;-2676.004,-1496.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;193;-2442.655,-1699.488;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;279;-1469.441,-679.9645;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;468;-5054.526,130.7492;Inherit;False;Property;_NormalTiling;Normal Tiling;22;0;Create;True;0;0;0;False;0;False;0,0;0.2,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;461;-4998.527,521.6127;Inherit;False;408;normals_moving;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;462;-4746.507,525.1497;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;480;-4857.869,47.70409;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;451;271.758,974.9376;Inherit;False;Property;_Extrusion;Extrusion;19;0;Create;True;0;0;0;False;0;False;0,0,0;0.02,0.02,0.02;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;449;1550.933,940.0988;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;452;524.0986,1177.053;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;491;-2555.642,1847.22;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;492;-2213.058,1910.912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;494;-1880.448,1946.296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;495;-1691.142,1960.45;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;506;911.8527,941.948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;450;1015.333,891.0593;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;508;724.6541,929.4294;Inherit;False;Property;_tempscale;temp scale;28;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;510;716.8937,1072.997;Inherit;False;Property;_tempoffset;temp offset;29;0;Create;True;0;0;0;False;0;False;0,0,0;-0.99,-0.99,-0.99;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;378;-287.3267,1722.126;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;470;258.6342,1893.519;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;473;641.2123,1859.256;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;356;-284.8817,2031.764;Inherit;False;Property;_Wind;Wind;13;0;Create;True;0;0;0;False;0;False;0;1.4;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;476;942.6793,1881.425;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;477;980.0214,1724.775;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;511;-2849.506,2343.92;Inherit;False;Global;_BushPosition;_BushPosition;31;0;Create;True;0;0;0;False;0;False;0,0,0;-180.7849,41.23263,-227.6301;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-2194.91,2438.424;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;493;-2043.599,1963.127;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;504;-2879.56,1983.936;Inherit;False;Property;_bendoffset;bend offset;27;0;Create;True;0;0;0;False;0;False;0,0,0;4,4,4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;498;460.6099,950.4803;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1967.156,2093.445;Inherit;False;Property;_SphereHardness;SphereHardness;26;0;Create;True;0;0;0;False;0;False;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;539;475.3582,566.2552;Inherit;False;Constant;_Float1;Float 1;32;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-1273.332,1967.178;Inherit;True;sphereMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;481;-4721.981,276.4821;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;465;-4581.456,398.1558;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4038.939,639.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-1023.29,-319.2087;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-701.2247,1717.931;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;559;-4823.771,754.1529;Inherit;False;Property;_NormalScale;Normal Scale;30;0;Create;True;0;0;0;False;0;False;0;0.212;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;561;-2409.31,2279.106;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;512;-2615.95,2361.441;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalVertexDataNode;505;-3441.527,1634.829;Inherit;True;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;489;-2476.925,2109.827;Inherit;False;Property;_SphereRadius;SphereRadius;25;0;Create;True;0;0;0;False;0;False;0;3.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;565;-2202.353,2085.013;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ObjectScaleNode;564;-2455.667,2210.402;Inherit;False;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCRemapNode;524;-3114.331,1948.636;Inherit;False;5;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;2;FLOAT3;1,1,1;False;3;FLOAT3;-0.5,-0.5,-0.5;False;4;FLOAT3;1,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;479;-5322.096,-85.7949;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;566;-5121.532,-187.5374;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;567;-4795,-142.6018;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;568;-5142.502,-18.27999;Inherit;False;Property;_useUVcoords;useUVcoords;31;1;[Toggle];Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1786.998,176.3287;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_FOLIAGE_NEW9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.WorldPosInputsNode;569;2404.757,542.3398;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;570;2647.867,593.9823;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;571;2823.032,697.6056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;572;2482.032,745.6056;Inherit;False;Property;_WorldFrequency;World Frequency;32;0;Create;True;0;0;0;False;0;False;0;0.3;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;3012.032,772.6056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;574;2709.032,887.6056;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CosOpNode;575;3088.032,927.6056;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;576;3288.032,902.6056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;577;3128.032,642.6056;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;578;3449.032,937.6056;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;579;3302.032,1122.606;Inherit;False;Property;_DoesSomething;DoesSomething;33;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;580;3617.032,904.6056;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;581;3633.032,1139.606;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;3829.032,938.6056;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;584;4008.032,950.6056;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;585;4230.032,899.6056;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;586;3992.032,751.6056;Inherit;False;Constant;_Vector0;Vector 0;34;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotateAboutAxisNode;587;4391.032,1021.606;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;588;4126.032,1153.606;Inherit;False;Property;_WindDirection;Wind Direction;34;0;Create;True;0;0;0;False;0;False;0;206;0;360;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;589;4838.162,1011.232;Inherit;False;NewWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;507;1499.705,564.6031;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;1500.953,688.7339;Inherit;False;589;NewWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;261;-4519.871,616.6649;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;0;False;0;False;-1;None;bd4806d82731a422ea0b106e0524d364;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
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
WireConnection;292;0;291;0
WireConnection;292;1;296;0
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
WireConnection;257;0;3;0
WireConnection;257;1;290;0
WireConnection;367;0;370;0
WireConnection;370;0;377;0
WireConnection;370;1;369;0
WireConnection;377;0;392;0
WireConnection;368;0;367;0
WireConnection;368;1;369;0
WireConnection;417;0;416;0
WireConnection;417;1;404;2
WireConnection;417;2;404;3
WireConnection;422;0;368;0
WireConnection;422;1;419;0
WireConnection;416;0;404;1
WireConnection;416;1;422;0
WireConnection;425;0;424;2
WireConnection;392;0;441;0
WireConnection;441;0;395;0
WireConnection;441;1;393;0
WireConnection;446;0;445;0
WireConnection;406;0;361;0
WireConnection;406;1;417;0
WireConnection;423;0;417;0
WireConnection;423;1;425;0
WireConnection;294;0;293;0
WireConnection;453;0;451;0
WireConnection;453;1;452;0
WireConnection;453;2;350;0
WireConnection;361;0;350;0
WireConnection;361;1;360;0
WireConnection;458;0;478;0
WireConnection;459;0;458;0
WireConnection;459;1;460;0
WireConnection;408;0;406;0
WireConnection;232;0;231;0
WireConnection;350;0;379;2
WireConnection;350;1;477;0
WireConnection;358;0;378;0
WireConnection;358;2;356;0
WireConnection;358;1;459;0
WireConnection;474;0;356;0
WireConnection;474;1;475;0
WireConnection;357;0;358;0
WireConnection;357;1;396;0
WireConnection;478;0;414;0
WireConnection;478;1;460;0
WireConnection;395;0;359;0
WireConnection;395;1;447;0
WireConnection;447;0;394;0
WireConnection;447;1;446;0
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
WireConnection;462;0;461;0
WireConnection;462;1;463;0
WireConnection;480;0;479;1
WireConnection;480;1;479;3
WireConnection;449;0;423;0
WireConnection;449;1;406;0
WireConnection;491;0;505;0
WireConnection;491;1;517;0
WireConnection;492;0;491;0
WireConnection;492;1;565;0
WireConnection;494;0;493;0
WireConnection;495;0;494;0
WireConnection;495;1;490;0
WireConnection;506;0;498;0
WireConnection;506;1;453;0
WireConnection;450;0;506;0
WireConnection;450;1;449;0
WireConnection;473;0;470;0
WireConnection;473;2;474;0
WireConnection;473;1;459;0
WireConnection;476;0;473;0
WireConnection;477;0;357;0
WireConnection;477;1;476;0
WireConnection;517;0;512;0
WireConnection;517;1;504;0
WireConnection;493;0;492;0
WireConnection;493;1;492;0
WireConnection;496;0;495;0
WireConnection;481;0;468;0
WireConnection;481;1;567;0
WireConnection;465;0;481;0
WireConnection;465;1;462;0
WireConnection;259;0;261;0
WireConnection;175;0;126;0
WireConnection;175;1;279;0
WireConnection;561;0;512;0
WireConnection;512;0;511;0
WireConnection;565;0;489;0
WireConnection;565;1;564;0
WireConnection;524;0;505;0
WireConnection;567;0;480;0
WireConnection;567;1;566;0
WireConnection;567;2;568;0
WireConnection;0;2;345;0
WireConnection;0;13;257;0
WireConnection;0;11;590;0
WireConnection;570;0;569;1
WireConnection;570;1;569;3
WireConnection;571;0;570;0
WireConnection;571;1;572;0
WireConnection;573;0;571;0
WireConnection;573;1;574;2
WireConnection;575;0;573;0
WireConnection;576;0;577;2
WireConnection;576;1;575;0
WireConnection;578;0;576;0
WireConnection;578;1;579;0
WireConnection;580;0;578;0
WireConnection;580;2;578;0
WireConnection;582;0;580;0
WireConnection;582;1;581;0
WireConnection;584;0;582;0
WireConnection;585;0;584;0
WireConnection;585;1;586;2
WireConnection;585;2;584;2
WireConnection;587;1;588;0
WireConnection;587;3;585;0
WireConnection;589;0;587;0
WireConnection;507;0;450;0
WireConnection;507;1;508;0
WireConnection;507;2;510;0
WireConnection;261;1;465;0
WireConnection;261;5;559;0
ASEEND*/
//CHKSM=E7B087479BC61A71C44036963742CC73801F4790