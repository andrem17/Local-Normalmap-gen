import SwiftUI
import SceneKit

struct Preview3DView: NSViewRepresentable {
    func makeNSView(context: Context) -> SCNView {
        let view = SCNView(frame: .zero)
        view.scene = Self.makeScene()
        view.allowsCameraControl = false
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {}

    private static func makeScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = NSColor.clear

        // Luz ambiente
        let amb = SCNLight()
        amb.type = .ambient
        amb.intensity = 350
        let ambNode = SCNNode()
        ambNode.light = amb
        scene.rootNode.addChildNode(ambNode)

        // Direcional
        let dir = SCNLight()
        dir.type = .directional
        dir.intensity = 900
        let dirNode = SCNNode()
        dirNode.eulerAngles = SCNVector3(-Float.pi/3, Float.pi/4, 0)
        dirNode.light = dir
        scene.rootNode.addChildNode(dirNode)

        // Câmera
        let cam = SCNCamera()
        cam.zNear = 0.1
        cam.zFar = 100
        let camNode = SCNNode()
        camNode.camera = cam
        camNode.position = SCNVector3(0, 0, 6)
        scene.rootNode.addChildNode(camNode)

        // Cubo
        let box = SCNBox(width: 1.4, height: 1.4, length: 1.4, chamferRadius: 0.14)
        let node = SCNNode(geometry: box)
        scene.rootNode.addChildNode(node)

        // Rotação contínua
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.fromValue = SCNVector4(0, 1, 0, 0)
        spin.toValue   = SCNVector4(0, 1, 0, Float.pi * 2)
        spin.duration  = 6
        spin.repeatCount = .infinity
        node.addAnimation(spin, forKey: "spin")

        return scene
    }
}
