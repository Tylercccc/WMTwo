using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static Cinemachine.CinemachineTargetGroup;
using static UnityEngine.GraphicsBuffer;

public class CameraController : MonoBehaviour
{
    public float pitch;
    public float zoomSpeed = 4f;
    public float minZoom = 5f;
    public float maxZoom = 15f;
    public Transform target;
    public Vector3 offset;
    public float yawSpeed = 100f;

    private float currentZoom = 10f;
    private float currentYaw = 0f;
    private float currentPitch = 0f;

    private WizardActions controls;

    public void Awake()
    {
        controls = new WizardActions();
    }

    void Update()
    {
        //currentZoom -= Input.GetAxis("Mouse ScrollWheel") * zoomSpeed;
        //currentZoom = Mathf.Clamp(currentZoom, minZoom, maxZoom);

        currentYaw -= Input.GetAxis("Horizontal") * yawSpeed * Time.deltaTime;
        currentPitch -= Input.GetAxis("Vertical") * yawSpeed * Time.deltaTime;
        //Vector3 v3 = new Vector3(Input.GetAxis("Vertical"), Input.GetAxis("Horizontal"), 0.0f);
        //transform.RotateAround(player.transform.position, transform.right, v3.x * (speed * Time.deltaTime));
        //transform.RotateAround(player.transform.position, transform.up, v3.y * (speed * Time.deltaTime));
    }

    void LateUpdate()
    {
        transform.position = target.position - offset * currentZoom;
        transform.LookAt(target.position + Vector3.up * pitch);

        transform.RotateAround(target.position, Vector3.up, currentYaw);
        transform.RotateAround(target.position, Vector3.Cross((target.position - transform.position).normalized, Vector3.up), currentPitch);
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
