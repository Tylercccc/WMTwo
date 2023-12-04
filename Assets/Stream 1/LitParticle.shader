// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Amplify Streams 1/Lit Particle"
{
	Properties
	{
		_NormalStrength("Normal Strength", Range( 0 , 2)) = 0

	}
	
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		Cull Off
		CGINCLUDE
		#pragma target 3.0 
		ENDCG
		
		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" }

			CGINCLUDE
			#pragma target 3.0
			ENDCG
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Back
			ColorMask RGBA
			ZWrite Off
			ZTest LEqual
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#define ASE_SHADOWS 1

			//This is a late directive
			
			uniform float _NormalStrength;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
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
			


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_color : COLOR;
				UNITY_SHADOW_COORDS(1)
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float4 color69 = IsGammaSpace() ? float4(0.4156863,0.3921569,0.3803922,1) : float4(0.1441285,0.1274377,0.1195384,1);
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 ase_worldPos = i.ase_texcoord2.xyz;
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float3 temp_output_66_0 = ( ase_lightColor.rgb * ase_atten );
				float2 uv010 = i.ase_texcoord3 * float2( 2,2 ) + float2( -1,-1 );
				float randomValue49 = i.ase_texcoord3.z;
				float simplePerlin2D31 = snoise( ( uv010 + 2.31 + randomValue49 )*1.5 );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float simplePerlin2D35 = snoise( ( uv010 + 5.08 + randomValue49 )*1.4 );
				simplePerlin2D35 = simplePerlin2D35*0.5 + 0.5;
				float simplePerlin2D36 = snoise( ( uv010 + 8.73 + randomValue49 )*1.3 );
				simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
				float3 appendResult34 = (float3(simplePerlin2D31 , simplePerlin2D35 , simplePerlin2D36));
				float dotResult11 = dot( uv010 , uv010 );
				float temp_output_14_0 = saturate( ( 1.0 - dotResult11 ) );
				float3 appendResult15 = (float3(uv010 , sqrt( temp_output_14_0 )));
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(ase_worldPos);
				float dotResult5 = dot( ( ( (appendResult34*2.0 + -1.0) * _NormalStrength ) + appendResult15 ) , mul( UNITY_MATRIX_I_V, float4( worldSpaceLightDir , 0.0 ) ).xyz );
				float temp_output_80_0 = saturate( (dotResult5*0.5 + 0.5) );
				float3 lerpResult62 = lerp( (color69).rgb , temp_output_66_0 , temp_output_80_0);
				float smoothstepResult60 = smoothstep( 0.0 , 1.0 , temp_output_14_0);
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth28 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth28 = saturate( abs( ( screenDepth28 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 1.0 ) ) );
				float alpha21 = saturate( ( smoothstepResult60 * distanceDepth28 * simplePerlin2D36 * i.ase_color.a ) );
				#ifdef UNITY_PASS_FORWARDADD
				float3 staticSwitch75 = ( ( temp_output_66_0 * temp_output_80_0 ) * alpha21 );
				#else
				float3 staticSwitch75 = ( (i.ase_color).rgb * lerpResult62 );
				#endif
				float3 color20 = staticSwitch75;
				float3 temp_output_25_0 = (color20).xyz;
				
				
				outColor = temp_output_25_0;
				outAlpha = alpha21;
				clip(outAlpha);
				return float4(outColor,outAlpha);
			}
			ENDCG
		}
		
		
		Pass
		{
			Name "ForwardAdd"
			Tags { "LightMode"="ForwardAdd" }
			ZWrite Off
			Blend One One
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd_fullshadows
			#define UNITY_PASS_FORWARDADD
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"
			#define ASE_SHADOWS 1

			//This is a late directive
			
			uniform float _NormalStrength;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
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
			


			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_color : COLOR;
				UNITY_SHADOW_COORDS(1)
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
			};
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord2.xyz = ase_worldPos;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord3 = v.ase_texcoord;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.pos = UnityObjectToClipPos(v.vertex);
				#if ASE_SHADOWS
					#if UNITY_VERSION >= 560
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#else
						TRANSFER_SHADOW( o );
					#endif
				#endif
				return o;
			}
			
			float4 frag (v2f i ) : SV_Target
			{
				float3 outColor;
				float outAlpha;

				float4 color69 = IsGammaSpace() ? float4(0.4156863,0.3921569,0.3803922,1) : float4(0.1441285,0.1274377,0.1195384,1);
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				float4 ase_lightColor = 0;
				#else //aselc
				float4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 ase_worldPos = i.ase_texcoord2.xyz;
				UNITY_LIGHT_ATTENUATION(ase_atten, i, ase_worldPos)
				float3 temp_output_66_0 = ( ase_lightColor.rgb * ase_atten );
				float2 uv010 = i.ase_texcoord3 * float2( 2,2 ) + float2( -1,-1 );
				float randomValue49 = i.ase_texcoord3.z;
				float simplePerlin2D31 = snoise( ( uv010 + 2.31 + randomValue49 )*1.5 );
				simplePerlin2D31 = simplePerlin2D31*0.5 + 0.5;
				float simplePerlin2D35 = snoise( ( uv010 + 5.08 + randomValue49 )*1.4 );
				simplePerlin2D35 = simplePerlin2D35*0.5 + 0.5;
				float simplePerlin2D36 = snoise( ( uv010 + 8.73 + randomValue49 )*1.3 );
				simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
				float3 appendResult34 = (float3(simplePerlin2D31 , simplePerlin2D35 , simplePerlin2D36));
				float dotResult11 = dot( uv010 , uv010 );
				float temp_output_14_0 = saturate( ( 1.0 - dotResult11 ) );
				float3 appendResult15 = (float3(uv010 , sqrt( temp_output_14_0 )));
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(ase_worldPos);
				float dotResult5 = dot( ( ( (appendResult34*2.0 + -1.0) * _NormalStrength ) + appendResult15 ) , mul( UNITY_MATRIX_I_V, float4( worldSpaceLightDir , 0.0 ) ).xyz );
				float temp_output_80_0 = saturate( (dotResult5*0.5 + 0.5) );
				float3 lerpResult62 = lerp( (color69).rgb , temp_output_66_0 , temp_output_80_0);
				float smoothstepResult60 = smoothstep( 0.0 , 1.0 , temp_output_14_0);
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth28 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float distanceDepth28 = saturate( abs( ( screenDepth28 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 1.0 ) ) );
				float alpha21 = saturate( ( smoothstepResult60 * distanceDepth28 * simplePerlin2D36 * i.ase_color.a ) );
				#ifdef UNITY_PASS_FORWARDADD
				float3 staticSwitch75 = ( ( temp_output_66_0 * temp_output_80_0 ) * alpha21 );
				#else
				float3 staticSwitch75 = ( (i.ase_color).rgb * lerpResult62 );
				#endif
				float3 color20 = staticSwitch75;
				float3 temp_output_25_0 = (color20).xyz;
				
				
				outColor = temp_output_25_0;
				outAlpha = alpha21;
				clip(outAlpha);
				return float4(outColor,outAlpha);
			}
			ENDCG
		}

	
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17501
410;571;1107;750;4006.293;2189.885;4.275621;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;48;-2276.236,236.0185;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-2021.929,284.6361;Inherit;False;randomValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2938.52,-704.3874;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;-1,-1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;41;-2945.059,-1070.306;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;5.08;5.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-2971.426,-1136.136;Inherit;False;49;randomValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2956.892,-918.1671;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;False;0;8.73;8.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-2948.376,-991.7683;Inherit;False;49;randomValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-2918.046,-800.0863;Inherit;False;49;randomValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2967.035,-1203.849;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;2.31;2.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-2615.425,-809.9796;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-2647.543,-1234.277;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-2671.344,-594.6571;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-2635.71,-1002.688;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;35;-2412.574,-1170.041;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;-2548.451,-596.1356;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-2405.813,-935.0715;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;31;-2410.691,-1390.64;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-2388.872,-593.6412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;90;-1826,-1314;Inherit;False;281;206;;1;89;make it -1 to 1 range;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-2041.269,-1257.512;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2110.79,-999.0842;Inherit;False;Property;_NormalStrength;Normal Strength;0;0;Create;True;0;0;False;0;0;0.5011627;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;89;-1776,-1264;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SqrtOpNode;13;-2214.564,-595.3022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;6;-1568,-320;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.InverseViewMatrixNode;8;-1504,-400;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2036.816,-705.8705;Inherit;True;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-1536,-1008;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1296,-656;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;28;-2347.561,-261.0648;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;60;-2277.132,-397.856;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;53;-2307.88,-157.1947;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1248,-352;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-1056,-512;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2084.681,-342.8893;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;61;-806.6984,-806.6362;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;65;-834.3133,-689.8135;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;81;-1923.32,-334.8259;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;30;-896,-512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;69;-1128.169,-239.0258;Inherit;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;0.4156863,0.3921569,0.3803922,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;80;-528.7467,-509.5168;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1771.836,-338.082;Inherit;False;alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-608.2866,-746.1816;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;70;-813.4218,-367.989;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;54;-512,-1024;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;-259.0991,-528.0122;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;62;-345.6858,-764.7627;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;55;-336,-1024;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;87;-281.0148,-350.0973;Inherit;False;21;alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;4.977526,-855.7797;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;71.80814,-534.2193;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;75;278.5981,-586.3221;Inherit;False;Property;_Keyword0;Keyword 0;1;0;Create;True;0;0;False;0;0;0;0;False;UNITY_PASS_FORWARDADD;Toggle;2;Key0;Key1;Fetch;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;629.4156,-584.3688;Inherit;False;color;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;112,-16;Inherit;False;20;color;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;25;304,-16;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;3;480,0;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;288,96;Inherit;False;21;alpha;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;73;640,171;Float;False;False;-1;2;ASEMaterialInspector;100;8;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;Deferred;0;2;Deferred;4;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=Deferred;True;2;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;74;640,0;Float;False;False;-1;2;ASEMaterialInspector;100;1;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ShadowCaster;0;3;ShadowCaster;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;;0;0;Standard;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;71;640,0;Float;False;True;-1;2;ASEMaterialInspector;100;16;Amplify Streams 1/Lit Particle;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardBase;0;0;ForwardBase;3;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;False;0;False;-1;0;False;-1;True;1;LightMode=ForwardBase;True;2;0;;0;0;Standard;0;0;4;True;True;False;False;False;;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;72;640,107;Float;False;False;-1;2;ASEMaterialInspector;100;16;New Amplify Shader;e1de45c0d41f68c41b2cc20c8b9c05ef;True;ForwardAdd;0;1;ForwardAdd;0;False;False;False;True;2;False;-1;False;False;False;False;False;True;1;RenderType=Opaque=RenderType;True;2;0;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;True;2;False;-1;False;False;True;1;LightMode=ForwardAdd;False;0;;0;0;Standard;0;0
WireConnection;49;0;48;3
WireConnection;39;0;10;0
WireConnection;39;1;42;0
WireConnection;39;2;52;0
WireConnection;37;0;10;0
WireConnection;37;1;40;0
WireConnection;37;2;50;0
WireConnection;11;0;10;0
WireConnection;11;1;10;0
WireConnection;38;0;10;0
WireConnection;38;1;41;0
WireConnection;38;2;51;0
WireConnection;35;0;38;0
WireConnection;12;0;11;0
WireConnection;36;0;39;0
WireConnection;31;0;37;0
WireConnection;14;0;12;0
WireConnection;34;0;31;0
WireConnection;34;1;35;0
WireConnection;34;2;36;0
WireConnection;89;0;34;0
WireConnection;13;0;14;0
WireConnection;15;0;10;0
WireConnection;15;2;13;0
WireConnection;46;0;89;0
WireConnection;46;1;47;0
WireConnection;44;0;46;0
WireConnection;44;1;15;0
WireConnection;60;0;14;0
WireConnection;9;0;8;0
WireConnection;9;1;6;0
WireConnection;5;0;44;0
WireConnection;5;1;9;0
WireConnection;29;0;60;0
WireConnection;29;1;28;0
WireConnection;29;2;36;0
WireConnection;29;3;53;4
WireConnection;81;0;29;0
WireConnection;30;0;5;0
WireConnection;80;0;30;0
WireConnection;21;0;81;0
WireConnection;66;0;61;1
WireConnection;66;1;65;0
WireConnection;70;0;69;0
WireConnection;88;0;66;0
WireConnection;88;1;80;0
WireConnection;62;0;70;0
WireConnection;62;1;66;0
WireConnection;62;2;80;0
WireConnection;55;0;54;0
WireConnection;56;0;55;0
WireConnection;56;1;62;0
WireConnection;86;0;88;0
WireConnection;86;1;87;0
WireConnection;75;1;56;0
WireConnection;75;0;86;0
WireConnection;20;0;75;0
WireConnection;25;0;22;0
WireConnection;3;0;25;0
WireConnection;3;3;23;0
WireConnection;71;0;25;0
WireConnection;71;1;23;0
ASEEND*/
//CHKSM=9CA4E37E2A16CCE0499672F8BC6DB7734E6649F9