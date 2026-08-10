// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Skybox New"
{
	Properties
	{
		_CloudColour( "Cloud Colour", Color ) = ( 0, 0, 0, 0 )
		_InteriorColour( "Interior Colour", Color ) = ( 0, 0, 0, 0 )
		[HDR] _EdgeColour( "Edge Colour", Color ) = ( 0, 0, 0, 0 )
		[HDR] _PierceColour( "Pierce Colour", Color ) = ( 0, 0, 0, 0 )
		[IntRange]_Octaves( "Octaves", Range( 1, 8 ) ) = 5
		_Cutoff( "Cutoff", Range( 0, 1 ) ) = 0
		_Smoothness( "Smoothness", Range( 0, 1 ) ) = 0
		_GradientStrength( "Gradient Strength", Range( 0, 10 ) ) = 0
		_ScrollSpeed( "Scroll Speed", Range( 0, 1 ) ) = 0
		_BendExponent( "Bend Exponent", Range( 1, 50 ) ) = 5
		_ScrollDirection( "Scroll Direction", Range( 0, 360 ) ) = 0
		[PowerSlider(3)] _SunPierceExponent( "Sun Pierce Exponent", Range( 0, 3000 ) ) = 1
		_CloudScale( "Cloud Scale", Float ) = 0
		_EdgeCutoff( "Edge Cutoff", Range( 0, 1 ) ) = 0
		_EdgeSmoothness( "Edge Smoothness", Range( 0, 1 ) ) = 0
		_InteriorCutoff( "Interior Cutoff", Range( 0, 1 ) ) = 1
		_InteriorSmoothness( "Interior Smoothness", Range( 0, 1 ) ) = 0
		_InteriorPierceBlocking( "Interior Pierce Blocking", Range( 0, 1 ) ) = 0
		[Header(Sky)] _SkyColour( "Sky Colour", Color ) = ( 0.2117647, 0.4313726, 0.6705883, 1 )
		_SunnySkyColour( "Sunny Sky Colour", Color ) = ( 0.5647059, 0.8156863, 0.8509804, 1 )
		_HorizonColour( "Horizon Colour", Color ) = ( 1, 0.6627451, 0.3647059, 1 )
		[PowerSlider(3)] _SunnySkyExponent( "Sunny Sky Exponent", Range( 0, 300 ) ) = 1
		_HorizonHeight( "Horizon Height", Range( 0, 1 ) ) = 0
		[PowerSlider(3)] _HorizonExponent( "Horizon Exponent", Range( 0, 200 ) ) = 20
		[HDR] _SunColour( "Sun Colour", Color ) = ( 1, 1, 1, 1 )
		_SunSize( "Sun Size", Range( 0, 1 ) ) = 0

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
				#define ASE_VERSION 19912

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#include "UnityCG.cginc"

				#include "Lighting.cginc"
				#include "UnityShaderVariables.cginc"
				#include "Assets/Shaders/FBMNoise.cginc"


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

				uniform float4 _SkyColour;
				uniform float4 _SunnySkyColour;
				uniform float _SunnySkyExponent;
				uniform float4 _HorizonColour;
				uniform float _HorizonHeight;
				uniform float _HorizonExponent;
				uniform float4 _SunColour;
				uniform float _SunSize;
				uniform float4 _CloudColour;
				uniform float4 _InteriorColour;
				uniform float _InteriorCutoff;
				uniform float _InteriorSmoothness;
				uniform float _ScrollDirection;
				uniform float _ScrollSpeed;
				uniform float _CloudScale;
				uniform float _BendExponent;
				uniform int _Octaves;
				uniform float _GradientStrength;
				uniform float4 _EdgeColour;
				uniform float _EdgeCutoff;
				uniform float _EdgeSmoothness;
				uniform float4 _PierceColour;
				uniform float _SunPierceExponent;
				uniform float _InteriorPierceBlocking;
				uniform float _Cutoff;
				uniform float _Smoothness;


				float4 FBMWithGradient( float2 UV, int Octaves, float Gain, float Lacunarity, float GradientStrength )
				{
					return fbmd(UV,Gain,Lacunarity,Octaves,GradientStrength);
				}
				

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

					float3 ase_mainLightDirection = _WorldSpaceLightPos0.xyz;
					float3 ase_positionWS = IN.ase_texcoord.xyz;
					float3 ase_viewVectorWS = ( ( unity_OrthoParams.w == 0 ) ? _WorldSpaceCameraPos - ase_positionWS : UNITY_MATRIX_V[ 2 ].xyz );
					float3 ase_viewDirWS = normalize( ase_viewVectorWS );
					float3 temp_output_98_0_g451 = ase_viewDirWS;
					float dotResult4_g451 = dot( -ase_mainLightDirection , temp_output_98_0_g451 );
					float temp_output_77_0_g451 = ( ( dotResult4_g451 + 1.0 ) * 0.5 );
					float3 lerpResult3_g451 = lerp( _SkyColour.rgb , _SunnySkyColour.rgb , ( _SunnySkyColour.a * saturate( pow( temp_output_77_0_g451 , _SunnySkyExponent ) ) ));
					float3 lerpResult29_g451 = lerp( lerpResult3_g451 , _HorizonColour.rgb , ( _HorizonColour.a * saturate( pow( ( ( 1.0 - -temp_output_98_0_g451.y ) + _HorizonHeight ) , _HorizonExponent ) ) ));
					float temp_output_118_0_g451 = ( 1.0 - ( _SunSize * 0.01 ) );
					float smoothstepResult121_g451 = smoothstep( temp_output_118_0_g451 , 1.0 , temp_output_77_0_g451);
					float3 lerpResult112_g451 = lerp( lerpResult29_g451 , _SunColour.rgb , ( _SunColour.a * smoothstepResult121_g451 ));
					float temp_output_2_0_g701 = _InteriorCutoff;
					float temp_output_27_0_g703 = radians( _ScrollDirection );
					float2 appendResult25_g703 = (float2(cos( temp_output_27_0_g703 ) , sin( temp_output_27_0_g703 )));
					float3 temp_output_1_0_g706 = float3( 0,0,0 );
					float3 temp_output_4_0_g706 = float3( 0,1,0 );
					#if ( SHADER_TARGET >= 50 )
					float recip510_g698 = rcp( _CloudScale );
					#else
					float recip510_g698 = 1.0 / _CloudScale;
					#endif
					float3 appendResult13_g705 = (float3(0.0 , recip510_g698 , 0.0));
					float dotResult5_g706 = dot( temp_output_4_0_g706 , ( appendResult13_g705 - temp_output_1_0_g706 ) );
					float3 temp_output_38_0_g698 = ase_viewDirWS;
					float3 temp_output_34_0_g703 = temp_output_38_0_g698;
					float3 temp_output_2_0_g706 = -temp_output_34_0_g703;
					float dotResult8_g706 = dot( temp_output_4_0_g706 , temp_output_2_0_g706 );
					float3 break14_g705 = ( temp_output_1_0_g706 + ( ( dotResult5_g706 / dotResult8_g706 ) * temp_output_2_0_g706 ) );
					float2 appendResult20_g705 = (float2(break14_g705.x , break14_g705.z));
					float2 lerpResult28_g705 = lerp( appendResult20_g705 , float2( 0,0 ) , pow( ( 1.0 - -temp_output_34_0_g703.y ) , _BendExponent ));
					float2 panner31_g703 = ( -0.1 * _Time.y * ( appendResult25_g703 * _ScrollSpeed ) + lerpResult28_g705);
					float2 UV16_g703 = panner31_g703;
					int Octaves16_g703 = _Octaves;
					float Gain16_g703 = 0.5;
					float Lacunarity16_g703 = 2.0;
					float GradientStrength16_g703 = _GradientStrength;
					float4 localFBMWithGradient16_g703 = FBMWithGradient( UV16_g703 , Octaves16_g703 , Gain16_g703 , Lacunarity16_g703 , GradientStrength16_g703 );
					float temp_output_14_0_g703 = (localFBMWithGradient16_g703).x;
					float temp_output_533_39_g698 = temp_output_14_0_g703;
					float smoothstepResult12_g701 = smoothstep( temp_output_2_0_g701 , min( ( temp_output_2_0_g701 + _InteriorSmoothness ), 1.0 ) , temp_output_533_39_g698);
					float temp_output_1025_516 = smoothstepResult12_g701;
					float3 lerpResult966 = lerp( _CloudColour.rgb , _InteriorColour.rgb , ( _InteriorColour.a * temp_output_1025_516 ));
					float3 temp_output_1_0_g700 = float3( 0,0,0 );
					float3 temp_output_4_0_g700 = float3( 0,1,0 );
					float3 appendResult457_g698 = (float3(0.0 , recip510_g698 , 0.0));
					float dotResult5_g700 = dot( temp_output_4_0_g700 , ( appendResult457_g698 - temp_output_1_0_g700 ) );
					float3 temp_output_39_0_g698 = ase_mainLightDirection;
					float3 temp_output_2_0_g700 = temp_output_39_0_g698;
					float dotResult8_g700 = dot( temp_output_4_0_g700 , temp_output_2_0_g700 );
					float3 temp_output_1_0_g699 = float3( 0,0,0 );
					float3 temp_output_4_0_g699 = float3( 0,1,0 );
					float dotResult5_g699 = dot( temp_output_4_0_g699 , ( appendResult457_g698 - temp_output_1_0_g699 ) );
					float3 temp_output_2_0_g699 = temp_output_38_0_g698;
					float dotResult8_g699 = dot( temp_output_4_0_g699 , temp_output_2_0_g699 );
					float3 normalizeResult459_g698 = normalize( ( ( temp_output_1_0_g700 + ( ( dotResult5_g700 / dotResult8_g700 ) * temp_output_2_0_g700 ) ) - ( temp_output_1_0_g699 + ( ( dotResult5_g699 / dotResult8_g699 ) * temp_output_2_0_g699 ) ) ) );
					float3 break461_g698 = normalizeResult459_g698;
					float3 appendResult491_g698 = (float3(break461_g698.x , break461_g698.z , 0.0));
					float3 normalizeResult440_g698 = normalize( appendResult491_g698 );
					float3 temp_output_533_0_g698 = (localFBMWithGradient16_g703).yzw;
					float dotResult434_g698 = dot( normalizeResult440_g698 , temp_output_533_0_g698 );
					float temp_output_2_0_g702 = _EdgeCutoff;
					float smoothstepResult12_g702 = smoothstep( temp_output_2_0_g702 , min( ( temp_output_2_0_g702 + _EdgeSmoothness ), 1.0 ) , temp_output_533_39_g698);
					float3 lerpResult965 = lerp( lerpResult966 , _EdgeColour.rgb , ( _EdgeColour.a * ( saturate( dotResult434_g698 ) * ( 1.0 - smoothstepResult12_g702 ) ) ));
					float dotResult521_g698 = dot( -temp_output_39_0_g698 , temp_output_38_0_g698 );
					float temp_output_520_0_g698 = ( ( dotResult521_g698 + 1.0 ) * 0.5 );
					float3 appendResult527_g698 = (float3(break461_g698.x , break461_g698.z , 1.0));
					float3 normalizeResult526_g698 = normalize( appendResult527_g698 );
					float dotResult529_g698 = dot( normalizeResult526_g698 , temp_output_533_0_g698 );
					float temp_output_1025_525 = saturate( max( saturate( pow( temp_output_520_0_g698 , ( _SunPierceExponent * 2.0 ) ) ), ( pow( temp_output_520_0_g698 , _SunPierceExponent ) * dotResult529_g698 ) ) );
					float lerpResult1024 = lerp( temp_output_1025_525 , ( ( 1.0 - temp_output_1025_516 ) * temp_output_1025_525 ) , _InteriorPierceBlocking);
					float3 lerpResult1026 = lerp( lerpResult965 , _PierceColour.rgb , ( lerpResult1024 * _PierceColour.a ));
					float temp_output_2_0_g704 = _Cutoff;
					float smoothstepResult12_g704 = smoothstep( temp_output_2_0_g704 , min( ( temp_output_2_0_g704 + _Smoothness ), 1.0 ) , temp_output_14_0_g703);
					float temp_output_4_0_g703 = saturate( smoothstepResult12_g704 );
					float3 lerpResult828 = lerp( lerpResult112_g451 , lerpResult1026 , ( _CloudColour.a * ( step( temp_output_34_0_g703.y , 0.0 ) * temp_output_4_0_g703 ) ));
					

					float3 Color = lerpResult828;
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

				#include "Assets/Shaders/FBMNoise.cginc"


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
{"type":"AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor","id":529,"pos":[3160,-568],"params":["Inherit","False","World","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":828,"pos":[5696,-360],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.MainLight, AmplifyShaderEditor","id":528,"pos":[3120,-160],"params":["Inherit","False","0","5","FLOAT3","0","FLOAT3","1","FLOAT3","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":982,"pos":[3624,-536],"params":["Inherit","False","SkyboxColour","25","","451","0c3f98426aec4244b83898e14f7900cd","0","2","98","FLOAT3","0,0,0","False","68","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":1019,"pos":[3520,304],"params":["Inherit","False","Property","_InteriorPierceSmoothness","InteriorPierceSmoothness","23","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0.894","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":1018,"pos":[3504,232],"params":["Inherit","False","Property","_InteriorPierceCutoff","Interior Pierce Cutoff","22","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0.837","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":966,"pos":[5200,-8],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":965,"pos":[5440,336],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":970,"pos":[5176,-280],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":964,"pos":[4736,-360],"params":["Inherit","False","Property","_CloudColour","Cloud Colour","0","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0.3882338,0.4508415,0.490196,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":963,"pos":[4792,-64],"params":["Inherit","False","Property","_InteriorColour","Interior Colour","1","0","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","0.1017003,0.09594022,0.2641495,0.454902","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":962,"pos":[5056,144],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":969,"pos":[5160,440],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":967,"pos":[4848,288],"params":["Inherit","False","Property","_EdgeColour","Edge Colour","2","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","11.31371,0.9649343,0,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":1024,"pos":[4424,600],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":1025,"pos":[3608,8],"params":["Inherit","False","SkyboxCloudColour","4","","698","e35217d2a61917344908c1fffe4ec998","0","2","38","FLOAT3","0,0,0","False","39","FLOAT3","0,0,0","False","4","FLOAT","525","FLOAT","515","FLOAT","516","FLOAT","401"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":1014,"pos":[3776,680],"params":["Inherit","False","Property","_InteriorPierceBlocking","Interior Pierce Blocking","24","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0.993","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":1016,"pos":[4176,544],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":1022,"pos":[3912,568],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":1026,"pos":[5664,312],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":1027,"pos":[5200,624],"params":["Inherit","False","Property","_PierceColour","Pierce Colour","3","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","0,0,0,0","145.3186,12.39407,0,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":1028,"pos":[5440,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":423,"pos":[2576,736],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ShadowCaster","0","2","ShadowCaster","0","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":800,"pos":[6080,-328],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ExtraPrePass","0","0","ExtraPrePass","6","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":422,"pos":[6128,-264],"params":["Float","False","True","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","Skybox New","0770190933193b94aaa3065e307002fa","True","Unlit","0","1","Unlit","8","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","2","Include","","False","","Native","False","0","0","","Include","","True","febec3adb872b90429418d9516a0f0f9","Custom","False","0","0","","","0","0","Standard","10","Surface","0","0","  Keep Alpha","0","0","  Blend","0","0","Alpha Clipping","0","0","  Use Shadow Threshold","0","0","Cast Shadows","1","0","Write Depth","0","0","  Conservative","0","0","Extra Pre Pass","0","0","Vertex Position","1","0","0","3","False","True","True","False","","False","0"]}
{"wire":[828,0,982,0]}
{"wire":[828,1,1026,0]}
{"wire":[828,2,970,0]}
{"wire":[982,98,529,0]}
{"wire":[982,68,528,0]}
{"wire":[966,0,964,5]}
{"wire":[966,1,963,5]}
{"wire":[966,2,962,0]}
{"wire":[965,0,966,0]}
{"wire":[965,1,967,5]}
{"wire":[965,2,969,0]}
{"wire":[970,0,964,4]}
{"wire":[970,1,1025,401]}
{"wire":[962,0,963,4]}
{"wire":[962,1,1025,516]}
{"wire":[969,0,967,4]}
{"wire":[969,1,1025,515]}
{"wire":[1024,0,1025,525]}
{"wire":[1024,1,1016,0]}
{"wire":[1024,2,1014,0]}
{"wire":[1025,38,529,0]}
{"wire":[1025,39,528,0]}
{"wire":[1016,0,1022,0]}
{"wire":[1016,1,1025,525]}
{"wire":[1022,0,1025,516]}
{"wire":[1026,0,965,0]}
{"wire":[1026,1,1027,5]}
{"wire":[1026,2,1028,0]}
{"wire":[1028,0,1024,0]}
{"wire":[1028,1,1027,4]}
{"wire":[422,0,828,0]}
ASEEND*/
//CHKSM=6FC67777B632655F07E951CE3BE9B17F918BE7BB