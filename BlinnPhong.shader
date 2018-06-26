// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "myshader/BlinnPhong"
{
	Properties
	{
		_Diffuse("Diffuse", COLOR) = (1, 1, 1, 1)
		_HighLight("HighLight", COLOR) = (1, 1, 1, 1)
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
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
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
				float4 worldPos : TEXCOORD0;
				float3 worldNormla : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormla = mul(v.normal, unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_SHADOW(o);
				return o;
			}
			fixed4 frag(v2f i):SV_TARGET
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 normalDir = normalize(i.worldNormla);
				fixed3 diffuse = _LightColor0.xyz * _Diffuse.xyz * max(0, dot(normalDir, lightDir));

				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float3 halfDir = normalize(lightDir + viewDir);
				fixed3 highLight = _LightColor0.xyz * _HighLight.xyz * pow(max(0, dot(normalDir, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 color = ambient + diffuse + highLight;
				return fixed4(color * atten, 1);
			}

			ENDCG
		}
	}
}