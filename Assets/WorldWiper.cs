using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldWiper : MonoBehaviour
{
    public Transform islandTransform;
    // Start is called before the first frame update
    void Start()
    {
        Shader.SetGlobalVector("_IslandPosition", islandTransform.localPosition);
    }
}
