//
//  ViewController.swift
//  AR Ruler
//
//  Created by Jerry Ding on 2018-05-28.
//  Copyright © 2018 Jerry Ding. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var boxNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
            boxNode.removeFromParentNode()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
        
    }
    
    func addDot(at hitResult: ARHitTestResult) {
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.red
        dotGeometry.materials = [dotMaterial]
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            let distance = calculate()
            addLine(startNode: dotNodes[0], endNode: dotNodes[1], distance: distance)
        }
        
    }
    
    func addLine(startNode: SCNNode, endNode: SCNNode, distance: Float) {
        
        let boxGeometry = SCNBox(width: 0.0025, height: 0.0025, length: CGFloat(distance), chamferRadius: 0)
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(
            x: (startNode.position.x + endNode.position.x) / 2,
            y: (startNode.position.y + endNode.position.y) / 2,
            z: (startNode.position.z + endNode.position.z) / 2
        )
        boxNode.look(at: endNode.position)
        sceneView.scene.rootNode.addChildNode(boxNode)
        
    }
    
    func calculate() -> Float {
        
        let startNode = dotNodes[0]
        let endNode = dotNodes[1]
        
        let distance = sqrt(
            pow(endNode.position.x - startNode.position.x, 2) +
            pow(endNode.position.y - startNode.position.y, 2) +
            pow(endNode.position.z - startNode.position.z, 2)
        )
        
        updateText(withText: "\(distance)", atPosition: endNode.position)
        
        return distance
        
    }
    
    func updateText(withText text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.orientation = sceneView.pointOfView!.worldOrientation
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
}
