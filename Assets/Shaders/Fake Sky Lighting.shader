// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fake Sky Lighting"
{
	Properties
	{
		_UVScale( "UV Scale", Float ) = 0
		_BendExponent( "Bend Exponent", Range( 1, 50 ) ) = 8
		_CloudCoverage( "Cloud Coverage", Range( 0, 1 ) ) = 0.5
		_CloudSmoothness( "Cloud Smoothness", Range( 0, 1 ) ) = 0.1
		_LightOffsetDistance( "Light Offset Distance", Range( 0.001, 0.5 ) ) = 0.001
		_Background( "Background", Color ) = ( 0, 0, 0, 0 )
		_Cloud( "Cloud", Color ) = ( 0, 0, 0, 0 )
		[HDR] _Light( "Light", Color ) = ( 0, 0, 0, 0 )
		_Noise( "Noise", 2D ) = "white" {}

	}

	SubShader
	{
		

		

		Tags { "RenderType"="Opaque" }

	LOD 0

		ZWrite On
		Cull Back
		AlphaToMask Off
		ColorMask RGBA
		Blend One Zero, One Zero
		BlendOp Add, Add

		

		Blend One Zero, One Zero
		BlendOp Add, Add
		

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
				#define ASE_VERSION 19912

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#include "UnityCG.cginc"

				#include "Lighting.cginc"
				#include "Assets/Shaders/Final/FBMNoise.cginc"


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

				uniform float4 _Background;
				uniform float4 _Cloud;
				uniform float4 _Light;
				uniform sampler2D _Noise;
				uniform float _UVScale;
				uniform float _BendExponent;
				uniform float _LightOffsetDistance;
				uniform float _CloudCoverage;
				uniform float _CloudSmoothness;


				
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

					float3 temp_output_1_0_g329 = float3( 0,0,0 );
					float3 temp_output_4_0_g329 = float3( 0,1,0 );
					#if ( SHADER_TARGET >= 50 )
					float recip6 = rcp( _UVScale );
					#else
					float recip6 = 1.0 / _UVScale;
					#endif
					float3 appendResult13_g328 = (float3(0.0 , recip6 , 0.0));
					float dotResult5_g329 = dot( temp_output_4_0_g329 , ( appendResult13_g328 - temp_output_1_0_g329 ) );
					float3 ase_positionWS = IN.ase_texcoord.xyz;
					float3 ase_viewVectorWS = ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz );
					float3 ase_viewDirWS = normalize( ase_viewVectorWS );
					float3 temp_output_2_0_g329 = -ase_viewDirWS;
					float dotResult8_g329 = dot( temp_output_4_0_g329 , temp_output_2_0_g329 );
					float3 break14_g328 = ( temp_output_1_0_g329 + ( ( dotResult5_g329 / dotResult8_g329 ) * temp_output_2_0_g329 ) );
					float2 appendResult20_g328 = (float2(break14_g328.x , break14_g328.z));
					float2 lerpResult28_g328 = lerp( appendResult20_g328 , float2( 0,0 ) , pow( ( 1.0 - -ase_viewDirWS.y ) , _BendExponent ));
					float2 temp_output_3_0 = lerpResult28_g328;
					float4 tex2DNode76 = tex2D( _Noise, temp_output_3_0 );
					float3 temp_output_1_0_g378 = float3( 0,0,0 );
					float3 temp_output_4_0_g378 = float3( 0,1,0 );
					float3 appendResult68 = (float3(0.0 , recip6 , 0.0));
					float dotResult5_g378 = dot( temp_output_4_0_g378 , ( appendResult68 - temp_output_1_0_g378 ) );
					float3 ase_mainLightDirection = _WorldSpaceLightPos0.xyz;
					float3 temp_output_2_0_g378 = ase_mainLightDirection;
					float dotResult8_g378 = dot( temp_output_4_0_g378 , temp_output_2_0_g378 );
					float3 temp_output_1_0_g379 = float3( 0,0,0 );
					float3 temp_output_4_0_g379 = float3( 0,1,0 );
					float dotResult5_g379 = dot( temp_output_4_0_g379 , ( appendResult68 - temp_output_1_0_g379 ) );
					float3 temp_output_2_0_g379 = ase_viewDirWS;
					float dotResult8_g379 = dot( temp_output_4_0_g379 , temp_output_2_0_g379 );
					float3 normalizeResult71 = normalize( ( ( temp_output_1_0_g378 + ( ( dotResult5_g378 / dotResult8_g378 ) * temp_output_2_0_g378 ) ) - ( temp_output_1_0_g379 + ( ( dotResult5_g379 / dotResult8_g379 ) * temp_output_2_0_g379 ) ) ) );
					float3 break69 = normalizeResult71;
					float2 appendResult55 = (float2(break69.x , break69.z));
					float3 lerpResult75 = lerp( _Cloud.rgb , _Light.rgb , saturate( ( tex2DNode76.r - tex2D( _Noise, ( temp_output_3_0 + ( appendResult55 * _LightOffsetDistance ) ) ).r ) ));
					float temp_output_2_0_g330 = ( 1.0 - _CloudCoverage );
					float smoothstepResult12_g330 = smoothstep( temp_output_2_0_g330 , min( ( temp_output_2_0_g330 + _CloudSmoothness ), 1.0 ) , tex2DNode76.r);
					float4 lerpResult58 = lerp( _Background , float4( lerpResult75 , 0.0 ) , saturate( smoothstepResult12_g330 ));
					

					float3 Color = lerpResult58.rgb;
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
				#define ASE_VERSION 19912

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#ifndef UNITY_PASS_SHADOWCASTER
					#define UNITY_PASS_SHADOWCASTER
				#endif
				#include "UnityCG.cginc"

				#include "Assets/Shaders/Final/FBMNoise.cginc"


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
Version=19912
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":4,"pos":[-1248,-288],"params":["Inherit","False","Property","_BendExponent","Bend Exponent","1","0","Create","True","1","Sky","0","0","False","0","False","Object","-1","","8","0","1","50","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor","id":8,"pos":[-1296,-472],"params":["Inherit","False","World","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":3,"pos":[-864,-328],"params":["Inherit","False","Skybox Cloud UV","-1","","328","4babc77e02c1a2642b5c7564fb429ae7","0","4","32","FLOAT3","0,0,0","False","31","FLOAT3","0,0,0","False","26","FLOAT","5","False","24","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":45,"pos":[-506.4436,-630.4342],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":46,"pos":[-834.4436,-622.4342],"params":["Float","False","Property","_CloudCoverage","Cloud Coverage","2","0","Create","True","0","0","0","False","0","False","Object","-1","","0.5","0","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":47,"pos":[-714.4436,-534.4342],"params":["Inherit","False","Property","_CloudSmoothness","Cloud Smoothness","3","0","Create","True","0","0","0","False","0","False","Object","-1","","0.1","0","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":42,"pos":[-176,-272],"params":["Inherit","False","FLOAT4","1","0","FLOAT4","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":43,"pos":[-64,-584],"params":["Inherit","False","MaskRemap","-1","","330","173036804ac0c37418ff32bbae959f1c","0","3","1","FLOAT","0","False","2","FLOAT","0","False","5","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":53,"pos":[-48,32],"params":["Inherit","False","FLOAT4","1","0","FLOAT4","0,0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":52,"pos":[120,-136],"params":["Inherit","False","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":44,"pos":[208,-584],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":67,"pos":[-1760,488],"params":["Inherit","False","RayPlaneIntersection","-1","","378","be9c3761635c8d844be2363f1409ecd8","0","4","1","FLOAT3","0,0,0","False","2","FLOAT3","0,0,0","False","3","FLOAT3","0,0,0","False","4","FLOAT3","0,1,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":68,"pos":[-2128,616],"params":["Inherit","False","FLOAT3","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor","id":70,"pos":[-1472,640],"params":["Inherit","False","2","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.NormalizeNode, AmplifyShaderEditor","id":71,"pos":[-1304,632],"params":["Inherit","False","False","1","0","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":72,"pos":[-1752,712],"params":["Inherit","False","RayPlaneIntersection","-1","","379","be9c3761635c8d844be2363f1409ecd8","0","4","1","FLOAT3","0,0,0","False","2","FLOAT3","0,0,0","False","3","FLOAT3","0,0,0","False","4","FLOAT3","0,1,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.MainLight, AmplifyShaderEditor","id":41,"pos":[-2616,80],"params":["Inherit","False","0","5","FLOAT3","0","FLOAT3","1","FLOAT3","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor","id":73,"pos":[-2440,736],"params":["Inherit","False","World","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":5,"pos":[-2784,-256],"params":["Inherit","False","Property","_UVScale","UV Scale","0","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0","0","0","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ReciprocalOpNode, AmplifyShaderEditor","id":6,"pos":[-2464,-272],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.BreakToComponentsNode, AmplifyShaderEditor","id":69,"pos":[-1168,440],"params":["Inherit","False","FLOAT3","1","0","FLOAT3","0,0,0","False","16","FLOAT","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT","5","FLOAT","6","FLOAT","7","FLOAT","8","FLOAT","9","FLOAT","10","FLOAT","11","FLOAT","12","FLOAT","13","FLOAT","14","FLOAT","15"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":50,"pos":[-1032,592],"params":["Inherit","False","Property","_LightOffsetDistance","Light Offset Distance","4","0","Create","True","0","0","0","False","0","False","Object","-1","","0.001","0","0.001","0.5","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":49,"pos":[-592,552],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.DynamicAppendNode, AmplifyShaderEditor","id":55,"pos":[-784,400],"params":["Inherit","False","FLOAT2","4","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","3","FLOAT","0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor","id":74,"pos":[390.5144,-109.0317],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":75,"pos":[600,-200],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":58,"pos":[632,-672],"params":["Inherit","False","3","0","COLOR","0,0,0,0","False","1","COLOR","0,0,0,0","False","2","FLOAT","0","False","1","COLOR","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":63,"pos":[264,64],"params":["Inherit","False","Property","_Light","Light","7","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":60,"pos":[184,-440],"params":["Inherit","False","Property","_Cloud","Cloud","6","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":59,"pos":[224,-952],"params":["Inherit","False","Property","_Background","Background","5","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0,0,0,0","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":76,"pos":[-568,-360],"params":["Inherit","True","Property","_TextureSample0","Texture Sample 0","8","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor","id":48,"pos":[-584,104],"params":["Inherit","False","2","2","0","FLOAT2","0,0","False","1","FLOAT2","0,0","False","1","FLOAT2","0"]}
{"type":"AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor","id":78,"pos":[-440,32],"params":["Inherit","True","Property","_TextureSample1","TextureSample1","8","0","Create","True","0","0","0","False","0","False","","-1","None","None","True","0","False","white","Auto","False","Object","-1","Auto","Texture2D","False","8","0","SAMPLER2D","","False","1","FLOAT2","0,0","False","2","FLOAT","0","False","3","FLOAT2","0,0","False","4","FLOAT2","0,0","False","5","FLOAT","1","False","6","FLOAT","0","False","7","SAMPLERSTATE","","False","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.TexturePropertyNode, AmplifyShaderEditor","id":77,"pos":[-1112,-32],"params":["Inherit","True","Property","_Noise","Noise","8","0","Create","True","0","0","0","False","0","False","","None","None","False","white","Auto","Texture2D","False","-1","0","2","SAMPLER2D","0","SAMPLERSTATE","1"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":38,"pos":[-48,-328],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ExtraPrePass","0","0","ExtraPrePass","6","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":40,"pos":[-48,-328],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ShadowCaster","0","2","ShadowCaster","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":39,"pos":[888,-504],"params":["Float","False","True","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","Fake Sky Lighting","0770190933193b94aaa3065e307002fa","True","Unlit","0","1","Unlit","8","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","2","Include","","False","","Native","False","0","0","","Include","","True","febec3adb872b90429418d9516a0f0f9","Custom","False","0","0","","","0","0","Standard","10","Surface","0","0","  Keep Alpha","0","0","  Blend","0","0","Alpha Clipping","0","0","  Use Shadow Threshold","0","0","Cast Shadows","1","0","Write Depth","0","0","  Conservative","0","0","Extra Pre Pass","0","0","Vertex Position","1","0","0","3","False","True","True","False","","False","0"]}
{"wire":[3,32,8,0]}
{"wire":[3,26,4,0]}
{"wire":[3,24,6,0]}
{"wire":[45,0,46,0]}
{"wire":[43,1,76,1]}
{"wire":[43,2,45,0]}
{"wire":[43,5,47,0]}
{"wire":[52,0,76,1]}
{"wire":[52,1,78,1]}
{"wire":[44,0,43,0]}
{"wire":[67,2,41,0]}
{"wire":[67,3,68,0]}
{"wire":[68,1,6,0]}
{"wire":[70,0,67,0]}
{"wire":[70,1,72,0]}
{"wire":[71,0,70,0]}
{"wire":[72,2,73,0]}
{"wire":[72,3,68,0]}
{"wire":[6,0,5,0]}
{"wire":[69,0,71,0]}
{"wire":[49,0,55,0]}
{"wire":[49,1,50,0]}
{"wire":[55,0,69,0]}
{"wire":[55,1,69,2]}
{"wire":[74,0,52,0]}
{"wire":[75,0,60,5]}
{"wire":[75,1,63,5]}
{"wire":[75,2,74,0]}
{"wire":[58,0,59,0]}
{"wire":[58,1,75,0]}
{"wire":[58,2,44,0]}
{"wire":[76,0,77,0]}
{"wire":[76,1,3,0]}
{"wire":[48,0,3,0]}
{"wire":[48,1,49,0]}
{"wire":[78,0,77,0]}
{"wire":[78,1,48,0]}
{"wire":[39,0,58,0]}
ASEEND*/
//CHKSM=996944D889F5D25FFBA8F88A4F7453D5C2DE4157