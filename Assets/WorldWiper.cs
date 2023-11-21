using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class WorldWiper : MonoBehaviour
{
    public Transform islandTransform;
    public Terrain terrain;
    //private Material terrainMat;
    // Start is called before the first frame update
    void Start()
    {
        //terrainMat = new Material(terrain.materialTemplate);
        //terrain.materialTemplate = terrainMat;
        Shader.SetGlobalVector("_IslandPosition", islandTransform.localPosition);
        TerrainTween();
    }
    private void TerrainTween()
    {
        LeanTween.value(terrain.gameObject, 0, 3, 15).setEase(LeanTweenType.linear).setOnUpdate((float val) =>
        {
            terrain.materialTemplate.SetFloat("_WorldDissolve",val);
            //bushMat.SetVector("_Squash", val);
        });
    }
    
}
