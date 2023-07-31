using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using StarterAssets;
using UnityEngine.InputSystem;
using StarterAssets;

// using UnityEngine;
// using UnityEngine.InputSystem;


// 基于FSM的第三人称控制脚本
public class State
{
    public enum States
    {
        BlendTreeMove,
        JumpUp,
        FreeFall,
        StumbleMove,
        HoldBalance,
        FallDown,
        GetUp,
        PickUpItem
    };

    public enum Event
    {
        Enter,
        Update,
        Exit
    };
    
    public States name;
    protected Event stage;
    protected State nextState;

    // 引用类型
    protected Transform player;
    protected Animator animator;
    protected GameObject mainCamera;
    protected PlayerInput playerInput;
    protected CharacterController controller;
    protected StarterAssetsInputs inputs;
    protected const float threshold = 0.01f;
    public Player Player = null;
    

    #region const 参数
    // Player
    // 玩家走路速度
    protected float MoveSpeed = 2.0f;
    // 玩家跑步速度
    protected float SprintSpeed = 5.335f;
    // 玩家转向速度
    protected float RotationSmoothTime = 0.12f;
    // 加速减速
    protected float SpeedChangeRate = 10.0f;
    // 玩家跳跃高度
    protected float JumpHeight = 1.5f;
    // 玩家重力
    protected float Gravity = -15.0f;
    // 跳跃间隔
    protected float JumpTimeout = 0.50f;
    // Time required to pass before entering the fall state. Useful for walking down stairs
    protected float FallTimeout = 0.15f;
    // Grounded
    // 地面检测
    protected bool Grounded = true;
    // Useful for rough ground
    protected float GroundedOffset = 0.2f;//0.14f;
    // The radius of the grounded check. Should match the radius of the CharacterController
    protected float GroundedRadius = 0.28f;
    // Ground Layers 如果想直接写的话，用位掩码
    protected LayerMask GroundLayers = 1 << 6;
    // Cinemachine
    protected GameObject CinemachineCameraTarget;
    // 相机向上的最低值
    protected float TopClamp = 70.0f;
    // 相机向下的最低值
    protected float BottomClamp = -30.0f;
    // Additional degress to override the camera. Useful for fine tuning camera position when locked
    protected float CameraAngleOverride = 0.0f;
    // 全局锁定相机的旋转轴
    protected bool LockCameraPosition = false;
    // Gameplay-BalanceHold
    // 用于玩家碰撞物体后保持平衡
    protected bool onholdbalance = false;
    #endregion
    
    // 一些引用参数
    #region Cinemachine
    // Cinemachine
    protected float _cinemachineTargetYaw;
    protected float _cinemachineTargetPitch;
    #endregion

    #region PlayerRelated
    // 速度 动画速度 转身速度
    protected float _speed;
    protected float _animationBlend;
    protected float _targetRotation = 0.0f;
    protected float _rotationVelocity;
    protected float _verticalVelocity;
    protected float _terminalVelocity = 53.0f;
    #endregion

    #region timeout
    // timeout deltatime
    protected float _jumpTimeoutDelta;
    protected float _fallTimeoutDelta;
    #endregion

    #region animation IDs
    protected int _animIDSpeed;
    protected int _animIDGrounded;
    protected int _animIDJump;
    protected int _animIDFreeFall;
    protected int _animIDMotionSpeed;
    #endregion

    #region GamePlayNeeded
    // 在玩法中需要的参数。
    // 是否碰撞
    protected bool IsCollision = false;
    // 玩家是否能操作 or 等某些动画完成后才可操作
    protected bool CanMove = true;
    protected bool IsStumble = false;
    #endregion
    
