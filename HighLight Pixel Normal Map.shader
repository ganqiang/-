// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/NormalMapWorldSpace"
{
	Properties
	{
		_Color("Color", COLOR) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}//纹理图片
		_BumpMap("Normal Map", 2D) = "bump"{}//法线贴图
		_BumpScale("Bump Scale", float) = 1//凹凸程度 ---- 当为0时，将不受光照影响，正数凹，负数凸
		_HighLight("HighLight", COLOR) = (1,1,1,1)//高光颜色
		_Gloss("Gloss", Range(8, 256)) = 20
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

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _HighLight;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;//纹理坐标
				//下面三个是一个矩阵，分别代表矩阵的每一行
				float4 TangentToWorld0 : TEXCOORD1;
				float4 TangentToWorld1 : TEXCOORD2;
				float4 TangentToWorld2 : TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);//世界空间下法线
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);//世界空间下切线
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;//世界空间下副切线
				//从切线空间计算变换矩阵到世界空间
				o.TangentToWorld0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TangentToWorld1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TangentToWorld2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				//在世界空间下获取位置
				float3 worldPos = float3(i.TangentToWorld0.w, i.TangentToWorld1.w, i.TangentToWorld2.w);
				//计算在世界空间下的光的方向和视野方向
				float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				//在切线空间获取法线
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy = bump.xy * _BumpScale;
				bump.z = sqrt(1 - max(0, dot(bump.xy, bump.xy)));
				//从切线空间变换法线到世界空间
				bump = normalize(half3(dot(i.TangentToWorld0.xyz, bump), dot(i.TangentToWorld1.xyz, bump), dot(i.TangentToWorld2.xyz, bump)));
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;//反照率
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				fixed3 halfDir = normalize(bump + lightDir);
				//float3 reflectDir = normalize(reflect(-tangentLightDir, tangentNormal));
				//fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(reflectDir, tangentNormal)), _Gloss);//计算高光反射
				fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(halfDir, bump)), _Gloss);//计算高光反射
				return fixed4(ambient + diffuse + highLight, 1);
			}

			ENDCG
		}
	}
}