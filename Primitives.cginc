// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float b = 2 * dot((ray.origin - sphere.xyz), ray.direction);
    float c = dot((ray.origin - sphere.xyz), (ray.origin - sphere.xyz)) - sphere.w*sphere.w;
    float disc = b * b - 4 * c;
    float t = 1.#INF;
    if (disc == 0) {
        t = -b / 2;
    }
    else if (disc > 0) {
        float t_0 = (-b + sqrt(disc)) / 2;
        float t_1 = (-b - sqrt(disc)) / 2;
        t = t_1;
        if(t_1 < 0)
        {
            t = t_0;
        }
    }
    if (t < bestHit.distance && t > 0) {
        bestHit.position = ray.origin + (ray.direction * t);
        bestHit.distance = t;
        bestHit.normal = normalize(bestHit.position - sphere.xyz);
        bestHit.material = material;
    }
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
    float t = 1.#INF;
    if (dot(ray.direction, n) != 0) {
        t = - dot((ray.origin - c), n) / dot(ray.direction, n);    
    }
    if (t < bestHit.distance && t > 0 ) {
        bestHit.position = ray.origin + (ray.direction * t);
        bestHit.distance = t;
        bestHit.normal = n;
        bestHit.material = material;
    }    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    RayHit hit = CreateRayHit();
    intersectPlane(ray, hit, m1, c, n);
    if(hit.distance < bestHit.distance && !isinf(hit.distance))
    {
        float t1, t2;
        if (n.x) {
            t1 = hit.position.y;
            t2 = hit.position.z;
        } else if (n.y != 0) { 
            t1 = hit.position.x;
            t2 = hit.position.z;
        } else {
            t1 = hit.position.x;
            t2 = hit.position.y;
        }
        float f1 = floor(t1);
        float f2 = floor(t2);
        float x = (t2 - 0.5f - f2) * (t1 - 0.5f - f1);
        if(x <= 0)
        {
            bestHit.material = m2;
        } 
        else 
        {
            bestHit.material = m1;
        }
        bestHit.distance = hit.distance;
        bestHit.normal = hit.normal;
        bestHit.position = hit.position;
    }
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    float3 n = normalize(cross((a - c), (b - c)));
    RayHit ray_hit = CreateRayHit();
    intersectPlane(ray, ray_hit, material, a, n);
    float3 p = ray_hit.position;
    float a_b = dot(cross(b - a, p - a), n);
    float b_c = dot(cross(c - b, p - b), n);
    float c_a = dot(cross(a - c, p - c), n);

    if (a_b >= 0 && b_c >= 0 && c_a >= 0){
        bestHit = ray_hit;
    }
}