    // 构造函数
    public State( StarterAssetsInputs _inputs, GameObject _cinemachineCameraTarget,
                Transform _player, Animator _animator, GameObject _mainCamera,
                PlayerInput _playerInput, CharacterController _controller,
                float passedInCinemachineTargetYaw, float passedInCinemachineTargetPitch, LayerMask groundLayers)
    {
        // Player.cs 中的引用变量通过函数转换到 State.cs 的 protected 引用变量中
        stage = Event.Enter;
        inputs = _inputs;
        player = _player;
        animator = _animator;
        mainCamera = _mainCamera;
        playerInput = _playerInput;
        controller = _controller;
        CinemachineCameraTarget = _cinemachineCameraTarget;
        _cinemachineTargetYaw = passedInCinemachineTargetYaw;
        _cinemachineTargetPitch = passedInCinemachineTargetPitch;
        GroundLayers = groundLayers;
    }

    public virtual void Enter()
    {
        AssignAnimationIDs();
        stage = Event.Update;
    }

    public virtual void Update()
    {
        // 在此处写一函数，用于持续追踪Player.cs中某些参数的变化。
        VariablesTrack();
        GroundedCheck();
        CameraRotation();
        if (CanMove)
        {
            Move();
        }
        else
        {
            StumbleMove();
        }
        stage = Event.Update;
    }

    public virtual void Exit()
    {
        stage = Event.Exit;
    }

    public State Process() {
        if (stage == Event.Enter) Enter();
        if (stage == Event.Update) Update();
        if (stage == Event.Exit) {
            Exit();
            return nextState;
        }
        return this;
    }
    
    // 地面检测
    protected void GroundedCheck()
    {
        // set sphere position, with offset
        Vector3 spherePosition = new Vector3(player.position.x, player.position.y + GroundedOffset,
            player.position.z);
        // 检查碰撞情况 返回bool
        Grounded = Physics.CheckSphere(spherePosition, GroundedRadius, GroundLayers,
            QueryTriggerInteraction.Ignore);
        // 动画更新
        animator.SetBool(_animIDGrounded, Grounded);
    }
    
