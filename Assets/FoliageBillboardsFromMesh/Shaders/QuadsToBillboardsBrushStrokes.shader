// Made with Amplify Shader Editor v1.9.1.8
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/QuadsToBillboardBrushStrokes"
{

    Properties
    {
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		_BillboardEffect("Billboard Effect", Range( 0 , 1)) = 1
		_Color("Color", Color) = (0.3949776,0.8207547,0.1974457,0)
		_unlitcolour("unlit colour", Color) = (0.3949776,0.8207547,0.1974457,0)
		_MainTex("MainTex", 2D) = "white" {}
		_bouncecolour("bounce colour", Color) = (0.3949776,0.8207547,0.1974457,0)
		_Shading("Shading", Range( 0 , 1)) = 0
		_BrightnessVariation("Brightness Variation", Range( 0 , 1)) = 1
		_SSSPower("SSS Power", Float) = 1
		_SSSScale("SSS Scale", Float) = 1
		_RotationMovementSpeed("Rotation Movement Speed", Float) = 0.5
		_RotationAmount("Rotation Amount", Range( 0 , 1)) = 1
		_RotationOffsetRandomisation("Rotation Offset Randomisation", Range( 0 , 1)) = 1
		_rows("rows", Float) = 4
		[Toggle]_limitbackfacing1("limit backfacing", Float) = 1
		_columns("columns", Float) = 4
		[ASEEnd]_FlipbookSpeed("Flipbook Speed", Float) = 1

        [HideInInspector][NoScaleOffset] unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset] unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }

    SubShader
    {
		LOD 0

		
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "UniversalMaterialType"="Lit" "Queue"="Transparent" "ShaderGraphShader"="true" }

		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
		ZTest LEqual
		ZWrite Off
		Offset 0 , 0
		ColorMask RGBA
		

		HLSLINCLUDE
		#pragma target 2.0
		#pragma prefer_hlslcc gles
		// ensure rendering platforms toggle list is visible
		ENDHLSL

		
        Pass
        {
			
            Name "Sprite Lit"
            Tags { "LightMode"="Universal2D" }

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120110


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR
            #define VARYINGS_NEED_SCREENPOSITION

            #define SHADERPASS SHADERPASS_SPRITELIT

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT


			struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				uint ase_vertexID : SV_VertexID;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float4 color : TEXCOORD2;
				float4 screenPosition : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
			};

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			half4 _RendererColor;

			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float4 _bouncecolour;
			float4 _unlitcolour;
			float _RotationMovementSpeed;
			float _RotationOffsetRandomisation;
			float _RotationAmount;
			float _BillboardEffect;
			float _limitbackfacing1;
			float _SSSPower;
			float _SSSScale;
			float _columns;
			float _rows;
			float _FlipbookSpeed;
			float _Shading;
			float _BrightnessVariation;
			CBUFFER_END


			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (floor( ( v.ase_vertexID / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				float temp_output_227_0 = ( Randombyface01337 * 6.2832 );
				float cos183 = cos( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float sin183 = sin( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float2 rotator183 = mul( (v.uv0.xy*2.0 + -1.0) - float2( 0,0 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0,0 );
				float3 appendResult261 = (float3(rotator183 , 0.0));
				float3 normalizeResult264 = normalize( mul( float4( mul( float4( appendResult261 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
				float dotResult376 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult378 = smoothstep( -0.8 , -0.6 , dotResult376);
				float3 VertexOffset267 = ( normalizeResult264 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult378 ):( 1.0 )) );
				
				o.ase_texcoord4.xyz = ase_worldNormal;
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				o.ase_texcoord5 = ase_shadowCoords;
				
				o.ase_texcoord4.w = v.ase_vertexID;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset267;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);

				o.positionCS = vertexInput.positionCS;
				o.positionWS.xyz =  vertexInput.positionWS;
				o.texCoord0.xyzw =  v.uv0;
				o.color.xyzw =  v.color;
				o.screenPosition.xyzw =  vertexInput.positionNDC;

				return o;
			}

			half4 frag( VertexOutput IN   ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - IN.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult287 = dot( -SafeNormalize(_MainLightPosition.xyz) , ase_worldViewDir );
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float fresnelNdotV330 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode330 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV330, 1.0 ) );
				float dotResult295 = dot( pow( ( (dotResult287*0.5 + 0.5) * saturate( fresnelNode330 ) ) , _SSSPower ) , _SSSScale );
				float ase_lightAtten = 0;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //la
				float4 ase_shadowCoords = IN.ase_texcoord5;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS) //la
				float4 ase_shadowCoords = TransformWorldToShadowCoord(IN.positionWS);
				#else //la
				float4 ase_shadowCoords = 0;
				#endif //la
				Light ase_mainLight = GetMainLight( ase_shadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float4 SSScontribution300 = ( dotResult295 * ase_lightAtten * _Color );
				float dotResult288 = dot( ase_worldNormal , SafeNormalize(_MainLightPosition.xyz) );
				float temp_output_303_0 = saturate( ( dotResult288 * ase_lightAtten ) );
				float2 texCoord368 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (floor( ( IN.ase_texcoord4.w / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles360 = _columns * _rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset360 = 1.0f / _columns;
				float fbrowsoffset360 = 1.0f / _rows;
				// Speed of animation
				float fbspeed360 = _TimeParameters.x * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling360 = float2(fbcolsoffset360, fbrowsoffset360);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex360 = round( fmod( fbspeed360 + ( ( _columns * _rows ) * Randombyface01337 ), fbtotaltiles360) );
				fbcurrenttileindex360 += ( fbcurrenttileindex360 < 0) ? fbtotaltiles360 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox360 = round ( fmod ( fbcurrenttileindex360, _columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx360 = fblinearindextox360 * fbcolsoffset360;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy360 = round( fmod( ( fbcurrenttileindex360 - fblinearindextox360 ) / _columns, _rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy360 = (int)(_rows-1) - fblinearindextoy360;
				// Multiply Offset Y by rowoffset
				float fboffsety360 = fblinearindextoy360 * fbrowsoffset360;
				// UV Offset
				float2 fboffset360 = float2(fboffsetx360, fboffsety360);
				// Flipbook UV
				half2 fbuv360 = texCoord368 * fbtiling360 + fboffset360;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode179 = tex2D( _MainTex, fbuv360 );
				
				float myVarName407 = tex2DNode179.a;
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				surfaceDescription.BaseColor = ( _MainLightColor * ( SSScontribution300 + ( ( _bouncecolour * saturate( -dotResult288 ) * ( 1.0 - _MainLightPosition.w ) ) + ( saturate( ( 1.0 - temp_output_303_0 ) ) * _unlitcolour ) + ( temp_output_303_0 * _Color ) ) ) * saturate( ( ( ase_lightAtten * _MainLightPosition.w ) + ( 1.0 - _MainLightPosition.w ) ) ) * saturate( (( 1.0 - _Shading ) + (tex2DNode179.r - 0.0) * (1.0 - ( 1.0 - _Shading )) / (1.0 - 0.0)) ) * saturate( (( 1.0 - _BrightnessVariation ) + (Randombyface01337 - 0.0) * (1.0 - ( 1.0 - _BrightnessVariation )) / (1.0 - 0.0)) ) ).rgb;
				surfaceDescription.Alpha = myVarName407;

				half4 color = half4(surfaceDescription.BaseColor, surfaceDescription.Alpha);

				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(color.rgb, color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				color *= IN.color * _RendererColor;
				return color;
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "Sprite Normal"
            Tags { "LightMode"="NormalsRendering" }

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120110


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS

            #define SHADERPASS SHADERPASS_SPRITENORMAL

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/NormalsRenderingShared.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float4 _bouncecolour;
			float4 _unlitcolour;
			float _RotationMovementSpeed;
			float _RotationOffsetRandomisation;
			float _RotationAmount;
			float _BillboardEffect;
			float _limitbackfacing1;
			float _SSSPower;
			float _SSSScale;
			float _columns;
			float _rows;
			float _FlipbookSpeed;
			float _Shading;
			float _BrightnessVariation;
			CBUFFER_END


			struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				uint ase_vertexID : SV_VertexID;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 tangentWS : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            struct SurfaceDescription
			{
				float3 NormalTS;
				float Alpha;
			};

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (floor( ( v.ase_vertexID / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				float temp_output_227_0 = ( Randombyface01337 * 6.2832 );
				float cos183 = cos( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float sin183 = sin( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float2 rotator183 = mul( (v.ase_texcoord.xy*2.0 + -1.0) - float2( 0,0 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0,0 );
				float3 appendResult261 = (float3(rotator183 , 0.0));
				float3 normalizeResult264 = normalize( mul( float4( mul( float4( appendResult261 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
				float dotResult376 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult378 = smoothstep( -0.8 , -0.6 , dotResult376);
				float3 VertexOffset267 = ( normalizeResult264 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult378 ):( 1.0 )) );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord2.z = v.ase_vertexID;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset267;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;


				float3 positionWS = TransformObjectToWorld(v.vertex);
				float4 tangentWS = float4(TransformObjectToWorldDir(v.tangent.xyz), v.tangent.w);

				o.positionCS = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  -GetViewForwardDir();
				o.tangentWS.xyzw =  tangentWS;
				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 texCoord368 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (floor( ( IN.ase_texcoord2.z / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles360 = _columns * _rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset360 = 1.0f / _columns;
				float fbrowsoffset360 = 1.0f / _rows;
				// Speed of animation
				float fbspeed360 = _TimeParameters.x * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling360 = float2(fbcolsoffset360, fbrowsoffset360);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex360 = round( fmod( fbspeed360 + ( ( _columns * _rows ) * Randombyface01337 ), fbtotaltiles360) );
				fbcurrenttileindex360 += ( fbcurrenttileindex360 < 0) ? fbtotaltiles360 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox360 = round ( fmod ( fbcurrenttileindex360, _columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx360 = fblinearindextox360 * fbcolsoffset360;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy360 = round( fmod( ( fbcurrenttileindex360 - fblinearindextox360 ) / _columns, _rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy360 = (int)(_rows-1) - fblinearindextoy360;
				// Multiply Offset Y by rowoffset
				float fboffsety360 = fblinearindextoy360 * fbrowsoffset360;
				// UV Offset
				float2 fboffset360 = float2(fboffsetx360, fboffsety360);
				// Flipbook UV
				half2 fbuv360 = texCoord368 * fbtiling360 + fboffset360;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode179 = tex2D( _MainTex, fbuv360 );
				float myVarName407 = tex2DNode179.a;
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.Alpha = myVarName407;

				half crossSign = (IN.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
				half3 bitangent = crossSign * cross(IN.normalWS.xyz, IN.tangentWS.xyz);
				half4 color = half4(1.0,1.0,1.0, surfaceDescription.Alpha);

				return NormalsRenderingShared(color, surfaceDescription.NormalTS, IN.tangentWS.xyz, bitangent, IN.normalWS);
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            Cull Off
			Blend Off
			ZTest LEqual
			ZWrite On

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120110


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define SHADERPASS SHADERPASS_DEPTHONLY
	        #define SCENESELECTIONPASS 1


            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float4 _bouncecolour;
			float4 _unlitcolour;
			float _RotationMovementSpeed;
			float _RotationOffsetRandomisation;
			float _RotationAmount;
			float _BillboardEffect;
			float _limitbackfacing1;
			float _SSSPower;
			float _SSSScale;
			float _columns;
			float _rows;
			float _FlipbookSpeed;
			float _Shading;
			float _BrightnessVariation;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				uint ase_vertexID : SV_VertexID;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};


			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            int _ObjectId;
            int _PassValue;

            struct SurfaceDescription
			{
				float Alpha;
			};

			
			VertexOutput vert( VertexInput v )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (floor( ( v.ase_vertexID / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				float temp_output_227_0 = ( Randombyface01337 * 6.2832 );
				float cos183 = cos( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float sin183 = sin( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float2 rotator183 = mul( (v.ase_texcoord.xy*2.0 + -1.0) - float2( 0,0 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0,0 );
				float3 appendResult261 = (float3(rotator183 , 0.0));
				float3 normalizeResult264 = normalize( mul( float4( mul( float4( appendResult261 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
				float dotResult376 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult378 = smoothstep( -0.8 , -0.6 , dotResult376);
				float3 VertexOffset267 = ( normalizeResult264 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult378 ):( 1.0 )) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord.z = v.ase_vertexID;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset267;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif


				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.positionCS = TransformWorldToHClip(positionWS);
				return o;
			}

			half4 frag( VertexOutput IN ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 texCoord368 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (floor( ( IN.ase_texcoord.z / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles360 = _columns * _rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset360 = 1.0f / _columns;
				float fbrowsoffset360 = 1.0f / _rows;
				// Speed of animation
				float fbspeed360 = _TimeParameters.x * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling360 = float2(fbcolsoffset360, fbrowsoffset360);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex360 = round( fmod( fbspeed360 + ( ( _columns * _rows ) * Randombyface01337 ), fbtotaltiles360) );
				fbcurrenttileindex360 += ( fbcurrenttileindex360 < 0) ? fbtotaltiles360 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox360 = round ( fmod ( fbcurrenttileindex360, _columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx360 = fblinearindextox360 * fbcolsoffset360;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy360 = round( fmod( ( fbcurrenttileindex360 - fblinearindextox360 ) / _columns, _rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy360 = (int)(_rows-1) - fblinearindextoy360;
				// Multiply Offset Y by rowoffset
				float fboffsety360 = fblinearindextoy360 * fbrowsoffset360;
				// UV Offset
				float2 fboffset360 = float2(fboffsetx360, fboffsety360);
				// Flipbook UV
				half2 fbuv360 = texCoord368 * fbtiling360 + fboffset360;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode179 = tex2D( _MainTex, fbuv360 );
				float myVarName407 = tex2DNode179.a;
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				surfaceDescription.Alpha = myVarName407;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

            ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }

            Cull Off
			Blend Off
			ZTest LEqual
			ZWrite On


            HLSLPROGRAM

			#define ASE_SRP_VERSION 120110


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT

            #define SHADERPASS SHADERPASS_DEPTHONLY
			#define SCENEPICKINGPASS 1

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        	#define ASE_NEEDS_VERT_NORMAL


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float4 _bouncecolour;
			float4 _unlitcolour;
			float _RotationMovementSpeed;
			float _RotationOffsetRandomisation;
			float _RotationAmount;
			float _BillboardEffect;
			float _limitbackfacing1;
			float _SSSPower;
			float _SSSScale;
			float _columns;
			float _rows;
			float _FlipbookSpeed;
			float _Shading;
			float _BrightnessVariation;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				uint ase_vertexID : SV_VertexID;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            float4 _SelectionID;

            struct SurfaceDescription
			{
				float Alpha;
			};

   			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (floor( ( v.ase_vertexID / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				float temp_output_227_0 = ( Randombyface01337 * 6.2832 );
				float cos183 = cos( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float sin183 = sin( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float2 rotator183 = mul( (v.ase_texcoord.xy*2.0 + -1.0) - float2( 0,0 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0,0 );
				float3 appendResult261 = (float3(rotator183 , 0.0));
				float3 normalizeResult264 = normalize( mul( float4( mul( float4( appendResult261 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
				float dotResult376 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult378 = smoothstep( -0.8 , -0.6 , dotResult376);
				float3 VertexOffset267 = ( normalizeResult264 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult378 ):( 1.0 )) );
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord.z = v.ase_vertexID;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset267;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				float3 positionWS = TransformObjectToWorld(v.vertex);
				o.positionCS = TransformWorldToHClip(positionWS);

				return o;
			}

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float2 texCoord368 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (floor( ( IN.ase_texcoord.z / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles360 = _columns * _rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset360 = 1.0f / _columns;
				float fbrowsoffset360 = 1.0f / _rows;
				// Speed of animation
				float fbspeed360 = _TimeParameters.x * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling360 = float2(fbcolsoffset360, fbrowsoffset360);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex360 = round( fmod( fbspeed360 + ( ( _columns * _rows ) * Randombyface01337 ), fbtotaltiles360) );
				fbcurrenttileindex360 += ( fbcurrenttileindex360 < 0) ? fbtotaltiles360 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox360 = round ( fmod ( fbcurrenttileindex360, _columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx360 = fblinearindextox360 * fbcolsoffset360;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy360 = round( fmod( ( fbcurrenttileindex360 - fblinearindextox360 ) / _columns, _rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy360 = (int)(_rows-1) - fblinearindextoy360;
				// Multiply Offset Y by rowoffset
				float fboffsety360 = fblinearindextoy360 * fbrowsoffset360;
				// UV Offset
				float2 fboffset360 = float2(fboffsetx360, fboffsety360);
				// Flipbook UV
				half2 fbuv360 = texCoord368 * fbtiling360 + fboffset360;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode179 = tex2D( _MainTex, fbuv360 );
				float myVarName407 = tex2DNode179.a;
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				surfaceDescription.Alpha = myVarName407;

				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = _SelectionID;
				return outColor;
			}


            ENDHLSL
        }

		
        Pass
        {
			
            Name "Sprite Forward"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM

			#define ASE_SRP_VERSION 120110


			#pragma vertex vert
			#pragma fragment frag

            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_COLOR
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_COLOR

            #define SHADERPASS SHADERPASS_SPRITEFORWARD

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile_fragment _ _SHADOWS_SOFT


			sampler2D _MainTex;
			CBUFFER_START( UnityPerMaterial )
			float4 _Color;
			float4 _bouncecolour;
			float4 _unlitcolour;
			float _RotationMovementSpeed;
			float _RotationOffsetRandomisation;
			float _RotationAmount;
			float _BillboardEffect;
			float _limitbackfacing1;
			float _SSSPower;
			float _SSSScale;
			float _columns;
			float _rows;
			float _FlipbookSpeed;
			float _Shading;
			float _BrightnessVariation;
			CBUFFER_END


            struct VertexInput
			{
				float3 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 uv0 : TEXCOORD0;
				float4 color : COLOR;
				uint ase_vertexID : SV_VertexID;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};


			struct VertexOutput
			{
				float4 positionCS : SV_POSITION;
				float4 texCoord0 : TEXCOORD0;
				float3 positionWS : TEXCOORD1;
				float4 color : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

            struct SurfaceDescription
			{
				float3 BaseColor;
				float Alpha;
				float3 NormalTS;
			};

			#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/SurfaceData2D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging2D.hlsl"

			
			VertexOutput vert( VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);


				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 temp_cast_0 = (floor( ( v.ase_vertexID / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				float temp_output_227_0 = ( Randombyface01337 * 6.2832 );
				float cos183 = cos( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float sin183 = sin( ( ( sin( ( ( _TimeParameters.x * _RotationMovementSpeed ) + ( ( _RotationOffsetRandomisation * 2 ) * Randombyface01337 ) ) ) * ( _RotationAmount * temp_output_227_0 ) ) + temp_output_227_0 ) );
				float2 rotator183 = mul( (v.uv0.xy*2.0 + -1.0) - float2( 0,0 ) , float2x2( cos183 , -sin183 , sin183 , cos183 )) + float2( 0,0 );
				float3 appendResult261 = (float3(rotator183 , 0.0));
				float3 normalizeResult264 = normalize( mul( float4( mul( float4( appendResult261 , 0.0 ), UNITY_MATRIX_V ).xyz , 0.0 ), GetObjectToWorldMatrix() ).xyz );
				float3 ase_worldPos = TransformObjectToWorld( (v.vertex).xyz );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.normal);
				float dotResult376 = dot( ase_worldViewDir , ase_worldNormal );
				float smoothstepResult378 = smoothstep( -0.8 , -0.6 , dotResult376);
				float3 VertexOffset267 = ( normalizeResult264 * _BillboardEffect * (( _limitbackfacing1 )?( smoothstepResult378 ):( 1.0 )) );
				
				o.ase_texcoord3.xyz = ase_worldNormal;
				float4 ase_shadowCoords = TransformWorldToShadowCoord(ase_worldPos);
				o.ase_texcoord4 = ase_shadowCoords;
				
				o.ase_texcoord3.w = v.ase_vertexID;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3( 0, 0, 0 );
				#endif
				float3 vertexValue = VertexOffset267;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.normal = v.normal;
				v.tangent.xyz = v.tangent.xyz;


				float3 positionWS = TransformObjectToWorld(v.vertex);

				o.positionCS = TransformWorldToHClip(positionWS);
				o.positionWS.xyz =  positionWS;
				o.texCoord0.xyzw =  v.uv0;
				o.color.xyzw =  v.color;

				return o;
			}

			half4 frag( VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - IN.positionWS );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult287 = dot( -SafeNormalize(_MainLightPosition.xyz) , ase_worldViewDir );
				float3 ase_worldNormal = IN.ase_texcoord3.xyz;
				float fresnelNdotV330 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode330 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV330, 1.0 ) );
				float dotResult295 = dot( pow( ( (dotResult287*0.5 + 0.5) * saturate( fresnelNode330 ) ) , _SSSPower ) , _SSSScale );
				float ase_lightAtten = 0;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) //la
				float4 ase_shadowCoords = IN.ase_texcoord4;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS) //la
				float4 ase_shadowCoords = TransformWorldToShadowCoord(IN.positionWS);
				#else //la
				float4 ase_shadowCoords = 0;
				#endif //la
				Light ase_mainLight = GetMainLight( ase_shadowCoords );
				ase_lightAtten = ase_mainLight.distanceAttenuation * ase_mainLight.shadowAttenuation;
				float4 SSScontribution300 = ( dotResult295 * ase_lightAtten * _Color );
				float dotResult288 = dot( ase_worldNormal , SafeNormalize(_MainLightPosition.xyz) );
				float temp_output_303_0 = saturate( ( dotResult288 * ase_lightAtten ) );
				float2 texCoord368 = IN.texCoord0.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_0 = (floor( ( IN.ase_texcoord3.w / 4.0 ) )).xx;
				float dotResult4_g1 = dot( temp_cast_0 , float2( 12.9898,78.233 ) );
				float lerpResult10_g1 = lerp( 0.0 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
				float Randombyface01337 = lerpResult10_g1;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles360 = _columns * _rows;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset360 = 1.0f / _columns;
				float fbrowsoffset360 = 1.0f / _rows;
				// Speed of animation
				float fbspeed360 = _TimeParameters.x * _FlipbookSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling360 = float2(fbcolsoffset360, fbrowsoffset360);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex360 = round( fmod( fbspeed360 + ( ( _columns * _rows ) * Randombyface01337 ), fbtotaltiles360) );
				fbcurrenttileindex360 += ( fbcurrenttileindex360 < 0) ? fbtotaltiles360 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox360 = round ( fmod ( fbcurrenttileindex360, _columns ) );
				// Multiply Offset X by coloffset
				float fboffsetx360 = fblinearindextox360 * fbcolsoffset360;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy360 = round( fmod( ( fbcurrenttileindex360 - fblinearindextox360 ) / _columns, _rows ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy360 = (int)(_rows-1) - fblinearindextoy360;
				// Multiply Offset Y by rowoffset
				float fboffsety360 = fblinearindextoy360 * fbrowsoffset360;
				// UV Offset
				float2 fboffset360 = float2(fboffsetx360, fboffsety360);
				// Flipbook UV
				half2 fbuv360 = texCoord368 * fbtiling360 + fboffset360;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode179 = tex2D( _MainTex, fbuv360 );
				
				float myVarName407 = tex2DNode179.a;
				
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				surfaceDescription.BaseColor = ( _MainLightColor * ( SSScontribution300 + ( ( _bouncecolour * saturate( -dotResult288 ) * ( 1.0 - _MainLightPosition.w ) ) + ( saturate( ( 1.0 - temp_output_303_0 ) ) * _unlitcolour ) + ( temp_output_303_0 * _Color ) ) ) * saturate( ( ( ase_lightAtten * _MainLightPosition.w ) + ( 1.0 - _MainLightPosition.w ) ) ) * saturate( (( 1.0 - _Shading ) + (tex2DNode179.r - 0.0) * (1.0 - ( 1.0 - _Shading )) / (1.0 - 0.0)) ) * saturate( (( 1.0 - _BrightnessVariation ) + (Randombyface01337 - 0.0) * (1.0 - ( 1.0 - _BrightnessVariation )) / (1.0 - 0.0)) ) ).rgb;
				surfaceDescription.NormalTS = float3(0.0f, 0.0f, 1.0f);
				surfaceDescription.Alpha = myVarName407;


				half4 color = half4(surfaceDescription.BaseColor, surfaceDescription.Alpha);

				#if defined(DEBUG_DISPLAY)
				SurfaceData2D surfaceData;
				InitializeSurfaceData(color.rgb, color.a, surfaceData);
				InputData2D inputData;
				InitializeInputData(IN.positionWS.xy, half2(IN.texCoord0.xy), inputData);
				half4 debugColor = 0;

				SETUP_DEBUG_DATA_2D(inputData, IN.positionWS);

				if (CanDebugOverrideOutputColor(surfaceData, inputData, debugColor))
				{
					return debugColor;
				}
				#endif

				color *= IN.color;
				return color;
			}


            ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
	
	Fallback Off
}
/*ASEBEGIN
Version=19108
Node;AmplifyShaderEditor.CommentaryNode;220;-2331.907,1152.94;Inherit;False;564.2708;193.0601;Group 4 verts together to get a stable Face ID;3;217;218;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;217;-2245.907,1262;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexIdVariableNode;196;-2321.216,1194.751;Inherit;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;218;-2094.568,1202.94;Inherit;False;2;0;INT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;219;-1917.636,1225.837;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;221;-1719.945,1131.568;Inherit;False;515.5742;233.6212;Random Range to 2*pi (a full rotation in radians);2;197;337;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;354;-3089.266,-68.9586;Inherit;False;1721.182;592.9589;;15;336;227;347;346;345;335;340;339;341;334;348;342;351;349;183;Rotation Movement;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;197;-1683.082,1198.646;Inherit;False;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;349;-3039.266,241.0396;Inherit;False;Property;_RotationOffsetRandomisation;Rotation Offset Randomisation;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;337;-1436.519,1205.597;Inherit;False;Randombyface01;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;339;-2912.292,383.3355;Inherit;False;337;Randombyface01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;336;-2891.251,-18.9586;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;341;-2966.363,66.58308;Inherit;False;Property;_RotationMovementSpeed;Rotation Movement Speed;9;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;351;-2729.896,251.6001;Inherit;False;2;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;342;-2635.491,20.63203;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;275;-1046.541,-2230.688;Inherit;False;2197.443;584.241;;15;300;299;296;295;293;291;290;289;287;284;282;278;332;330;331;Subsurface Scattering Directional Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;348;-2562.747,281.2124;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;340;-2404.278,175.4766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;227;-2364.956,414.7981;Inherit;False;6.2832;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;347;-2431.148,328.2268;Inherit;False;Property;_RotationAmount;Rotation Amount;10;0;Create;True;0;0;0;False;0;False;1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;278;-989.024,-2178.281;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;284;-674.6973,-2113.039;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;281;-1010.104,-1226.827;Inherit;False;511.3331;414.3488;;3;288;286;283;N.L;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;282;-951.4882,-2013.467;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;346;-2145.118,230.6331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;335;-2272.298,160.3961;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;283;-935.712,-1176.827;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;285;-395.4185,-988.9883;Inherit;False;1436.482;566.3243;;9;319;317;313;312;309;305;303;302;301;Lit/Unlit Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;286;-960.104,-995.4778;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;287;-504.2877,-2083.318;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;330;-970.5583,-1843.475;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;345;-2062.189,99.74155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode;2;-2215.747,-358.3636;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;301;-345.4185,-674.2518;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;288;-650.7714,-1081.809;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;334;-1890.428,252.6808;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;331;-510.8787,-1802.976;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;289;-314.0267,-2041.101;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;332;-152.3683,-1862.417;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-961.2895,538.6675;Inherit;False;Property;_columns;columns;14;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;260;-1040.297,-389.0843;Inherit;False;992.897;335.1885;;9;267;266;265;264;263;261;357;358;359;Camera Facing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;361;-948.4943,636.9507;Inherit;False;Property;_rows;rows;12;0;Create;True;0;0;0;False;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;11.32117,-1829.419;Float;False;Property;_SSSPower;SSS Power;7;0;Create;True;0;0;0;False;0;False;1;1.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;302;-146.9163,-759.0171;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;372;-1076.768,-4.446106;Inherit;False;889.4738;436.4;Optimisation?;7;379;378;377;376;375;374;373;Limit billboarding to frontfacing;1,1,1,1;0;0
Node;AmplifyShaderEditor.RotatorNode;183;-1653.479,157.0285;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;293;235.8618,-1827.833;Float;False;Property;_SSSScale;SSS Scale;8;0;Create;True;0;0;0;False;0;False;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;373;-1006.768,45.55389;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;374;-1026.768,238.5541;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;303;8.171997,-757.4878;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;261;-990.2966,-339.0843;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;294;-294.6359,-1540.064;Inherit;False;915.6871;478.2158;Comment;6;320;316;315;311;306;304;Direction Light Bounce Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;363;-748.9197,618.9326;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewMatrixNode;357;-978.7117,-226.2576;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.GetLocalVarNode;364;-865.6771,809.5071;Inherit;False;337;Randombyface01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;291;140.432,-1973.964;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;377;-766.5286,350.8318;Inherit;False;Constant;_7;-0.6;16;0;Create;True;0;0;0;False;0;False;-0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;376;-777.7676,152.5539;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;375;-787.3286,253.3324;Inherit;False;Constant;_9;-0.8;16;0;Create;True;0;0;0;False;0;False;-0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;369;-829.9969,968.5977;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;304;-7.495911,-1312.351;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;370;-439.1765,868.5503;Inherit;False;Property;_FlipbookSpeed;Flipbook Speed;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-826.5607,-328.8171;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;327;495.6317,62.23156;Inherit;False;870.7595;284.1104;;4;201;230;200;199;Texture Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;269;420.5293,746.4581;Inherit;False;974.4776;330.6777;;5;225;224;223;229;338;Brightness Variation;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;295;321.5121,-1971.906;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;309;367.4329,-634.6641;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;0.7921569,0.6628789,0.3098039,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;365;-618.3284,733.2451;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;296;431.83,-1834.939;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;305;164.3067,-835.4758;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;306;-244.6359,-1172.849;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;368;-724.1547,471.9061;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldMatrixNode;358;-958.5875,-139.0519;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.CommentaryNode;292;539.3035,-345.7331;Inherit;False;776.9953;318.8523;;6;322;318;314;310;308;307;Point Light Falloff;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;315;226.4565,-1490.064;Inherit;False;Property;_bouncecolour;bounce colour;4;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;0.3033061,0.2710038,0.3962263,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;316;266.3253,-1310.748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;509.6317,137.342;Inherit;False;Property;_Shading;Shading;5;0;Create;True;0;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;360;-422.444,553.3288;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;359;-713.7407,-231.2887;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;313;281.3515,-930.8713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;223;470.5293,961.1356;Inherit;False;Property;_BrightnessVariation;Brightness Variation;6;0;Create;True;0;0;0;False;0;False;1;0.241;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;308;603.2737,-295.7331;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;307;589.3036,-195.7631;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;711.1635,-1970.966;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;312;488.3039,-905.2784;Inherit;False;Property;_unlitcolour;unlit colour;2;0;Create;True;0;0;0;False;0;False;0.3949776,0.8207547,0.1974457,0;0.3568627,0.1609469,0.1568627,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;311;-40.74481,-1183.49;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;264;-611.7817,-315.7192;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;310;844.3384,-284.8987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;314;829.7982,-137.8809;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;200;785.2317,145.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;319;879.0638,-938.9883;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;338;631.3237,836.4851;Inherit;False;337;Randombyface01;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;224;770.0039,940.2705;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;320;459.0512,-1372.923;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;773.6166,-746.9144;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;179;42.80067,407.3784;Inherit;True;Property;_MainTex;MainTex;3;0;Create;True;0;0;0;False;0;False;-1;None;1400baf212feeed44847717f0c013422;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;300;887.1202,-1964.755;Inherit;False;SSScontribution;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;326;1211.531,-1124.281;Inherit;False;300;SSScontribution;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-430.5029,-324.8052;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;321;1113.721,-1017.673;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;230;960.8253,150.2316;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;318;988.1255,-218.6598;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;229;963.7097,820.1949;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;225;1230.006,796.4579;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;323;1809.72,-304.7764;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;325;1483.328,-1037.523;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;201;1161.391,180.554;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;322;1151.299,-186.3482;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;371;-618.267,958.0955;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;324;2276.077,-166.731;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;400;2768.587,-47.55548;Float;False;False;-1;2;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;17;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;Sprite Lit;0;0;Sprite Lit;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;UniversalMaterialType=Lit;Queue=Transparent=Queue=0;ShaderGraphShader=true;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Universal2D;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;401;2768.587,-47.55548;Float;False;False;-1;2;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;17;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;Sprite Normal;0;1;Sprite Normal;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;UniversalMaterialType=Lit;Queue=Transparent=Queue=0;ShaderGraphShader=true;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=NormalsRendering;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;402;2768.587,-47.55548;Float;False;False;-1;2;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;17;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;SceneSelectionPass;0;2;SceneSelectionPass;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;UniversalMaterialType=Lit;Queue=Transparent=Queue=0;ShaderGraphShader=true;True;0;True;12;all;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;403;2768.587,-47.55548;Float;False;False;-1;2;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;17;New Amplify Shader;ece0159bad6633944bf6b818f4dd296c;True;ScenePickingPass;0;3;ScenePickingPass;0;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;UniversalMaterialType=Lit;Queue=Transparent=Queue=0;ShaderGraphShader=true;True;0;True;12;all;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;404;2768.587,-47.55548;Float;False;True;-1;2;UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI;0;17;EdShaders/QuadsToBillboardBrushStrokes;ece0159bad6633944bf6b818f4dd296c;True;Sprite Forward;0;4;Sprite Forward;6;False;True;2;5;False;;10;False;;3;1;False;;10;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;2;False;;True;3;False;;True;True;0;False;;0;False;;True;5;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;UniversalMaterialType=Lit;Queue=Transparent=Queue=0;ShaderGraphShader=true;True;0;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=UniversalForward;False;False;0;;0;0;Standard;2;Vertex Position;1;0;Debug Display;0;0;0;5;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;407;1757.998,189.6361;Inherit;False;myVarName;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;268;2145.698,404.9375;Inherit;False;267;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;34;-1963.316,-349.9391;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;378;-581.5941,121.2978;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;-0.8;False;2;FLOAT;-0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;266;-559.3032,-175.5297;Inherit;False;Property;_BillboardEffect;Billboard Effect;0;0;Create;True;0;0;0;False;0;False;1;0.24;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;267;-51.50034,-306.623;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;379;-416.0017,111.1372;Inherit;False;Property;_limitbackfacing1;limit backfacing;13;0;Create;True;0;0;0;False;0;False;1;True;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;218;0;196;0
WireConnection;218;1;217;0
WireConnection;219;0;218;0
WireConnection;197;1;219;0
WireConnection;337;0;197;0
WireConnection;351;0;349;0
WireConnection;342;0;336;0
WireConnection;342;1;341;0
WireConnection;348;0;351;0
WireConnection;348;1;339;0
WireConnection;340;0;342;0
WireConnection;340;1;348;0
WireConnection;227;0;339;0
WireConnection;284;0;278;0
WireConnection;346;0;347;0
WireConnection;346;1;227;0
WireConnection;335;0;340;0
WireConnection;287;0;284;0
WireConnection;287;1;282;0
WireConnection;345;0;335;0
WireConnection;345;1;346;0
WireConnection;288;0;283;0
WireConnection;288;1;286;0
WireConnection;334;0;345;0
WireConnection;334;1;227;0
WireConnection;331;0;330;0
WireConnection;289;0;287;0
WireConnection;332;0;289;0
WireConnection;332;1;331;0
WireConnection;302;0;288;0
WireConnection;302;1;301;0
WireConnection;183;0;34;0
WireConnection;183;2;334;0
WireConnection;303;0;302;0
WireConnection;261;0;183;0
WireConnection;363;0;362;0
WireConnection;363;1;361;0
WireConnection;291;0;332;0
WireConnection;291;1;290;0
WireConnection;376;0;373;0
WireConnection;376;1;374;0
WireConnection;263;0;261;0
WireConnection;263;1;357;0
WireConnection;295;0;291;0
WireConnection;295;1;293;0
WireConnection;365;0;363;0
WireConnection;365;1;364;0
WireConnection;305;0;303;0
WireConnection;306;0;288;0
WireConnection;316;0;304;2
WireConnection;360;0;368;0
WireConnection;360;1;362;0
WireConnection;360;2;361;0
WireConnection;360;3;370;0
WireConnection;360;4;365;0
WireConnection;360;5;369;0
WireConnection;359;0;263;0
WireConnection;359;1;358;0
WireConnection;313;0;305;0
WireConnection;299;0;295;0
WireConnection;299;1;296;0
WireConnection;299;2;309;0
WireConnection;311;0;306;0
WireConnection;264;0;359;0
WireConnection;310;0;308;0
WireConnection;310;1;307;2
WireConnection;314;0;307;2
WireConnection;200;0;199;0
WireConnection;319;0;313;0
WireConnection;319;1;312;0
WireConnection;224;0;223;0
WireConnection;320;0;315;0
WireConnection;320;1;311;0
WireConnection;320;2;316;0
WireConnection;317;0;303;0
WireConnection;317;1;309;0
WireConnection;179;1;360;0
WireConnection;300;0;299;0
WireConnection;265;0;264;0
WireConnection;265;1;266;0
WireConnection;265;2;379;0
WireConnection;321;0;320;0
WireConnection;321;1;319;0
WireConnection;321;2;317;0
WireConnection;230;0;179;1
WireConnection;230;3;200;0
WireConnection;318;0;310;0
WireConnection;318;1;314;0
WireConnection;229;0;338;0
WireConnection;229;3;224;0
WireConnection;225;0;229;0
WireConnection;325;0;326;0
WireConnection;325;1;321;0
WireConnection;201;0;230;0
WireConnection;322;0;318;0
WireConnection;371;0;364;0
WireConnection;371;1;369;0
WireConnection;324;0;323;0
WireConnection;324;1;325;0
WireConnection;324;2;322;0
WireConnection;324;3;201;0
WireConnection;324;4;225;0
WireConnection;404;0;324;0
WireConnection;404;2;407;0
WireConnection;404;3;268;0
WireConnection;407;0;179;4
WireConnection;34;0;2;0
WireConnection;378;0;376;0
WireConnection;378;1;375;0
WireConnection;378;2;377;0
WireConnection;267;0;265;0
WireConnection;379;1;378;0
ASEEND*/
//CHKSM=74CB62BBABC68EF4595520710B8982B6D7C73D98