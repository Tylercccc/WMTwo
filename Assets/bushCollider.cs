using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class bushCollider : MonoBehaviour
{
    public Vector3 offset;
    public GameObject psLeaves;

    private float timePassed = 0;
    private void Update()
    {
        Shader.SetGlobalVector("_BushPosition", transform.position + offset);


    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Bush")
        {
            BushAnimate(other, new Vector3(2.25f, -1.5f, 2.25f), 0.75f, LeanTweenType.easeOutBack);
        }
    }
    private void OnTriggerStay(Collider other)
    {
        if(other.tag == "Bush")
        {
            timePassed += Time.deltaTime;
            if(timePassed > 1f)
            {
                Instantiate(psLeaves, transform.position, psLeaves.transform.rotation);
                timePassed = 0;
            }
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Bush")
        {
            BushAnimate(other, new Vector3(0, 0, 0), 2f, LeanTweenType.easeOutElastic);
        }
    }
    private void BushAnimate(Collider other, Vector3 squashAmt, float squashTime, LeanTweenType ltType )
    {
        LeanTween.cancel(other.gameObject);
        Material bushMat = other.GetComponent<MeshRenderer>().material;
        Vector3 currentSquash = bushMat.GetVector("_Squash");
        LeanTween.value(other.gameObject, currentSquash, squashAmt, squashTime).setEase(ltType).setOnUpdate((Vector3 val) =>
        {
            bushMat.SetVector("_Squash", val);
        });
    }
}
