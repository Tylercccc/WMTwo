// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hidden/BOXOPHOBIC/Atmospherics/Height Fog Global"
{
	Properties
	{
		[StyledCategory(Fog Settings, false, _HeightFogStandalone, 10, 10)]_FogCat("[ Fog Cat]", Float) = 1
		[StyledCategory(Skybox Settings, false, _HeightFogStandalone, 10, 10)]_SkyboxCat("[ Skybox Cat ]", Float) = 1
		[StyledCategory(Directional Settings, false, _HeightFogStandalone, 10, 10)]_DirectionalCat("[ Directional Cat ]", Float) = 1
		[StyledCategory(Noise Settings, false, _HeightFogStandalone, 10, 10)]_NoiseCat("[ Noise Cat ]", Float) = 1
		[StyledCategory(Advanced Settings, false, _HeightFogStandalone, 10, 10)]_AdvancedCat("[ Advanced Cat ]", Float) = 1
		_Stepppp("Stepppp", Float) = 20
		[HideInInspector]_HeightFogGlobal("_HeightFogGlobal", Float) = 1
		[HideInInspector]_IsHeightFogShader("_IsHeightFogShader", Float) = 1
		[ASEEnd][StyledBanner(Height Fog Global)]_Banner("[ Banner ]", Float) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Overlay" "Queue"="Overlay" }
	LOD 0

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Front
		ColorMask RGBA
		ZWrite Off
		ZTest Always
		Stencil
		{
			Ref 222
			Comp NotEqual
			Pass Zero
			Fail Keep
			ZFail Keep
		}
		
		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			//Atmospheric Height Fog Defines
			//#define AHF_DISABLE_NOISE3D
			//#define AHF_DISABLE_DIRECTIONAL
			//#define AHF_DISABLE_SKYBOXFOG
			//#define AHF_DISABLE_FALLOFF
			//#define AHF_DEBUG_WORLDPOS


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half _IsHeightFogShader;
			uniform half _HeightFogGlobal;
			uniform half _Banner;
			uniform half _FogCat;
			uniform half _SkyboxCat;
			uniform half _AdvancedCat;
			uniform half _NoiseCat;
			uniform half _DirectionalCat;
			uniform half4 AHF_FogColorStart;
			uniform half4 AHF_FogColorEnd;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform half AHF_FogDistanceStart;
			uniform half AHF_FogDistanceEnd;
			uniform half AHF_FogDistanceFalloff;
			uniform half AHF_FogColorDuo;
			uniform half4 AHF_DirectionalColor;
			uniform half3 AHF_DirectionalDir;
			uniform half AHF_JitterIntensity;
			uniform half AHF_DirectionalIntensity;
			uniform half AHF_DirectionalFalloff;
			uniform half3 AHF_FogAxisOption;
			uniform half AHF_FogHeightEnd;
			uniform half AHF_FarDistanceHeight;
			uniform float AHF_FarDistanceOffset;
			uniform half AHF_FogHeightStart;
			uniform half AHF_FogHeightFalloff;
			uniform half AHF_FogLayersMode;
			uniform half AHF_NoiseScale;
			uniform half3 AHF_NoiseSpeed;
			uniform half AHF_NoiseMin;
			uniform half AHF_NoiseMax;
			uniform half AHF_NoiseDistanceEnd;
			uniform half AHF_NoiseIntensity;
			uniform half AHF_FogIntensity;
			uniform half AHF_SkyboxFogOffset;
			uniform half AHF_SkyboxFogHeight;
			uniform half AHF_SkyboxFogFalloff;
			uniform half AHF_SkyboxFogBottom;
			uniform half AHF_SkyboxFogFill;
			uniform half AHF_SkyboxFogIntensity;
			uniform float _Stepppp;
			float4 mod289( float4 x )
			{
				return x - floor(x * (1.0 / 289.0)) * 289.0;
			}
			
			float4 perm( float4 x )
			{
				return mod289(((x * 34.0) + 1.0) * x);
			}
			
			float SimpleNoise3D( float3 p )
			{
				    float3 a = floor(p);
				    float3 d = p - a;
				    d = d * d * (3.0 - 2.0 * d);
				    float4 b = a.xxyy + float4(0.0, 1.0, 0.0, 1.0);
				    float4 k1 = perm(b.xyxy);
				    float4 k2 = perm(k1.xyxy + b.zzww);
				    float4 c = k2 + a.zzzz;
				    float4 k3 = perm(c);
				    float4 k4 = perm(c + 1.0);
				    float4 o1 = frac(k3 * (1.0 / 41.0));
				    float4 o2 = frac(k4 * (1.0 / 41.0));
				    float4 o3 = o2 * d.z + o1 * (1.0 - d.z);
				    float2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
				    return o4.y * d.y + o4.x * (1.0 - d.y);
			}
			
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV235_g1030 = ase_screenPosNorm.xy;
				float2 localUnStereo235_g1030 = UnStereo( UV235_g1030 );
				float2 break248_g1030 = localUnStereo235_g1030;
				float clampDepth227_g1030 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch250_g1030 = ( 1.0 - clampDepth227_g1030 );
				#else
				float staticSwitch250_g1030 = clampDepth227_g1030;
				#endif
				float3 appendResult244_g1030 = (float3(break248_g1030.x , break248_g1030.y , staticSwitch250_g1030));
				float4 appendResult220_g1030 = (float4((appendResult244_g1030*2.0 + -1.0) , 1.0));
				float4 break229_g1030 = mul( unity_CameraInvProjection, appendResult220_g1030 );
				float3 appendResult237_g1030 = (float3(break229_g1030.x , break229_g1030.y , break229_g1030.z));
				float4 appendResult233_g1030 = (float4(( ( appendResult237_g1030 / break229_g1030.w ) * half3(1,1,-1) ) , 1.0));
				float4 break245_g1030 = mul( unity_CameraToWorld, appendResult233_g1030 );
				float3 appendResult239_g1030 = (float3(break245_g1030.x , break245_g1030.y , break245_g1030.z));
				half3 WorldPosFromDepth_Birp566_g1030 = appendResult239_g1030;
				half3 WorldPosFromDepth253_g1030 = WorldPosFromDepth_Birp566_g1030;
				float3 WorldPosition2_g1030 = WorldPosFromDepth253_g1030;
				float temp_output_7_0_g1033 = AHF_FogDistanceStart;
				float temp_output_155_0_g1030 = saturate( ( ( distance( WorldPosition2_g1030 , _WorldSpaceCameraPos ) - temp_output_7_0_g1033 ) / ( AHF_FogDistanceEnd - temp_output_7_0_g1033 ) ) );
				#ifdef AHF_DISABLE_FALLOFF
				float staticSwitch467_g1030 = temp_output_155_0_g1030;
				#else
				float staticSwitch467_g1030 = ( 1.0 - pow( ( 1.0 - abs( temp_output_155_0_g1030 ) ) , AHF_FogDistanceFalloff ) );
				#endif
				half FogDistanceMask12_g1030 = staticSwitch467_g1030;
				float3 lerpResult258_g1030 = lerp( (AHF_FogColorStart).rgb , (AHF_FogColorEnd).rgb , ( ( FogDistanceMask12_g1030 * FogDistanceMask12_g1030 * FogDistanceMask12_g1030 ) * AHF_FogColorDuo ));
				float3 normalizeResult318_g1030 = normalize( ( WorldPosition2_g1030 - _WorldSpaceCameraPos ) );
				float dotResult145_g1030 = dot( normalizeResult318_g1030 , AHF_DirectionalDir );
				float4 ScreenPos3_g1032 = screenPos;
				float2 UV13_g1032 = ( ( (ScreenPos3_g1032).xy / (ScreenPos3_g1032).z ) * (_ScreenParams).xy );
				float3 Magic14_g1032 = float3(0.06711056,0.00583715,52.98292);
				float dotResult16_g1032 = dot( UV13_g1032 , (Magic14_g1032).xy );
				float lerpResult494_g1030 = lerp( 0.0 , frac( ( frac( dotResult16_g1032 ) * (Magic14_g1032).z ) ) , ( AHF_JitterIntensity * 0.1 ));
				half Jitter502_g1030 = lerpResult494_g1030;
				float temp_output_140_0_g1030 = ( saturate( (( dotResult145_g1030 + Jitter502_g1030 )*0.5 + 0.5) ) * AHF_DirectionalIntensity );
				#ifdef AHF_DISABLE_FALLOFF
				float staticSwitch470_g1030 = temp_output_140_0_g1030;
				#else
				float staticSwitch470_g1030 = pow( abs( temp_output_140_0_g1030 ) , AHF_DirectionalFalloff );
				#endif
				float DirectionalMask30_g1030 = staticSwitch470_g1030;
				float3 lerpResult40_g1030 = lerp( lerpResult258_g1030 , (AHF_DirectionalColor).rgb , DirectionalMask30_g1030);
				#ifdef AHF_DISABLE_DIRECTIONAL
				float3 staticSwitch442_g1030 = lerpResult258_g1030;
				#else
				float3 staticSwitch442_g1030 = lerpResult40_g1030;
				#endif
				half3 Input_Color6_g1031 = staticSwitch442_g1030;
				#ifdef UNITY_COLORSPACE_GAMMA
				float3 staticSwitch1_g1031 = Input_Color6_g1031;
				#else
				float3 staticSwitch1_g1031 = ( Input_Color6_g1031 * ( ( Input_Color6_g1031 * ( ( Input_Color6_g1031 * 0.305306 ) + 0.6821711 ) ) + 0.01252288 ) );
				#endif
				half3 Final_Color462_g1030 = staticSwitch1_g1031;
				half3 AHF_FogAxisOption181_g1030 = AHF_FogAxisOption;
				float3 break159_g1030 = ( WorldPosition2_g1030 * AHF_FogAxisOption181_g1030 );
				float temp_output_7_0_g1034 = AHF_FogDistanceEnd;
				float temp_output_643_0_g1030 = saturate( ( ( distance( WorldPosition2_g1030 , _WorldSpaceCameraPos ) - temp_output_7_0_g1034 ) / ( ( AHF_FogDistanceEnd + AHF_FarDistanceOffset ) - temp_output_7_0_g1034 ) ) );
				half FogDistanceMaskFar645_g1030 = ( temp_output_643_0_g1030 * temp_output_643_0_g1030 );
				float lerpResult690_g1030 = lerp( AHF_FogHeightEnd , ( AHF_FogHeightEnd + AHF_FarDistanceHeight ) , FogDistanceMaskFar645_g1030);
				float temp_output_7_0_g1035 = lerpResult690_g1030;
				float temp_output_167_0_g1030 = saturate( ( ( ( break159_g1030.x + break159_g1030.y + break159_g1030.z ) - temp_output_7_0_g1035 ) / ( AHF_FogHeightStart - temp_output_7_0_g1035 ) ) );
				#ifdef AHF_DISABLE_FALLOFF
				float staticSwitch468_g1030 = temp_output_167_0_g1030;
				#else
				float staticSwitch468_g1030 = pow( abs( temp_output_167_0_g1030 ) , AHF_FogHeightFalloff );
				#endif
				half FogHeightMask16_g1030 = staticSwitch468_g1030;
				float lerpResult328_g1030 = lerp( ( FogDistanceMask12_g1030 * FogHeightMask16_g1030 ) , saturate( ( FogDistanceMask12_g1030 + FogHeightMask16_g1030 ) ) , AHF_FogLayersMode);
				float mulTime204_g1030 = _Time.y * 2.0;
				float3 temp_output_197_0_g1030 = ( ( WorldPosition2_g1030 * ( 1.0 / AHF_NoiseScale ) ) + ( -AHF_NoiseSpeed * mulTime204_g1030 ) );
				float3 p1_g1039 = temp_output_197_0_g1030;
				float localSimpleNoise3D1_g1039 = SimpleNoise3D( p1_g1039 );
				float temp_output_7_0_g1038 = AHF_NoiseMin;
				float temp_output_7_0_g1037 = AHF_NoiseDistanceEnd;
				half NoiseDistanceMask7_g1030 = saturate( ( ( distance( WorldPosition2_g1030 , _WorldSpaceCameraPos ) - temp_output_7_0_g1037 ) / ( 0.0 - temp_output_7_0_g1037 ) ) );
				float lerpResult198_g1030 = lerp( 1.0 , saturate( ( ( localSimpleNoise3D1_g1039 - temp_output_7_0_g1038 ) / ( AHF_NoiseMax - temp_output_7_0_g1038 ) ) ) , ( NoiseDistanceMask7_g1030 * AHF_NoiseIntensity ));
				half NoiseSimplex3D24_g1030 = lerpResult198_g1030;
				#ifdef AHF_DISABLE_NOISE3D
				float staticSwitch42_g1030 = lerpResult328_g1030;
				#else
				float staticSwitch42_g1030 = ( lerpResult328_g1030 * NoiseSimplex3D24_g1030 );
				#endif
				float temp_output_454_0_g1030 = ( staticSwitch42_g1030 * AHF_FogIntensity );
				float3 normalizeResult169_g1030 = normalize( ( WorldPosition2_g1030 - _WorldSpaceCameraPos ) );
				float3 break170_g1030 = ( normalizeResult169_g1030 * AHF_FogAxisOption181_g1030 );
				float temp_output_449_0_g1030 = ( ( break170_g1030.x + break170_g1030.y + break170_g1030.z ) + -AHF_SkyboxFogOffset );
				float temp_output_7_0_g1036 = AHF_SkyboxFogHeight;
				float temp_output_176_0_g1030 = saturate( ( ( abs( temp_output_449_0_g1030 ) - temp_output_7_0_g1036 ) / ( 0.0 - temp_output_7_0_g1036 ) ) );
				float saferPower309_g1030 = abs( temp_output_176_0_g1030 );
				#ifdef AHF_DISABLE_FALLOFF
				float staticSwitch469_g1030 = temp_output_176_0_g1030;
				#else
				float staticSwitch469_g1030 = pow( saferPower309_g1030 , AHF_SkyboxFogFalloff );
				#endif
				float lerpResult179_g1030 = lerp( saturate( ( staticSwitch469_g1030 + ( AHF_SkyboxFogBottom * step( temp_output_449_0_g1030 , 0.0 ) ) ) ) , 1.0 , AHF_SkyboxFogFill);
				half SkyboxFogHeightMask108_g1030 = ( lerpResult179_g1030 * AHF_SkyboxFogIntensity );
				float clampDepth118_g1030 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch123_g1030 = clampDepth118_g1030;
				#else
				float staticSwitch123_g1030 = ( 1.0 - clampDepth118_g1030 );
				#endif
				half SkyboxFogMask95_g1030 = ( 1.0 - ceil( staticSwitch123_g1030 ) );
				float lerpResult112_g1030 = lerp( temp_output_454_0_g1030 , SkyboxFogHeightMask108_g1030 , SkyboxFogMask95_g1030);
				#ifdef AHF_DISABLE_SKYBOXFOG
				float staticSwitch455_g1030 = temp_output_454_0_g1030;
				#else
				float staticSwitch455_g1030 = lerpResult112_g1030;
				#endif
				half Final_Alpha463_g1030 = staticSwitch455_g1030;
				float4 appendResult114_g1030 = (float4(Final_Color462_g1030 , Final_Alpha463_g1030));
				float4 appendResult457_g1030 = (float4(WorldPosition2_g1030 , 1.0));
				#ifdef AHF_DEBUG_WORLDPOS
				float4 staticSwitch456_g1030 = appendResult457_g1030;
				#else
				float4 staticSwitch456_g1030 = appendResult114_g1030;
				#endif
				
				
				finalColor = ( floor( ( staticSwitch456_g1030 * _Stepppp ) ) / _Stepppp );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "HeightFogShaderGUI"
	
	Fallback Off
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.RangedFloatNode;885;-2912,-4864;Half;False;Property;_IsHeightFogShader;_IsHeightFogShader;44;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;879;-3136,-4864;Half;False;Property;_HeightFogGlobal;_HeightFogGlobal;43;1;[HideInInspector];Create;False;0;0;0;True;0;False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;892;-3328,-4864;Half;False;Property;_Banner;[ Banner ];45;0;Create;True;0;0;0;True;1;StyledBanner(Height Fog Global);False;1;1;1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;383;-3072,-4608;Float;False;True;-1;2;HeightFogShaderGUI;0;5;Hidden/BOXOPHOBIC/Atmospherics/Height Fog Global;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;2;5;False;;10;False;;0;5;False;;10;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;1;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;True;True;True;222;False;;255;False;;255;False;;6;False;;2;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;7;False;;True;False;0;False;;1000;False;;True;2;RenderType=Overlay=RenderType;Queue=Overlay=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.CommentaryNode;880;-3328,-4992;Inherit;False;919.8825;100;Drawers;0;;1,0.475862,0,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1119;-3328,-4608;Inherit;False;Base;0;;1030;13c50910e5b86de4097e1181ba121e0e;36,360,0,380,0,372,0,384,0,476,0,450,0,370,0,376,0,374,0,386,0,555,0,557,0,388,0,550,0,368,0,378,0,382,0,347,0,351,0,339,0,392,0,355,0,116,1,364,0,361,0,597,0,343,0,354,0,99,1,500,0,603,1,681,0,345,0,685,0,349,0,366,0;0;3;FLOAT4;113;FLOAT3;86;FLOAT;87
WireConnection;383;0;1119;113
ASEEND*/
//CHKSM=1D0C1E2C3A12AEDDE79378D89D3AC0DFEF8B5A7A