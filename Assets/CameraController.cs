using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.GraphicsBuffer;

public class CameraController : MonoBehaviour
{
    public float speed = 75.0f;
    public GameObject player;

    private WizardActions controls;

    public void Awake()
    {
        controls = new WizardActions();
    }

    void Update()
    {
        //transform.LookAt(player.transform);
        Vector3 v3 = new Vector3(Input.GetAxis("Vertical"), Input.GetAxis("Horizontal"), 0.0f);
        transform.RotateAround(player.transform.position,v3,Time.deltaTime * speed);
    }
    public void OnEnable()
    {
        controls.Enable();
    }

    public void OnDisable()
    {
        controls.Disable();
    }
}
