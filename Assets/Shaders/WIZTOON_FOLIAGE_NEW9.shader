// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_FOLIAGE_NEW9"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Color("Color", Color) = (1,1,1,0)
		[IntRange]_Steps("Steps", Range( 1 , 10)) = 5
		_ShadowColor1("Shadow Color", Color) = (0,0,0,0)
		_PointLightAttenuationBoost("PointLight Attenuation Boost", Range( 1 , 10)) = 1
		_RimPower("Rim Power", Float) = 5
		_LeafPower("LeafPower", Float) = 5
		_LeafScale("LeafScale", Float) = 1
		_RimScale("Rim Scale", Float) = 1
		_ShadowLevel("Shadow Level", Range( 0 , 1)) = 0.5
		_LightGradientMidLevel("Light Gradient MidLevel", Range( 0 , 1)) = 0
		_LightGradientSize("Light Gradient Size", Range( 0 , 1)) = 0
		_Dither("Dither", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_SphereHardness("SphereHardness", Float) = 0
		_bendoffset("bend offset", Vector) = (0,0,0,0)
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
		_Normal("Normal", 2D) = "bump" {}
		_dasvcxvef("dasvcxvef", Float) = 0
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_xDeform("xDeform", Float) = 0
		_yDeform("yDeform", Float) = 0
		_zDeform("zDeform", Float) = 0
		_bushdimensions("bush dimensions", Vector) = (0,0,0,0)
		_textureScale("textureScale", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 screenPosition;
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
		uniform float2 _secondaryspeed;
		uniform float _SecondaryFrequency;
		uniform float _BendAmt;
		uniform float3 _Squash;
		uniform float3 _BushPosition;
		uniform float3 _bendoffset;
		uniform float3 _bushdimensions;
		uniform float _SphereHardness;
		uniform float _xDeform;
		uniform float _yDeform;
		uniform float _zDeform;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float _NormalScale;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _NoiseTex;
		uniform float2 _textureScale;
		uniform float _dasvcxvef;
		uniform float4 _RimColor;
		uniform float _LeafScale;
		uniform float _LeafPower;
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		uniform float _Steps;
		uniform float _ShadowLevel;
		uniform sampler2D _Dither;
		float4 _Dither_TexelSize;
		uniform float4 _Color;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _ShadowColor1;
		uniform float _Cutoff = 0.5;


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


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
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


		inline float3 TriplanarSampling958( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2D( topTexMap, tiling * worldPos.zy * float2(  nsign.x, 1.0 ) );
			yNorm = tex2D( topTexMap, tiling * worldPos.xz * float2(  nsign.y, 1.0 ) );
			zNorm = tex2D( topTexMap, tiling * worldPos.xy * float2( -nsign.z, 1.0 ) );
			xNorm.xyz  = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2(  nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz  = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2(  nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz  = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float DitherNoiseTex( float4 screenPos, sampler2D noiseTexture, float4 noiseTexelSize )
		{
			float dither = tex2Dlod( noiseTexture, float4(screenPos.xy * _ScreenParams.xy * noiseTexelSize.xy, 0, 0) ).g;
			float ditherRate = noiseTexelSize.x * noiseTexelSize.y;
			dither = ( 1 - ditherRate ) * dither + ditherRate;
			return dither;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float smoothstepResult599 = smoothstep( 0.0 , _BottomGradientSize , ( _GradientHeight - ( 1.0 - ase_worldNormal.y ) ));
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_648_0 = ( floor( ( _timespeed * _Time.y ) ) / _bushtimesteps );
			float2 panner618 = ( temp_output_648_0 * _secondaryspeed + ase_worldNormal.xy);
			float simplePerlin2D616 = snoise( panner618*_SecondaryFrequency );
			simplePerlin2D616 = simplePerlin2D616*0.5 + 0.5;
			float clampResult631 = clamp( simplePerlin2D616 , 0.5 , 1.0 );
			float temp_output_578_0 = ( ( ( ase_worldNormal.y * cos( ( ( ( ase_worldPos.x + ase_worldPos.z ) * _WorldFrequency ) + temp_output_648_0 ) ) ) * clampResult631 ) * _BendAmt );
			float4 appendResult580 = (float4(temp_output_578_0 , 0.0 , temp_output_578_0 , 0.0));
			float4 break584 = appendResult580;
			float4 appendResult585 = (float4(break584.x , 0 , break584.z , 0.0));
			float3 worldToObjDir1059 = ASESafeNormalize( mul( unity_WorldToObject, float4( ( smoothstepResult599 * appendResult585 ).xyz, 0 ) ).xyz );
			float3 worldToObjDir1072 = mul( unity_WorldToObject, float4( (ase_worldNormal*_Squash + 0.0), 0 ) ).xyz;
			float3 worldToObj1060 = mul( unity_WorldToObject, float4( ase_worldPos, 1 ) ).xyz;
			float3 worldToObj512 = mul( unity_WorldToObject, float4( _BushPosition, 1 ) ).xyz;
			float3 ase_parentObjectScale = (1.0/float3( length( unity_WorldToObject[ 0 ].xyz ), length( unity_WorldToObject[ 1 ].xyz ), length( unity_WorldToObject[ 2 ].xyz ) ));
			float3 temp_output_492_0 = ( ( worldToObj1060 - ( worldToObj512 * _bendoffset ) ) / ( _bushdimensions / ase_parentObjectScale ) );
			float dotResult493 = dot( temp_output_492_0 , temp_output_492_0 );
			float saferPower495 = abs( saturate( dotResult493 ) );
			float temp_output_495_0 = pow( saferPower495 , _SphereHardness );
			float sphereMask496 = temp_output_495_0;
			float4 appendResult1047 = (float4(( ase_worldNormal.x * _xDeform ) , ( ase_worldNormal.y * _yDeform ) , ( ase_worldNormal.z * _zDeform ) , 0.0));
			float3 worldToObjDir1064 = mul( unity_WorldToObject, float4( ( ( 1.0 - sphereMask496 ) * appendResult1047 ).xyz, 0 ) ).xyz;
			float3 rotatedValue587 = RotateAroundAxis( float3( 0,0,0 ), ( ( worldToObjDir1059 + worldToObjDir1072 ) - worldToObjDir1064 ), float3( 0,0,0 ), _WindDirection );
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV712 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode712 = ( 0.01 + _LeafScale * pow( 1.0 - fresnelNdotV712, _LeafPower ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos930 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 computeScreenPos931 = ComputeScreenPos( unityObjectToClipPos930 );
			float4 unityObjectToClipPos939 = UnityObjectToClipPos( float3(0,0,0) );
			float4 computeScreenPos940 = ComputeScreenPos( unityObjectToClipPos939 );
			float4 transform945 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 newNoiseScale948 = ( ( ( ( computeScreenPos931 / (computeScreenPos931).w ) * float4( _textureScale, 0.0 , 0.0 ) ) - ( ( computeScreenPos940 / (computeScreenPos940).w ) * float4( _textureScale, 0.0 , 0.0 ) ) ) * distance( ( float4( _WorldSpaceCameraPos , 0.0 ) - transform945 ) , float4( 0,0,0,0 ) ) );
			float4 tex2DNode855 = tex2D( _NoiseTex, newNoiseScale948.xy );
			float4 temp_output_717_0 = ( fresnelNode712 * tex2DNode855 );
			float4 LeafOpacity713 = temp_output_717_0;
			float4 temp_output_833_0 = ( 1.0 - LeafOpacity713 );
			float IsPointLight76 = _WorldSpaceLightPos0.w;
			float temp_output_209_0 = ( _LightGradientSize * 0.5 );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar958 = TriplanarSampling958( _Normal, ase_worldPos, ase_worldNormal, 1.0, uv_Normal, _NormalScale, 0 );
			float3 tanTriplanarNormal958 = mul( ase_worldToTangent, triplanar958 );
			float3 normal259 = tanTriplanarNormal958;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5 = dot( (WorldNormalVector( i , normal259 )) , ase_worldlightDir );
			float NdotL131 = dotResult5;
			float smoothstepResult205 = smoothstep( ( _LightGradientMidLevel - temp_output_209_0 ) , ( _LightGradientMidLevel + temp_output_209_0 ) , (NdotL131*0.5 + 0.5));
			float temp_output_192_0 = ( 0.0 + smoothstepResult205 );
			float temp_output_106_0 = ( ase_lightAtten * ( 1.0 - IsPointLight76 ) );
			float temp_output_181_0 = ( ( temp_output_106_0 * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( temp_output_192_0 * _Steps * ( 1.0 - IsPointLight76 ) ) ) / _Steps ) );
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float dither275 = DitherNoiseTex(ase_screenPosNorm, _Dither, _Dither_TexelSize);
			dither275 = step( dither275, ( temp_output_181_0 * smoothstepResult205 ) );
			float temp_output_224_0 = ( 1.0 - ( ( floor( ( saturate( ( ( _PointLightAttenuationBoost * IsPointLight76 * ase_lightAtten ) * temp_output_192_0 ) ) * _Steps ) ) / _Steps ) + (( temp_output_181_0 >= 0.0 && temp_output_181_0 <= 1.0 ) ? dither275 :  temp_output_181_0 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode285 = tex2D( _Albedo, uv_Albedo );
			float4 temp_cast_10 = (temp_output_224_0).xxxx;
			float dither292 = DitherNoiseTex(ase_screenPosNorm, _Dither, _Dither_TexelSize);
			float cameraDepthFade293 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 5.0);
			float clampResult294 = clamp( cameraDepthFade293 , 1.0 , 20.0 );
			dither292 = step( dither292, ( clampResult294 * tex2DNode285 ).r );
			float4 temp_output_257_0 = ( ( ( ( 1.0 - temp_output_224_0 ) * ase_lightColor ) * ( _Color * tex2DNode285 ) ) + ( ( min( temp_cast_10 , _ShadowColor1 ) * ( 1.0 - IsPointLight76 ) ) * dither292 ) );
			c.rgb = temp_output_257_0.rgb;
			c.a = 1;
			clip( temp_output_833_0.r - _Cutoff );
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar958 = TriplanarSampling958( _Normal, ase_worldPos, ase_worldNormal, 1.0, uv_Normal, _NormalScale, 0 );
			float3 tanTriplanarNormal958 = mul( ase_worldToTangent, triplanar958 );
			float3 normal259 = tanTriplanarNormal958;
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float fresnelNdotV118 = dot( mul(ase_tangentToWorldFast,normal259), ase_worldViewDir );
			float fresnelNode118 = ( 0.0 + _RimScale * pow( 1.0 - fresnelNdotV118, _RimPower ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos930 = UnityObjectToClipPos( ase_vertex3Pos );
			float4 computeScreenPos931 = ComputeScreenPos( unityObjectToClipPos930 );
			float4 unityObjectToClipPos939 = UnityObjectToClipPos( float3(0,0,0) );
			float4 computeScreenPos940 = ComputeScreenPos( unityObjectToClipPos939 );
			float4 transform945 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 newNoiseScale948 = ( ( ( ( computeScreenPos931 / (computeScreenPos931).w ) * float4( _textureScale, 0.0 , 0.0 ) ) - ( ( computeScreenPos940 / (computeScreenPos940).w ) * float4( _textureScale, 0.0 , 0.0 ) ) ) * distance( ( float4( _WorldSpaceCameraPos , 0.0 ) - transform945 ) , float4( 0,0,0,0 ) ) );
			float4 tex2DNode855 = tex2D( _NoiseTex, newNoiseScale948.xy );
			float4 RimWrap195 = ( floor( ( ( fresnelNode118 * tex2DNode855 ) * _dasvcxvef ) ) / _dasvcxvef );
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
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;673;4478.147,832.4617;Inherit;False;465.3599;241.5649;????;0;LOOK AT THIS TMRW (STOP WIND BASED ON PLAYER POSITION MASK?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;651;2561.192,-15.60339;Inherit;False;4194.815;1508.157;Comment;50;569;570;571;572;573;575;579;581;582;584;586;585;599;597;604;588;576;577;580;606;618;628;616;631;603;622;578;587;640;639;642;643;574;645;646;647;648;649;668;672;673;970;1041;1042;980;1043;1046;1056;1059;1072;WIND;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;650;-2969.379,1797.22;Inherit;False;1751.468;747.2209;Comment;15;491;492;494;495;493;490;489;565;564;517;512;504;496;1061;1071;Player Deform Bush;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;536;-1827.159,-644.2699;Inherit;False;100;100; f;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;307;-2675.733,-887.3652;Inherit;False;100;100; ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-2885.612,-913.2354;Inherit;False;1379.942;546.2153;;12;198;199;78;171;181;180;179;178;77;172;201;307;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;92;-3547.607,-3049.049;Inherit;False;1067.878;672.6326;;4;118;114;112;815;Rim Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4290.296,-456.7152;Inherit;False;1025.107;587.7744;Basic lighting;4;5;7;6;131;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;6;-4182.831,-376.0671;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-4204.932,-118.6672;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;212;-3969.807,-1667.438;Inherit;False;927.405;493.4576;;8;206;211;209;207;208;205;186;38;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-3948.828,-272.0672;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3774.34,-227.2643;Inherit;False;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3030.111,826.9662;Inherit;False;528.8752;183;;2;76;75;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleNode;209;-3676.961,-1291.98;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;211;-3919.807,-1517.473;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;10;0;Create;True;0;0;0;False;0;False;0;0.641;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;208;-3471.961,-1306.98;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;207;-3471.961,-1418.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;-5187.416,-1755.717;Inherit;False;936.9688;707.0591;;7;106;105;102;101;100;98;97;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-5113.211,-1705.717;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;4;0;Create;True;0;0;0;False;0;False;1;10;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-5099.51,-1562.309;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-3359.705,-955.5967;Inherit;False;Property;_Steps;Steps;2;1;[IntRange];Create;True;0;0;0;False;0;False;5;3;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;100;-5080.172,-1436.925;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-4825.77,-1646.348;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-5177.416,-1320.394;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;94;-2443.691,-1389.961;Inherit;False;888.2502;342.3433;;4;126;125;124;200;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;98;-4960.516,-1316.811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-4734.148,-1366.108;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-1768.84,307.8115;Inherit;False;932.1631;425.7859;Directional Light Only;4;224;251;88;235;Shadow Colour;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;35;-19.37829,440.4236;Inherit;False;464.8;298.7;Material Color;1;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;1;259;Normals;1,1,1,1;0;0
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
Node;AmplifyShaderEditor.SamplerNode;285;-447.682,804.0729;Inherit;True;Property;_Albedo;Albedo;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;230;-1422.968,945.3193;Inherit;False;Property;_ShadowColor1;Shadow Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4509804,0.6078432,0.4901961,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;291;-584.3527,1239.109;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-250.9145,615.31;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.4588235,0.7176471,0.5176471,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;38;-3537.574,-1617.438;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-3910.961,-1389.98;Inherit;False;Property;_LightGradientSize;Light Gradient Size;11;0;Create;True;0;0;0;False;0;False;0;0.31;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;205;-3242.402,-1528.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;186;-3810.594,-1602.487;Inherit;False;131;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-454.0071,446.9763;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;295;-2136.439,319.0111;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;283;-2275.811,-192.2104;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;280;-2405.055,4.84398;Inherit;True;Property;_Dither;Dither;12;0;Create;True;0;0;0;False;0;False;None;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;262;-4626.501,-331.4977;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CameraDepthFade;293;-980.1703,1503.753;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;294;-644.3625,1517.31;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;232;-1158.111,1238.667;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;199;-2734.457,-598.7814;Inherit;False;76;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;203;-2949.081,-1021.271;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;202;-2947.052,-532.3419;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;201;-2592.788,-450.5684;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;198;-2552.794,-599.8965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;204;-2253.978,-1040.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-2251.612,-1704.403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;200;-2132.371,-1192.872;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2753.487,-823.5073;Inherit;False;Property;_ShadowLevel;Shadow Level;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-1023.29,-319.2087;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;296;-701.2247,1717.931;Inherit;False;295;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DitheringNode;292;-331.2404,1517.277;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;491;-2555.642,1847.22;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;492;-2213.058,1910.912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;504;-2858.104,2131.062;Inherit;False;Property;_bendoffset;bend offset;17;0;Create;True;0;0;0;False;0;False;0,0,0;4,4,4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;569;3247.576,193.36;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;570;3490.686,245.0024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;571;3665.851,348.6257;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;572;3324.851,396.6256;Inherit;False;Property;_WorldFrequency;World Frequency;18;0;Create;True;0;0;0;False;0;False;0;0.458;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;575;3930.851,578.6256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;584;5701.877,427.4518;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector3Node;586;5685.877,228.4519;Inherit;False;Constant;_Vector0;Vector 0;34;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;585;5923.877,378.7389;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;588;5819.877,630.4504;Inherit;False;Property;_WindDirection;Wind Direction;20;0;Create;True;0;0;0;False;0;False;0;1.41;0;6.21;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;606;3340.433,818.4102;Inherit;False;Property;_SecondaryFrequency;Secondary Frequency;23;0;Create;True;0;0;0;False;0;False;0;9.47;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;616;4122.788,1206.497;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;631;4812.732,1168.196;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;578;5179.776,410.576;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;574;2699.238,497.4879;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;645;2806.863,730.3485;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;646;2611.192,726.3142;Inherit;False;Property;_timespeed;time speed;25;0;Create;True;0;0;0;False;0;False;0;8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;647;2996.483,724.2972;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;648;3133.655,728.3315;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;649;2783.494,882.8047;Inherit;False;Property;_bushtimesteps;bush time steps;26;0;Create;True;0;0;0;False;0;False;0;9.2;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;517;-2265.027,2364.993;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;257;855.7325,700.2125;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;670;-4831.604,795.7223;Inherit;False;Property;_NormalScale;Normal Scale;28;0;Create;True;0;0;0;False;0;False;0;0.245;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;628;5243,756.3207;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;580;5385.563,381.4518;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DitheringNode;275;-1999.236,-8.152191;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;118;-3018.471,-2998.382;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4038.939,639.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1967.156,2093.445;Inherit;False;Property;_SphereHardness;SphereHardness;16;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;815;-2644.285,-2963.277;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;817;-2687.66,-2172.358;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;818;-2856.579,-2176.986;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;819;-3037.068,-2128.393;Inherit;False;Property;_dasvcxvef;dasvcxvef;30;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;820;-2523.368,-2179.3;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-3389.618,-2999.049;Inherit;False;Property;_RimScale;Rim Scale;8;0;Create;True;0;0;0;False;0;False;1;8.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-3493.607,-2905.049;Inherit;False;Property;_RimPower;Rim Power;5;0;Create;True;0;0;0;False;0;False;5;4.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;469;-3566.9,-3206.471;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;854;-1108.565,-1507.932;Inherit;True;Property;_NoiseTex;Noise Tex;31;0;Create;True;0;0;0;False;0;False;None;3eda0c4754885564f9df920405499055;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PosVertexDataNode;929;6411.323,-1385.676;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;930;6642.164,-1379.653;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;931;6883.8,-1378.513;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;932;7298.46,-1377.144;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;933;7078.131,-1260.82;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;934;7469.525,-1337.458;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;935;7305.305,-1087.017;Inherit;False;Property;_TexScale;Tex Scale;32;0;Create;True;0;0;0;False;0;False;0;1.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;936;7658.382,-1270.399;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;937;7792.498,-1166.391;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;939;6636.9,-1014.627;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComputeScreenPosHlpNode;940;6881.864,-1005.047;Inherit;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;941;7054.299,-864.0889;Inherit;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;942;7291.054,-980.4138;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;943;7477.829,-961.6801;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;944;6744.111,-687.3852;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;945;6760.702,-445.6514;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;946;7078.272,-630.5065;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DistanceOpNode;947;7336.598,-663.6858;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;938;6390.223,-1009.764;Inherit;False;Constant;_Vector4;Vector 4;48;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexturePropertyNode;679;-5213.146,687.7877;Inherit;True;Property;_Normal;Normal;29;0;Create;True;0;0;0;False;0;False;None;3a2858a83a7314e4fba23919a78dfc80;True;bump;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;961;-4733.408,1138.107;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;958;-4523.305,911.4661;Inherit;True;Spherical;World;True;Top Texture 0;_TopTexture0;white;-1;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;346;784.4771,396.6868;Inherit;False;Property;_RimColor;Rim Color;14;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0.0754717,0.02945238,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;344;321.7058,57.3531;Inherit;False;195;RimWrap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;195;-2392.995,-2603.417;Inherit;False;RimWrap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1016;1616.108,687.2475;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;1293.145,717.5705;Inherit;False;589;NewWind;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;1036;1931.092,976.4218;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1037;2156.281,1003.642;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1038;2339.401,1028.388;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;668;6417.009,954.6628;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;573;3816.137,423.6256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1041;3902.87,140.9554;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;618;3477.343,1179.642;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;1042;3084.49,1025.19;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;980;6616.278,852.6344;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;948;8163.672,-1087.319;Inherit;False;newNoiseScale;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;579;4941.864,507.9565;Inherit;False;Property;_BendAmt;Bend Amt;19;0;Create;True;0;0;0;False;0;False;0;3.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;577;3878.311,340.1434;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;672;4478.343,854.4024;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;581;5326.877,616.4504;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;1043;5445.58,749.3928;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;643;5579.89,1073.396;Inherit;False;Constant;_Vector1;Vector 1;39;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;642;5861.285,952.5356;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;639;5559.151,828.0914;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;640;5998.547,830.3385;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;999;6269.926,1561.7;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;622;3250.682,1331.554;Inherit;False;Property;_secondaryspeed;secondary speed;24;0;Create;True;0;0;0;False;0;False;1,1;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.NormalVertexDataNode;664;4868.971,1467.572;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;653;5211.901,1479.288;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;1,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;970;5584.43,1471.636;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;667;4993.994,1675.785;Inherit;False;Property;_Squash;Squash;27;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1023;-3022.487,1413.026;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1045;-2676.59,1491.787;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1044;-2467.893,1485.936;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldNormalVector;1046;4916.613,1315.323;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;1013;5547.535,1838.555;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;1047;5959.91,1820.744;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1050;5839.554,1732.375;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1051;5640.554,1766.375;Inherit;False;Property;_xDeform;xDeform;33;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1049;5656.054,2004.875;Inherit;False;Property;_yDeform;yDeform;34;0;Create;True;0;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1048;5817.054,1887.875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1053;5869.554,2065.375;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1052;5708.554,2182.375;Inherit;False;Property;_zDeform;zDeform;35;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;5553.261,509.3618;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TransformDirectionNode;1056;6074.284,1094.706;Inherit;False;World;Object;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;576;4130.671,509.2471;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;599;5700.426,-59.03848;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;597;5473.9,-49.64149;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;604;5309.876,0.3685417;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;598;5198.35,-153.5821;Inherit;False;Property;_GradientHeight;Gradient Height;22;0;Create;True;0;0;0;False;0;False;0;1;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;596;5441.559,-293.2969;Inherit;False;Property;_BottomGradientSize;Bottom Gradient Size;21;0;Create;True;0;0;0;False;0;False;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;603;6122.856,191.1074;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectScaleNode;564;-2568.549,2113.625;Inherit;False;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;565;-2332.306,2049.313;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;494;-1880.448,1952.008;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;495;-1695.426,1970.447;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1061;-1581.329,1802.067;Inherit;False;World;Object;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;-1367.471,1961.048;Inherit;True;sphereMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;587;6726.557,585.8563;Inherit;False;False;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;994;6061.407,1508.648;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1059;6460.111,325.556;Inherit;False;World;Object;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;589;7079.586,520.806;Inherit;False;NewWind;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1030;1418.818,637.1389;Inherit;False;496;sphereMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1065;-3097.525,1706.616;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;1060;-2813.15,1652.203;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;512;-2602.95,2360.441;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;511;-3149.308,2226.189;Inherit;False;Global;_BushPosition;_BushPosition;31;0;Create;True;0;0;0;False;0;False;0,0,0;-199.1005,92.58701,-470.0052;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;489;-2582.796,2021.731;Inherit;False;Property;_SphereRadius;SphereRadius;15;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;493;-2042.171,1926.463;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1071;-2762.072,1980.174;Inherit;False;Property;_bushdimensions;bush dimensions;36;0;Create;True;0;0;0;False;0;False;0,0,0;4,12,4;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;1064;6601.775,1481.342;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformDirectionNode;1072;5593.633,1348.443;Inherit;False;World;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;1077;-4667.042,-783.4382;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1081;664.9589,1502.145;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;1523.77,207.3025;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1086;968.3287,1433.158;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;1085;1398.329,1627.158;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceViewDirHlpNode;1084;859.3286,1601.158;Inherit;False;1;0;FLOAT4;0,0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1088;958.3286,1800.158;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1087;1225.329,1476.158;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;1083;1071.131,1681.432;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;1089;47.26105,1526.741;Inherit;False;Global;_ShadowCoord;_ShadowCoord;38;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;1090;274.8521,1343.484;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1091;413.6727,1569.441;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1093;552.7627,1769.535;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;1094;628.7148,1949.146;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1096;1328.948,973.3856;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1097;1336.141,869.0892;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1098;607.8652,1181.978;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;1076;1540.783,1125.493;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CustomExpressionNode;1080;1426.734,1385.797;Inherit;False;GetSunShadowsAttenuation(worldPositions, screenDepth)@;1;Create;2;True;worldPositions;FLOAT;0;In;;Inherit;False;True;screenDepth;FLOAT;0;In;;Inherit;False;Shadows;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1075;1003.191,1060.333;Inherit;True;Global;_ShadowMapTexture;_ShadowMapTexture;37;0;Fetch;True;0;0;0;False;0;False;1075;None;;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;713;213.2955,-2487.712;Inherit;False;LeafOpacity;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;855;-884.0026,-2186.087;Inherit;True;Property;_TextureSample0;Texture Sample 0;43;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;950;-1128.445,-2172.915;Inherit;False;948;newNoiseScale;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClipNode;1100;-377.9394,-2516.457;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1070;1869.098,770.5123;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1012;2043.047,600.5444;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1104;1162.794,400.968;Inherit;False;Constant;_Float1;Float 1;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1105;1344.07,481.4166;Inherit;False;Constant;_Float2;Float 2;38;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;1107;1763.908,561.7464;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;711;-1238.886,-2481.718;Inherit;False;Property;_LeafScale;LeafScale;7;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;710;-1252.049,-2353.139;Inherit;False;Property;_LeafPower;LeafPower;6;0;Create;True;0;0;0;False;0;False;5;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1109;-799.9592,-2402.478;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;1108;-591.3114,-2499.752;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1111;-864.8089,-2595.617;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;1116;-326.4551,-2042.852;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1112;-197.9845,-2229.078;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;1117;-6.485596,-2096.18;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1106;1567.401,481.2428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1120;1471.787,24.46233;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1121;1681.81,-18.32007;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;1118;1236.505,-100.0267;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;1123;2086.298,-31.93266;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;1122;1503.615,-77.09193;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;717;-554.3253,-2261.754;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;832;551.9178,158.8052;Inherit;False;713;LeafOpacity;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;833;799.3542,132.556;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1126;1050.343,275.351;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;1125;415.2707,173.2174;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1119;380.9441,284.8532;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;1128;664.357,524.3634;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1127;550.655,339.981;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1102;635.5732,-134.9383;Inherit;False;Constant;_Float0;Float 0;38;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1101;1019.009,-148.6132;Inherit;False;Property;_Keyword0;Keyword 0;37;0;Create;True;0;0;0;False;0;False;0;0;0;False;UNITY_PASS_SHADOWCASTER;Toggle;2;Key0;Key1;Fetch;False;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1786.998,176.3287;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_FOLIAGE_NEW9;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;5;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.FresnelNode;712;260.4433,-748.0637;Inherit;False;Standard;TangentNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.01;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1129;7129.611,-1047.374;Inherit;False;Property;_textureScale;textureScale;38;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
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
WireConnection;283;0;181;0
WireConnection;283;1;205;0
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
WireConnection;175;0;126;0
WireConnection;175;1;279;0
WireConnection;292;0;291;0
WireConnection;292;1;296;0
WireConnection;491;0;1060;0
WireConnection;491;1;517;0
WireConnection;492;0;491;0
WireConnection;492;1;565;0
WireConnection;570;0;569;1
WireConnection;570;1;569;3
WireConnection;571;0;570;0
WireConnection;571;1;572;0
WireConnection;575;0;573;0
WireConnection;584;0;580;0
WireConnection;585;0;584;0
WireConnection;585;1;586;2
WireConnection;585;2;584;2
WireConnection;616;0;618;0
WireConnection;616;1;606;0
WireConnection;631;0;616;0
WireConnection;578;0;628;0
WireConnection;578;1;579;0
WireConnection;645;0;646;0
WireConnection;645;1;574;2
WireConnection;647;0;645;0
WireConnection;648;0;647;0
WireConnection;648;1;649;0
WireConnection;517;0;512;0
WireConnection;517;1;504;0
WireConnection;257;0;3;0
WireConnection;257;1;290;0
WireConnection;628;0;576;0
WireConnection;628;1;631;0
WireConnection;580;0;578;0
WireConnection;580;2;578;0
WireConnection;275;0;283;0
WireConnection;275;1;295;0
WireConnection;118;0;469;0
WireConnection;118;2;114;0
WireConnection;118;3;112;0
WireConnection;259;0;958;0
WireConnection;815;0;118;0
WireConnection;815;1;855;0
WireConnection;817;0;818;0
WireConnection;818;0;815;0
WireConnection;818;1;819;0
WireConnection;820;0;817;0
WireConnection;820;1;819;0
WireConnection;930;0;929;0
WireConnection;931;0;930;0
WireConnection;932;0;931;0
WireConnection;932;1;933;0
WireConnection;933;0;931;0
WireConnection;934;0;932;0
WireConnection;934;1;1129;0
WireConnection;936;0;934;0
WireConnection;936;1;943;0
WireConnection;937;0;936;0
WireConnection;937;1;947;0
WireConnection;939;0;938;0
WireConnection;940;0;939;0
WireConnection;941;0;940;0
WireConnection;942;0;940;0
WireConnection;942;1;941;0
WireConnection;943;0;942;0
WireConnection;943;1;1129;0
WireConnection;946;0;944;0
WireConnection;946;1;945;0
WireConnection;947;0;946;0
WireConnection;961;2;679;0
WireConnection;958;0;679;0
WireConnection;958;8;670;0
WireConnection;958;3;961;0
WireConnection;195;0;820;0
WireConnection;1037;0;1036;0
WireConnection;1038;0;1037;0
WireConnection;668;0;1059;0
WireConnection;668;1;1072;0
WireConnection;573;0;571;0
WireConnection;573;1;648;0
WireConnection;618;0;1042;0
WireConnection;618;2;622;0
WireConnection;618;1;648;0
WireConnection;980;0;668;0
WireConnection;980;1;1064;0
WireConnection;948;0;937;0
WireConnection;642;0;639;0
WireConnection;642;1;643;0
WireConnection;640;0;585;0
WireConnection;640;1;642;0
WireConnection;999;0;994;0
WireConnection;999;1;1047;0
WireConnection;653;0;1046;0
WireConnection;653;1;667;0
WireConnection;1045;0;1023;2
WireConnection;1044;0;1023;1
WireConnection;1044;1;1045;0
WireConnection;1044;2;1023;3
WireConnection;1047;0;1050;0
WireConnection;1047;1;1048;0
WireConnection;1047;2;1053;0
WireConnection;1050;0;1013;1
WireConnection;1050;1;1051;0
WireConnection;1048;0;1013;2
WireConnection;1048;1;1049;0
WireConnection;1053;0;1013;3
WireConnection;1053;1;1052;0
WireConnection;582;0;580;0
WireConnection;582;1;581;0
WireConnection;576;0;1041;2
WireConnection;576;1;575;0
WireConnection;599;0;597;0
WireConnection;599;2;596;0
WireConnection;597;0;598;0
WireConnection;597;1;604;0
WireConnection;604;0;1041;2
WireConnection;603;0;599;0
WireConnection;603;1;585;0
WireConnection;565;0;1071;0
WireConnection;565;1;564;0
WireConnection;494;0;493;0
WireConnection;495;0;494;0
WireConnection;495;1;490;0
WireConnection;1061;0;495;0
WireConnection;496;0;495;0
WireConnection;587;1;588;0
WireConnection;587;3;980;0
WireConnection;994;0;970;0
WireConnection;1059;0;603;0
WireConnection;589;0;587;0
WireConnection;1060;0;1065;0
WireConnection;512;0;511;0
WireConnection;493;0;492;0
WireConnection;493;1;492;0
WireConnection;1064;0;999;0
WireConnection;1072;0;653;0
WireConnection;1077;0;106;0
WireConnection;345;0;344;0
WireConnection;345;1;346;0
WireConnection;1086;0;1081;0
WireConnection;1086;1;1085;0
WireConnection;1085;0;1084;0
WireConnection;1084;0;1081;0
WireConnection;1087;0;1086;0
WireConnection;1087;1;1088;0
WireConnection;1090;0;1089;1
WireConnection;1090;1;1089;2
WireConnection;1090;2;1089;3
WireConnection;1091;0;1090;0
WireConnection;1091;1;1089;4
WireConnection;1093;0;1091;0
WireConnection;1094;0;1093;0
WireConnection;1094;1;1093;1
WireConnection;1096;0;257;0
WireConnection;1096;1;1075;0
WireConnection;1097;0;257;0
WireConnection;1097;1;1075;0
WireConnection;1076;0;1075;0
WireConnection;1080;0;1087;0
WireConnection;1080;1;1083;0
WireConnection;1075;1;1098;0
WireConnection;713;0;717;0
WireConnection;855;0;854;0
WireConnection;855;1;950;0
WireConnection;1100;0;717;0
WireConnection;1100;1;717;0
WireConnection;1070;0;1030;0
WireConnection;1107;1;1106;0
WireConnection;1108;0;1111;0
WireConnection;1108;1;1109;0
WireConnection;1116;0;712;0
WireConnection;1112;0;1117;0
WireConnection;1112;1;717;0
WireConnection;1117;0;712;0
WireConnection;1106;0;1105;0
WireConnection;1120;0;1118;0
WireConnection;1120;1;1119;3
WireConnection;1121;0;1120;0
WireConnection;1121;1;833;0
WireConnection;1123;0;1121;0
WireConnection;1122;0;1119;0
WireConnection;717;0;712;0
WireConnection;717;1;855;0
WireConnection;833;0;832;0
WireConnection;1126;0;833;0
WireConnection;1126;1;1128;0
WireConnection;1128;0;1127;0
WireConnection;1127;0;1125;0
WireConnection;1127;1;1119;0
WireConnection;1101;1;833;0
WireConnection;1101;0;1102;0
WireConnection;0;2;345;0
WireConnection;0;10;833;0
WireConnection;0;13;257;0
WireConnection;0;11;590;0
WireConnection;712;2;711;0
WireConnection;712;3;710;0
ASEEND*/
//CHKSM=5BDC35D6F98DD863E1B6C8B810EA4811CBB3010F