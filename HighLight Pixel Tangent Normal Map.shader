// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/HighLight Pixel Tangent Normal Map"
{
	Properties
	{
		_Color("Color", COLOR) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}//纹理图片
		_BumpMap("Normal Map", 2D) = "bump"{}//法线贴图
		_BumpScale("Bump Scale", float) = 1//凹凸程度 ---- 当为0时，将不受光照影响
		_HighLight("HighLight", COLOR) = (1,1,1,1)
		_Gloss("Gloss", Range(0, 20)) = 20
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
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;//光方向
				float3 viewDir : TEXCOORD2;//视野方向
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				TANGENT_SPACE_ROTATION;//使用Unity内置宏函数 ---- 调用这个后会得到一个矩阵rotation，用来把模型空间下的方向转换到切线空间下
				//光方向从物体空间到切线空间的转换
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				//视野方向从物体空间到切线空间的转换
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				//在法线贴图中获取纹理
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);//填充法线
				fixed3 tangentNormal = UnpackNormal(packedNormal);//得到正确的法线方向
				tangentNormal.xy = tangentNormal.xy * _BumpScale;//控制凹凸度
				tangentNormal.z = sqrt(1 - max(0, dot(tangentNormal.xy, tangentNormal.xy)));
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);//半角向量 --- 入射光线与视野光线的平均值
				//float3 reflectDir = normalize(reflect(-tangentLightDir, tangentNormal));     //((_Gloss + 2) / 8)
				//fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(reflectDir, tangentNormal)), _Gloss);//计算高光反射
				//fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);//计算高光反射
				//return fixed4(ambient + diffuse, 1);

				//fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * ((_Gloss + 2) / 8) * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);//计算高光反射

				//fixed3 highLight = _LightColor0.rgb * _HighLight.rgb * ((_Gloss + 2) / 8) * max(0, pow(dot(tangentNormal, halfDir), _Gloss));//计算高光反射

				//fixed3 highLight = cross(((_Gloss + 2) / 8) * pow(normalize(dot(tangentNormal, halfDir)), _Gloss) * (_HighLight.rgb + (1 - _HighLight.rgb) * pow((1 - dot(tangentLightDir, halfDir)), 5)), _LightColor0.rgb * dot(tangentNormal, tangentLightDir));
				fixed3 highLight = ((_Gloss + 2) / 8) * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * (_HighLight.rgb + (1 - _HighLight.rgb) * pow((1 - dot(tangentLightDir, halfDir)), 5)) * _LightColor0.rgb * max(0, dot(tangentNormal, tangentLightDir));

				return fixed4(ambient + diffuse + highLight, 1);
			}

			ENDCG
		}
	}
}