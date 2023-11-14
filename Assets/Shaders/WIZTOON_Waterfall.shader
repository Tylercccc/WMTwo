// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WIZTOON_Waterfall"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.35
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.0
		#pragma surface surf StandardCustomLighting keepalpha noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPosition;
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

		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Cutoff = 0.35;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			half eyeDepth435 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			half temp_output_437_0 = abs( ( eyeDepth435 - ase_screenPos.w ) );
			half FoamDepthFade691 = temp_output_437_0;
			half temp_output_693_0 = FoamDepthFade691;
			half3 temp_cast_0 = (temp_output_693_0).xxx;
			c.rgb = temp_cast_0;
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
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;450;-4267.783,1840.563;Inherit;False;1106.2;503.3005;Comment;10;440;441;442;443;444;445;446;447;448;449;Cepth Control;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-4574.59,566.6649;Inherit;False;595.6497;280;Comment;1;259;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;259;-4202.939,635.7206;Inherit;False;normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;416;-5556.146,1076.123;Inherit;False;1281.603;457.1994;Blend panning normals to fake noving ripples;7;423;422;421;420;419;418;417;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;418;-5177.546,1363.221;Float;False;Property;_NormalScale;Normal Scale;4;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;423;-4449.543,1278.922;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;421;-4876.545,1344.322;Inherit;True;Property;_WaterNormal;Water Normal;2;0;Create;True;0;0;0;False;0;False;-1;None;c78e565eaf65cb1428fac66341a4a8bc;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;432;-5457.684,2051.365;Inherit;False;843.903;553.8391;Screen depth difference to get intersection and fading effect with terrain and objects;5;437;436;435;434;433;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;433;-5414.827,2131.204;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;443;-4101.583,1890.563;Float;False;Property;_DeepColor;Deep Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.01868992,0.4734451,0.7924528,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;445;-3859.182,1979.764;Float;False;Property;_ShalowColor;Shalow Color;5;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.739854,0.8413892,0.9622642,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;446;-3653.587,2211.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;447;-3555.09,1953.481;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;448;-3553.19,2046.081;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;449;-3343.582,2087.365;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;434;-5414.683,2298.865;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;435;-5187.683,2104.365;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;417;-5506.146,1153.422;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;470;-5702.961,1300.054;Inherit;False;Property;_refreactsteps;refreact steps;12;0;Create;True;0;0;0;False;0;False;0;2;0;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;466;-5633.232,1617.024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;467;-5333.317,1473.493;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;420;-5231.146,1238.622;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0.04;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;419;-5233.446,1124.407;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.03,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;471;-5846.468,1623.348;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;472;-5712.078,1494.699;Inherit;False;Property;_Float0;Float 0;15;0;Create;True;0;0;0;False;0;False;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;458;-343.7294,919.8429;Float;False;Global;_WaterGrab;WaterGrab;-1;0;Create;True;0;0;0;False;0;False;Object;-1;False;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;483;-1207.767,1003.649;Inherit;False;Sai_DepthMaskedRefraction;-1;;1;bb954a2a716624fed8b85e64959850f3;2,40,0,103,0;2;35;FLOAT3;0,0,0;False;37;FLOAT;0.02;False;1;FLOAT2;38
Node;AmplifyShaderEditor.RangedFloatNode;452;-1439.647,1173.904;Float;False;Property;_Distortion;Distortion;9;0;Create;True;0;0;0;False;0;False;0.5;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;484;-3980.134,2479.743;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;487;-3702.907,2452.007;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;488;-3951.742,2720.06;Inherit;False;Property;_DitherDepth;Dither Depth;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;489;-1217.752,2099.232;Inherit;False;1083.102;484.2006;Foam controls and texture;9;498;497;496;495;494;493;492;491;490;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;490;-1096.051,2223.132;Float;False;Property;_FoamDepth;Foam Depth;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-915.8494,2149.232;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;493;-905.2504,2285.032;Float;False;Property;_FoamFalloff;Foam Falloff;16;0;Create;True;0;0;0;False;0;False;0;0.53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;494;-731.0498,2158.132;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;497;-509.8487,2206.132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;422;-4889.446,1134.422;Inherit;True;Property;_Normal2;Normal2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;504;-1217.635,2641.278;Inherit;False;Property;_Foamtiling;Foam tiling;19;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;515;134.3433,1010.884;Inherit;False;Property;_Displacement;Displacement;21;0;Create;True;0;0;0;False;0;False;0;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;149.4731,1502.328;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;506;-228.3755,1944.643;Inherit;False;Property;_foamdepthfade;foam depth fade;20;0;Create;True;0;0;0;False;0;False;0;11.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;501;438.1416,2256.907;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;-298.5065,2310.249;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;500;299.8668,2603.334;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;542;-86.02277,2639.02;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;549;-284.3555,2649.823;Inherit;False;Property;_test;test;22;0;Create;True;0;0;0;False;0;False;0;4.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;550;-291.769,2839.879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;548;634.6291,2480.725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;444;-3859.888,2189.881;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;441;-4040.283,2228.864;Float;False;Property;_WaterFalloff;Water Falloff;8;0;Create;True;0;0;0;False;0;False;0;-0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;442;-4036.088,2103.481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;440;-4214.159,2240.276;Float;False;Property;_WaterDepth;Water Depth;6;0;Create;True;0;0;0;False;0;False;0;3.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;464;-4202.739,2380.116;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;463;-4331.841,2365.851;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;465;-4400.226,2582.292;Inherit;False;Property;_Depthsteps;Depth steps;11;0;Create;True;0;0;0;False;0;False;0;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;437;-4741.509,2194.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;436;-4950.284,2187.349;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;512;90.62681,2076.889;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;502;147.9153,2397.845;Inherit;False;Property;_foamsteps;foam steps;18;0;Create;True;0;0;0;False;0;False;0;0.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;553;857.0134,2161.56;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;554;672.8892,2069.499;Inherit;False;Property;_s;s;23;0;Create;True;0;0;0;False;0;False;0;10.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;854.1097,2453.01;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;545;596.8235,2150.306;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;459;-1504.995,2087.115;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;562;-979.7932,1828.173;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;563;-3627.864,838.2031;Inherit;False;528.8752;183;;2;565;564;Is Point Light?;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;564;-3579.864,886.2034;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;565;-3339.864,902.2034;Inherit;False;IsPointLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;566;-2989.093,819.65;Inherit;False;936.9688;707.0591;;9;573;572;571;570;569;568;567;574;575;Light Attenuation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;567;-2914.888,869.65;Inherit;False;Property;_PointLightAttenuationBoost;PointLight Attenuation Boost;7;0;Create;True;0;0;0;False;0;False;1;3.78;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;-2901.187,1013.058;Inherit;False;565;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;569;-2881.849,1138.442;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;570;-2627.447,929.019;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;571;-2979.093,1254.973;Inherit;False;565;IsPointLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;572;-2762.193,1258.556;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;573;-2535.825,1209.259;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;574;-2318.184,1125.094;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;575;-2173.077,1299.502;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;577;-1889.839,1291.13;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;576;-2072.619,1140.442;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;581;-1693.163,1349.307;Inherit;False;888.2502;342.3433;;4;585;584;583;582;Posterising Point Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;584;-919.6096,1421.987;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RelayNode;585;-1381.844,1546.396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;590;-3140.404,314.9966;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;591;-2928.622,331.1325;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;593;-3309.831,181.8763;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;592;-2688.602,371.4719;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;595;-2825.755,611.4918;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;594;-2545.395,486.4394;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;596;-2353.782,506.6095;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;598;-2072.943,399.7094;Inherit;True;Property;_TextureSample0;Texture Sample 0;27;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;600;-1635.534,519.6509;Inherit;False;Ripples;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;597;-2613.972,684.103;Inherit;False;Constant;_Float1;Float 1;27;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;587;-3580.032,132.7867;Inherit;False;Global;_Position;_Position;24;0;Create;True;0;0;0;False;0;False;0,0,0;-209.6,107.3,-490.37;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;589;-3501.912,542.4119;Inherit;False;Global;_OrthographicCamSize;_OrthographicCamSize;26;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;599;-2428.972,133.538;Inherit;True;Global;_GlobalEffectRT;GlobalEffectRT;26;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;602;42.41667,1743.49;Inherit;False;600;Ripples;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;559;1104.648,2228.182;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;496;-676.5046,2371.432;Inherit;True;Property;_Foam;Foam;13;0;Create;True;0;0;0;False;0;False;-1;None;2a2d71ee416d3c844adfa1a053ea32f4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;509;818.1746,1826.923;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;610;631.3865,1866.046;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;613;-106.6952,1873.026;Inherit;False;Property;_ripple_step;ripple_step;25;0;Create;True;0;0;0;False;0;False;0;0.392;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;611;278.2368,1812.9;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;612;415.4452,1922.566;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;557;1018.922,1852.692;Inherit;False;Property;_FoamColor;Foam Color;24;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1326985,0.241095,0.3962264,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;618;1313.147,1742.476;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;556;944.3687,1642.761;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;586;-2001.882,1783.163;Inherit;False;Property;_Steps;Steps;3;1;[IntRange];Create;True;0;0;0;False;0;False;5;2;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;582;-1272.52,1419.782;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;621;452.3575,996.3546;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;583;-1099.005,1422.616;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;626;861.2595,1249.019;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;630;1063.987,1154.712;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;460;-1629.441,1024.048;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;578;-643.0464,1334.994;Inherit;False;PointLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;631;-4043.35,1361.746;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;632;-4250.899,1452.634;Inherit;False;600;Ripples;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;634;-666.9629,1968;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;633;-513.457,1880.561;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;635;-338.5768,1797.006;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;636;-394.9271,2037.953;Inherit;False;Property;_TestStepper;TestStepper;27;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;637;-1091.576,2045.499;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;638;-1313.293,2229.251;Inherit;False;Property;_ColorMult;ColorMult;28;0;Create;True;0;0;0;False;0;False;0;1.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1376.78,462.0296;Half;False;True;-1;4;ASEMaterialInspector;0;0;CustomLighting;WIZTOON_Waterfall;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.35;True;False;0;True;TransparentCutout;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;644;-230.6167,615.412;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;462;534.0004,174.2953;Inherit;False;Property;_Watertint;Water tint;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;646;-444.5635,48.70652;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;656;-2.902024,13.37733;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;657;1051.811,235.828;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;513;63.8671,826.9426;Inherit;False;259;normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;664;651.1024,628.989;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;661;442.1024,671.989;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;660;280.1024,575.989;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;666;1026.102,722.989;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;667;922.1024,790.989;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;668;1127.102,831.989;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;580;750.3335,915.165;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;619;653.3218,1352.964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;579;191.2078,1158.465;Inherit;False;578;PointLight;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;669;954.1023,931.989;Inherit;False;Constant;_Float4;Float 4;31;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;514;244.6349,903.9972;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;645;25.05823,505.201;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;651;-141.7557,186.7643;Inherit;False;Property;_WaterfallHeight;Waterfall Height;29;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;640;-507.8904,311.6036;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;643;-509.1076,619.4818;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;652;884.597,505.762;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;672;688.1455,509.6296;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;659;274.9008,825.857;Inherit;False;Constant;_Float3;Float 3;31;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;673;480.1455,593.6296;Inherit;False;Constant;_Float5;Float 3;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;674;912.1455,655.6296;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;671;-692.3281,464.1947;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;642;-967.9237,611.7135;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;5,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;655;-319.149,-63.22908;Inherit;False;Property;_WaterfallGradientDistribution;Waterfall Gradient Distribution;30;0;Create;True;0;0;0;False;0;False;1;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;676;-560.993,-176.3107;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;678;-432.1812,241.4919;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;641;-927.1084,237.1439;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;6,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;677;-930.7542,99.10518;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;650;139.8694,177.5023;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;680;-1079.089,375.3837;Inherit;False;Constant;_Float6;Float 6;32;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;675;-797.1898,-72.3442;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;684;-465.3108,445.4199;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;686;-858.9111,359.0074;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;679;-715.11,395.3156;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;687;-1076.054,515.4655;Inherit;False;Constant;_Float7;Float 7;32;0;Create;True;0;0;0;False;0;False;-2.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;670;-911.5639,478.5698;Inherit;False;Property;_WaterFallSpeed;WaterFallSpeed;31;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;689;-1160.17,533.6735;Inherit;False;Constant;_Float8;Float 8;32;0;Create;True;0;0;0;False;0;False;0.63;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;639;-265.8908,304.4931;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;688;77.01453,289.2718;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;690;1535.316,1031.915;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;505;306.4586,2077.939;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;649;410.0659,370.3351;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;692;1443.916,1110.602;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;693;1217.653,1223.733;Inherit;False;691;FoamDepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;551;5.8342,2926.004;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;695;-743.2145,2738.012;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;694;-1034.734,2736.747;Inherit;False;Property;_BottomFoamSpeed;Bottom Foam Speed;32;0;Create;True;0;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;492;-1196.904,2396.633;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;495;-947.0486,2416.832;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;691;-4807.541,2604.984;Inherit;False;FoamDepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;259;0;631;0
WireConnection;423;0;422;0
WireConnection;423;1;421;0
WireConnection;421;1;420;0
WireConnection;421;5;418;0
WireConnection;446;0;487;0
WireConnection;447;0;443;0
WireConnection;448;0;445;0
WireConnection;449;0;447;0
WireConnection;449;1;448;0
WireConnection;449;2;446;0
WireConnection;435;0;433;0
WireConnection;466;0;471;0
WireConnection;467;0;466;0
WireConnection;467;1;470;0
WireConnection;420;0;417;0
WireConnection;420;1;467;0
WireConnection;419;0;417;0
WireConnection;419;1;467;0
WireConnection;471;0;472;0
WireConnection;458;0;483;38
WireConnection;483;35;460;0
WireConnection;483;37;452;0
WireConnection;484;0;444;0
WireConnection;487;0;444;0
WireConnection;487;1;488;0
WireConnection;487;2;484;0
WireConnection;487;3;444;0
WireConnection;491;1;490;0
WireConnection;494;0;491;0
WireConnection;494;1;493;0
WireConnection;497;0;551;0
WireConnection;422;1;419;0
WireConnection;422;5;418;0
WireConnection;499;0;635;0
WireConnection;499;1;556;0
WireConnection;501;0;500;0
WireConnection;501;1;502;0
WireConnection;498;0;497;0
WireConnection;498;1;496;1
WireConnection;500;0;542;0
WireConnection;542;0;498;0
WireConnection;542;1;549;0
WireConnection;550;0;494;0
WireConnection;548;0;501;0
WireConnection;444;0;442;0
WireConnection;444;1;441;0
WireConnection;442;0;437;0
WireConnection;442;1;440;0
WireConnection;464;0;463;0
WireConnection;464;1;465;0
WireConnection;463;0;437;0
WireConnection;437;0;436;0
WireConnection;436;0;435;0
WireConnection;436;1;434;4
WireConnection;512;0;506;0
WireConnection;512;1;498;0
WireConnection;553;0;545;0
WireConnection;553;1;554;0
WireConnection;544;0;553;0
WireConnection;544;1;548;0
WireConnection;545;0;505;0
WireConnection;459;0;449;0
WireConnection;459;1;562;0
WireConnection;459;2;446;0
WireConnection;562;0;458;0
WireConnection;565;0;564;2
WireConnection;570;0;567;0
WireConnection;570;1;568;0
WireConnection;570;2;569;0
WireConnection;572;0;571;0
WireConnection;573;0;569;0
WireConnection;573;1;572;0
WireConnection;574;0;570;0
WireConnection;574;1;573;0
WireConnection;575;0;574;0
WireConnection;577;0;576;0
WireConnection;577;1;575;0
WireConnection;584;0;583;0
WireConnection;584;1;585;0
WireConnection;585;0;586;0
WireConnection;591;0;590;1
WireConnection;591;1;590;3
WireConnection;593;0;587;1
WireConnection;593;1;587;3
WireConnection;592;0;591;0
WireConnection;592;1;593;0
WireConnection;595;0;589;0
WireConnection;594;0;592;0
WireConnection;594;1;595;0
WireConnection;596;0;594;0
WireConnection;596;1;597;0
WireConnection;598;0;599;0
WireConnection;598;1;596;0
WireConnection;600;0;598;3
WireConnection;559;0;545;0
WireConnection;559;2;544;0
WireConnection;496;1;495;0
WireConnection;509;0;559;0
WireConnection;610;0;612;0
WireConnection;611;0;602;0
WireConnection;611;1;613;0
WireConnection;612;0;611;0
WireConnection;618;0;610;0
WireConnection;618;1;557;0
WireConnection;556;0;509;0
WireConnection;556;1;557;0
WireConnection;582;0;577;0
WireConnection;582;1;585;0
WireConnection;621;0;579;0
WireConnection;583;0;582;0
WireConnection;626;0;619;0
WireConnection;630;0;626;0
WireConnection;630;1;621;0
WireConnection;578;0;584;0
WireConnection;631;0;423;0
WireConnection;631;1;632;0
WireConnection;634;0;637;0
WireConnection;634;1;636;0
WireConnection;633;0;634;0
WireConnection;635;0;633;0
WireConnection;635;1;636;0
WireConnection;637;0;459;0
WireConnection;637;1;638;0
WireConnection;0;0;462;0
WireConnection;0;2;690;0
WireConnection;0;10;652;0
WireConnection;0;13;580;0
WireConnection;0;11;514;0
WireConnection;0;15;693;0
WireConnection;644;0;643;0
WireConnection;656;0;655;0
WireConnection;656;1;678;0
WireConnection;664;0;649;0
WireConnection;664;1;661;0
WireConnection;661;0;660;0
WireConnection;661;1;659;0
WireConnection;660;0;649;0
WireConnection;666;0;667;0
WireConnection;667;0;664;0
WireConnection;667;1;669;0
WireConnection;668;0;666;0
WireConnection;668;1;669;0
WireConnection;580;0;619;0
WireConnection;580;1;621;0
WireConnection;619;0;618;0
WireConnection;619;1;499;0
WireConnection;514;0;513;0
WireConnection;514;1;515;0
WireConnection;645;0;639;0
WireConnection;645;1;644;0
WireConnection;640;0;641;0
WireConnection;640;1;671;0
WireConnection;643;0;642;0
WireConnection;643;1;671;0
WireConnection;652;0;649;0
WireConnection;672;0;649;0
WireConnection;672;1;673;0
WireConnection;674;0;664;0
WireConnection;671;0;670;0
WireConnection;676;0;675;0
WireConnection;678;0;677;2
WireConnection;650;0;656;0
WireConnection;650;1;651;0
WireConnection;684;0;679;0
WireConnection;686;0;680;0
WireConnection;686;1;677;2
WireConnection;679;0;686;0
WireConnection;679;1;687;0
WireConnection;639;0;640;0
WireConnection;688;0;639;0
WireConnection;688;1;679;0
WireConnection;690;0;668;0
WireConnection;505;0;512;0
WireConnection;649;0;650;0
WireConnection;649;1;645;0
WireConnection;692;0;668;0
WireConnection;692;1;693;0
WireConnection;551;0;550;0
WireConnection;551;1;502;0
WireConnection;695;0;694;0
WireConnection;492;0;504;0
WireConnection;495;0;492;0
WireConnection;691;0;437;0
ASEEND*/
//CHKSM=8A07031FB29A07C0BBEF2CBE7F95E292ABD838BD