using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class CreateBounds
{
    /// <summary>
    /// 创建包围球
    /// </summary>
    /// <param name="whereDoYouWantToCreateIt">想把生成的包围球放在哪个游戏物体下</param>
    /// <param name="vertexs">顶点</param>
    /// <param name="vertex_Count">顶点个数</param>
    public static void CreateSphereBounds(GameObject whereDoYouWantToCreateIt, List<Vector3> vertexs, int vertex_Count)
    {
        if(whereDoYouWantToCreateIt == null)
        {
            Debug.LogError("生成包围球的游戏物体不存在，请检查传入的游戏物体是否为空！");
            return;
        }
        SphereCollider sp;
        Vector3 total = new Vector3(0, 0, 0);
        Vector3 center = new Vector3(0, 0, 0);
        float radius = 0f;
        float[] distance = new float[vertex_Count - 1];
        if (whereDoYouWantToCreateIt.GetComponent<SphereCollider>() == null)
        {
            sp = whereDoYouWantToCreateIt.AddComponent<SphereCollider>();
            for (int i = 0; i < vertexs.Count; i++)
            {
                total += vertexs[i];
                center = total / vertex_Count;
                for (int j = 0; j < vertexs.Count - 1; j++)
                {
                    radius = Vector3.Distance(vertexs[j], center);
                    distance[j] = radius;
                }
            }
            radius = Sort(distance)[0];         //把排序后的第一个数作为包围球半径
            sp.center = center;
            sp.radius = radius;
        }
    }

    /// <summary>
    /// 从大到小排序
    /// </summary>
    /// <param name="f"></param>
    /// <returns></returns>
    public static float[] Sort(float[] f)
    {
        for (int i = 0; i < f.Length; i++)
        {
            for (int j = 0; j < f.Length - 1; j++)
            {
                if (f[j] < f[j + 1])
                {
                    float temp = f[j];
                    f[j] = f[j + 1];
                    f[j + 1] = temp;
                }
            }
        }
        return f;
    }

    /// <summary>
    /// 创建AABB包围盒
    /// </summary>
    /// <param name="parent">父物体</param>
    /// <param name="aabbBounds">需不需要把包围盒数据转换到另一游戏物体上</param>
    public static void CreateAABBBounds(GameObject parent, GameObject aabbBounds = null)
    {
        if(parent == null)
        {
            Debug.LogError("父物体不存在，请检查传入的游戏物体是否为空！");
            return;
        }
        if (parent.GetComponent<BoxCollider>() == null)
        {
            Vector3 postion = parent.transform.position;
            Quaternion rotation = parent.transform.rotation;
            Vector3 scale = parent.transform.localScale;
            parent.transform.position = Vector3.zero;
            parent.transform.rotation = Quaternion.Euler(Vector3.zero);
            parent.transform.localScale = Vector3.one;

            Vector3 center = Vector3.zero;
            Renderer[] renders = parent.GetComponentsInChildren<Renderer>();
            foreach (Renderer child in renders)
            {
                center += child.bounds.center;
            }
            center = parent.transform.position;
            Bounds bounds = new Bounds(center, Vector3.zero);
            foreach (Renderer child in renders)
            {
                bounds.Encapsulate(child.bounds);
            }
            BoxCollider boxCollider = parent.AddComponent<BoxCollider>();
            boxCollider.center = bounds.center - parent.transform.position;//设置包围盒中心点
            boxCollider.size = bounds.size;

            if(aabbBounds != null)
            {
                aabbBounds.transform.position = bounds.center - parent.transform.position;
                aabbBounds.transform.rotation = rotation;
                aabbBounds.transform.localScale = bounds.size;
                if (aabbBounds.gameObject.GetComponent<BoxCollider>() == null)
                    aabbBounds.gameObject.AddComponent<BoxCollider>();
            }
        }
        else
        {
            Debug.Log("请销毁父物体上的BoxCollider组件");
        }
    }
}
