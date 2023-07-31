using System;
using System.Collections;
using System.Collections.Generic;
using StarterAssets;
using UnityEngine;
using UnityEngine.InputSystem;

public class Player : MonoBehaviour
{
    // FSM 相关
    State currentState;
    
    [Header("主要引用")]
    public Transform _player;
    public CharacterController _controller;
    
    [Header("动画系统")]
    public Animator _animator;

    [Header("玩家输入处理")]
    public PlayerInput _playerInput;
    public StarterAssetsInputs _input;
    
    [Header("相机相关")]
    public GameObject _mainCamera;
    public GameObject _cinemachineCameraTarget;
    private float _cinemachineTargetYaw;
    private float _cinemachineTargetPitch;

    [Header("碰撞相关")]
    public LayerMask _GroundLayers;
    public bool _isCollision = false;

    private void Awake()
    {
        if (_mainCamera == null)
        {
            _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");
        }
    }

    private void Start() {
        _input = GetComponent<StarterAssetsInputs>();
        _playerInput = GetComponent<PlayerInput>();
        _controller = GetComponent<CharacterController>();
        _animator = GetComponent<Animator>();


        // 状态注册
        currentState = new BlendTreeMove(_input,_cinemachineCameraTarget,_player,_animator,_mainCamera,_playerInput,_controller,
                                _cinemachineTargetYaw,_cinemachineTargetPitch,_GroundLayers);
    }
    
    void Update() {
        currentState = currentState.Process();
    }

    #region 碰撞部分函数
    // 碰撞部分的函数
    private void OnCollisionEnter(Collision collision)
    {
        if (!_isCollision)
        {
            _isCollision = !_isCollision;
        }
        Debug.Log("<color=yellow>[MSG] </color> IsCollision = "+ _isCollision);
    }

    private void OnCollisionExit(Collision other)
    {
        if (_isCollision)
        {
            _isCollision = !_isCollision;
        }
        Debug.Log("<color=yellow>[MSG] </color> IsCollision = "+ _isCollision);
    }
    #endregion
}
