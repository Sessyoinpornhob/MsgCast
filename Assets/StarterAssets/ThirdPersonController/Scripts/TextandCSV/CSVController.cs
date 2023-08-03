using System;
using UnityEngine;
using System.Collections;
using System.IO;
using System.Collections.Generic;

public class CSVController: MonoBehaviour  {

    public static CSVController instance;
    [HideInInspector]
    public List<string[]> arrayData;

    public TextAsset csvFile;

    private void Awake()
    {
        instance = this;
    }

    //public TextAsset csvFile;

    
    //public string filename;

    private CSVController()   //单例，构造方法为私有
    {
        arrayData = new List<string[]>();
    }

    public static CSVController GetInstance()   //单例方法获取对象
    {
        if(instance == null)
        {
            instance = new CSVController();
        }
        return instance;
    }

    public void loadFile()
    {
        arrayData.Clear();

        //Debug.Log(_filename);
        //TextAsset csvFile = Resources.Load<TextAsset>("CardData/" + _filename); // load csv file from resource folder
        if (csvFile == null)
        {
            Debug.Log("no csv file assigned");
            return;
        }

        string[] lines = csvFile.text.Split('\n'); // split csv file by line
        foreach (string line in lines)
        {
            arrayData.Add(line.Split(',')); // split each line by comma
        }
    }

    

    public string getString(int row,int col)
    {
        return arrayData[row][col];
    }

    // 获取csv文件的行数
    public int getRowCount()
    {
        return arrayData.Count;
    }
    
}