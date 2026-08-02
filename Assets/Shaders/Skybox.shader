// Made with Amplify Shader Editor v1.9.9.11
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "W/Skybox"
{
	Properties
	{
		_FarClip( "FarClip", Float ) = 1000
		[SingleLineTexture] _Stars( "Stars", 2D ) = "white" {}

	}

	SubShader
	{
		

		

		Tags { "RenderType"="Opaque" }

	LOD 100

		ZWrite On
		Cull Back
		AlphaToMask Off
		ColorMask RGBA
		Blend One Zero, One Zero
		BlendOp Add, Add

		

		Blend Off
		

		CGINCLUDE
			#pragma target 3.5
			// ensure rendering platforms toggle list is visible

			float4 ComputeClipSpacePosition( float2 screenPosNorm, float deviceDepth )
			{
				float4 positionCS = float4( screenPosNorm * 2.0 - 1.0, deviceDepth, 1.0 );
			#if UNITY_UV_STARTS_AT_TOP
				positionCS.y = -positionCS.y;
			#endif
				return positionCS;
			}
		ENDCG

		
		Pass
		{
			
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }

			Cull Back
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Blend One Zero, One Zero
			BlendOp Add, Add

			

			CGPROGRAM
				#define ASE_VERSION 19911

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#include "UnityCG.cginc"

				#include "Lighting.cginc"
				#include "AutoLight.cginc"


				#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
					#define ASE_SV_DEPTH SV_DepthLessEqual
					#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
				#else
					#define ASE_SV_DEPTH SV_Depth
					#define ASE_SV_POSITION_QUALIFIERS
				#endif

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					ASE_SV_POSITION_QUALIFIERS float4 pos : SV_POSITION;
					float4 ase_texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				uniform float4 CloudColor;
				uniform float4 CloudShadeColor;
				uniform float2 CloudRemap;
				uniform sampler2D _CloudShape;
				uniform float _FarClip;
				uniform float FarClipDistance;
				uniform float SunOffset;
				uniform sampler2D _CloudDetail;
				uniform float BendAmount;
				uniform float2 BendRemap;
				uniform float CloudDetailScale;
				uniform float SunOffsetDetail;
				uniform float SunOffsetVolumeMult;
				uniform float InnerCloudVolumeCutoff;
				uniform float CloudScale;
				uniform float CloudDetailDistort;
				uniform float CloudRoughness;
				uniform float CloudDetailStr;
				uniform float2 CloudHorizonRemap;
				uniform float CloudHorizonStr;
				uniform float CloudVolumeStr;
				uniform float CloudAlpha;
				uniform float HorizonFade;
				uniform sampler2D _Stars;
				uniform float4 StarColor;


				//This is a late directive
				

				v2f vert( appdata v  )
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					float3 ase_positionWS = mul( unity_ObjectToWorld, float4( ( v.vertex ).xyz, 1 ) ).xyz;
					o.ase_texcoord.xyz = ase_positionWS;
					
					
					//setting value to unused interpolator channels and avoid initialization warnings
					o.ase_texcoord.w = 0;

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					o.pos = UnityObjectToClipPos( v.vertex );

					#if defined( ASE_SHADOWS )
						UNITY_TRANSFER_SHADOW( o, v.texcoord );
					#endif
					return o;
				}

				half4 frag( v2f IN 
							#if defined( ASE_WRITE_DEPTH )
								, out float outputDepth : SV_Depth
							#endif
				) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( IN );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

					float4 ScreenPosNorm = float4( IN.pos.xy * ( _ScreenParams.zw - 1.0 ), IN.pos.zw );
					float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, IN.pos.z ) * IN.pos.w;
					float4 ScreenPos = ComputeScreenPos( ClipPos );

					float4 temp_cast_0 = (1.0).xxxx;
					float2 CloudRemap178_g83 = CloudRemap;
					float2 break235_g83 = CloudRemap178_g83;
					float3 ase_positionWS = IN.ase_texcoord.xyz;
					float3 ase_viewVectorWS = ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz );
					float3 ase_viewDirWS = normalize( ase_viewVectorWS );
					float3 temp_output_275_0_g83 = ase_viewDirWS;
					float FarClip32_g85 = _FarClip;
					float3 SkyWP41_g85 = ( -temp_output_275_0_g83 * ( FarClip32_g85 * 10.0 ) );
					float3 worldSpaceLightDir = UnityWorldSpaceLightDir( ase_positionWS );
					float FarClip179_g83 = FarClipDistance;
					float3 SunPos194_g83 = ( worldSpaceLightDir * ( FarClip179_g83 * 10.0 * 1.0 ) );
					float3 normalizeResult201_g83 = normalize( ( SunPos194_g83 - ase_positionWS ) );
					float3 SunDir206_g83 = normalizeResult201_g83;
					float FarClip32_g84 = _FarClip;
					float3 SkyWP41_g84 = ( -temp_output_275_0_g83 * ( FarClip32_g84 * 10.0 ) );
					float3 break7_g84 = ( SkyWP41_g84 + float3( 0,0,0 ) );
					float2 appendResult9_g84 = (float2(break7_g84.x , break7_g84.z));
					float2 break16_g84 =  (float2( -1,-1 ) + ( BendRemap - float2( 0,0 ) ) * ( float2( 1,1 ) - float2( -1,-1 ) ) / ( float2( 1,1 ) - float2( 0,0 ) ) );
					float SkyY31_g84 = ( SkyWP41_g84.y / ( FarClip32_g84 * 10.0 ) );
					float smoothstepResult17_g84 = smoothstep( break16_g84.x , break16_g84.y , SkyY31_g84);
					float SkyYFactor25_g84 = ( SkyWP41_g84.y + ( ( FarClip32_g84 * BendAmount ) * ( 1.0 - smoothstepResult17_g84 ) ) );
					float2 SkyUV136_g83 = ( appendResult9_g84 / SkyYFactor25_g84 );
					float T_CloudDetail143_g83 = tex2D( _CloudDetail, ( SkyUV136_g83 * CloudDetailScale ) ).r;
					float lerpResult191_g83 = lerp( CloudRemap178_g83.x , 1.0 , InnerCloudVolumeCutoff);
					float CloudScale144_g83 = CloudScale;
					float CloudDetailDistort145_g83 = CloudDetailDistort;
					float2 temp_output_155_0_g83 = ( ( SkyUV136_g83 * CloudScale144_g83 ) + ( T_CloudDetail143_g83 * CloudDetailDistort145_g83 ) );
					float lerpResult168_g83 = lerp( tex2D( _CloudShape, temp_output_155_0_g83 ).r , tex2D( _CloudShape, ( temp_output_155_0_g83 * 3.0 ) ).r , CloudRoughness);
					float CloudDetailStr160_g83 = CloudDetailStr;
					float T_Cloud173_g83 = ( lerpResult168_g83 + ( T_CloudDetail143_g83 * CloudDetailStr160_g83 ) );
					float2 break157_g83 = ( 1.0 - CloudHorizonRemap );
					float SkyY151_g83 = SkyY31_g84;
					float smoothstepResult161_g83 = smoothstep( break157_g83.x , break157_g83.y ,  (1.0 + ( SkyY151_g83 - -1.0 ) * ( 0.0 - 1.0 ) / ( 1.0 - -1.0 ) ));
					float CloudHorizonAddition172_g83 = ( ( 1.0 - smoothstepResult161_g83 ) * CloudHorizonStr );
					float CloudShapeValue186_g83 = ( T_Cloud173_g83 + CloudHorizonAddition172_g83 );
					float smoothstepResult193_g83 = smoothstep( CloudRemap178_g83.x , lerpResult191_g83 , CloudShapeValue186_g83);
					float VolumeValueRaw198_g83 = ( 1.0 - smoothstepResult193_g83 );
					float lerpResult209_g83 = lerp( SunOffsetVolumeMult , 1.0 , VolumeValueRaw198_g83);
					float3 break7_g85 = ( SkyWP41_g85 + ( SunDir206_g83 * ( ( SunOffset + ( T_CloudDetail143_g83 * SunOffsetDetail ) ) * FarClip179_g83 * lerpResult209_g83 ) ) );
					float2 appendResult9_g85 = (float2(break7_g85.x , break7_g85.z));
					float2 break16_g85 =  (float2( -1,-1 ) + ( BendRemap - float2( 0,0 ) ) * ( float2( 1,1 ) - float2( -1,-1 ) ) / ( float2( 1,1 ) - float2( 0,0 ) ) );
					float SkyY31_g85 = ( SkyWP41_g85.y / ( FarClip32_g85 * 10.0 ) );
					float smoothstepResult17_g85 = smoothstep( break16_g85.x , break16_g85.y , SkyY31_g85);
					float SkyYFactor25_g85 = ( SkyWP41_g85.y + ( ( FarClip32_g85 * BendAmount ) * ( 1.0 - smoothstepResult17_g85 ) ) );
					float2 SkyUV_SunOffset215_g83 = ( appendResult9_g85 / SkyYFactor25_g85 );
					float2 temp_output_222_0_g83 = ( ( SkyUV_SunOffset215_g83 * CloudScale144_g83 ) + ( T_CloudDetail143_g83 * CloudDetailDistort145_g83 ) );
					float lerpResult229_g83 = lerp( tex2D( _CloudShape, temp_output_222_0_g83 ).r , tex2D( _CloudShape, ( temp_output_222_0_g83 * 3.0 ) ).r , CloudRoughness);
					float T_Cloud_SunOffset231_g83 = ( lerpResult229_g83 + ( T_CloudDetail143_g83 * CloudDetailStr160_g83 ) );
					float smoothstepResult237_g83 = smoothstep( break235_g83.x , break235_g83.y , ( T_Cloud_SunOffset231_g83 + CloudHorizonAddition172_g83 ));
					float CloudShape_SunOffset241_g83 = smoothstepResult237_g83;
					float4 lerpResult251_g83 = lerp( temp_cast_0 , CloudShadeColor , CloudShape_SunOffset241_g83);
					float lerpResult242_g83 = lerp( 1.0 , VolumeValueRaw198_g83 , CloudVolumeStr);
					float VolumeValue244_g83 = lerpResult242_g83;
					float2 break240_g83 = CloudRemap178_g83;
					float smoothstepResult243_g83 = smoothstep( break240_g83.x , break240_g83.y , CloudShapeValue186_g83);
					float CloudShape245_g83 = smoothstepResult243_g83;
					float smoothstepResult255_g83 = smoothstep( 0.0 , HorizonFade , SkyY151_g83);
					float temp_output_332_130 = ( CloudShape245_g83 * CloudAlpha * smoothstepResult255_g83 );
					float4 lerpResult154 = lerp( float4( 0,0,0,0 ) , ( ( CloudColor * lerpResult251_g83 ) * VolumeValue244_g83 ) , temp_output_332_130);
					float FarClip32_g81 = _FarClip;
					float3 SkyWP41_g81 = ( -ase_viewDirWS * ( FarClip32_g81 * 10.0 ) );
					float3 break7_g81 = ( SkyWP41_g81 + float3( 0,0,0 ) );
					float2 appendResult9_g81 = (float2(break7_g81.x , break7_g81.z));
					float2 break16_g81 =  (float2( -1,-1 ) + ( BendRemap - float2( 0,0 ) ) * ( float2( 1,1 ) - float2( -1,-1 ) ) / ( float2( 1,1 ) - float2( 0,0 ) ) );
					float SkyY31_g81 = ( SkyWP41_g81.y / ( FarClip32_g81 * 10.0 ) );
					float smoothstepResult17_g81 = smoothstep( break16_g81.x , break16_g81.y , SkyY31_g81);
					float SkyYFactor25_g81 = ( SkyWP41_g81.y + ( ( FarClip32_g81 * BendAmount ) * ( 1.0 - smoothstepResult17_g81 ) ) );
					float4 tex2DNode348 = tex2Dlod( _Stars, float4( ( ( appendResult9_g81 / SkyYFactor25_g81 ) * 0.15 ), 0, 0.0) );
					float smoothstepResult349 = smoothstep( 0.6 , 0.7 , tex2DNode348.r);
					float StarY359 = SkyY31_g81;
					float4 Star361 = ( ( ( smoothstepResult349 * ( tex2DNode348.r * tex2DNode348.r * tex2DNode348.r * tex2DNode348.r * tex2DNode348.r ) ) * StarColor * StarColor.a ) * saturate( StarY359 ) );
					float smoothstepResult369 = smoothstep( 0.01 , 0.0 , temp_output_332_130);
					

					float3 Color = ( lerpResult154 + ( Star361 * smoothstepResult369 ) ).rgb;
					float Alpha = 1;
					half AlphaClipThreshold = 0.5;
					half AlphaClipThresholdShadow = 0.5;

					#if defined( ASE_WRITE_DEPTH )
						outputDepth = IN.pos.z;
					#endif

					#ifdef _ALPHATEST_ON
						clip( Alpha - AlphaClipThreshold );
					#endif

				#if defined( ASE_SURFACE_TRANSPARENT ) || defined( ASE_OPAQUE_KEEP_ALPHA )
					return half4( Color, Alpha );
				#else
					return half4( Color, 1.0 );
				#endif
				}
			ENDCG
		}

		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			CGPROGRAM
				#define ASE_VERSION 19911

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#ifndef UNITY_PASS_SHADOWCASTER
					#define UNITY_PASS_SHADOWCASTER
				#endif
				#include "UnityCG.cginc"

				

				#if defined(ASE_WRITE_DEPTH_CONSERVATIVE) && (SHADER_TARGET >= 45)
					#define ASE_SV_DEPTH SV_DepthLessEqual
					#define ASE_SV_POSITION_QUALIFIERS linear noperspective centroid
				#else
					#define ASE_SV_DEPTH SV_Depth
					#define ASE_SV_POSITION_QUALIFIERS
				#endif

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					ASE_SV_POSITION_QUALIFIERS UNITY_POSITION( pos );
					V2F_SHADOW_CASTER_NOPOS
					
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				#ifdef UNITY_STANDARD_USE_DITHER_MASK
					sampler3D _DitherMaskLOD;
				#endif

				

				
				v2f vert( appdata v  )
				{
					UNITY_SETUP_INSTANCE_ID( v );
					v2f o;
					UNITY_INITIALIZE_OUTPUT( v2f, o );
					UNITY_TRANSFER_INSTANCE_ID( v, o );
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

					

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}

				half4 frag( v2f IN 
							#if defined( ASE_WRITE_DEPTH )
								, out float outputDepth : SV_Depth
							#endif
							) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);

					#ifdef LOD_FADE_CROSSFADE
						UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
					#endif

					

					float Alpha = 1;
					half AlphaClipThreshold = 0.5;
					half AlphaClipThresholdShadow = 0.5;

					#if defined( ASE_WRITE_DEPTH )
						outputDepth = IN.pos.z;
					#endif

					#ifdef _ALPHATEST_SHADOW_ON
						if (unity_LightShadowBias.z != 0.0)
							clip(Alpha - AlphaClipThresholdShadow);
						#ifdef _ALPHATEST_ON
						else
							clip(Alpha - AlphaClipThreshold);
						#endif
					#else
						#ifdef _ALPHATEST_ON
							clip(Alpha - AlphaClipThreshold);
						#endif
					#endif

					#ifdef UNITY_STANDARD_USE_DITHER_MASK
						half alphaRef = tex3D(_DitherMaskLOD, float3(IN.pos.xy*0.25,Alpha*0.9375)).a;
						clip(alphaRef - 0.01);
					#endif

					SHADOW_CASTER_FRAGMENT(IN)
				}
			ENDCG
		}
		
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19911
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":344,"pos":[480,-1440],"params":["Inherit","False","SkyboxUV","0","","81","baba5632a7c61324790fc3d38f495ee9","0","3","43","FLOAT3","0,0,0","False","69","FLOAT3","0,0,0","False","39","FLOAT3","0,0,0","False","2","FLOAT2","0","FLOAT","40"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":351,"pos":[1056,-1360],"params":["Inherit","False","Constant","_Float7","Float 7","2","0","Create","True","0","0","0","False","0","False","Object","-1","","0.15","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":350,"pos":[1248,-1424],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":348,"pos":[1472,-1456],"params":["Inherit","True","Property","_Stars","Stars","9","1","[SingleLineTexture]","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","MipLevel","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":352,"pos":[2000,-1264],"params":["Inherit","False","5","5","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","4","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":349,"pos":[1984,-1488],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0.6","False","2","FLOAT","0.7","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":359,"pos":[784,-1312],"params":["Inherit","False","StarY","-1","True","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":353,"pos":[2272,-1408],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":355,"pos":[2272,-1088],"params":["Inherit","False","Global","StarColor","StarColor","3","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","1,1,1,1","0,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":360,"pos":[2784,-1088],"params":["Inherit","False","359","StarY","1","0","OBJECT","","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":354,"pos":[2560,-1232],"params":["Inherit","False","3","3","0","FLOAT","0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":363,"pos":[3040,-1104],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":356,"pos":[3248,-1232],"params":["Inherit","False","2","2","0","COLOR","0,0,0,0","False","1","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor","id":361,"pos":[3536,-1232],"params":["Inherit","False","Star","-1","True","1","0","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":367,"pos":[1360,528],"params":["Inherit","False","SampleSkyColor","-1","","90","","0","0","0"]}
{"type":"AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor","id":362,"pos":[1696,1088],"params":["Inherit","False","361","Star","1","0","OBJECT","","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":369,"pos":[1656.708,857.8217],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0.01","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":154,"pos":[1856,608],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":370,"pos":[2014.708,956.8217],"params":["Inherit","False","2","2","0","COLOR","0,0,0,0","False","1","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":357,"pos":[2288,704],"params":["Inherit","False","2","2","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":332,"pos":[1360,704],"params":["Inherit","False","SampleClouds","2","","83","9aed58410f893cb4f94d69d875097b79","0","2","275","FLOAT3","0,0,0","False","260","FLOAT","0","False","2","COLOR","0","FLOAT","130"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":15,"pos":[2576,736],"params":["Float","False","True","-1","3","AmplifyShaderEditor.MaterialInspector","100","7","W/Skybox","0770190933193b94aaa3065e307002fa","True","Unlit","0","1","Unlit","8","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","10","Surface","0","0","  Keep Alpha","0","0","  Blend","0","0","Alpha Clipping","0","0","  Use Shadow Threshold","0","0","Cast Shadows","1","0","Write Depth","0","0","  Conservative","0","0","Extra Pre Pass","0","0","Vertex Position","1","0","0","3","False","True","True","False","","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":371,"pos":[2576,746],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","1","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ShadowCaster","0","2","ShadowCaster","0","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":372,"pos":[2576,736],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","1","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ExtraPrePass","0","0","ExtraPrePass","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","0","False","0"]}
{"wire":[350,0,344,0]}
{"wire":[350,1,351,0]}
{"wire":[348,1,350,0]}
{"wire":[352,0,348,1]}
{"wire":[352,1,348,1]}
{"wire":[352,2,348,1]}
{"wire":[352,3,348,1]}
{"wire":[352,4,348,1]}
{"wire":[349,0,348,1]}
{"wire":[359,0,344,40]}
{"wire":[353,0,349,0]}
{"wire":[353,1,352,0]}
{"wire":[354,0,353,0]}
{"wire":[354,1,355,0]}
{"wire":[354,2,355,4]}
{"wire":[363,0,360,0]}
{"wire":[356,0,354,0]}
{"wire":[356,1,363,0]}
{"wire":[361,0,356,0]}
{"wire":[369,0,332,130]}
{"wire":[154,1,332,0]}
{"wire":[154,2,332,130]}
{"wire":[370,0,362,0]}
{"wire":[370,1,369,0]}
{"wire":[357,0,154,0]}
{"wire":[357,1,370,0]}
{"wire":[15,0,357,0]}
ASEEND*/
//CHKSM=C62009209EB723FCBE4A13E5968039D8A90C136B