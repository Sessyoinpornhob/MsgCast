using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshCollision : MonoBehaviour
{
    private void OnCollisionEnter(Collision collision)
    {
        Debug.Log ("**** collision.gameObject.name***:" + collision.gameObject.name);
        if(collision.gameObject.name == "Player")
        {
            Debug.Log("fine");
        }
    }
}
