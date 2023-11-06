using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class bushCollider : MonoBehaviour
{
    public Vector3 offset;

    public GameObject psLeaves;
    public GameObject psLeavesExit;

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
                var collisionPoint = other.ClosestPoint(transform.position);
                Instantiate(psLeaves, collisionPoint, psLeaves.transform.rotation);
                timePassed = 0;
            }


                //Debug.DrawRay(item.point, item.normal * 100, Random.ColorHSV(0f, 1f, 1f, 1f, 0.5f, 1f), 10f);
            
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Bush")
        {
            BushAnimate(other, new Vector3(0, 0, 0), 2f, LeanTweenType.easeOutElastic);
            GameObject leavesExit = Instantiate(psLeavesExit, other.transform.position, psLeaves.transform.rotation);
            var bushShape = leavesExit.GetComponent<ParticleSystem>().shape;
            bushShape.mesh = other.GetComponent<MeshFilter>().mesh;
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
