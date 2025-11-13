//
//  ImmersiveView.swift
//  Portal Box Tutorial
//
//  Created by Jason Deng on 11/9/25.
//

import RealityKit
import RealityKitContent
import SwiftUI

@MainActor
struct ImmersiveView: View {

    @State private var box = Entity()  // to store our box

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(
                named: "PortalBoxScene",
                in: realityKitContentBundle
            ) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/

                // change default position of the box
                guard let box = immersiveContentEntity.findEntity(named: "Box")
                else {
                    fatalError()
                }
                self.box = box
                box.position = [1, 1, 1.5]  // meters
                box.scale *= [0.5, 1, 0.5]

                // Make world 1
                let world1 = Entity()
                world1.components.set(WorldComponent())
                let skybox1 = await createSkyboxEntity(texture: "skybox1")
                world1.addChild(skybox1)
                content.add(world1)

                // Make world 2
                let world2 = Entity()
                world2.components.set(WorldComponent())
                let skybox2 = await createSkyboxEntity(texture: "skybox2")
                world2.addChild(skybox2)
                content.add(world2)

                // Make world 3
                let world3 = Entity()
                world3.components.set(WorldComponent())
                let skybox3 = await createSkyboxEntity(texture: "skybox3")
                world3.addChild(skybox3)
                content.add(world3)

                // Make world 4
                let world4 = Entity()
                world4.components.set(WorldComponent())
                let skybox4 = await createSkyboxEntity(texture: "skybox4")
                world4.addChild(skybox4)
                content.add(world4)

                // Make portal 1
                let world1Portal = createPortal(target: world1)
                content.add(world1Portal)

                guard
                    let anchorPortal1 = immersiveContentEntity.findEntity(
                        named: "AnchorPortal_1"
                    )
                else {
                    fatalError("Cannot find portal anchor")
                }

                anchorPortal1.addChild(world1Portal)
                world1Portal.transform.rotation = simd_quatf(
                    angle: .pi / 2,
                    axis: [1, 0, 0]
                )

                // Make portal 2
                let world2Portal = createPortal(target: world2)
                content.add(world2Portal)

                guard
                    let anchorPortal2 = immersiveContentEntity.findEntity(
                        named: "AnchorPortal_2"
                    )
                else {
                    fatalError("Cannot find portal anchor")
                }

                anchorPortal2.addChild(world2Portal)
                world2Portal.transform.rotation = simd_quatf(
                    angle: -.pi / 2,
                    axis: [1, 0, 0]
                )

                // Make portal 3
                let world3Portal = createPortal(target: world3)
                content.add(world3Portal)

                guard
                    let anchorPortal3 = immersiveContentEntity.findEntity(
                        named: "AnchorPortal_3"
                    )
                else {
                    fatalError("Cannot find portal anchor")
                }

                anchorPortal3.addChild(world3Portal)
                let portal3RotX = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                let portal3RotY = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
                world3Portal.transform.rotation = portal3RotY * portal3RotX

                // Make portal 4
                let world4Portal = createPortal(target: world4)
                content.add(world4Portal)

                guard
                    let anchorPortal4 = immersiveContentEntity.findEntity(
                        named: "AnchorPortal_4"
                    )
                else {
                    fatalError("Cannot find portal anchor")
                }

                anchorPortal4.addChild(world4Portal)
                let portal4RotX = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
                let portal4RotY = simd_quatf(angle: -.pi / 2, axis: [0, 1, 0])
                world4Portal.transform.rotation = portal4RotY * portal4RotX

            }
        }
    }

    func createSkyboxEntity(texture: String) async -> Entity {
        guard let resource = try? await TextureResource(named: texture) else {
            fatalError("Unable to load the skybox")
        }

        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))

        let entity = Entity()
        entity.components.set(
            ModelComponent(
                mesh: .generateSphere(radius: 1000),
                materials: [material]
            )
        )
        entity.scale *= .init(x: -1, y: 1, z: 1)

        return entity
    }

    func createPortal(target: Entity) -> Entity {
        let portalMesh = MeshResource.generatePlane(width: 1, depth: 1)  // meters
        let portal = ModelEntity(
            mesh: portalMesh,
            materials: [PortalMaterial()]
        )
        portal.components.set(PortalComponent(target: target))

        return portal
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
