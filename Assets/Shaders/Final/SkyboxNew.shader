// Made with Amplify Shader Editor v1.9.9.12
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Skybox New"
{
	Properties
	{
		[Header(Cloud Colours)] _BaseColour( "Base Colour", Color ) = ( 0.3882353, 0.4509804, 0.4901961, 1 )
		_InteriorColour( "Interior Colour", Color ) = ( 0.1019608, 0.09411765, 0.2627451, 0.4117647 )
		[HDR] _EdgeColour( "Edge Colour", Color ) = ( 11.31371, 0.9649343, 0, 1 )
		[HDR] _TransmissionColour( "Transmission Colour", Color ) = ( 4.541207, 0.09375719, 0, 1 )
		[Header(Cloud Shape)] _CloudScale( "Cloud Scale", Float ) = 3
		[IntRange]_CloudNoiseOctaves( "Cloud Noise Octaves", Range( 1, 8 ) ) = 4
		_CloudCoverage( "Cloud Coverage", Range( 0, 1 ) ) = 0.5
		_CloudSmoothness( "Cloud Smoothness", Range( 0, 1 ) ) = 1
		_BendExponent( "Bend Exponent", Range( 1, 50 ) ) = 8
		[Header(Cloud Movement)] _ScrollSpeed( "Scroll Speed", Range( 0, 1 ) ) = 0.1
		_ScrollDirection( "Scroll Direction", Range( 0, 360 ) ) = 0
		_CloudHorizonStrength( "Cloud Horizon Strength", Range( 0, 1 ) ) = 0
		_CloudHorizonHeight( "Cloud Horizon Height", Range( 0, 1 ) ) = 0.2
		_DistortionAmount( "Distortion Amount", Range( 0, 1 ) ) = 0
		_DistortionExponent( "Distortion Exponent", Range( 0.001, 1 ) ) = 0.001
		[Header(Cloud Edge)] _EdgeCutoff( "Edge Cutoff", Range( 0, 1 ) ) = 0.4
		_EdgeSmoothness( "Edge Smoothness", Range( 0, 1 ) ) = 0.2
		[Header(Cloud Interior)] _InteriorCutoff( "Interior Cutoff", Range( 0, 1 ) ) = 0.5
		_InteriorSmoothness( "Interior Smoothness", Range( 0, 1 ) ) = 0.2
		[Header(Cloud Horizon Fade)] _CloudFadeHeight( "Cloud Fade Height", Range( 0, 1 ) ) = 0
		_CloudFadeSmoothness( "Cloud Fade Smoothness", Range( 0, 1 ) ) = 0.1
		[Header(Cloud Transmission)][PowerSlider(3)] _TransmissionExponent( "Transmission Exponent", Range( 0, 3000 ) ) = 100
		_InteriorTransmission( "Interior Transmission", Range( 0, 1 ) ) = 0
		[Header(Sky)] _SkyColour( "Sky Colour", Color ) = ( 0.3921569, 0.6509804, 0.8431373 )
		_SunnySkyColour( "Sunny Sky Colour", Color ) = ( 0.572549, 0.945098, 1, 1 )
		[PowerSlider(3)] _SunnySkyExponent( "Sunny Sky Exponent", Range( 0, 300 ) ) = 16
		[HDR][Header(Sun)] _SunColour( "Sun Colour", Color ) = ( 188.0174, 30.84035, 9.75562, 1 )
		_SunSize( "Sun Size", Range( 0, 1 ) ) = 0.1
		[Header(Horizon)] _HorizonColour( "Horizon Colour", Color ) = ( 0.9686275, 0.627451, 0.4784314, 1 )
		_HorizonHeight( "Horizon Height", Range( 0, 1 ) ) = 0.1
		[PowerSlider(3)] _HorizonExponent( "Horizon Exponent", Range( 0, 200 ) ) = 5
		[Header(Ground)] _GroundColour( "Ground Colour", Color ) = ( 0.2352941, 0.3098039, 0.3568628, 1 )
		_GroundSmoothness( "Ground Smoothness", Range( 0, 1 ) ) = 0

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

				uniform float3 _SkyColour;
				uniform float4 _SunnySkyColour;
				uniform float _SunnySkyExponent;
				uniform float4 _HorizonColour;
				uniform float _HorizonHeight;
				uniform float _HorizonExponent;
				uniform float4 _SunColour;
				uniform float _SunSize;
				uniform float4 _BaseColour;
				uniform float4 _InteriorColour;
				uniform float _InteriorCutoff;
				uniform float _InteriorSmoothness;
				uniform float _ScrollDirection;
				uniform float _ScrollSpeed;
				uniform float _CloudScale;
				uniform float _BendExponent;
				uniform int _CloudNoiseOctaves;
				uniform float _DistortionAmount;
				uniform float _DistortionExponent;
				uniform float4 _EdgeColour;
				uniform float _EdgeCutoff;
				uniform float _EdgeSmoothness;
				uniform float4 _TransmissionColour;
				uniform float _TransmissionExponent;
				uniform float _InteriorTransmission;
				uniform float _CloudCoverage;
				uniform float _CloudSmoothness;
				uniform float _CloudHorizonHeight;
				uniform float _CloudHorizonStrength;
				uniform float _CloudFadeHeight;
				uniform float _CloudFadeSmoothness;
				uniform float4 _GroundColour;
				uniform float _GroundSmoothness;


				float4 FBMWithGradient( float2 UV, int Octaves, float Gain, float Lacunarity, float DistortionAmount, float DistortionExponent )
				{
					return fbmd(UV,Gain,Lacunarity,Octaves,DistortionAmount,DistortionExponent);
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
					float3 temp_output_98_0_g1112 = ase_viewDirWS;
					float dotResult4_g1112 = dot( -ase_mainLightDirection , temp_output_98_0_g1112 );
					float temp_output_77_0_g1112 = ( ( dotResult4_g1112 + 1.0 ) * 0.5 );
					float3 lerpResult3_g1112 = lerp( _SkyColour , _SunnySkyColour.rgb , ( _SunnySkyColour.a * saturate( pow( temp_output_77_0_g1112 , _SunnySkyExponent ) ) ));
					float3 lerpResult29_g1112 = lerp( lerpResult3_g1112 , _HorizonColour.rgb , ( _HorizonColour.a * saturate( pow( ( ( 1.0 - -temp_output_98_0_g1112.y ) + _HorizonHeight ) , _HorizonExponent ) ) ));
					float smoothstepResult121_g1112 = smoothstep( ( 1.0 - ( _SunSize * 0.01 ) ) , 1.0 , temp_output_77_0_g1112);
					float3 lerpResult112_g1112 = lerp( lerpResult29_g1112 , _SunColour.rgb , ( _SunColour.a * smoothstepResult121_g1112 ));
					float temp_output_2_0_g470 = _InteriorCutoff;
					float temp_output_27_0_g474 = radians( _ScrollDirection );
					float2 appendResult25_g474 = (float2(cos( temp_output_27_0_g474 ) , sin( temp_output_27_0_g474 )));
					float3 temp_output_1_0_g477 = float3( 0,0,0 );
					float3 temp_output_4_0_g477 = float3( 0,1,0 );
					#if ( SHADER_TARGET >= 50 )
					float recip510_g468 = rcp( _CloudScale );
					#else
					float recip510_g468 = 1.0 / _CloudScale;
					#endif
					float3 appendResult13_g476 = (float3(0.0 , recip510_g468 , 0.0));
					float dotResult5_g477 = dot( temp_output_4_0_g477 , ( appendResult13_g476 - temp_output_1_0_g477 ) );
					float3 temp_output_38_0_g468 = ase_viewDirWS;
					float3 temp_output_34_0_g474 = temp_output_38_0_g468;
					float3 temp_output_2_0_g477 = -temp_output_34_0_g474;
					float dotResult8_g477 = dot( temp_output_4_0_g477 , temp_output_2_0_g477 );
					float3 break14_g476 = ( temp_output_1_0_g477 + ( ( dotResult5_g477 / dotResult8_g477 ) * temp_output_2_0_g477 ) );
					float2 appendResult20_g476 = (float2(break14_g476.x , break14_g476.z));
					float2 lerpResult28_g476 = lerp( appendResult20_g476 , float2( 0,0 ) , pow( ( 1.0 - -temp_output_34_0_g474.y ) , _BendExponent ));
					float2 panner31_g474 = ( -0.1 * _Time.y * ( appendResult25_g474 * _ScrollSpeed ) + lerpResult28_g476);
					float2 UV16_g474 = panner31_g474;
					int Octaves16_g474 = _CloudNoiseOctaves;
					float Gain16_g474 = 0.5;
					float Lacunarity16_g474 = 2.0;
					float DistortionAmount16_g474 = ( _DistortionAmount * _Time.y );
					float DistortionExponent16_g474 = _DistortionExponent;
					float4 localFBMWithGradient16_g474 = FBMWithGradient( UV16_g474 , Octaves16_g474 , Gain16_g474 , Lacunarity16_g474 , DistortionAmount16_g474 , DistortionExponent16_g474 );
					float temp_output_14_0_g474 = (localFBMWithGradient16_g474).x;
					float temp_output_585_39_g468 = temp_output_14_0_g474;
					float smoothstepResult12_g470 = smoothstep( temp_output_2_0_g470 , min( ( temp_output_2_0_g470 + _InteriorSmoothness ), 1.0 ) , temp_output_585_39_g468);
					float temp_output_1116_516 = smoothstepResult12_g470;
					float3 lerpResult966 = lerp( _BaseColour.rgb , _InteriorColour.rgb , ( _InteriorColour.a * temp_output_1116_516 ));
					float3 temp_output_1_0_g472 = float3( 0,0,0 );
					float3 temp_output_4_0_g472 = float3( 0,1,0 );
					float3 appendResult457_g468 = (float3(0.0 , recip510_g468 , 0.0));
					float dotResult5_g472 = dot( temp_output_4_0_g472 , ( appendResult457_g468 - temp_output_1_0_g472 ) );
					float3 temp_output_39_0_g468 = ase_mainLightDirection;
					float3 temp_output_2_0_g472 = temp_output_39_0_g468;
					float dotResult8_g472 = dot( temp_output_4_0_g472 , temp_output_2_0_g472 );
					float3 temp_output_1_0_g473 = float3( 0,0,0 );
					float3 temp_output_4_0_g473 = float3( 0,1,0 );
					float dotResult5_g473 = dot( temp_output_4_0_g473 , ( appendResult457_g468 - temp_output_1_0_g473 ) );
					float3 temp_output_2_0_g473 = temp_output_38_0_g468;
					float dotResult8_g473 = dot( temp_output_4_0_g473 , temp_output_2_0_g473 );
					float3 normalizeResult459_g468 = normalize( ( ( temp_output_1_0_g472 + ( ( dotResult5_g472 / dotResult8_g472 ) * temp_output_2_0_g472 ) ) - ( temp_output_1_0_g473 + ( ( dotResult5_g473 / dotResult8_g473 ) * temp_output_2_0_g473 ) ) ) );
					float3 break461_g468 = normalizeResult459_g468;
					float3 appendResult491_g468 = (float3(break461_g468.x , break461_g468.z , 0.0));
					float3 normalizeResult440_g468 = normalize( appendResult491_g468 );
					float3 temp_output_585_0_g468 = (localFBMWithGradient16_g474).yzw;
					float dotResult434_g468 = dot( normalizeResult440_g468 , temp_output_585_0_g468 );
					float temp_output_2_0_g469 = _EdgeCutoff;
					float smoothstepResult12_g469 = smoothstep( temp_output_2_0_g469 , min( ( temp_output_2_0_g469 + _EdgeSmoothness ), 1.0 ) , temp_output_585_39_g468);
					float3 lerpResult965 = lerp( lerpResult966 , _EdgeColour.rgb , ( _EdgeColour.a * ( saturate( dotResult434_g468 ) * ( 1.0 - smoothstepResult12_g469 ) ) ));
					float dotResult521_g468 = dot( -temp_output_39_0_g468 , temp_output_38_0_g468 );
					float temp_output_520_0_g468 = ( ( dotResult521_g468 + 1.0 ) * 0.5 );
					float3 appendResult527_g468 = (float3(break461_g468.x , break461_g468.z , 1.0));
					float3 normalizeResult526_g468 = normalize( appendResult527_g468 );
					float dotResult529_g468 = dot( normalizeResult526_g468 , temp_output_585_0_g468 );
					float temp_output_1116_525 = saturate( max( saturate( pow( temp_output_520_0_g468 , ( _TransmissionExponent * 2.0 ) ) ), ( pow( temp_output_520_0_g468 , _TransmissionExponent ) * dotResult529_g468 ) ) );
					float lerpResult1024 = lerp( ( ( 1.0 - temp_output_1116_516 ) * temp_output_1116_525 ) , temp_output_1116_525 , _InteriorTransmission);
					float3 lerpResult1026 = lerp( lerpResult965 , _TransmissionColour.rgb , ( lerpResult1024 * _TransmissionColour.a ));
					float temp_output_2_0_g475 = ( 1.0 - _CloudCoverage );
					float smoothstepResult19_g474 = smoothstep( 0.0 , _CloudHorizonHeight , -temp_output_34_0_g474.y);
					float smoothstepResult12_g475 = smoothstep( temp_output_2_0_g475 , min( ( temp_output_2_0_g475 + _CloudSmoothness ), 1.0 ) , ( ( ( 1.0 - smoothstepResult19_g474 ) * _CloudHorizonStrength ) + temp_output_14_0_g474 ));
					float temp_output_2_0_g471 = ( 1.0 - _CloudFadeHeight );
					float smoothstepResult12_g471 = smoothstep( temp_output_2_0_g471 , min( ( temp_output_2_0_g471 + _CloudFadeSmoothness ), 1.0 ) , ( 1.0 - -temp_output_38_0_g468.y ));
					float3 lerpResult828 = lerp( lerpResult112_g1112 , lerpResult1026 , ( _BaseColour.a * ( saturate( smoothstepResult12_g475 ) * ( 1.0 - smoothstepResult12_g471 ) ) ));
					float smoothstepResult1048 = smoothstep( ( 1.0 - _GroundSmoothness ) , 1.0 , ( 1.0 - -ase_viewDirWS.y ));
					float3 lerpResult1038 = lerp( lerpResult828 , _GroundColour.rgb , ( _GroundColour.a * smoothstepResult1048 ));
					

					float3 Color = lerpResult1038;
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
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":828,"pos":[5696,-360],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.MainLight, AmplifyShaderEditor","id":528,"pos":[3120,-160],"params":["Inherit","False","0","5","FLOAT3","0","FLOAT3","1","FLOAT3","2","FLOAT","3","FLOAT","4"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":966,"pos":[5200,-8],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":965,"pos":[5440,336],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":970,"pos":[5176,-280],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":962,"pos":[5056,144],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":969,"pos":[5160,440],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":1024,"pos":[4424,600],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":1016,"pos":[4176,544],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":1022,"pos":[3912,568],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":1026,"pos":[5664,312],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":1028,"pos":[5440,512],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.LerpOp, AmplifyShaderEditor","id":1038,"pos":[5872,-488],"params":["Inherit","False","3","0","FLOAT3","0,0,0","False","1","FLOAT3","0,0,0","False","2","FLOAT","0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.NegateNode, AmplifyShaderEditor","id":1042,"pos":[3414.682,-454.2608],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":1047,"pos":[3664,-408],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor","id":1048,"pos":[4088,-360],"params":["Inherit","False","3","0","FLOAT","0","False","1","FLOAT","0","False","2","FLOAT","1","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor","id":1050,"pos":[3856,-304],"params":["Inherit","False","1","0","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor","id":1051,"pos":[5528,-472],"params":["Inherit","False","2","2","0","FLOAT","0","False","1","FLOAT","0","False","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":1014,"pos":[3992,696],"params":["Inherit","False","Property","_InteriorTransmission","Interior Transmission","24","0","Create","True","0","0","0","False","0","False","Object","-1","","0","0.5","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor","id":1049,"pos":[3528,-264],"params":["Inherit","False","Property","_GroundSmoothness","Ground Smoothness","35","0","Create","True","1","Ground","0","0","False","0","False","Object","-1","","0","0.1","0","1","0","1","FLOAT","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":963,"pos":[4792,-64],"params":["Inherit","False","Property","_InteriorColour","Interior Colour","1","0","Create","True","0","0","0","False","0","False","Object","-1","","0.1019608,0.09411765,0.2627451,0.4117647","0.1016985,0.09593832,0.2641475,0.4117647","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":967,"pos":[4848,288],"params":["Inherit","False","Property","_EdgeColour","Edge Colour","2","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","11.31371,0.9649343,0,1","11.31371,0.9649343,0,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":1027,"pos":[5200,624],"params":["Inherit","False","Property","_TransmissionColour","Transmission Colour","3","1","[HDR]","Create","True","0","0","0","False","0","False","Object","-1","","4.541207,0.09375719,0,1","4.541207,0.09375719,0,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":1039,"pos":[5256,-656],"params":["Inherit","False","Property","_GroundColour","Ground Colour","34","1","[Header]","Create","True","1","Ground","0","0","False","0","False","Object","-1","","0.2352941,0.3098039,0.3568628,1","0.2350475,0.309113,0.3584901,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":1089,"pos":[3624,-536],"params":["Inherit","False","Skybox Colour","25","","1112","0c3f98426aec4244b83898e14f7900cd","0","2","98","FLOAT3","0,0,0","False","68","FLOAT3","0,0,0","False","1","FLOAT3","0"]}
{"type":"AmplifyShaderEditor.ColorNode, AmplifyShaderEditor","id":964,"pos":[4736,-360],"params":["Inherit","False","Property","_BaseColour","Base Colour","0","1","[Header]","Create","True","1","Cloud Colours","0","0","False","0","False","Object","-1","","0.3882353,0.4509804,0.4901961,1","0.3882319,0.4508415,0.490196,1","True","True","0","6","COLOR","0","FLOAT","1","FLOAT","2","FLOAT","3","FLOAT","4","FLOAT3","5"]}
{"type":"AmplifyShaderEditor.VoronoiNode, AmplifyShaderEditor","id":1091,"pos":[4400,-608],"params":["Inherit","False","0","0","1","0","1","False","1","False","False","False","4","0","FLOAT2","0,0","False","1","FLOAT","0","False","2","FLOAT","1","False","3","FLOAT","0","False","3","FLOAT","0","FLOAT2","1","FLOAT2","2"]}
{"type":"AmplifyShaderEditor.ViewDirInputsCoordNode, AmplifyShaderEditor","id":529,"pos":[3152,-536],"params":["Inherit","False","World","False","0","4","FLOAT3","0","FLOAT","1","FLOAT","2","FLOAT","3"]}
{"type":"AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor","id":1116,"pos":[3608,8],"params":["Inherit","False","Skybox Clouds","4","","468","e35217d2a61917344908c1fffe4ec998","0","2","38","FLOAT3","0,0,0","False","39","FLOAT3","0,0,0","False","4","FLOAT","525","FLOAT","515","FLOAT","516","FLOAT","401"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":423,"pos":[2576,736],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ShadowCaster","0","2","ShadowCaster","0","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","False","True","1","False","","True","3","False","","False","False","True","1","LightMode=ShadowCaster","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":800,"pos":[6080,-328],"params":["Float","False","False","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","New Amplify Shader","0770190933193b94aaa3065e307002fa","True","ExtraPrePass","0","0","ExtraPrePass","6","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","0","1","False","","0","False","","False","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","0","False","0"]}
{"type":"AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor","id":422,"pos":[6272,-528],"params":["Float","False","True","-1","3","AmplifyShaderEditor.MaterialInspector","0","7","Skybox New","0770190933193b94aaa3065e307002fa","True","Unlit","0","1","Unlit","8","False","True","0","1","False","","0","False","","0","1","False","","0","False","","True","0","False","","0","False","","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","False","False","False","True","1","RenderType=Opaque=RenderType","True","3","True","14","all","0","False","True","1","1","False","","0","False","","1","1","False","","0","False","","True","1","False","","1","False","","False","False","False","False","False","False","False","False","False","False","False","True","0","False","","False","True","True","True","True","True","0","False","","False","False","False","False","False","False","False","True","False","0","False","","255","False","","255","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","0","False","","False","True","1","False","","True","3","False","","True","True","0","False","","0","False","","False","True","1","LightMode=ForwardBase","False","False","0","","0","0","Standard","10","Surface","0","0","  Keep Alpha","0","0","  Blend","0","0","Alpha Clipping","0","0","  Use Shadow Threshold","0","0","Cast Shadows","1","0","Write Depth","0","0","  Conservative","0","0","Extra Pre Pass","0","0","Vertex Position","1","0","0","3","False","True","True","False","","False","0"]}
{"wire":[828,0,1089,0]}
{"wire":[828,1,1026,0]}
{"wire":[828,2,970,0]}
{"wire":[966,0,964,5]}
{"wire":[966,1,963,5]}
{"wire":[966,2,962,0]}
{"wire":[965,0,966,0]}
{"wire":[965,1,967,5]}
{"wire":[965,2,969,0]}
{"wire":[970,0,964,4]}
{"wire":[970,1,1116,401]}
{"wire":[962,0,963,4]}
{"wire":[962,1,1116,516]}
{"wire":[969,0,967,4]}
{"wire":[969,1,1116,515]}
{"wire":[1024,0,1016,0]}
{"wire":[1024,1,1116,525]}
{"wire":[1024,2,1014,0]}
{"wire":[1016,0,1022,0]}
{"wire":[1016,1,1116,525]}
{"wire":[1022,0,1116,516]}
{"wire":[1026,0,965,0]}
{"wire":[1026,1,1027,5]}
{"wire":[1026,2,1028,0]}
{"wire":[1028,0,1024,0]}
{"wire":[1028,1,1027,4]}
{"wire":[1038,0,828,0]}
{"wire":[1038,1,1039,5]}
{"wire":[1038,2,1051,0]}
{"wire":[1042,0,529,2]}
{"wire":[1047,0,1042,0]}
{"wire":[1048,0,1047,0]}
{"wire":[1048,1,1050,0]}
{"wire":[1050,0,1049,0]}
{"wire":[1051,0,1039,4]}
{"wire":[1051,1,1048,0]}
{"wire":[1089,98,529,0]}
{"wire":[1089,68,528,0]}
{"wire":[1116,38,529,0]}
{"wire":[1116,39,528,0]}
{"wire":[422,0,1038,0]}
ASEEND*/
//CHKSM=375041C7423E82119C4CB4F854C4FA97A35F4F66