using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class bushCollider : MonoBehaviour
{
    public Vector3 offset;
    private void Update()
    {
        //transform.position = new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z);
        Shader.SetGlobalVector("_BushPosition", transform.position + offset);
    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Bush")
        {
            LeanTween.cancel(other.gameObject);
            Material bushMat = other.GetComponent<MeshRenderer>().material;
            Vector3 currentSquash = bushMat.GetVector("_Squash");
            LeanTween.value(other.gameObject, currentSquash, new Vector3(2.25f, -1.5f, 2.25f), 0.75f).setEase(LeanTweenType.easeOutBack).setOnUpdate((Vector3 val) =>
                 {
                     bushMat.SetVector("_Squash", val);
                 });
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Bush")
        {
            LeanTween.cancel(other.gameObject);
            Material bushMat = other.GetComponent<MeshRenderer>().material;
            Vector3 currentSquash = bushMat.GetVector("_Squash");
            LeanTween.value(other.gameObject, currentSquash, new Vector3(0, 0, 0), 2f).setEase(LeanTweenType.easeOutElastic).setOnUpdate((Vector3 val) =>
            {
                bushMat.SetVector("_Squash", val);
            });
        }
    }
}
