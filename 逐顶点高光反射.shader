// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/逐顶点高光反射"
{
	Properties
	{
		_Diffuse("Diffuse",COLOR) = (1,1,1,1)
		_HighLight("HighLight",COLOR) = (1,1,1,1)
		_Gloss("Gloss",Range(8,256)) = 20
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
			fixed4 _HighLight;
			float _Gloss;

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
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//获取环境光
				fixed3 worldNormal = normalize(mul(v.normal,unity_ObjectToWorld));//获得世界空间法线
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);//获得世界空间光的方向
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(worldNormal,worldLightDir));//计算漫反射
				fixed3 reflectDir = normalize(reflect(-worldLightDir,-worldNormal));//获取反射光线方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_WorldToObject, v.vertex).xyz);//获取视野方向
				fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(reflectDir, viewDir)),_Gloss);//计算高光反射
				o.color = ambient + diffuse + highLight;
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				return fixed4(i.color,1);
			}

			ENDCG
		}
	}
}