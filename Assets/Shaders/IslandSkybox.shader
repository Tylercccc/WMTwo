// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Skybox/IslandSkybox"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 0", 2D) = "white" {}
		_Float0("Float 0", Float) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		_Contrast("Contrast", Range( 0 , 1)) = 0
		_Speed("Speed", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Background" "Queue"="Background" "PreviewType"="Skybox" }
	LOD 0

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Off
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		
		
		
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
			#define ASE_NEEDS_FRAG_WORLD_POSITION


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
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _TextureSample0;
			uniform sampler2D _TextureSample1;
			uniform float _Speed;
			uniform float _Float0;
			uniform float _Contrast;
			uniform float4 _Color0;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				
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
				float3 normalizeResult2093 = normalize( WorldPosition );
				float3 break2092 = normalizeResult2093;
				float2 appendResult2038 = (float2(( atan2( break2092.x , break2092.z ) / 6.28318548202515 ) , ( asin( break2092.y ) / ( UNITY_PI / 2.0 ) )));
				float2 UVSkybox2039 = appendResult2038;
				float2 panner2095 = ( _SinTime.x * float2( 0.04,0 ) + UVSkybox2039);
				float mulTime2100 = _Time.y * _Speed;
				float2 panner2101 = ( mulTime2100 * float2( 0,1 ) + UVSkybox2039);
				float4 tex2DNode2098 = tex2D( _TextureSample1, panner2101 );
				float4 temp_output_2102_0 = ( tex2D( _TextureSample0, panner2095 ) * tex2DNode2098 );
				float4 temp_output_2109_0 = ( ( floor( ( temp_output_2102_0 * _Float0 ) ) / _Float0 ) + _Contrast );
				float4 temp_output_2110_0 = ( temp_output_2109_0 * _Color0 );
				
				
				finalColor = temp_output_2110_0;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback "Skybox/Cubemap"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;2033;-1648.634,440.0536;Inherit;False;1598.481;501.0421;Skybox UV;15;2093;2092;2091;2090;2089;2088;2087;2039;2038;2037;2036;2035;2100;2122;2121;;0.4027907,1,0,1;0;0
Node;AmplifyShaderEditor.ATan2OpNode;2035;-928.6335,488.0536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2036;-736.6335,488.0536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2037;-752.6335,696.0536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2038;-592.6335,616.0536;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PiNode;2087;-1048.634,796.0536;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2088;-872.6335,796.0536;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TauNode;2089;-912.6335,584.0536;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ASinOpNode;2090;-942.6335,692.0536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2091;-1596.634,663.0536;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BreakToComponentsNode;2092;-1280.634,664.0536;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NormalizeNode;2093;-1421.634,665.0536;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2109;1093.849,679.9272;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.7735849;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2110;1695.687,792.2232;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2112;874.522,923.82;Inherit;False;Property;_Contrast;Contrast;5;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;2105;744.3329,696.59;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2103;541.2639,539.8159;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2119;353.2092,961.3956;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2120;457.4485,200.6047;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;2039;-448.6335,600.0536;Inherit;False;UVSkybox;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2118;1.596517,205.2724;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2115;-105.861,884.2186;Inherit;False;0;2098;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2116;230.1033,798.4843;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2102;582.2935,254.4775;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;2122;-499.3647,785.6213;Inherit;False;Property;_Tiling;Tiling;6;0;Create;True;0;0;0;False;0;False;0,0;-0.53,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;2097;140.0795,-117.2242;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;ca448943ac4f143e4b61ab12dc271fd9;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;2123;852.0695,453.4574;Inherit;False;Normal From Height;-1;;1;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;1;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;2124;1355.807,400.3159;Inherit;False;ColorBurn;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;2126;857.8373,1428.307;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;2127;1075.698,1440.327;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;2130;1437.698,1349.327;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.AbsOpNode;2131;1426.698,1566.327;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2132;1585.698,1458.327;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2133;1768.849,1360.55;Inherit;True;Property;_Clouds;Clouds;2;0;Create;True;0;0;0;False;0;False;-1;None;737606a54d1820743b1a2b4b990b7465;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;2128;1261.698,1446.327;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SamplerNode;2098;86.16353,403.0277;Inherit;True;Property;_TextureSample1;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;737606a54d1820743b1a2b4b990b7465;True;0;False;white;LockedToTexture2D;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2121;-202.573,567.3433;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2104;518.8826,833.269;Inherit;False;Property;_Float0;Float 0;3;0;Create;True;0;0;0;False;0;False;0;5.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2135;980.293,1068.17;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;2136;1415.436,1121.474;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DitheringNode;2134;468.8158,721.0536;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2137;695.364,1194.936;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2106;926.5455,686.4945;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;2107;1389.143,550.4187;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2111;1234.656,853.3223;Inherit;False;Property;_Color0;Color 0;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1241243,0.03466536,0.1792453,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1194;848.1337,191.689;Float;False;True;-1;2;ASEMaterialInspector;0;5;Skybox/IslandSkybox;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;255;False;;255;False;;255;False;;7;False;;1;False;;1;False;;1;False;;7;False;;1;False;;1;False;;1;False;;False;True;2;False;;True;0;False;;True;False;0;False;;0;False;;True;3;RenderType=Background=RenderType;Queue=Background=Queue=0;PreviewType=Skybox;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;Skybox/Cubemap;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2117;-317.2806,128.0315;Inherit;False;0;2097;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;2095;-376.1038,319.0693;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinTimeNode;2138;-594.0195,156.5815;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;2096;-645.2057,336.7009;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;2100;-306.848,800.6985;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;2101;-117.8794,681.2845;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2139;-301.2245,987.3024;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
WireConnection;2035;0;2092;0
WireConnection;2035;1;2092;2
WireConnection;2036;0;2035;0
WireConnection;2036;1;2089;0
WireConnection;2037;0;2090;0
WireConnection;2037;1;2088;0
WireConnection;2038;0;2036;0
WireConnection;2038;1;2037;0
WireConnection;2088;0;2087;0
WireConnection;2090;0;2092;1
WireConnection;2092;0;2093;0
WireConnection;2093;0;2091;0
WireConnection;2109;0;2106;0
WireConnection;2109;1;2112;0
WireConnection;2110;0;2109;0
WireConnection;2110;1;2111;0
WireConnection;2105;0;2103;0
WireConnection;2103;0;2102;0
WireConnection;2103;1;2104;0
WireConnection;2119;0;2101;0
WireConnection;2119;1;2115;0
WireConnection;2120;0;2095;0
WireConnection;2120;1;2117;0
WireConnection;2039;0;2038;0
WireConnection;2118;0;2095;0
WireConnection;2118;1;2117;0
WireConnection;2118;2;2039;0
WireConnection;2116;0;2101;0
WireConnection;2116;1;2115;0
WireConnection;2116;2;2039;0
WireConnection;2102;0;2097;0
WireConnection;2102;1;2098;0
WireConnection;2097;1;2095;0
WireConnection;2123;20;2102;0
WireConnection;2127;0;2126;0
WireConnection;2130;0;2128;0
WireConnection;2130;1;2128;2
WireConnection;2131;0;2128;1
WireConnection;2132;0;2130;0
WireConnection;2132;1;2131;0
WireConnection;2133;1;2132;0
WireConnection;2128;0;2127;0
WireConnection;2098;1;2101;0
WireConnection;2121;0;2039;0
WireConnection;2121;1;2122;0
WireConnection;2135;0;2110;0
WireConnection;2135;1;2133;0
WireConnection;2136;0;2110;0
WireConnection;2136;1;2133;0
WireConnection;2136;2;2133;0
WireConnection;2134;0;2098;0
WireConnection;2137;0;2039;0
WireConnection;2137;1;2132;0
WireConnection;2106;0;2105;0
WireConnection;2106;1;2104;0
WireConnection;2107;0;2109;0
WireConnection;1194;0;2110;0
WireConnection;2095;0;2039;0
WireConnection;2095;1;2138;1
WireConnection;2100;0;2139;0
WireConnection;2101;0;2039;0
WireConnection;2101;1;2100;0
ASEEND*/
//CHKSM=6A25AB5FBD9A7BB67DE894769EBD7BE7A77753AD