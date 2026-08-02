    /*
	// Wrap to periods, if desired
    if (any(greaterThan(period, float2(0.0, 0.0))))
    {
        xw = float3(v0.x, v1.x, v2.x);
        yw = float3(v0.y, v1.y, v2.y);
        if (period.x > 0.0)
            xw = mod(float3(v0.x, v1.x, v2.x), period.x);
        if (period.y > 0.0)
            yw = mod(float3(v0.y, v1.y, v2.y), period.y);
		// Transform back to simplex space and fix rounding errors
        iu = floor(xw + 0.5 * yw + 0.5);
        iv = floor(yw + 0.5);
    }
    else
    { // Shortcut if neither x nor y periods are specified
        iu = float3(i0.x, i1.x, i2.x);
        iv = float3(i0.y, i1.y, i2.y);
    }
*/



#define mod(x, y) (x - y * floor(x / y))



float psrdnoise(float2 x, float2 period, float alpha, out float2 gradient)
{

	// Transform to simplex space (axis-aligned hexagonal grid)
    float2 uv = float2(x.x + x.y * 0.5, x.y);

	// Determine which simplex we're in, with i0 being the "base"
    float2 i0 = floor(uv);
    float2 f0 = frac(uv);
	// o1 is the offset in simplex space to the second corner
    float cmp = step(f0.y, f0.x);
    float2 o1 = float2(cmp, 1.0 - cmp);

	// Enumerate the remaining simplex corners
    float2 i1 = i0 + o1;
    float2 i2 = i0 + float2(1.0, 1.0);

	// Transform corners back to texture space
    float2 v0 = float2(i0.x - i0.y * 0.5, i0.y);
    float2 v1 = float2(v0.x + o1.x - o1.y * 0.5, v0.y + o1.y);
    float2 v2 = float2(v0.x + 0.5, v0.y + 1.0);

	// Compute vectors from v to each of the simplex corners
    float2 x0 = x - v0;
    float2 x1 = x - v1;
    float2 x2 = x - v2;

    float3 iu, iv;
    float3 xw, yw;

    xw = float3(v0.x, v1.x, v2.x);
    yw = float3(v0.y, v1.y, v2.y);
    if (period.x > 0.0)
        xw = mod(float3(v0.x, v1.x, v2.x), period.x);
    if (period.y > 0.0)
        yw = mod(float3(v0.y, v1.y, v2.y), period.y);
		// Transform back to simplex space and fix rounding errors
    iu = floor(xw + 0.5 * yw + 0.5);
    iv = floor(yw + 0.5);
    

  //  iu = float3(i0.x, i1.x, i2.x);
  //  iv = float3(i0.y, i1.y, i2.y);
    
    
	// Compute one pseudo-random hash value for each corner
    float3 hash = mod(iu, 289.0);
    hash = mod((hash * 51.0 + 2.0) * hash + iv, 289.0);
    hash = mod((hash * 34.0 + 10.0) * hash, 289.0);

	// Pick a pseudo-random angle and add the desired rotation
    float3 psi = hash * 0.07482 + alpha;
    float cospsi = cos(psi);
    float sinpsi = sin(psi);
    float3 gx = float3(cospsi, cospsi, cospsi);
    float3 gy = float3(sinpsi, sinpsi, sinpsi);

	// Reorganize for dot products below
    float2 g0 = float2(gx.x, gy.x);
    float2 g1 = float2(gx.y, gy.y);
    float2 g2 = float2(gx.z, gy.z);

	// Radial decay with distance from each simplex corner
    float3 w = 0.8 - float3(dot(x0, x0), dot(x1, x1), dot(x2, x2));
    w = max(w, 0.0);
    float3 w2 = w * w;
    float3 w4 = w2 * w2;

	// The value of the linear ramp from each of the corners
    float3 gdotx = float3(dot(g0, x0), dot(g1, x1), dot(g2, x2));

	// Multiply by the radial decay and sum up the noise value
    float n = dot(w4, gdotx);

	// Compute the first order partial derivatives
    float3 w3 = w2 * w;
    float3 dw = -8.0 * w3 * gdotx;
    float2 dn0 = w4.x * g0 + dw.x * x0;
    float2 dn1 = w4.y * g1 + dw.y * x1;
    float2 dn2 = w4.z * g2 + dw.z * x2;
    gradient = 10.9 * (dn0 + dn1 + dn2);

	// Scale the return value to fit nicely into the range [-1,1]
    return 10.9 * n;
}



float billow(in float2 uv, in float alpha, in float scale, in float warp)
{
 
    const float2 p = float2(128.0, 128.0);
    
    float2 v = scale * (uv - 0.5);

    
    float2 g = 0.0;
    float n = 0.0;
    float w = 1.0;
    float s = 1.0;
    float2 gsum = float2(0.0, 0.0);
    
    for (float i = 0.0; i < 5.0; i++)
    {
        n += w * psrdnoise(s * v + warp * gsum, s * p, s * alpha, g);
        gsum += w * g;
        w *= 0.5;
        s *= 2.0;
    }
    
    return n;
}



