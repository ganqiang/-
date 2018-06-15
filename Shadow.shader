// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "myshader/Shadow"
{
	Properties
	{
		_Diffuse("Diffuse", COLOR) = (1, 1, 1, 1)
		_HighLight("HighLight", COLOR) = (1, 1, 1, 1)//控制高光反射颜色
		_Gloss("Gloss", Range(8, 256)) = 20//控制高光区域大小
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
			#include "AutoLight.cginc"
			#pragma multi_compile_fwdbase

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
				SHADOW_COORDS(2)//声明一个用于对阴影纹理采样的坐标
			};

			v2f vert(a2v v)
			{
				v2f o;
				//从物体空间到投影空间的顶点变换
				o.pos = UnityObjectToClipPos(v.vertex);
				//从模型空间下的法线变换到世界空间下，并做归一化
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//从模型空间变换顶点坐标到世界空间
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				TRANSFER_SHADOW(o);//计算上一步中声明的阴影纹理坐标
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				fixed shadow = SHADOW_ATTENUATION(i);//计算阴影值
				//获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//获得世界空间法线
				float3 worldNormal = normalize(i.worldNormal);
				//获得世界空间下的光的方向
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//得到世界空间下的反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//得到世界空间中获得观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//半角向量
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				//计算高光反射
				fixed3 hightLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				fixed atten = 1;//光的衰减
				return fixed4(ambient + (diffuse + hightLight) * shadow * atten, 1);
			}

			ENDCG
		}
		pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#pragma multi_compile_fwdadd

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
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				//从模型空间变换顶点坐标到世界空间
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				//获得世界空间法线
				float3 worldNormal = normalize(i.worldNormal);
				//获得世界空间下的光的方向
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//得到世界空间下的反射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
				//得到世界空间中获得观察方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				//半角向量
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				//计算高光反射
				fixed3 hightLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				fixed atten = 1;//光的衰减
				return fixed4((diffuse + hightLight) * atten, 1);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}