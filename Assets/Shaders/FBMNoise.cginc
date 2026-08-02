float hash21(in float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
}

float2 hash22(in float2 uv)
{
    uv = float2(dot(uv, float2(127.1, 311.7)), dot(uv, float2(269.5, 183.3)));
 
    return -1.0 + 2.0 * frac(sin(uv) * 43758.5453123);
}


 
float3 gradient_noised(in float2 uv)
{
#define hash hash22
    
    float2 i = floor(uv);
    float2 f = frac(uv);

    float2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    float2 du = 30.0 * f * f * (f * (f - 2.0) + 1.0);
    
    float2 ga = hash(i + float2(0.0, 0.0));
    float2 gb = hash(i + float2(1.0, 0.0));
    float2 gc = hash(i + float2(0.0, 1.0));
    float2 gd = hash(i + float2(1.0, 1.0));
    
    float va = dot(ga, f - float2(0.0, 0.0));
    float vb = dot(gb, f - float2(1.0, 0.0));
    float vc = dot(gc, f - float2(0.0, 1.0));
    float vd = dot(gd, f - float2(1.0, 1.0));

    return float3(va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd), // value
                 ga + u.x * (gb - ga) + u.y * (gc - ga) + u.x * u.y * (ga - gb - gc + gd) + // derivatives
                 du * (u.yx * (va - vb - vc + vd) + float2(vb, vc) - va));
}

float gradient_noise(in float2 uv)
{
#define hash hash22
    
    float2 i = floor(uv);
    float2 f = frac(uv);
	
    float2 u = f * f * f * (6.0 * f * f - 15.0 * f + 10.0);

    float a = dot(hash(i + float2(0.0, 0.0)), f - float2(0.0, 0.0));
    float b = dot(hash(i + float2(1.0, 0.0)), f - float2(1.0, 0.0));
    float c = dot(hash(i + float2(0.0, 1.0)), f - float2(0.0, 1.0));
    float d = dot(hash(i + float2(1.0, 1.0)), f - float2(1.0, 1.0));
    
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}


float value_noise(in float2 uv)
{
#define hash hash21
    
    float2 i = floor(uv);
    float2 f = frac(uv);

    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));

    float2 u = f * f * (3.0 - 2.0 * f);

    return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;

}


float fbm(in float2 uv, in float gain, in int octaves)
{
#define noise gradient_noise
  
    float value = 0.0;
    float amplitude = 1.0;
    float totalAmplitude = 0;
    
   //float G = exp2(-H);

    for (int i = 0; i < octaves; i++)
    {
        value += amplitude * noise(uv);
        uv *= 2.0;
        totalAmplitude += amplitude;
        amplitude *= gain;

    }
    
    return 0.5 + (value / totalAmplitude);
    
   // return 0.5 + 0.5 * (value / totalAmplitude);
}

float4 fbmd(in float2 uv, in float gain, in float lacunarity, in int octaves, in float gradientStrength)
{
#define noised gradient_noised
  
    const float2x2 m = float2x2(0.8, -0.6, 0.6, 0.8);
    
    float value = 0.0;
    float amplitude = 1.0;
    float totalAmplitude = 0;
    float2 gradient = float2(0.0, 0.0);
    
   // float2 d = float2(0.0, 0.0);
    
   //float G = exp2(-H);

    for (int i = 0; i < octaves; i++)
    {
        float3 n = noised(uv);
        
        
        value += amplitude * n.x; // accumulate values
       // d += amplitude * m * n.yz; // accumulate derivatives
        
        gradient += n.yz * amplitude; // * frequency;
        
       
        totalAmplitude += amplitude;
        amplitude *= gain;

        uv *= lacunarity;
        
     //   uv = lacunarity * m3 * uv;
      //  m = lacunarity * m3i * m;
    }
    
    value = 0.5 + (value / totalAmplitude);
 //   gradient = 0.5 + (gradient / totalAmplitude);
    gradient = (gradient / totalAmplitude) * -gradientStrength;
    
    float3 normal = normalize(float3(gradient.x, gradient.y, 1.0));
    
    //float3 normal = normalize(float3(-gradient.x, -gradient.y, 1.0 - gradientStrength)) * 0.5 + 0.5;
    
    return float4(value, normal);
    
   // return 0.5 + 0.5 * (value / totalAmplitude);
}


/*

    float f = 1.98;  // could be 2.0
    float s = 0.49;  // could be 0.5
    float value = 0.0;
    float b = 0.5;
    vec3  d = vec3(0.0,0.0,0.0);
    mat3  m = mat3(1.0,0.0,0.0,
                   0.0,1.0,0.0,
                   0.0,0.0,1.0);
    for( int i=0; i<octaves; i++ )
    {
        vec4 n = noised(uv);
        value += amplitude*n.x;          // accumulate values
        d += amplitude*m*n.yzw;      // accumulate derivatives
        amplitude *= gain;
        uv = lacunarity*m3*uv;
        m = lacunarity*m3i*m;
    }
    return vec4( a, d );

float terrain( in vec2 p )
{
    float a = 0.0;
    float b = 1.0;
    vec2  d = vec2(0.0,0.0);
    for( int i=0; i<15; i++ )
    {
        vec3 n=noised(p);
        d += n.yz;
        a += b*n.x/(1.0+dot(d,d));
        b *= 0.5;
        p = m*p*2.0;
    }
    return a;
}*/

float3 fbmGradient(in float2 uv, in float gain, in int octaves, float uvOffset, float gradientStrength)
{
    
    float a = fbm(uv + float2(uvOffset, 0), gain, octaves);
    float b = fbm(uv + float2(-uvOffset, 0), gain, octaves);
    float c = fbm(uv + float2(0, uvOffset), gain, octaves);
    float d = fbm(uv + float2(0, -uvOffset), gain, octaves);
  
    float dhdx = (a - b) * 0.5;
    float dhdy = (c - d) * 0.5;

    return normalize(float3(-dhdx, -dhdy, 1.0 - gradientStrength)) * 0.5 + 0.5;
    
}
