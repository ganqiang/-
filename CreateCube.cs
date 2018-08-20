using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CreateCube : MonoBehaviour {

    private Vector3 cubeScale = new Vector3(5, 5, 5);

    private void Start()
    {
        if(GameObject.Find("Scene") == null)
        {
            GameObject go = new GameObject();
            go.name = "Scene";
        }
    }
    [ContextMenu("CreateCubes")]
    private void CreateCubes()
    {
        for (int i = 0; i < 3000; i++)
        {
            GameObject go1 = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go1.transform.position = new Vector3(Random.Range(-1500, 1500), 20, Random.Range(-1500, 1500));
            go1.transform.localScale = cubeScale;
            go1.transform.SetParent(GameObject.Find("Scene").transform);
        }
    }
}
