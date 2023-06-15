uniform float time;

varying vec2 vUv;

#define PI 3.14159265359
#define TWO_PI 6.28318530718

// 2D Random
    float random (in vec2 st) {
        return fract(sin(dot(st.xy,
                            vec2(12.9898,78.233)))
                    * 43758.5453123);
    }

    vec2 random2( vec2 p ) {
        return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
    }

    // 2D Noise based on Morgan McGuire @morgan3d
    // https://www.shadertoy.com/view/4dS3Wd
    float noise (in vec2 st) {
        vec2 i = floor(st);
        vec2 f = fract(st);

        // Four corners in 2D of a tile
        float a = random(i);
        float b = random(i + vec2(1.0, 0.0));
        float c = random(i + vec2(0.0, 1.0));
        float d = random(i + vec2(1.0, 1.0));

        // Smooth Interpolation

        // Cubic Hermine Curve.  Same as SmoothStep()
        vec2 u = f*f*(3.0-2.0*f);
        // u = smoothstep(0.,1.,f);

        // Mix 4 coorners percentages
        return mix(a, b, u.x) +
                (c - a)* u.y * (1.0 - u.x) +
                (d - b) * u.x * u.y;
    }

    vec3 voronoi(vec2 x)
    {
        vec2 n=floor(x);
        vec2 f=fract(x);
        
        vec2 mg,mr;
        float md=1.5;
        
        for(int i=-1;i<=1;i++){
            for(int j=-1;j<=1;j++){
                vec2 g=vec2(float(j),float(i));
                vec2 o=random2(n+g);
                o=.5+.5*sin((time * 0.5)+TWO_PI*o);
                
                vec2 r=g+o-f;
                float d=dot(r,r);
                
                if(d<md){
                    md=d;
                    mr=r;
                    mg=g;
                }
                
            }
        }
        md=1.;
        for(int i=-1;i<=1;i++){
            for(int j=-1;j<=1;j++){
                vec2 g=vec2(float(j),float(i));
                vec2 o=random2(n+g);
                o=.5+.5*sin((time * 0.5)+TWO_PI*o);
                
                vec2 r=g+o-f;
                if(dot(mr-r,mr-r)>.005){
                    md=min(md,dot(.5*(mr+r),normalize(r-mr)));
                    
                }
                
            }
        }
        return vec3(md, mr);
    }

    float sdSegment(vec2 p, vec2 a, vec2 b)
        {
            vec2 pa = p-a;
            vec2 ba = b-a;
            float h = clamp(dot(pa, ba)/dot(ba,ba), 0., 1.);
            float v = length(pa - ba * h);
            return 1. - smoothstep(0.01, 0.015, v);
        }

float plot(vec2 vUv,float p){
    return smoothstep(p + 0.5,p,vUv.y)-
    smoothstep(p,p-(0.5),vUv.y);
}

vec2 Rot(vec2 vUv,float a){
    //vUv*=2.;
    vUv-=.5;
    vUv=mat2(cos(a),-sin(a),
    sin(a),cos(a))*vUv;
    vUv+=.5;
    return vUv;
}

float Box(vec2 vUv, vec2 size){
    vec2 b = smoothstep(size, size + vec2(0.01), vUv);
    b *= smoothstep(size, size + vec2(0.01), 1. - vUv);
    float b1 = b.x * b.y;
    return b1;
}

void main()
{
    vec2 p = vUv;
    p = Rot(p, PI);
    p-= 0.5;
    vec3 c = vec3(0.);

    float seg;
    vec2 uv2 = p;

    uv2 *= 25.;

    vec2 iUv = floor(uv2);
    vec2 fUv = fract(uv2);

    float m_dist = 50.;
    float shape;

    vec3 s = voronoi(uv2);
    vec3 s2 = voronoi(vec2(uv2.x  + sin(time)/4., uv2.y  + cos(time)/4.));
    float dd = length(s.yz) + 0.;
    seg = sdSegment(fUv, vec2(s2.yz), vec2(s.yz));
    c+=mix(vec3(1.), c, smoothstep(0.01, 0.021, s.x));
    c+= mix(vec3(1.), c,smoothstep(0.01, 0.021, s2.x));
    // c += 1. - smoothstep(0.01, 0.02, s.x);
    
    // c += seg;

    gl_FragColor = vec4(c , 1.);
}
