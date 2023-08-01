using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 各种必要功能的函数
public static class Utility
{
    // 向下取整
    public static double Round (double value, int digit)
    {
        double vt = Math.Pow (10, digit);
        //1.乘以倍数 + 0.5
        double vx = value * vt + 0.5;
        //2.向下取整
        double temp = Math.Floor (vx);
        //3.再除以倍数
        return (temp / vt);
    }
}
