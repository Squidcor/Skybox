float2 hash(in float2 uv)
{
    uv = float2(dot(uv, float2(127.1, 311.7)), dot(uv, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(uv) * 43758.5453123);
}

 
float3 noised(in float2 uv)
{

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



float4 fbmd(in float2 uv, in float gain, in float lacunarity, in int octaves, in float2 distortionDirection, in float distortionAmount, in float distortionExponent)
{

    float value = 0.0;
    float amplitude = 1.0;
    float totalAmplitude = 0;
    float2 gradient = float2(0.0, 0.0);


    for (int i = 0; i < octaves; i++)
    {
        float distortion = pow((float) i / octaves, distortionExponent) * distortionAmount;
        float2 offset = distortionDirection * distortion;
        
        distortionDirection *= -1;

        float3 n = noised(uv + offset);
        
        value += amplitude * n.x; // accumulate values
        gradient += n.yz * amplitude; // accumulate derivatives
               
        totalAmplitude += amplitude;
        amplitude *= gain;

        uv *= lacunarity;
        
    }
    
    value = 0.5 + (value / totalAmplitude);
    gradient = -gradient / totalAmplitude;
    
    float3 normal = normalize(float3(gradient.x, gradient.y, 1.0));
    
    return float4(value, normal);
    
}
