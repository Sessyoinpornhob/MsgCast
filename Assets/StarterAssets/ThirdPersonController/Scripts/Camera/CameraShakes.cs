using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class CameraShakes : MonoBehaviour
{
    public static CameraShakes Instance;

    // 另一种办法
    private CinemachineVirtualCamera cinemachineVirtualCamera;
    private float shakeTimer;
    private float shakeTimerTotal;
    private float startingIntensity;
    private CinemachineBasicMultiChannelPerlin cinemachineBasicMultiChannelPerlin;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        cinemachineVirtualCamera = GetComponent<CinemachineVirtualCamera>();
        
    }
    

    /// <summary>
    /// 镜头震动 平滑减弱
    /// </summary>
    /// <param name="intensity"></param>
    /// <param name="time"></param>
    public void ShakeCamera(float intensity, float time)
    {
        cinemachineBasicMultiChannelPerlin =
            cinemachineVirtualCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        
        cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = intensity;

        startingIntensity = intensity;
        shakeTimer = time;
        shakeTimerTotal = time;
    }

    private void Update()
    {
        if (shakeTimer > 0)
        {
            shakeTimer -= Time.deltaTime;
            if (shakeTimer <= 0f)
            {
                // 震动时间结束
                cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = 
                    Mathf.Lerp(startingIntensity, 0f, 1 - (shakeTimer / shakeTimerTotal));
            }
        }
    }
}
