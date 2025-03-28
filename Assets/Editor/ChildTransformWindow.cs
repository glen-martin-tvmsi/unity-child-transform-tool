using UnityEditor;
using UnityEngine;

public class ChildTransformWindow : EditorWindow
{
    public Transform parentTransform;
    private bool updatePosition = true;
    private bool updateScale = false;
    private bool updateRotation = false;
    private Vector3 targetPosition = Vector3.zero;
    private Vector3 targetScale = Vector3.one;
    private Vector3 targetRotation = Vector3.zero;
    private bool[] positionAxisMask = { false, false, false };
    private bool[] scaleAxisMask = { false, false, false };
    private bool[] rotationAxisMask = { false, false, false };
    private bool useWorldSpace = false;
    const int MAX_CHILDREN_WARNING = 50;

    void OnGUI()
    {
        GUILayout.Label("Child Transform Settings", EditorStyles.boldLabel);

        updatePosition = EditorGUILayout.ToggleLeft("Update Position", updatePosition);
        if (updatePosition)
        {
            targetPosition = EditorGUILayout.Vector3Field("Target Position", targetPosition);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            positionAxisMask[0] = EditorGUILayout.ToggleLeft("X", positionAxisMask[0], GUILayout.Width(30));
            positionAxisMask[1] = EditorGUILayout.ToggleLeft("Y", positionAxisMask[1], GUILayout.Width(30));
            positionAxisMask[2] = EditorGUILayout.ToggleLeft("Z", positionAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        updateScale = EditorGUILayout.ToggleLeft("Update Scale", updateScale);
        if (updateScale)
        {
            targetScale = EditorGUILayout.Vector3Field("Target Scale", targetScale);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            scaleAxisMask[0] = EditorGUILayout.ToggleLeft("X", scaleAxisMask[0], GUILayout.Width(30));
            scaleAxisMask[1] = EditorGUILayout.ToggleLeft("Y", scaleAxisMask[1], GUILayout.Width(30));
            scaleAxisMask[2] = EditorGUILayout.ToggleLeft("Z", scaleAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        updateRotation = EditorGUILayout.ToggleLeft("Update Rotation", updateRotation);
        if (updateRotation)
        {
            targetRotation = EditorGUILayout.Vector3Field("Target Rotation (Euler Angles)", targetRotation);
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Apply to axes:", GUILayout.Width(80));
            rotationAxisMask[0] = EditorGUILayout.ToggleLeft("X", rotationAxisMask[0], GUILayout.Width(30));
            rotationAxisMask[1] = EditorGUILayout.ToggleLeft("Y", rotationAxisMask[1], GUILayout.Width(30));
            rotationAxisMask[2] = EditorGUILayout.ToggleLeft("Z", rotationAxisMask[2], GUILayout.Width(30));
            EditorGUILayout.EndHorizontal();
        }

        useWorldSpace = EditorGUILayout.ToggleLeft("Use World Space (for Position & Rotation only)", useWorldSpace);

        if (GUILayout.Button("Apply"))
        {
            ApplyTransforms();
            Close();
        }
    }

    void ApplyTransforms()
    {
        if (parentTransform == null || parentTransform.childCount == 0) return;

        if (parentTransform.childCount > MAX_CHILDREN_WARNING)
        {
            if (!EditorUtility.DisplayDialog("Warning", $"This will modify {parentTransform.childCount} children. Continue?", "Yes", "No")) 
                return;
        }

        Undo.IncrementCurrentGroup();
        Undo.SetCurrentGroupName("Modify Child Transforms");
        
        foreach (Transform child in parentTransform)
        {
            if (updatePosition) UpdatePosition(child);
            if (updateScale) UpdateScale(child);
            if (updateRotation) UpdateRotation(child);
        }

        Undo.CollapseUndoOperations(Undo.GetCurrentGroup());
        EditorUtility.SetDirty(parentTransform.gameObject);
    }

    void UpdatePosition(Transform child)
    {
        Vector3 newPosition = useWorldSpace ? child.position : child.localPosition;
        
        if (positionAxisMask[0]) newPosition.x = targetPosition.x;
        if (positionAxisMask[1]) newPosition.y = targetPosition.y;
        if (positionAxisMask[2]) newPosition.z = targetPosition.z;

        Undo.RecordObject(child, "Child Position Modification");
        
        if (useWorldSpace)
            child.position = newPosition;
        else
            child.localPosition = newPosition;
    }

    void UpdateScale(Transform child)
    {
        Vector3 newScale = child.localScale;

        if (scaleAxisMask[0]) newScale.x = targetScale.x;
        if (scaleAxisMask[1]) newScale.y = targetScale.y;
        if (scaleAxisMask[2]) newScale.z = targetScale.z;

        Undo.RecordObject(child, "Child Scale Modification");
        child.localScale = newScale;
    }

    void UpdateRotation(Transform child)
    {
        Vector3 newRotation = useWorldSpace ? child.eulerAngles : child.localEulerAngles;

        if (rotationAxisMask[0]) newRotation.x = targetRotation.x;
        if (rotationAxisMask[1]) newRotation.y = targetRotation.y;
        if (rotationAxisMask[2]) newRotation.z = targetRotation.z;

        Undo.RecordObject(child, "Child Rotation Modification");
        
        if (useWorldSpace)
            child.eulerAngles = newRotation;
        else
            child.localEulerAngles = newRotation;
    }
}