    // 位置移动脚本
    protected void Move()
    {
        float targetSpeed = inputs.sprint ? SprintSpeed : MoveSpeed;
        if (inputs.move == Vector2.zero) targetSpeed = 0.0f;

        // a reference to the players current horizontal velocity
        float currentHorizontalSpeed = new Vector3(controller.velocity.x, 0.0f, controller.velocity.z).magnitude;

        float speedOffset = 0.1f;
        float inputMagnitude = inputs.analogMovement ? inputs.move.magnitude : 1f;

        // 条件判定 出现加速 or 减速
        if (currentHorizontalSpeed < targetSpeed - speedOffset ||
            currentHorizontalSpeed > targetSpeed + speedOffset)
        {
            // 设置一个灵敏的非线性加速
            _speed = Mathf.Lerp(currentHorizontalSpeed, targetSpeed * inputMagnitude,
                Time.deltaTime * SpeedChangeRate);

            // round speed to 3 decimal places 看起来像是某种取整
            _speed = Mathf.Round(_speed * 1000f) / 1000f;
        }
        else
        {
            _speed = targetSpeed;
        }

        // 将 Blendtree 的判定参数随speed改变
        _animationBlend = Mathf.Lerp(_animationBlend, targetSpeed, Time.deltaTime * SpeedChangeRate);
        if (_animationBlend < 0.01f) _animationBlend = 0f;

        // normalise input direction
        Vector3 inputDirection = new Vector3(inputs.move.x, 0.0f, inputs.move.y).normalized;

        // 旋转部分
        // note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
        // if there is a move input rotate player when the player is moving
        if (inputs.move != Vector2.zero)
        {
            // 目标的旋转方向 = 输入的“前方” + 相机的旋转方向（欧拉角）
            _targetRotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg +
                              mainCamera.transform.eulerAngles.y;
            float rotation = Mathf.SmoothDampAngle(player.eulerAngles.y, _targetRotation, ref _rotationVelocity,
                RotationSmoothTime);

            // rotate to face input direction relative to camera position
            player.rotation = Quaternion.Euler(0.0f, rotation, 0.0f);
        }
        
        Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;

        // move the player
        controller.Move(targetDirection.normalized * (_speed * Time.deltaTime) +
                         new Vector3(0.0f, _verticalVelocity, 0.0f) * Time.deltaTime);

        // blendtree 相关的动画内容
        animator.SetFloat(_animIDSpeed, _animationBlend);
        animator.SetFloat(_animIDMotionSpeed, inputMagnitude);
    }
    protected void StumbleMove()
    {
        if (!Grounded)
        {
            _verticalVelocity = Gravity * 0.1f;
        }
        float targetSpeed = inputs.sprint ? SprintSpeed : MoveSpeed;
        if (inputs.move == Vector2.zero) targetSpeed = 0.0f;

        // a reference to the players current horizontal velocity
        float currentHorizontalSpeed = new Vector3(controller.velocity.x, 0.0f, controller.velocity.z).magnitude;

        float speedOffset = 0.1f;
        float inputMagnitude = inputs.analogMovement ? inputs.move.magnitude : 1f;

        // 条件判定 出现加速 or 减速
        if (currentHorizontalSpeed < targetSpeed - speedOffset ||
            currentHorizontalSpeed > targetSpeed + speedOffset)
        {
            // 设置一个灵敏的非线性加速
            _speed = Mathf.Lerp(currentHorizontalSpeed, targetSpeed * inputMagnitude,
                Time.deltaTime * SpeedChangeRate);

            // round speed to 3 decimal places 看起来像是某种取整
            _speed = Mathf.Round(_speed * 1000f) / 1000f;
        }
        else
        {
            _speed = targetSpeed;
        }

        // 将 Blendtree 的判定参数随speed改变
        _animationBlend = Mathf.Lerp(_animationBlend, targetSpeed, Time.deltaTime * SpeedChangeRate);
        if (_animationBlend < 0.01f) _animationBlend = 0f;

        // normalise input direction
        Vector3 inputDirection = new Vector3(inputs.move.x, 0.0f, inputs.move.y).normalized;

        // 旋转部分
        // note: Vector2's != operator uses approximation so is not floating point error prone, and is cheaper than magnitude
        // if there is a move input rotate player when the player is moving
        if (inputs.move != Vector2.zero)
        {
            // 目标的旋转方向 = 输入的“前方” + 相机的旋转方向（欧拉角）
            _targetRotation = Mathf.Atan2(inputDirection.x, inputDirection.z) * Mathf.Rad2Deg +
                              mainCamera.transform.eulerAngles.y;
            float rotation = Mathf.SmoothDampAngle(player.eulerAngles.y, _targetRotation, ref _rotationVelocity,
                RotationSmoothTime);

            // rotate to face input direction relative to camera position
            player.rotation = Quaternion.Euler(0.0f, rotation, 0.0f);
        }
        
        Vector3 targetDirection = Quaternion.Euler(0.0f, _targetRotation, 0.0f) * Vector3.forward;

        // move the player
        controller.Move(targetDirection.normalized * (_speed * Time.deltaTime) +
                         new Vector3(0.0f, _verticalVelocity, 0.0f) * Time.deltaTime);

        // blendtree 相关的动画内容
        animator.SetFloat(_animIDSpeed, _animationBlend);
        animator.SetFloat(_animIDMotionSpeed, inputMagnitude);
    }
    
    // 相机旋转相关
    protected void CameraRotation()
    {
        // 转换 State 的时候需要将 CameraRotation 的角度临时记录并应用在下一个 State

        // if there is an input and camera position is not fixed
        if (inputs.look.sqrMagnitude >= threshold && !LockCameraPosition)
        {
            //Don't multiply mouse input by Time.deltaTime 如果是Time.deltaTime的话，相机会无目的缓动
            float deltaTimeMultiplier = 1;//IsCurrentDeviceMouse ? 1.0f : Time.deltaTime;

            _cinemachineTargetYaw += inputs.look.x * deltaTimeMultiplier;
            _cinemachineTargetPitch += inputs.look.y * deltaTimeMultiplier;
        }

        // clamp our rotations so our values are limited 360 degrees
        _cinemachineTargetYaw = ClampAngle(_cinemachineTargetYaw, float.MinValue, float.MaxValue);
        _cinemachineTargetPitch = ClampAngle(_cinemachineTargetPitch, BottomClamp, TopClamp);

        // Cinemachine will follow this target 在此获取Cinemachine
        CinemachineCameraTarget.transform.rotation = Quaternion.Euler(_cinemachineTargetPitch + CameraAngleOverride,
            _cinemachineTargetYaw, 0.0f);
    }
    
