// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/QuadsToBillboardsDitherClouds"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BillboardEffect("Billboard Effect", Range( 0 , 1)) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Shading("Shading", Range( 0 , 1)) = 0
		_Color("Color", Color) = (0.3949776,0.8207547,0.1974457,0)
		_unlitcolour("unlit colour", Color) = (0.3949776,0.8207547,0.1974457,0)
		_bouncecolour("bounce colour", Color) = (0.3949776,0.8207547,0.1974457,0)
		_SSSPower("SSS Power", Float) = 1
		_SSSScale("SSS Scale", Float) = 1
		_CircleGradientSize("Circle Gradient Size", Range( 0 , 1)) = 0.5
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_EdgeFadeScale("Edge Fade Scale", Float) = 0
		_EdgeFadePower("Edge Fade Power", Float) = 0
		_RotationSpeed("Rotation Speed", Float) = 0
		_bluenoise("bluenoise", 2D) = "white" {}
		[Toggle]_limitbackfacing1("limit backfacing", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5

		struct appdata_full_custom
		{
			float4 vertex : POSITION;
			float4 tangent : TANGENT;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 texcoord1 : TEXCOORD1;
			float4 texcoord2 : TEXCOORD2;
			float4 texcoord3 : TEXCOORD3;
			fixed4 color : COLOR;
			UNITY_VERTEX_INPUT_INSTANCE_ID
			uint ase_vertexId : SV_VertexID;
		};
		struct Input
		{
			float3 worldPos;
			uint ase_vertexId;
			float4 screenPosition;
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
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

		uniform float _BillboardEffect;
		uniform float _limitbackfacing1;
		uniform sampler2D _bluenoise;
		float4 _bluenoise_TexelSize;
		uniform sampler2D _MainTex;
		uniform float _RotationSpeed;
		uniform float _CircleGradientSize;
		uniform float _Opacity;
		uniform float _EdgeFadeScale;
		uniform float _EdgeFadePower;
		uniform float4 _bouncecolour;
		uniform float4 _unlitcolour;
		uniform float4 _Color;
		uniform float _SSSPower;
		uniform float _SSSScale;
		uniform float _Shading;
		uniform float _Cutoff = 0.5;


		inline float DitherNoiseTex( float4 screenPos, sampler2D noiseTexture, float4 noiseTexelSize )
		{
			float dither = tex2Dlod( noiseTexture, float4(screenPos.xy * _ScreenParams.xy * noiseTexelSize.xy, 0, 0) ).g;
			float ditherRate = noiseTexelSize.x * noiseTexelSize.y;
			dither = ( 1 - ditherRate ) * dither + ditherRate;
			return dither;
		}


		void vertexDataFunc( inout appdata_full_custom v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_output_34_0 = (v.texcoord.xy*2.0 + -1.0);
			float3 appendResult10 = (float3(temp_output_34_0 , 0.0));
			float3 normalizeResult18 = normalize( mul( float4( mul( float4( appendResult10 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), unity_ObjectToWorld ).xyz );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float dotResult344 = dot( ase_worldViewDir , ase_worldNormal );
			float smoothstepResult346 = smoothstep( -0.8 , -0.6 , dotResult344);
			float3 VertexOffset300 = ( normalizeResult18 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult346 ):( 1.0 )) );
			v.vertex.xyz += VertexOffset300;
			v.vertex.w = 1;
			o.ase_vertexId = v.ase_vertexId;
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
			float2 temp_cast_0 = (floor( ( i.ase_vertexId / 4.0 ) )).xx;
			float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
			float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
			float Randombyface01284 = lerpResult10_g1;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float4 ditherCustomScreenPos167 = ( Randombyface01284 + ase_screenPosNorm );
			float dither167 = DitherNoiseTex(ditherCustomScreenPos167, _bluenoise, _bluenoise_TexelSize);
			float cos183 = cos( ( ( _RotationSpeed * (Randombyface01284*2.0 + -1.0) * _Time.y ) + ( Randombyface01284 * 6.2832 ) ) );
			float sin183 = sin( ( ( _RotationSpeed * (Randombyface01284*2.0 + -1.0) * _Time.y ) + ( Randombyface01284 * 6.2832 ) ) );
			float2 rotator183 = mul( i.uv_texcoord - float2( 0.5,0.5 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0.5,0.5 );
			float2 rotatingUVs309 = rotator183;
			float4 tex2DNode179 = tex2D( _MainTex, rotatingUVs309 );
			float2 temp_output_34_0 = (i.uv_texcoord*2.0 + -1.0);
			float circleGradient307 = saturate( (0.0 + (( 1.0 - length( temp_output_34_0 ) ) - ( 1.0 - _CircleGradientSize )) * (1.0 - 0.0) / (1.0 - ( 1.0 - _CircleGradientSize ))) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV262 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode262 = ( 0.0 + _EdgeFadeScale * pow( 1.0 - fresnelNdotV262, _EdgeFadePower ) );
			dither167 = step( dither167, ( tex2DNode179.a * circleGradient307 * _Opacity * ( 1.0 - saturate( fresnelNode262 ) ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult155 = dot( ase_worldNormal , ase_worldlightDir );
			float temp_output_158_0 = saturate( ( dotResult155 * ase_lightAtten ) );
			float dotResult247 = dot( -ase_worldlightDir , i.viewDir );
			float fresnelNdotV334 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode334 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV334, 1.0 ) );
			float dotResult255 = dot( pow( ( (dotResult247*0.5 + 0.5) * saturate( fresnelNode334 ) ) , _SSSPower ) , _SSSScale );
			float SSScontribution325 = ( ase_lightAtten * dotResult255 );
			c.rgb = ( ( ase_lightColor * ( ( _bouncecolour * saturate( -dotResult155 ) * ( 1.0 - _WorldSpaceLightPos0.w ) * ase_lightAtten ) + ( saturate( ( 1.0 - temp_output_158_0 ) ) * _unlitcolour ) + ( temp_output_158_0 * _Color ) + SSScontribution325 ) * saturate( ( ( ase_lightAtten * _WorldSpaceLightPos0.w ) + ( 1.0 - _WorldSpaceLightPos0.w ) ) ) ) * saturate( (( 1.0 - _Shading ) + (tex2DNode179.r - 0.0) * (1.0 - ( 1.0 - _Shading )) / (1.0 - 0.0)) ) ).rgb;
			c.a = 1;
			clip( dither167 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
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
				float3 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full_custom v )
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
				o.worldNormal = worldNormal;
				o.customPack1.x = customInputData.ase_vertexId;
				o.customPack2.xyzw = customInputData.screenPosition;
				o.customPack1.yz = customInputData.uv_texcoord;
				o.customPack1.yz = v.texcoord;
				o.worldPos = worldPos;
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
				surfIN.ase_vertexId = IN.customPack1.x;
				surfIN.screenPosition = IN.customPack2.xyzw;
				surfIN.uv_texcoord = IN.customPack1.yz;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
Version=18900
275;722;1857;800;4343.436;374.7321;1.727468;True;False
Node;AmplifyShaderEditor.CommentaryNode;220;-3046.909,1499.559;Inherit;False;709.2708;225.0601;Group 4 verts together to get a stable Face ID;4;219;218;217;196;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-2826.909,1645.619;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexIdVariableNode;196;-2989.218,1562.37;Inherit;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;218;-2664.57,1549.559;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;237;-1392,-2592;Inherit;False;2197.443;584.241;;15;325;258;256;255;254;253;252;259;244;247;245;240;334;335;336;Subsurface Scattering Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;221;-2298.824,1491.633;Inherit;False;506.1724;241.8636;Random Range to 2*pi (a full rotation in radians);2;197;284;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FloorOpNode;219;-2487.638,1572.456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;240;-1328,-2544;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;197;-2261.961,1558.711;Inherit;False;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;245;-1086.938,-2501.451;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;244;-1319.002,-2386.871;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;287;-4391.059,507.0078;Inherit;False;1492.018;693.8762;Rotating the UVs separately to the billboarding (vertex offset) creates less overlap artifacts;6;286;285;278;183;288;309;Rotation Randomisation;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;284;-2042.652,1598.664;Inherit;False;Randombyface01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;322;-1312,-1072;Inherit;False;511.3331;414.3488;;3;156;157;155;N.L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;288;-4213.647,541.4965;Inherit;False;688.6851;451.8908;Rotation Movement;4;280;281;277;279;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;-4337.118,1075.031;Inherit;False;284;Randombyface01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;334;-1254.517,-2198.256;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;247;-945.0831,-2473.097;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;156;-1248,-1024;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;157;-1264,-848;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TexCoordVertexDataNode;2;-3433.447,-174.3539;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;280;-4088.263,834.3872;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;279;-4163.646,591.4966;Inherit;False;Property;_RotationSpeed;Rotation Speed;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;335;-880.6116,-2215.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;330;-704,-832;Inherit;False;1436.482;566.3243;;9;273;312;162;21;164;163;159;274;158;Lit/Unlit Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;259;-738.5826,-2426.596;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;277;-4084.61,714.5241;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;286;-3735.667,1013.828;Inherit;False;222;161;Rotation Offset (2*pi (one full rotation in radians));1;227;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;155;-960,-928;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;227;-3685.667,1063.828;Inherit;False;6.2832;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;34;-3080.356,-469.276;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;289;-2801.645,-819.7764;Inherit;False;1304.894;329.0329;;7;152;151;150;232;38;260;307;Circle Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;252;-336,-2192;Float;False;Property;_SSSPower;SSS Power;7;0;Create;True;0;0;0;False;0;False;1;1.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-3686.962,687.7977;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;336;-500.6013,-2363.471;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;273;-656,-528;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;340;-2804.458,232.6881;Inherit;False;889.4738;436.4;Optimisation?;7;347;346;345;344;343;342;341;Limit billboarding to frontfacing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2603.846,-755.2478;Inherit;False;Property;_CircleGradientSize;Circle Gradient Size;9;0;Create;True;0;0;0;False;0;False;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;253;-208,-2336;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;329;-1137.26,740.25;Inherit;False;2950.165;887.1367;;5;261;308;180;305;298;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;278;-3451.211,776.0031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;290;-2801.514,-277.9268;Inherit;False;1151.897;336.1885;;9;300;23;22;18;82;10;339;338;337;Camera Facing;1,1,1,1;0;0
Node;AmplifyShaderEditor.LengthOpNode;260;-2751.645,-665.1686;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-448,-608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-112,-2192;Float;False;Property;_SSSScale;SSS Scale;8;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;258;144,-2224;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;341;-2734.458,282.6881;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;342;-2754.458,475.6883;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;255;-16,-2336;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;298;-1077.227,1072.213;Inherit;False;900.4987;347.5639;;5;262;263;264;276;275;Fresnel Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;232;-2293.229,-769.7764;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;-2751.514,-227.9268;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;150;-2570.633,-672.7825;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;299;624,-208;Inherit;False;776.9953;318.8523;;6;209;292;295;294;296;297;Point Light Falloff;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewMatrixNode;337;-2710.829,-37.40576;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;321;-608,-1392;Inherit;False;915.6871;478.2158;Comment;7;311;315;314;316;266;265;333;Direction Light Bounce Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;158;-304,-608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;183;-3290.861,593.8463;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;311;-560,-1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;345;-2494.218,587.9661;Inherit;False;Constant;_7;-0.6;16;0;Create;True;0;0;0;False;0;False;-0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;344;-2505.458,389.6881;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;343;-2515.018,490.4666;Inherit;False;Constant;_9;-0.8;16;0;Create;True;0;0;0;False;0;False;-0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;309;-3099.288,604.2593;Inherit;False;rotatingUVs;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;338;-2498.829,-47.40576;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;368,-2336;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;323;469.3808,303.7329;Inherit;False;947.49;287.9385;;4;199;200;230;201;Texture Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;312;-144,-688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;151;-2101.914,-733.0323;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;275;-1027.227,1180.712;Inherit;False;Property;_EdgeFadeScale;Edge Fade Scale;11;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;276;-1016.438,1303.777;Inherit;False;Property;_EdgeFadePower;Edge Fade Power;12;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;209;688,-160;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;292;672,-48;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightPos;265;-320,-1168;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2527.405,-207.5974;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;294;912,0;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;310;-925.8954,335.0836;Inherit;False;309;rotatingUVs;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;315;-80,-1344;Inherit;False;Property;_bouncecolour;bounce colour;6;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;0.7167587,0.844296,0.8584906,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;199;519.3808,475.6715;Inherit;False;Property;_Shading;Shading;3;0;Create;True;0;0;0;False;0;False;0;0.178;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;305;772.7141,890.5879;Inherit;False;966.7778;643.1501;;3;304;282;167;Dither Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;162;-32,-784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;339;-2387.829,-170.4058;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;152;-1920.344,-729.5479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;325;544,-2336;Inherit;False;SSScontribution;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;314;-352,-1040;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;928,-144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;266;-48,-1152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;262;-809.4451,1127.788;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;64,-480;Inherit;False;Property;_Color;Color;4;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;163;176,-752;Inherit;False;Property;_unlitcolour;unlit colour;5;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;0.3779812,0.4239644,0.5849056,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;346;-2309.284,358.432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.8;False;2;FLOAT;-0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;333;-96,-1008;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;159;464,-592;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;304;822.714,1182.733;Inherit;False;476.1761;351.0049;;3;168;169;303;Dither Offset per face;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;-1715.694,-712.6988;Inherit;False;circleGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;18;-2209.999,-201.5617;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;263;-495.9058,1142.888;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;164;576,-784;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;179;-701.4701,302.8018;Inherit;True;Property;_MainTex;MainTex;2;0;Create;True;0;0;0;False;0;False;-1;None;c2603324a1359894f88564add6922e72;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;326;784.3439,-532.1201;Inherit;False;325;SSScontribution;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;316;144,-1216;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;200;814.0211,465.6946;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2189.151,-96.48026;Inherit;False;Property;_BillboardEffect;Billboard Effect;1;0;Create;True;0;0;0;False;0;False;1;0.714;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;347;-2143.691,348.2714;Inherit;False;Property;_limitbackfacing1;limit backfacing;15;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;296;1072,-80;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;320;1007.553,-830.5237;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;168;883.5388,1321.738;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;297;1232,-48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;264;-355.7281,1122.214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;4.823282,1183.316;Inherit;False;Property;_Opacity;Opacity;10;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2045.72,-211.6478;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;303;872.7141,1232.733;Inherit;False;284;Randombyface01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;207;1328,-704;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;308;31.80582,938.8715;Inherit;False;307;circleGradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;230;995.4083,353.733;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;201;1250.092,404.1291;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;-1890.607,-208.2048;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;169;1146.89,1254.788;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;180;332.5155,947.8502;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;1488,-528;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;282;934.746,940.5878;Inherit;True;Property;_bluenoise;bluenoise;14;0;Create;True;0;0;0;False;0;False;None;16d574e53541bba44a84052fa38778df;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;328;2272,-448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;2356.746,-172.2688;Inherit;False;300;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DitheringNode;167;1484.492,1106.412;Inherit;False;2;True;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2758.326,-508.7631;Float;False;True;-1;3;ASEMaterialInspector;0;0;CustomLighting;EdShaders/QuadsToBillboardsDitherClouds;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;True;231;False;0;Custom;0.5;True;True;0;True;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;218;0;196;0
WireConnection;218;1;217;0
WireConnection;219;0;218;0
WireConnection;197;1;219;0
WireConnection;245;0;240;0
WireConnection;284;0;197;0
WireConnection;247;0;245;0
WireConnection;247;1;244;0
WireConnection;280;0;285;0
WireConnection;335;0;334;0
WireConnection;259;0;247;0
WireConnection;155;0;156;0
WireConnection;155;1;157;0
WireConnection;227;0;285;0
WireConnection;34;0;2;0
WireConnection;281;0;279;0
WireConnection;281;1;280;0
WireConnection;281;2;277;0
WireConnection;336;0;259;0
WireConnection;336;1;335;0
WireConnection;253;0;336;0
WireConnection;253;1;252;0
WireConnection;278;0;281;0
WireConnection;278;1;227;0
WireConnection;260;0;34;0
WireConnection;274;0;155;0
WireConnection;274;1;273;0
WireConnection;255;0;253;0
WireConnection;255;1;254;0
WireConnection;232;0;38;0
WireConnection;10;0;34;0
WireConnection;150;0;260;0
WireConnection;158;0;274;0
WireConnection;183;0;2;0
WireConnection;183;2;278;0
WireConnection;311;0;155;0
WireConnection;344;0;341;0
WireConnection;344;1;342;0
WireConnection;309;0;183;0
WireConnection;256;0;258;0
WireConnection;256;1;255;0
WireConnection;312;0;158;0
WireConnection;151;0;150;0
WireConnection;151;1;232;0
WireConnection;82;0;10;0
WireConnection;82;1;337;0
WireConnection;294;0;292;2
WireConnection;162;0;312;0
WireConnection;339;0;82;0
WireConnection;339;1;338;0
WireConnection;152;0;151;0
WireConnection;325;0;256;0
WireConnection;314;0;311;0
WireConnection;295;0;209;0
WireConnection;295;1;292;2
WireConnection;266;0;265;2
WireConnection;262;2;275;0
WireConnection;262;3;276;0
WireConnection;346;0;344;0
WireConnection;346;1;343;0
WireConnection;346;2;345;0
WireConnection;159;0;158;0
WireConnection;159;1;21;0
WireConnection;307;0;152;0
WireConnection;18;0;339;0
WireConnection;263;0;262;0
WireConnection;164;0;162;0
WireConnection;164;1;163;0
WireConnection;179;1;310;0
WireConnection;316;0;315;0
WireConnection;316;1;314;0
WireConnection;316;2;266;0
WireConnection;316;3;333;0
WireConnection;200;0;199;0
WireConnection;347;1;346;0
WireConnection;296;0;295;0
WireConnection;296;1;294;0
WireConnection;320;0;316;0
WireConnection;320;1;164;0
WireConnection;320;2;159;0
WireConnection;320;3;326;0
WireConnection;297;0;296;0
WireConnection;264;0;263;0
WireConnection;23;0;18;0
WireConnection;23;1;22;0
WireConnection;23;2;347;0
WireConnection;230;0;179;1
WireConnection;230;3;200;0
WireConnection;201;0;230;0
WireConnection;300;0;23;0
WireConnection;169;0;303;0
WireConnection;169;1;168;0
WireConnection;180;0;179;4
WireConnection;180;1;308;0
WireConnection;180;2;261;0
WireConnection;180;3;264;0
WireConnection;208;0;207;0
WireConnection;208;1;320;0
WireConnection;208;2;297;0
WireConnection;328;0;208;0
WireConnection;328;1;201;0
WireConnection;167;0;180;0
WireConnection;167;1;282;0
WireConnection;167;2;169;0
WireConnection;0;10;167;0
WireConnection;0;13;328;0
WireConnection;0;11;301;0
ASEEND*/
//CHKSM=7CAD1305B97B8365E44A60BF38A1D61DB122CD94