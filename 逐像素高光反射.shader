// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/逐像素高光反射"
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,unity_WorldToObject);//得到世界空间下的法线
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;//从模型空间变换顶点到世界空间
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;//获取环境光
				float3 worldNormalDir = normalize(i.worldNormal);//获取世界空间下的法线方向
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);//获取世界空间下光的方向
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormalDir, worldLightDir));//计算漫反射
				float3 reflectDir = normalize(reflect(-worldLightDir, worldNormalDir));//计算反射光方向
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);//计算视野方向
				fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0,dot(reflectDir, viewDir)),_Gloss);//计算高光反射 = 直射光颜色 * max(0, dot(反射光方向， 视野方向));
				return fixed4(ambient + diffuse + highLight, 1);
			}

			ENDCG
		}
	}
}