// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/逐像素漫反射"
{
	Properties
	{
		_Diffuse("Diffuse",COLOR) = (1,1,1,1)
	}
	SubShader
	{
		pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			float4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,unity_WorldToObject);
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//获取环境光
				fixed3 lightDir = normalize(_LightColor0.rgb);//获取光的方向
				fixed3 worldNormalDir = normalize(i.worldNormal);//获取世界空间下的法线方向
				fixed3 diffuse = _LightColor0.rgb * max(0,dot(lightDir,worldNormalDir));
				return fixed4(diffuse + ambient,1);
			}

			ENDCG
		}
	}
}