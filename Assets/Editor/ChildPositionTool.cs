using UnityEditor;
using UnityEngine;

public class ChildPositionTool : Editor
{
    [MenuItem("GameObject/Set Children Transform", true, 20)]
    static bool ValidateSetChildrenTransform()
    {
        return Selection.activeGameObject != null && 
               Selection.activeGameObject.transform.childCount > 0;
    }

    [MenuItem("GameObject/Set Children Transform", false, 20)]
    static void InitTransformSetter(MenuCommand command)
    {
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = Selection.activeGameObject.transform;
        window.ShowModalUtility();
    }
}
