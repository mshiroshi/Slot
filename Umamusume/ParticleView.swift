import SpriteKit
import SwiftUI

struct ParticleView: View {
    @State var fileNames: [String]
    let size: CGSize

    private var scene: SKScene {
        let scene = SKScene(size: size)
        scene.backgroundColor = .clear
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        fileNames.forEach {
            if let emitterNode = SKEmitterNode(fileNamed: $0) {
                emitterNode.position = self.getAnchorPoint(fileName: $0)
                scene.addChild(emitterNode)
            }
        }
        
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
    }
    
    private func getAnchorPoint(fileName: String) -> CGPoint {
        if fileName.hasSuffix("Right") {
            return CGPoint(x: size.width / 2, y: size.height / 2)
        } else if fileName.hasSuffix("Left") {
            return CGPoint(x: 0 - size.width / 2, y: size.height / 2)
        }
        
        return CGPoint(x: 0.5, y: 0.5)
    }
}
