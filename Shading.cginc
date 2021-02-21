// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    float3 h = normalize((l + v) / 2);
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 specular = pow(max(0, dot(n, h)), shininess) * 0.4;
    return diffuse + specular;
}

// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    ray.direction = 2.0  * dot(-ray.direction, hit.normal)* hit.normal + ray.direction;
    ray.origin = hit.position + hit.normal * EPS;
    ray.energy = ray.energy * hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float t_1 = 1.0f;
    float t_2 = hit.material.refractiveIndex;
    float3 normal = hit.normal;

    if(dot(normal, ray.direction) > 0){
        float t_3;
        t_3 = t_1;
        t_1 = t_2;
        t_2 = t_3;
        normal *= -1;
    }
    float t = t_1 / t_2;
    float c1 = abs(dot(normal, ray.direction));
    float c2 = sqrt(1.0f - pow(t, 2) * (1.0f - pow(c1, 2)));
    
    ray.direction = t * ray.direction + (t * c1 - c2) * normal;
    ray.origin = hit.position - normal * EPS;
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}