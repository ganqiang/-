// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/HighLight Vertex"
{
	Properties
	{
		_Diffuse("Diffuse",COLOR) = (1, 1, 1, 1)
		_HighLight("HighLight",COLOR) = (1, 1, 1, 1)//控制高光反射颜色
		_Gloss("Gloss",Range(8,256)) = 20//控制高光区域大小
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
				//从物体空间到投影空间的顶点变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				//从模型空间下的法线变换到世界空间下，并做归一化
				float3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//获得世界空间下的光的方向
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				//得到世界空间下的反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				//得到世界空间中获得观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);
				//计算高光反射
				fixed3 hightLight = _LightColor0.rgb * _HighLight.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);
				o.color = ambient + diffuse + hightLight;
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