using UnityEngine;

public class SunLight : MonoBehaviour
{
    void Start()
    {
        Debug.Log(Mathf.Cos(90f * Mathf.Deg2Rad));
        Debug.Log(Mathf.Sin(90f * Mathf.Deg2Rad));
    }

    private void OnDrawGizmos()
    {

        Gizmos.DrawLine(Vector3.zero, -transform.forward * 1000f);
    }
}
