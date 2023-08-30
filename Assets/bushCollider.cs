using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class bushCollider : MonoBehaviour
{
    public Vector3 offset;
    private void LateUpdate()
    {
        //transform.position = new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z);
        Shader.SetGlobalVector("_BushPosition", transform.position);
    }
}
