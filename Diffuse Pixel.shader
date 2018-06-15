// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "myshader/Diffuse Pixel"
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
				fixed3 worldNormal : TEXCOORD0;
			};
			v2f vert(a2v v)
			{
				v2f o;
				//从物体空间到投影空间的顶点变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//从模型空间下的法线变换到世界空间下，并做归一化
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				//获取世界空间法线
				fixed3 worldNormal = normalize(i.worldNormal);
				//获取世界空间下的光的方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				//fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				fixed3 halfLBT = dot(worldLightDir,worldNormal) * 0.5 + 0.5;//半兰伯特光照模型    dot(worldLightDir,worldNormal)：光和法线的夹角：cosθ
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLBT;
				fixed3 color = ambient + diffuse;
				return fixed4(color,1);
			}

			ENDCG
		}
	}
}