import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet weak var sessionInfoView: UIView!
	@IBOutlet weak var sessionInfoLabel: UILabel!
	@IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        UIApplication.shared.isIdleTimerDisabled = true
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's AR session.
		sceneView.session.pause()
	}
	
	// MARK: - ARSCNViewDelegate
    
    /// - Tag: PlaceARContent
	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return }
        
        let scene = SCNScene(named: "Assets.scnassets/chessBoard.scn")!
        let planeNode = scene.rootNode.childNodes[0]
        planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        planeNode.opacity = 1.0
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        planeNode.geometry?.materials = [material]
        addObject(planeNode: planeNode)
        node.addChildNode(planeNode)
	}

    // MARK: - ARSessionDelegate

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }

    // MARK: - ARSessionObserver
	
	func sessionWasInterrupted(_ session: ARSession) {
		sessionInfoLabel.text = "Session was interrupted"
	}
	
	func sessionInterruptionEnded(_ session: ARSession) {
		sessionInfoLabel.text = "Session interruption ended"
		resetTracking()
	}
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        resetTracking()
    }

    // MARK: - Private methods

    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        let message: String
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            message = "Move the device around to detect horizontal surfaces."
        case .normal:
            message = ""
        case .notAvailable:
            message = "Tracking unavailable."
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
        case .limited(.initializing):
            message = "Initializing AR session."
        }
        sessionInfoLabel.text = message
        sessionInfoView.isHidden = message.isEmpty
    }

    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func addObject(planeNode:SCNNode){
        planeNode.enumerateChildNodes { (node, stop) in
            if node.geometry is SCNBox{
                for i in 0...7{
                    if node.name == "box0\(i)" || node.name == "box1\(i)" || node.name == "box6\(i)" || node.name == "box7\(i)" {
                        let scene2 = SCNScene(named: "Assets.scnassets/pawn.scn")!
                        let bishopNode = scene2.rootNode.childNodes[0]
                        bishopNode.position = SCNVector3Make(0, 0, 0)
                        let material = SCNMaterial()
                        if node.name == "box0\(i)" || node.name == "box1\(i)"{
                            material.diffuse.contents = UIColor.black
                        }else{
                            material.diffuse.contents = UIColor.white
                        }
                        bishopNode.geometry?.materials = [material]
                        bishopNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
                        node.addChildNode(bishopNode)
                    }
                }
            }
        }
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node.name != nil{
//                planetName = node.name!
//                showAlert(planetName: planetName)
            }
        }
    }
}
