Shader "myshader/A"
{
	Properties
	{
		_Color1 ("Main Color 1", Color) = (1, 1, 1, 1)
		_Color2 ("Main Color 2", Color) = (0, 0, 0, 0)
		_Center ("Main Center", Range(0.5, -0.5)) = 0
		_R ("Main R", Range(0.5, -0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _Color1;
			float4 _Color2;
			float  _Center;
			float _R;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
			};
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = v.vertex;
				return o;
			}
			fixed4 frag (v2f i) : SV_Target
			{
				float y = i.worldPos.y;
				float d = y - _Center;
 
				float s = abs(d);
				d = d / s;
 
				float f = s / _R;
				f = saturate(f);
				d *= f;
 
				d = d / 2 + 0.5;
 
				return lerp(_Color1,_Color2,d);
			}

			ENDCG
		}
	}
}
