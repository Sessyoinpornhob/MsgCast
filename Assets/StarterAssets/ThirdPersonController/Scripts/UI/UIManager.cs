using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    // 数据来源
    public static UIManager Instance;
    // staminaNum
    public float staminaNum = 90;
    
    // UI相关内容
    public TextMeshProUGUI textMeshPro;
    public GameObject staminaUI;
    // Stamina 图形指示
    public Image StaminaInside;

    // 放弃思考了，单例模式 启动
    private void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(Instance);
    }

    void Start()
    {
        textMeshPro = staminaUI.GetComponent<TextMeshProUGUI>();
        textMeshPro.SetText(Mathf.Round(staminaNum).ToString());
    }
    
    void Update()
    {
        SetStamina();
    }

    void SetStamina()
    {
        textMeshPro.SetText(Mathf.Round(staminaNum).ToString());
        StaminaInside.fillAmount = Mathf.Round(staminaNum) / 100;
    }
}
