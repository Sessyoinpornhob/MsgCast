using System;
using System.Collections;
using System.Collections.Generic;
using StarterAssets;
using UnityEngine;
using UnityEngine.InputSystem;

public class Player : MonoBehaviour
{
    public static Player Instance;
    // FSM 相关
    private State currentState;
    
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
    [Tooltip("State.cs 关注的变量")] public bool _isCollision = false;

    [Header("动画系统回调参数")]
    [Tooltip("State.cs 关注的变量")] public int _AnimationStumbleFinish = 0;
    [Tooltip("State.cs 关注的变量")] public int _AnimationFallDownFinish = 0;
    private float _stamina = 100f;   // 最初的_stamina

    private void Awake()
    {
        if (_mainCamera == null)
            _mainCamera = GameObject.FindGameObjectWithTag("MainCamera");

        if (Instance == null)
            Instance = this;
        else
            Destroy(Instance);

    }

    private void Start() {
        _input = GetComponent<StarterAssetsInputs>();
        _playerInput = GetComponent<PlayerInput>();
        _controller = GetComponent<CharacterController>();
        _animator = GetComponent<Animator>();


        // 状态注册
        currentState = new BlendTreeMove(_input,_cinemachineCameraTarget,_player,_animator,_mainCamera,_playerInput,_controller,
                                _cinemachineTargetYaw,_cinemachineTargetPitch,_GroundLayers,_stamina);
        
    }
    
    void Update() {
        currentState = currentState.Process();

        //Debug.Log(TextManager.Instance.TextSearch("01", 1));
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

    #region Animation CallBack
    // 动画片段完成后，回调Event函数，改变某些参数。
    public void CallBack_AnimationStumbleFinish()
    {
        _AnimationStumbleFinish = 1;
        Debug.Log("_AnimationStumbleFinish = " + _AnimationStumbleFinish);
    }
    public void CallBack_AnimationFallDownFinish()
    {
        _AnimationFallDownFinish = 1;
        Debug.Log("_AnimationFallDownFinish = " + _AnimationFallDownFinish);
    }
    #endregion

    #region Animation Event Camera Part
    
    // 针对相机震动和效果的AnimationEvent
    public void CameraShakeStumble()
    {
        CameraShakes.Instance.ShakeCamera(0.8f,0.8f);
    }
    public void CameraShakeFallDown()
    {
        CameraShakes.Instance.ShakeCamera(2f,0.3f);
    }
    

    #endregion
}
