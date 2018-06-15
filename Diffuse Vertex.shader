// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/Diffuse Vertex"
{
	Properties
	{
		_Diffuse("Diffuse", COLOR) = (1, 1, 1, 1)
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
				//从物体空间到投影空间的顶点变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//获得环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//从模型空间下的法线变换到世界空间下，并做归一化
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//获得世界空间下的光的方向
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * dot(worldLight,worldNormal) * 0.5 + 0.5;
				//总的光
				o.color = ambient + diffuse;
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