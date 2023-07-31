using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshCollision : MonoBehaviour
{
    void OnControllerColliderHit(ControllerColliderHit hit)
    {
        Rigidbody body = hit.collider.attachedRigidbody;
        if(body == null || body.isKinematic)
        {
            return;
        }
        else
        {
            Debug.Log("touch gameObject： " + hit.collider.gameObject.name);
                
            //摧毁物体
            //Destroy(hit.collider.gameObject);
        
            //给物体一个移动的力
            //body.velocity = new Vector3(hit.moveDirection.x,0,hit.moveDirection.z) * 30.0f;
                
            // todo: 改变某个变量，改变状态，记录平衡值，执行失去平衡动画。
        }
    } 
}
