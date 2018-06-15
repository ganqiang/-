// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/逐顶点漫反射"
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

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//获取环境光
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);//获去光方向
				float3 normalDir = normalize(v.normal);//获去法线方向
				float3 diffuse = _LightColor0.rgb * max(0,mul(lightDir,normalDir));//计算漫反射
				o.color = diffuse + ambient;//总的光
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				return fixed4(i.color, 1);
			}

			ENDCG
		}
	}
}