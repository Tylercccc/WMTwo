using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovementController : MonoBehaviour
{
    private WizardActions _inputMapping;

    private void Awake() => _inputMapping = new WizardActions();
    
    void Start()
    {
        _inputMapping.Player.Walk.performed += Walk;

    }

    private void OnEnable() => _inputMapping.Enable();
    private void OnDisable() => _inputMapping.Disable();

    private void Walk(InputAction.CallbackContext context)
    {
        Debug.Log("Walk");
    }
}
