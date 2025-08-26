import SwiftUI
import SceneKit

struct Preview3DController: NSViewRepresentable {
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = context.coordinator.scene
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = NSColor.clear
        return scnView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        let scene = SCNScene()
        let cubeNode = SCNNode()

        init() {
            let cube = SCNBox(width: 1.5, height: 1.5, length: 1.5, chamferRadius: 0.0) // Aumentei o tamanho
            cube.materials.first?.diffuse.contents = NSColor.gray // Cor cinza para o cubo
            cubeNode.geometry = cube
            cubeNode.position = SCNVector3(0, 0, 0)
            scene.rootNode.addChildNode(cubeNode)

            // Animação de rotação
            let rotation = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 5.0)
            let repeatRotation = SCNAction.repeatForever(rotation)
            cubeNode.runAction(repeatRotation)

            // Câmera
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5) // Ajustei a câmera para o cubo maior
            scene.rootNode.addChildNode(cameraNode)
        }
    }
}
