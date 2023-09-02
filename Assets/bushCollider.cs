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
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Bush")
        {
            Material bushMat = other.GetComponent<MeshRenderer>().material;
            LeanTween.value(other.gameObject, new Vector3(0, 0, 0), new Vector3(0, -1, 0), 1f).setOnUpdate((Vector3 val) =>
                 {
                     bushMat.SetVector("_Squash", val);
                 });
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Bush")
        {
            Material bushMat = other.GetComponent<MeshRenderer>().material;
            LeanTween.value(other.gameObject, new Vector3(0, -1, 0), new Vector3(0, 0, 0), 2f).setEase(LeanTweenType.easeOutElastic).setOnUpdate((Vector3 val) =>
            {
                bushMat.SetVector("_Squash", val);
            });
        }
    }
}
