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
		[HideInInspector]_Mask2("_Mask2", 2D) = "white" {}
		_NormalScale2("NormalScale2", Range( 0 , 1)) = 0
		[HideInInspector]_Mask0("_Mask0", 2D) = "white" {}
		[HideInInspector]_Mask1("_Mask1", 2D) = "white" {}
		_NormalScale0("NormalScale0", Range( 0 , 1)) = 0
		[HideInInspector]_Mask3("_Mask3", 2D) = "white" {}
		_NormalScale1("NormalScale1", Range( 0 , 1)) = 0
		_NormalScale3("NormalScale3", Range( 0 , 1)) = 0
		_Float1("Float 1", Float) = 0
		_Float2("Float 2", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry-100" }
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
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

		uniform float4 _MaskMapRemapOffset2;
		uniform float4 _MaskMapRemapScale2;
		uniform float4 _MaskMapRemapScale1;
		uniform float4 _MaskMapRemapOffset1;
		uniform float4 _MaskMapRemapScale3;
		uniform float4 _MaskMapRemapOffset3;
		uniform float4 _MaskMapRemapOffset0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask0);
		SamplerState sampler_Mask0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask1);
		SamplerState sampler_Mask1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask2);
		SamplerState sampler_Mask2;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Mask3);
		SamplerState sampler_Mask3;
		uniform float4 _MaskMapRemapScale0;
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
		uniform float _PointLightAttenuationBoost;
		uniform float _LightGradientMidLevel;
		uniform float _LightGradientSize;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Control);
		uniform float4 _Control_ST;
		SamplerState sampler_Control;
		uniform float _Float2;
		uniform float _Float1;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal0);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat0);
		uniform float4 _Splat0_ST;
		SamplerState sampler_Normal0;
		uniform float _NormalScale0;
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Normal1);
		UNITY_DECLARE_TEX2D_NOSAMPLER(_Splat1);
		uniform float4 _Splat1_ST;
		SamplerState sampler_Normal1;
		uniform float _NormalScale1;
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
			float2 uv_Control = i.uv_texcoord * _Control_ST.xy + _Control_ST.zw;
			float4 tex2DNode222 = SAMPLE_TEXTURE2D( _Control, sampler_Control, uv_Control );
			float4 temp_output_269_0 = ( floor( ( tex2DNode222 * _Float2 ) ) / _Float1 );
			float4 Control122 = temp_output_269_0;
			float2 uv_Splat0 = i.uv_texcoord * _Splat0_ST.xy + _Splat0_ST.zw;
			float2 uv_Splat1 = i.uv_texcoord * _Splat1_ST.xy + _Splat1_ST.zw;
			float2 uv_Splat2 = i.uv_texcoord * _Splat2_ST.xy + _Splat2_ST.zw;
			float2 uv_Splat3 = i.uv_texcoord * _Splat3_ST.xy + _Splat3_ST.zw;
			float4 weightedBlendVar23 = Control122;
			float3 weightedBlend23 = ( weightedBlendVar23.x*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal0, sampler_Normal0, uv_Splat0 ), _NormalScale0 ) + weightedBlendVar23.y*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal1, sampler_Normal1, uv_Splat1 ), _NormalScale1 ) + weightedBlendVar23.z*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal2, sampler_Normal2, uv_Splat2 ), _NormalScale2 ) + weightedBlendVar23.w*UnpackScaleNormal( SAMPLE_TEXTURE2D( _Normal3, sampler_Normal3, uv_Splat3 ), _NormalScale3 ) );
			float3 Normals25 = weightedBlend23;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult11 = dot( (WorldNormalVector( i , Normals25 )) , ase_worldlightDir );
			float NdotL10 = dotResult11;
			float smoothstepResult45 = smoothstep( ( _LightGradientMidLevel - temp_output_39_0 ) , ( _LightGradientMidLevel + temp_output_39_0 ) , (NdotL10*0.5 + 0.5));
			float temp_output_59_0 = ( ( ( ase_lightAtten * ( 1.0 - IsPointLight28 ) ) * step( _ShadowLevel , ase_lightAtten ) ) * ( floor( ( smoothstepResult45 * _Steps * ( 1.0 - IsPointLight28 ) ) ) / _Steps ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 weightedBlendVar1 = Control122;
			float4 weightedAvg1 = ( ( weightedBlendVar1.x*SAMPLE_TEXTURE2D( _Splat0, sampler_Splat0, uv_Splat0 ) + weightedBlendVar1.y*SAMPLE_TEXTURE2D( _Splat1, sampler_Splat1, uv_Splat1 ) + weightedBlendVar1.z*SAMPLE_TEXTURE2D( _Splat2, sampler_Splat2, uv_Splat2 ) + weightedBlendVar1.w*SAMPLE_TEXTURE2D( _Splat3, sampler_Splat3, uv_Splat3 ) )/( weightedBlendVar1.x + weightedBlendVar1.y + weightedBlendVar1.z + weightedBlendVar1.w ) );
			float4 Albedos126 = weightedAvg1;
			float temp_output_78_0 = ( 1.0 - ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + temp_output_59_0 ) );
			float4 weightedBlendVar89 = Control122;
			float4 weightedAvg89 = ( ( weightedBlendVar89.x*_Specular0 + weightedBlendVar89.y*_Specular1 + weightedBlendVar89.z*_Specular2 + weightedBlendVar89.w*_Specular3 )/( weightedBlendVar89.x + weightedBlendVar89.y + weightedBlendVar89.z + weightedBlendVar89.w ) );
			float4 ShadowColor129 = weightedAvg89;
			c.rgb = ( ( ( ( ( floor( ( saturate( ( PointLightAttenuation106 * smoothstepResult45 ) ) * _Steps ) ) / _Steps ) + temp_output_59_0 ) * ase_lightColor ) * Albedos126 ) + ( ( temp_output_78_0 * ShadowColor129 ) * ( 1.0 - IsPointLight28 ) ) ).rgb;
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
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
Node;AmplifyShaderEditor.CommentaryNode;148;-212.9223,121.602;Inherit;False;751.4393;422.4538;Comment;4;94;95;96;133;Multiplies lit areas with albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;145;-660.8116,661.3414;Inherit;False;605.6092;303;Comment;2;130;141;Applies Shadow Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;144;-148.9679,1063.848;Inherit;False;476.9345;314.1964;Comment;2;104;105;Dithers Mid-range Shadow Values;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;139;-1547.288,49.00008;Inherit;False;100;100; sat ;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;131;-3731.646,709.2673;Inherit;False;1031.701;1051.666;Comment;7;80;86;127;128;88;89;129;Splat Specular (Shadow Cols);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;121;-1679.311,-270.1599;Inherit;False;564.9662;532.2659;Comment;5;73;74;120;75;76;Dithering;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;8;-4942.581,676.2258;Inherit;False;1029.55;1142.421;Comment;12;126;1;7;6;5;3;247;292;293;289;290;291;Splat Albedos;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;9;-4923.427,-1092.876;Inherit;False;1045.97;441.7339;Basic lighting;5;14;13;12;11;10;N dot L;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-4098.322,-863.425;Inherit;True;NdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-4278.479,-882.7019;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;12;-4529.499,-1015.064;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;13;-4571.454,-817.2249;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;16;-6385.42,718.6832;Inherit;False;1206.452;1116.543;Comment;8;25;124;19;24;23;20;21;22;Splat Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-4928.833,-2182.177;Inherit;False;528.8752;183;;2;28;27;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;29;-4923.822,-1885.455;Inherit;False;609.5977;695.7705;;7;36;35;34;33;32;31;30;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-4849.617,-1835.456;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;9;0;Create;True;0;0;0;False;0;False;1;4.79;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-4835.916,-1692.049;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;32;-4816.578,-1566.665;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-4562.176,-1776.088;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-4913.822,-1450.134;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-4696.922,-1446.551;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-4470.554,-1495.848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;38;-3669.1,-1709.724;Inherit;False;977.7146;495.7445;;8;42;44;39;41;43;46;45;40;Shading Edge Size;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-3619.1,-1559.759;Inherit;False;Property;_LightGradientMidLevel;Light Gradient MidLevel;10;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;45;-2941.695,-1571.182;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-3169.815,-1321.937;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;39;-3371.939,-1304.061;Inherit;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-3618.883,-1432.266;Inherit;False;Property;_LightGradientSize;Light Gradient Size;11;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-3171.254,-1432.499;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;47;-2443.331,-1002.886;Inherit;False;1379.942;546.2153;;11;64;63;62;61;59;58;57;56;55;53;50;Posterising Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2917.424,-1045.247;Inherit;False;Property;_Steps;Steps;15;1;[IntRange];Create;True;0;0;0;False;0;False;5;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;51;-2506.8,-1110.921;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;52;-2504.771,-621.9946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;53;-2150.507,-540.2211;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2311.205,-913.1584;Inherit;False;Property;_ShadowLevel;Shadow Level;17;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;56;-2291.5,-812.1217;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;58;-1769.823,-943.117;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-1291.26,-848.4384;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1936.135,-719.434;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;-2110.514,-689.5491;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;63;-1716.706,-715.0091;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-1583.225,-717.2291;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-4366.816,-1776.437;Inherit;False;PointLightAttenuation;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;108;-2506.173,-1741.719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;110;-2458.173,-1754.719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;109;-2532.173,-1556.719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;111;-2519.173,-1589.719;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;113;-2528.927,-1498.831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;112;-1965.712,-1433.771;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;114;-1999.165,-1463.514;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2528.081,-1911.691;Inherit;False;106;PointLightAttenuation;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-2255.399,-1806.972;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-2043.717,-1801.565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1758.382,-1726.301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;70;-1574.545,-1715.724;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;68;-1826.419,-1573.882;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;115;-2119.047,-1103.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;54;-1852.985,-1153.617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;116;-1876.486,-1095.813;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1532.385,-957.196;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;71;-1395.15,-1592.493;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-574.5312,-768.7025;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;118;-657.2051,-1540.984;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;117;-603.0703,-1474.818;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;119;-1211.792,-489.8296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1469.682,-176.1086;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;74;-1320.345,6.050682;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;120;-1559.242,-220.1599;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SummedBlendNode;23;-5939.064,1201.936;Inherit;False;5;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WeightedBlendNode;89;-3194.785,1244.896;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-5416.889,1210.143;Inherit;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-2923.947,1291.196;Inherit;False;ShadowColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-3681.646,759.2673;Inherit;False;122;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;135;-3794.434,-1185.41;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;136;-2222.496,-1172.527;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;75;-1629.311,-28.4301;Inherit;True;Property;_Dither;Dither;18;0;Create;True;0;0;0;False;0;False;71ee2865e455142fb9a3cd6e3ef3fc51;073ff050942f0429caa7fe8744145704;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;76;-1351.199,147.106;Inherit;False;DitherPattern;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;138;-618.8962,-861.3864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;104;98.96655,1113.848;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-98.96793,1263.044;Inherit;False;76;DitherPattern;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RelayNode;77;-1048.811,318.6606;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;78;-619.7217,708.214;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;146;-461.0425,1056.617;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-206.8492,722.0742;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;147;-353.3678,1127.202;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;94;-162.9223,335.1635;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;303.5171,171.6784;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;80;-3645.082,1007.099;Inherit;False;Property;_Specular0;Specular0;16;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.9056604,0.08116765,0.08116765,0;0.6973284,0.4009434,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;86;-3637.275,1189.766;Inherit;False;Property;_Specular1;Specular1;12;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;127;-3634.132,1367.31;Inherit;False;Property;_Specular2;Specular2;13;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;0.09090912,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;128;-3627.156,1553.933;Inherit;False;Property;_Specular3;Specular3;14;1;[HideInInspector];Create;True;0;0;0;False;0;False;0,0,0,0;1,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-4887.775,1153.995;Inherit;True;Property;_Splat1;Splat1;3;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-4880.565,1371.486;Inherit;True;Property;_Splat2;Splat2;5;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-4870.953,1593.782;Inherit;True;Property;_Splat3;Splat3;7;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-6324.959,1415.496;Inherit;True;Property;_Normal2;Normal2;6;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-6313.792,1636.239;Inherit;True;Property;_Normal3;Normal3;8;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;124;-6229.625,817.4749;Inherit;False;122;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;27;-4880.833,-2134.177;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-4640.833,-2118.177;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2292.175,-688.4339;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;150;-118.4783,916.3269;Inherit;False;28;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;662.9216,734.8383;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCCompareWithRange;60;-945.9747,-823.2586;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;43;-3219.608,-1666.916;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-3509.887,-1644.773;Inherit;False;10;NdotL;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-4834.197,-967.6586;Inherit;False;25;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;19;-6335.421,980.1654;Inherit;True;Property;_Normal0;Normal0;2;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-6330.613,1194.081;Inherit;True;Property;_Normal1;Normal1;4;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;5259d0042c9854375b96305b6256ecfd;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;24;-5693.783,1014.998;Inherit;False;Object;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;153;-6633.264,1223.137;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;154;-6628.846,1421.97;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;155;-6627.377,1650.261;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;152;-6637.545,1013.686;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;161;-6664.946,1141.076;Inherit;False;Property;_NormalScale0;NormalScale0;23;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;162;-6664.947,1347.682;Inherit;False;Property;_NormalScale1;NormalScale1;25;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-6663.501,1551.398;Inherit;False;Property;_NormalScale2;NormalScale2;20;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-6657.723,1772.451;Inherit;False;Property;_NormalScale3;NormalScale3;26;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1386.358,-15.11673;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Terrain_New;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;-100;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;1;BaseMapShader=ASESampleShaders/SimpleTerrainBase;0;False;;-1;0;False;;0;0;0;True;0.1;False;;0;False;;True;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CustomExpressionNode;165;988.5618,300.1436;Float;False;v.tangent.xyz = cross ( v.normal, float3( 0, 0, 1 ) )@$v.tangent.w = -1@;1;Call;0;CalculateTangentsStandard;True;False;0;;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;170;-8069.495,-944.7587;Inherit;False;1210.908;2784.683;;22;186;185;184;183;182;181;180;179;178;177;176;175;174;173;172;171;193;194;195;196;197;198;Mask Variables;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;171;-7575.227,196.3095;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-7599.963,-38.74341;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;174;-8026.554,617.6764;Inherit;False;Global;_MaskMapRemapScale2;_MaskMapRemapScale2;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;175;-7401.626,56.53053;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;176;-8026.554,425.6766;Inherit;False;Global;_MaskMapRemapScale1;_MaskMapRemapScale1;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;179;-8026.554,809.6764;Inherit;False;Global;_MaskMapRemapScale3;_MaskMapRemapScale3;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;180;-8048.8,-16.97046;Inherit;False;Global;_MaskMapRemapOffset3;_MaskMapRemapOffset3;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;181;-8056.232,-620.4147;Inherit;False;Global;_MaskMapRemapOffset0;_MaskMapRemapOffset0;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;182;-7982.291,-846.7977;Inherit;True;Property;_Mask0;_Mask0;21;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;183;-7764.505,-845.7206;Inherit;True;Property;_Mask1;_Mask1;22;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;184;-7549.542,-849.4257;Inherit;True;Property;_Mask2;_Mask2;19;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;185;-7334.377,-847.1476;Inherit;True;Property;_Mask3;_Mask3;24;1;[HideInInspector];Create;True;0;0;0;True;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.Vector4Node;186;-8026.554,217.6765;Inherit;False;Global;_MaskMapRemapScale0;_MaskMapRemapScale0;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;156;-4921.119,54.87766;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;157;-4719.338,48.98705;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;173;-8049.726,-218.5874;Inherit;False;Global;_MaskMapRemapOffset2;_MaskMapRemapOffset2;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;178;-7233.929,56.53053;Inherit;False;defaultOcclusion;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector4Node;177;-8045.411,-420.9575;Inherit;False;Global;_MaskMapRemapOffset1;_MaskMapRemapOffset1;23;0;Create;True;0;0;0;True;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-8013.251,1116.489;Inherit;False;Global;_LayerHasMask1;_LayerHasMask1;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;194;-7580.251,1139.489;Inherit;False;layerHasMask;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;195;-8024.251,1292.49;Inherit;False;Global;_LayerHasMask3;_LayerHasMask3;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;-8011.251,1206.489;Inherit;False;Global;_LayerHasMask2;_LayerHasMask2;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;197;-7787.251,1123.489;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;198;-8026.251,1036.489;Inherit;False;Global;_LayerHasMask0;_LayerHasMask0;23;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;199;-8057.888,1936.37;Inherit;False;917.8029;677.2048;;10;209;208;207;206;205;204;203;202;201;200;Compute Masks;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;200;-8004.885,2323.375;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;-7370.292,2442.149;Inherit;False;mask3;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;202;-7380.885,2211.375;Inherit;False;mask1;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;203;-8007.888,2072.434;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;-7366.485,2330.706;Inherit;False;mask2;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;205;-8004.885,2194.258;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;207;-8004.885,2451.375;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;208;-7364.885,2051.375;Inherit;False;mask0;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;206;-7684.885,2179.375;Inherit;False;masks0 = 0.5h@$masks1 = 0.5h@$masks2 = 0.5h@$masks3 = 0.5h@$#ifdef _MASKMAP$masks0 = lerp(masks0, SAMPLE_TEXTURE2D(_Mask0, sampler_Mask0, uvMask0), hasMask.x)@$masks1 = lerp(masks1, SAMPLE_TEXTURE2D(_Mask1, sampler_Mask0, uvMask1), hasMask.y)@$masks2 = lerp(masks2, SAMPLE_TEXTURE2D(_Mask2, sampler_Mask0, uvMask2), hasMask.z)@$masks3 = lerp(masks3, SAMPLE_TEXTURE2D(_Mask3, sampler_Mask0, uvMask3), hasMask.w)@$#endif$masks0 *= _MaskMapRemapScale0.rgba@$masks0 += _MaskMapRemapOffset0.rgba@$masks1 *= _MaskMapRemapScale1.rgba@$masks1 += _MaskMapRemapOffset1.rgba@$masks2 *= _MaskMapRemapScale2.rgba@$masks2 += _MaskMapRemapOffset2.rgba@$masks3 *= _MaskMapRemapScale3.rgba@$masks3 += _MaskMapRemapOffset3.rgba@;7;Create;9;True;masks0;FLOAT4;0,0,0,0;Out;;Inherit;False;True;masks1;FLOAT4;0,0,0,0;Out;;Inherit;False;True;masks2;FLOAT4;0,0,0,0;Out;;Inherit;False;True;masks3;FLOAT4;0,0,0,0;Out;;Inherit;False;False;hasMask;FLOAT4;0,0,0,0;In;;Inherit;False;False;uvMask0;FLOAT2;0,0;In;;Inherit;False;False;uvMask1;FLOAT2;0,0;In;;Inherit;False;False;uvMask2;FLOAT2;0,0;In;;Inherit;False;True;uvMask3;FLOAT2;0,0;In;;Inherit;False;ComputeMasks;True;False;0;;False;10;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;9;FLOAT2;0,0;False;5;FLOAT;0;FLOAT4;2;FLOAT4;3;FLOAT4;4;FLOAT4;5
Node;AmplifyShaderEditor.CommentaryNode;216;-6644.396,40.95816;Inherit;False;1473.57;484.0052;Comment;9;224;223;222;221;220;219;218;217;122;Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;-7982.953,1986.37;Inherit;False;194;layerHasMask;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;217;-5648.506,117.5814;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;218;-6626.477,286.2574;Float;False;Constant;_Vector0;Vector 0;9;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;219;-6080.506,357.5814;Float;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;220;-6329.128,268.9425;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;221;-5773.012,278.957;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-6197.611,265.6543;Float;False;SplatWeight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;222;-6634.515,86.88625;Inherit;True;Property;_Control;Control;0;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;224;-5977.628,227.0368;Float;False;#if !defined(SHADER_API_MOBILE) && defined(TERRAIN_SPLAT_ADDPASS)$	clip(SplatWeight == 0.0f ? -1 : 1)@$#endif;1;Call;1;True;SplatWeight;FLOAT;0;In;;Float;False;SplatClip;False;False;0;;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-4992.329,606.2815;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;258;-5213.94,452.1989;Inherit;False;158;AppendedWorldPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SwizzleNode;262;-4450.449,388.1423;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;266;-4268.666,441.8117;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;261;-4687.64,334.4737;Inherit;False;122;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;268;-5967.143,-111.7444;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;269;-5743.419,-103.1396;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;270;-6012.89,-38.98838;Inherit;False;Property;_Float1;Float 1;28;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;272;-6316.421,-192.2425;Inherit;False;Property;_Float2;Float 2;29;0;Create;True;0;0;0;False;0;False;0;3.94;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-6114.582,-175.4326;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;273;-5573.459,-151.3987;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;158;-4566.167,46.03928;Inherit;False;AppendedWorldPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;259;-5130.833,722.2761;Inherit;False;Property;_sdasdasd;sdasdasd;27;0;Create;True;0;0;0;False;0;False;0;-0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-4901.5,951.0812;Inherit;True;Property;_Splat0;Splat0;1;1;[HideInInspector];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-5891.275,72.95982;Inherit;False;Control;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;306;-4396.621,619.6497;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-411.3601,852.095;Inherit;False;129;ShadowColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;151;79.63765,911.0009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;324.7565,700.5284;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;53.91785,171.602;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.HeightMapBlendNode;248;-4284.055,170.64;Inherit;True;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;123;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;288;-4551.536,524.7068;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;287;-4137.939,531.2494;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-4062.763,1253.337;Inherit;False;Albedos;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;75.33709,429.0558;Inherit;True;126;Albedos;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;249;-5023.175,384.402;Inherit;False;208;mask0;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;251;-4841.079,437.7945;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;247;-4878.64,801.896;Inherit;False;122;Control;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WeightedBlendNode;1;-4185.417,1048.926;Inherit;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-4638.737,898.7527;Inherit;False;Property;_Float3;Float 3;30;0;Create;True;0;0;0;False;0;False;0;4.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;289;-4566.265,767.976;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;290;-4410.448,768.0526;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;293;-4386.795,953.0665;Inherit;False;Property;_Float4;Float 3;31;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;291;-4262.125,788.2886;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;-434.2199,421.305;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;315;-911.2517,735.8665;Inherit;False;Constant;_Float5;Float 5;32;0;Create;True;0;0;0;False;0;False;255;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;316;-655.9127,558.2384;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;311;-860.9888,400.4423;Inherit;True;122;Control;1;0;OBJECT;;False;1;COLOR;0
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
WireConnection;119;0;59;0
WireConnection;73;0;120;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;120;0;119;0
WireConnection;23;0;124;0
WireConnection;23;1;19;0
WireConnection;23;2;20;0
WireConnection;23;3;21;0
WireConnection;23;4;22;0
WireConnection;89;0;88;0
WireConnection;89;1;80;0
WireConnection;89;2;86;0
WireConnection;89;3;127;0
WireConnection;89;4;128;0
WireConnection;25;0;23;0
WireConnection;129;0;89;0
WireConnection;135;0;36;0
WireConnection;136;0;135;0
WireConnection;76;0;75;0
WireConnection;138;0;117;0
WireConnection;104;0;147;0
WireConnection;104;1;105;0
WireConnection;77;0;72;0
WireConnection;78;0;77;0
WireConnection;146;0;78;0
WireConnection;141;0;78;0
WireConnection;141;1;130;0
WireConnection;147;0;146;0
WireConnection;96;0;95;0
WireConnection;96;1;133;0
WireConnection;21;1;154;0
WireConnection;21;5;163;0
WireConnection;22;1;155;0
WireConnection;22;5;164;0
WireConnection;28;0;27;2
WireConnection;97;0;96;0
WireConnection;97;1;149;0
WireConnection;60;0;59;0
WireConnection;60;3;74;0
WireConnection;60;4;59;0
WireConnection;43;0;46;0
WireConnection;19;1;152;0
WireConnection;19;5;161;0
WireConnection;20;1;153;0
WireConnection;20;5;162;0
WireConnection;24;0;23;0
WireConnection;0;13;97;0
WireConnection;0;11;165;0
WireConnection;171;0;186;2
WireConnection;171;1;176;2
WireConnection;171;2;174;2
WireConnection;171;3;179;2
WireConnection;172;0;181;2
WireConnection;172;1;177;2
WireConnection;172;2;173;2
WireConnection;172;3;180;2
WireConnection;175;0;172;0
WireConnection;175;1;171;0
WireConnection;157;0;156;1
WireConnection;157;1;156;3
WireConnection;178;0;175;0
WireConnection;194;0;197;0
WireConnection;197;0;198;0
WireConnection;197;1;193;0
WireConnection;197;2;196;0
WireConnection;197;3;195;0
WireConnection;201;0;206;5
WireConnection;202;0;206;3
WireConnection;204;0;206;4
WireConnection;208;0;206;2
WireConnection;206;5;209;0
WireConnection;206;6;203;0
WireConnection;206;7;205;0
WireConnection;206;8;200;0
WireConnection;206;9;207;0
WireConnection;217;0;222;0
WireConnection;217;1;221;0
WireConnection;220;0;222;0
WireConnection;220;1;218;0
WireConnection;221;0;224;0
WireConnection;221;1;219;0
WireConnection;223;0;220;0
WireConnection;224;0;223;0
WireConnection;224;1;223;0
WireConnection;260;0;258;0
WireConnection;260;1;259;0
WireConnection;262;0;261;0
WireConnection;266;0;262;0
WireConnection;268;0;271;0
WireConnection;269;0;268;0
WireConnection;269;1;270;0
WireConnection;271;0;222;0
WireConnection;271;1;272;0
WireConnection;273;0;269;0
WireConnection;158;0;157;0
WireConnection;122;0;269;0
WireConnection;306;0;251;0
WireConnection;306;1;288;1
WireConnection;151;0;150;0
WireConnection;149;0;141;0
WireConnection;149;1;151;0
WireConnection;95;0;77;0
WireConnection;95;1;94;0
WireConnection;248;0;251;0
WireConnection;248;1;247;0
WireConnection;288;0;247;0
WireConnection;287;0;288;0
WireConnection;287;1;306;0
WireConnection;287;2;288;2
WireConnection;287;3;288;3
WireConnection;126;0;1;0
WireConnection;251;0;260;0
WireConnection;1;0;247;0
WireConnection;1;1;3;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;1;4;7;0
WireConnection;289;0;247;0
WireConnection;289;1;292;0
WireConnection;290;0;289;0
WireConnection;291;0;290;0
WireConnection;291;1;293;0
WireConnection;308;0;78;0
WireConnection;308;1;316;0
WireConnection;316;0;311;0
ASEEND*/
//CHKSM=094F686B810508208D6CBE7A743E5F6B06E8C19C