import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var game:Game!
    var chessPieces:[Piece]!
    var isPieceSelected:Bool = false
    var movement:Dictionary = [String:Any]()
    var sourceNode:Piece!
    var isAgainstAI:Bool!
    var boardNode:SCNNode!
    
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
        if node.childNodes.count == 0 {
            chessPieces = []
            game = Game(viewController: self)
            boardNode = game.board.designBoard(planeAnchor: planeAnchor)
            node.addChildNode(boardNode)
        }
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
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        let location = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0]
            let node = result.node
            if node is Square{
                if isPieceSelected{
                    movement["new"] = node.position
                    let squareNode = node as? Square
                    
                    if game.isMoveValid(piece: sourceNode, fromIndex: sourceNode!.index, toIndex: (squareNode?.index)!){
                        game.move(piece: sourceNode, sourceIndex: sourceNode.index, destIndex: (squareNode?.index)!)
                        if game.isGameOver(){
                            displayWinner()
                            return
                        }
                        
                        if shouldPromotePawn(){
                            promptForPawnPromotion()
                        }else{
                            resumeGame()
                        }
                    }
                }
            }
            if node is Piece{
                movement["name"] = node.name
                movement["old"] = node.position
                sourceNode = (node as? Piece)!
                isPieceSelected = true
            }
        }
    }
    
//    @IBAction func redoMoves(_ sender: Any) {
//        if game.board.movements.count != 0 {
//            let movement = game.board.movements.last
//            let node = game.board.childNode(withName: movement!["name"] as! String, recursively: true)
//            
//            let action1 = SCNAction.move(to:movement!["old"] as! SCNVector3 , duration: 0.1)
//            node?.runAction(action1, completionHandler: {
//                self.game.board.movements.removeLast()
////                print(self.game.board.movements)
//            })
//        }
//    }
    
    func displayWinner(){
        let box = UIAlertController(title: "Game Over", message: "\(game.winner!) wins", preferredStyle: UIAlertControllerStyle.alert)
        
        box.addAction(UIAlertAction(title: "Back to main menu", style: UIAlertActionStyle.default, handler: {
            action in self.performSegue(withIdentifier: "backToMainMenu", sender: self)
        }))
        
        box.addAction(UIAlertAction(title: "Rematch", style: UIAlertActionStyle.default, handler: {
            action in
            
            for chessPiece in self.chessPieces{
                self.game.board.remove(piece: chessPiece)
            }
            
            //create new game
            self.game.board.addPieces()
            self.game.winner = ""
        }))
        
        self.present(box, animated: true, completion: nil)
    }
    
    func displayCheck(){
        let checkString = game.getPlayerChecked()
        if checkString != nil {
            print(checkString! + "is in check")
        }
    }
    
    func shouldPromotePawn() -> Bool{
        return (game.getPawnToBePromoted() != nil)
    }
    
    func promote(pawn pawnToBePromoted: Piece, into pieceName: String){
        
        game.board.remove(piece: pawnToBePromoted)
        
        switch pieceName {
        case "Queen":
            game.board.board[pawnToBePromoted.index.row][pawnToBePromoted.index.col] = Piece.init(isWhite: pawnToBePromoted.isWhite, type: .queen, board: game.board, index: pawnToBePromoted.index, name: "queen")
        case "Bishop":
            game.board.board[pawnToBePromoted.index.row][pawnToBePromoted.index.col] = Piece.init(isWhite: pawnToBePromoted.isWhite, type: .bishop, board: game.board, index: pawnToBePromoted.index, name: "bishop")
        case "Knight":
            game.board.board[pawnToBePromoted.index.row][pawnToBePromoted.index.col] = Piece.init(isWhite: pawnToBePromoted.isWhite, type: .knight, board: game.board, index: pawnToBePromoted.index, name: "knight")
        case "Rook":
            game.board.board[pawnToBePromoted.index.row][pawnToBePromoted.index.col] = Piece.init(isWhite: pawnToBePromoted.isWhite, type: .rook, board: game.board, index: pawnToBePromoted.index, name: "rook")
        default:
            break
        }
    }
    
    func promptForPawnPromotion(){
        if let pawnToPromote = game.getPawnToBePromoted(){
            
            let box = UIAlertController(title: "Pawn promotion", message: "Choose piece", preferredStyle: UIAlertControllerStyle.alert)
            
            box.addAction(UIAlertAction(title: "Queen", style: UIAlertActionStyle.default, handler: {
                action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            box.addAction(UIAlertAction(title: "Bishop", style: UIAlertActionStyle.default, handler: {
                action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            box.addAction(UIAlertAction(title: "Knight", style: UIAlertActionStyle.default, handler: {
                action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            box.addAction(UIAlertAction(title: "Rook", style: UIAlertActionStyle.default, handler: {
                action in
                self.promote(pawn: pawnToPromote, into: action.title!)
                self.resumeGame()
            }))
            
            self.present(box, animated: true, completion: nil)
        }
    }
    
    func resumeGame(){
        displayCheck()
        game.playerTurn()
        
        print(isAgainstAI)
        print(game.turnIsWhite)
        if isAgainstAI && !game.turnIsWhite {
            game.makeAIMove()
            
            if game.isGameOver(){
                displayWinner()
                return
            }
            
            if shouldPromotePawn(){
                promote(pawn: game.getPawnToBePromoted()!, into: "Queen")
            }
            
            displayCheck()
            game.playerTurn()
        }
        updateTurnOnScreen()
    }
    
    func updateTurnOnScreen(){
        popView()
    }
    
    func popView(){
        performSegue(withIdentifier: "gameOver", sender: self)
    }
}