    // ClampAngle 角度
    private static float ClampAngle(float lfAngle, float lfMin, float lfMax)
    {
        if (lfAngle < -360f) lfAngle += 360f;
        if (lfAngle > 360f) lfAngle -= 360f;
        return Mathf.Clamp(lfAngle, lfMin, lfMax);
    }
    
    // 动画注册
    private void AssignAnimationIDs()
    {
        _animIDSpeed = Animator.StringToHash("Speed");
        _animIDGrounded = Animator.StringToHash("Grounded");
        _animIDJump = Animator.StringToHash("Jump");
        _animIDFreeFall = Animator.StringToHash("FreeFall");
        _animIDMotionSpeed = Animator.StringToHash("MotionSpeed");
    }
    
    // 参数传值
    protected void VariablesTrack()
    {
        if (!Player)
        {
            Player = player.gameObject.GetComponent<Player>();
        }
        IsCollision = Player._isCollision;
        //Debug.Log("<color=blue> [MSG] </color> IsCollision = "+ IsCollision);
    }
}

public class BlendTreeMove : State
{
    public BlendTreeMove( StarterAssetsInputs _inputs, GameObject _cinemachineCameraTarget,
                        Transform _player, Animator _animator, GameObject _mainCamera,
                        PlayerInput _playerInput, CharacterController _controller,
                        float _cinemachineTargetYaw, float _cinemachineTargetPitch, LayerMask groundLayers
                    ) : base(_inputs,_cinemachineCameraTarget,_player, _animator, _mainCamera, _playerInput, _controller, 
                        _cinemachineTargetYaw, _cinemachineTargetPitch, groundLayers)
    {
        // 在构造函数中，将 debugstr 命名为状态name
        name = States.BlendTreeMove;
    }
    
    public override void Enter()
    {
        Debug.Log("<color=yellow> [MSG] </color> States = " + name);
        base.Enter();
    }

    public override void Update()
    {
        base.Update();
        // 转换到 JumpUp
        if (inputs.jump && Grounded)
        {
            // 这样传值是能传过去的  inputs.jump = false;
            nextState = new JumpUp(inputs,CinemachineCameraTarget,player,animator,mainCamera,playerInput,
                controller,_cinemachineTargetYaw,_cinemachineTargetPitch,GroundLayers);
            stage = Event.Exit;
        }
        // 转换到 FreeFall
        if (!Grounded)
        {
            nextState = new FreeFall(inputs,CinemachineCameraTarget,player,animator,mainCamera,playerInput,
                controller,_cinemachineTargetYaw,_cinemachineTargetPitch,GroundLayers);
            stage = Event.Exit;
        }
        // 转换到 Stumble
        if (IsCollision)
        {
            nextState = new StumbleMove(inputs,CinemachineCameraTarget,player,animator,mainCamera,playerInput,
                controller,_cinemachineTargetYaw,_cinemachineTargetPitch,GroundLayers);
            stage = Event.Exit;
        }
    }
    
    public override void Exit() 
    {
        base.Exit();
    }
}

public class JumpUp : State
{
    public JumpUp( StarterAssetsInputs _inputs, GameObject _cinemachineCameraTarget,
                Transform _player, Animator _animator, GameObject _mainCamera,
                PlayerInput _playerInput, CharacterController _controller,
                float _cinemachineTargetYaw, float _cinemachineTargetPitch, LayerMask groundLayers
                ) : base(_inputs,_cinemachineCameraTarget,_player, _animator, _mainCamera, _playerInput, _controller, 
                _cinemachineTargetYaw, _cinemachineTargetPitch, groundLayers)
    {
        name = States.JumpUp;
    }
    
