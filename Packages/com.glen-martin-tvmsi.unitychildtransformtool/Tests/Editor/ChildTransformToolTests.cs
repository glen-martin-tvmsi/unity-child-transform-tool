using System.Collections;
using System.Collections.Generic;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;
using UnityEditor;

public class ChildTransformToolTests
{
    // Test position updates in local space
    [Test]
    public void PositionLocalSpaceTest()
    {
        // Create test objects
        var parent = new GameObject("TestParent");
        var child = new GameObject("TestChild");
        child.transform.parent = parent.transform;
        
        // Setup initial conditions
        child.transform.localPosition = new Vector3(1, 2, 3);
        
        // Create test window
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = parent.transform;
        
        // Set private fields via reflection
        var targetPositionField = typeof(ChildTransformWindow).GetField("targetPosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        targetPositionField.SetValue(window, new Vector3(5, 5, 5));
        
        var positionAxisMaskField = typeof(ChildTransformWindow).GetField("positionAxisMask", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        positionAxisMaskField.SetValue(window, new bool[] { true, false, true });
        
        var updatePositionField = typeof(ChildTransformWindow).GetField("updatePosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        updatePositionField.SetValue(window, true);
        
        // Use reflection to call private method
        var method = typeof(ChildTransformWindow).GetMethod("ApplyTransforms", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method.Invoke(window, null);
        
        // Verify results
        Assert.AreEqual(5, child.transform.localPosition.x);
        Assert.AreEqual(2, child.transform.localPosition.y); // Should remain unchanged
        Assert.AreEqual(5, child.transform.localPosition.z);
        
        // Cleanup
        Object.DestroyImmediate(parent);
    }
    
    // Test world space position updates
    [Test]
    public void PositionWorldSpaceTest()
    {
        // Create test objects
        var parent = new GameObject("TestParent");
        parent.transform.position = new Vector3(10, 0, 0);
        
        var child = new GameObject("TestChild");
        child.transform.parent = parent.transform;
        child.transform.position = new Vector3(15, 2, 3);
        
        // Create test window
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = parent.transform;
        
        // Set private fields via reflection
        var targetPositionField = typeof(ChildTransformWindow).GetField("targetPosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        targetPositionField.SetValue(window, new Vector3(20, 20, 20));
        
        var positionAxisMaskField = typeof(ChildTransformWindow).GetField("positionAxisMask", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        positionAxisMaskField.SetValue(window, new bool[] { false, false, true });
        
        var updatePositionField = typeof(ChildTransformWindow).GetField("updatePosition", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        updatePositionField.SetValue(window, true);
        
        var useWorldSpaceField = typeof(ChildTransformWindow).GetField("useWorldSpace", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        useWorldSpaceField.SetValue(window, true);
        
        // Use reflection to call private method
        var method = typeof(ChildTransformWindow).GetMethod("ApplyTransforms", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method.Invoke(window, null);
        
        // Verify results
        Assert.AreEqual(15, child.transform.position.x); // Should remain unchanged
        Assert.AreEqual(2, child.transform.position.y);  // Should remain unchanged
        Assert.AreEqual(20, child.transform.position.z); // Changed to target z-position
        
        // Cleanup
        Object.DestroyImmediate(parent);
    }
    
    // Test rotation updates
    [Test]
    public void RotationTest()
    {
        // Create test objects
        var parent = new GameObject("TestParent");
        var child = new GameObject("TestChild");
        child.transform.parent = parent.transform;
        
        // Setup initial conditions
        child.transform.localEulerAngles = new Vector3(0, 0, 0);
        
        // Create test window
        var window = ScriptableObject.CreateInstance<ChildTransformWindow>();
        window.parentTransform = parent.transform;
        
        // Set private fields via reflection
        var targetRotationField = typeof(ChildTransformWindow).GetField("targetRotation", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        targetRotationField.SetValue(window, new Vector3(45, 90, 0));
        
        var rotationAxisMaskField = typeof(ChildTransformWindow).GetField("rotationAxisMask", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        rotationAxisMaskField.SetValue(window, new bool[] { true, true, false });
        
        var updateRotationField = typeof(ChildTransformWindow).GetField("updateRotation", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        updateRotationField.SetValue(window, true);
        
        // Use reflection to call private method
        var method = typeof(ChildTransformWindow).GetMethod("ApplyTransforms", 
            System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
        method.Invoke(window, null);
        
        // Verify results (using approximate comparison due to floating-point precision)
        Assert.AreEqual(45, child.transform.localEulerAngles.x, 0.01f);
        Assert.AreEqual(90, child.transform.localEulerAngles.y, 0.01f);
        Assert.AreEqual(0, child.transform.localEulerAngles.z, 0.01f);
        
        // Cleanup
        Object.DestroyImmediate(parent);
    }
}
