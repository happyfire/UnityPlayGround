//物体被遮挡部分显示轮廓
//原理：
//1. 使用一个pass渲染轮廓
//2. ZTest设置为Greater，从而只渲染被遮挡部分
//3. 被遮挡部分使用边缘光方式渲染轮廓，可以调节颜色，边缘光范围和强度

Shader "happyfire/Occlusions/OcclusionOutline"
{
    Properties
    {
        _OutlineColor("Outline Color", Color) = (0, 1, 1, 1)
        _OutlineWidth("Outline Width", Range(0, 10)) = 1
        _OutlineIntensity("Outline Intensity", Range(0, 10)) = 1

        _MainTex("Main Tex", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue"="Geometry+100" "RenderType"="Opaque" }

        //渲染被遮挡部分
        Pass
        {
            Tags { "LightMode"="ForwardBase"}
            ZTest Greater
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 worldPos : SV_POSITION;
                float3 viewDir : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            fixed4 _OutlineColor;
            fixed _OutlineWidth;
            half _OutlineIntensity;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.worldPos = UnityObjectToClipPos(v.vertex);
                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                half rim = 1 - saturate( dot(i.worldNormal, i.viewDir) );
                fixed4 color;
                color.rgb = _OutlineColor.rgb;
                color.a = pow(rim, _OutlineWidth) * _OutlineIntensity;       
                return color;
            }

            ENDCG
        }

        //渲染原物体

        Pass {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag         
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
                       
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);                         
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                return tex2D(_MainTex, i.uv);
            }

            ENDCG
        }
        


    }

    Fallback "Diffuse"
}