    public override void Enter()
    {
        base.Enter();
        Debug.Log("States = " + name);
        // 根据需求的高度计算需要的向上的速度
        _verticalVelocity = Mathf.Sqrt(JumpHeight * -2f * Gravity);
    }

    public override void Update()
    {
        base.Update();
        
        _fallTimeoutDelta = FallTimeout;

        // 在地上跳起来的逻辑
        if (_jumpTimeoutDelta <= 0.0f)
        {
            _verticalVelocity += Gravity * Time.deltaTime;

            // update animator if using character
            animator.SetBool(_animIDJump, true);
            

            if (_verticalVelocity <= 0f)
            {
                Debug.Log("switch");
                inputs.jump = false;
                animator.SetBool(_animIDJump, false);
                nextState = new FreeFall(inputs,CinemachineCameraTarget,player,animator,mainCamera,
                    playerInput,controller,_cinemachineTargetYaw,_cinemachineTargetPitch,GroundLayers);
                stage = Event.Exit;
            }
        }
        if (_jumpTimeoutDelta >= 0.0f)  // 跳跃cd时间
        {
            _jumpTimeoutDelta -= Time.deltaTime;
        }

    }
    
    public override void Exit() 
    {
        base.Exit();
    }
}

public class FreeFall : State
{
    public FreeFall( StarterAssetsInputs _inputs, GameObject _cinemachineCameraTarget,
                    Transform _player, Animator _animator, GameObject _mainCamera,
                    PlayerInput _playerInput, CharacterController _controller,
                    float _cinemachineTargetYaw, float _cinemachineTargetPitch, LayerMask groundLayers
                    ) : base(_inputs,_cinemachineCameraTarget,_player, _animator, _mainCamera, _playerInput, _controller, 
                    _cinemachineTargetYaw, _cinemachineTargetPitch, groundLayers)
    {
        name = States.FreeFall;
    }
    
    public override void Enter()
    {
        base.Enter();
        Debug.Log("States = " + name);
    }

    public override void Update()
    {
        base.Update();
        
        if (!Grounded)
        {
            inputs.jump = false;
            if (_verticalVelocity < _terminalVelocity)
            {
                _verticalVelocity += Gravity * Time.deltaTime;
            }

            // fall timeout
            if (_fallTimeoutDelta >= 0.0f)
            {
                _fallTimeoutDelta -= Time.deltaTime;
            }
            else
            {
                animator.SetBool(_animIDFreeFall, true);
            }
        }
        else
        {
            _verticalVelocity = 0f;
            inputs.jump = false;
            animator.SetBool(_animIDFreeFall, false);
            // 播放落地动画，播完后：
            nextState = new BlendTreeMove(inputs,CinemachineCameraTarget,player,animator,mainCamera,
                playerInput,controller,_cinemachineTargetYaw,_cinemachineTargetPitch,GroundLayers);
            stage = Event.Exit;
        }

    }
    
    public override void Exit() 
    {
        base.Exit();
    }
}


public class StumbleMove : State
{
    public StumbleMove( StarterAssetsInputs _inputs, GameObject _cinemachineCameraTarget,
                        Transform _player, Animator _animator, GameObject _mainCamera,
                        PlayerInput _playerInput, CharacterController _controller,
                        float _cinemachineTargetYaw, float _cinemachineTargetPitch, LayerMask groundLayers
                    ) : base(_inputs,_cinemachineCameraTarget,_player, _animator, _mainCamera, _playerInput, _controller, 
                        _cinemachineTargetYaw, _cinemachineTargetPitch, groundLayers)
    {
        name = States.StumbleMove;
    }
    
    public override void Enter()
    {
        base.Enter();
        Debug.Log("<color=yellow> [MSG] </color> States = " + name);
        CanMove = false;
    }

    public override void Update()
    {
        base.Update();
        
    }
    
    public override void Exit() 
    {
        base.Exit();
    }
}

