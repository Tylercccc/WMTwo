using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

using Cinemachine;
using static Cinemachine.CinemachineTargetGroup;
using static UnityEngine.GraphicsBuffer;

public class CameraController : MonoBehaviour
{
    public CinemachineVirtualCamera virtualCam;
    public float pitch;

    public Transform target;
    public Vector3 offset;
    public float yawSpeed = 100f;

    public float zoomLevel;
    public float sensitivity = 1;
    public float speed = 30;
    public float maxZoom = 30;
    float zoomPosition;

    private float currentYaw = 0f;
    private float currentPitch = 0f;

    private WizardActions controls;
    private InputAction zoomVal;
    //public InputAction controls;
    public void Awake()
    {
        controls = new WizardActions();
    }

    void Update()
    {

        //currentZoom -= zoomVal.ReadValue<Vector2>().y* 0.1f * zoomSpeed;
        //currentZoom = Mathf.Clamp(currentZoom, minZoom, maxZoom);
        
        zoomLevel += zoomVal.ReadValue<Vector2>().y * sensitivity;
        zoomLevel = Mathf.Clamp(zoomLevel, 0, maxZoom);
        zoomPosition = Mathf.MoveTowards(zoomPosition, zoomLevel, speed * Time.deltaTime);
        //Debug.Log(currentZoom);
        Debug.Log("Zoom value: " + zoomVal.ReadValue<Vector2>().y);
        currentYaw -= Input.GetAxis("Horizontal") * yawSpeed * Time.deltaTime;
        currentPitch -= Input.GetAxis("Vertical") * yawSpeed * Time.deltaTime;

        //Vector3 v3 = new Vector3(Input.GetAxis("Vertical"), Input.GetAxis("Horizontal"), 0.0f);
        //transform.RotateAround(player.transform.position, transform.right, v3.x * (speed * Time.deltaTime));
        //transform.RotateAround(player.transform.position, transform.up, v3.y * (speed * Time.deltaTime));
    }

    void LateUpdate()
    {
        transform.position = target.position - offset;
        transform.LookAt(target.position + Vector3.up * pitch);
        virtualCam.GetCinemachineComponent<CinemachineFramingTransposer>().m_CameraDistance = zoomPosition;
        //transform.position += transform.forward * zoomPosition;
        transform.RotateAround(target.position, Vector3.up, currentYaw);
        transform.RotateAround(target.position, Vector3.Cross((target.position - transform.position).normalized, Vector3.up), currentPitch);
      //- zoomPosition;
    }
    public void OnEnable()
    {
        zoomVal = controls.Camera.ScrollWheel;
        zoomVal.Enable();
        //controls.Enable();
    }

    public void OnDisable()
    {
        zoomVal.Disable();
        //controls.Disable();
    }
}
