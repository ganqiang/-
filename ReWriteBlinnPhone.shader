Shader "myshader/ReWriteBlinnPhone"
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
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				//从物体空间到投影空间的顶点变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//从模型空间下的法线变换到世界空间下，并做归一化
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//从模型空间变换顶点坐标到世界空间
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				//获得世界空间法线
				float3 worldNormal = normalize(i.worldNormal);
				//获得世界空间下的光的方向
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				//得到世界空间下的反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				//得到世界空间中获得观察方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed3 halfDir = normalize(worldLightDir + viewDir); 

				//计算高光反射
				fixed3 hightLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(worldNormal,halfDir)),_Gloss);
				return fixed4(ambient + diffuse + hightLight,1);
			}

			ENDCG
		}
	}
}