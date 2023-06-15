import { useFrame, extend } from "@react-three/fiber"
import { useRef } from "react"
import { OrbitControls } from "@react-three/drei"
import { useGLTF, Stage, PresentationControls, ContactShadows, shaderMaterial } from "@react-three/drei"
import * as THREE from 'three'
import { useEffect } from "react"

import portalVertexShader from './portal/vertex.glsl'
import portalFragmentShader from './portal/fragment.glsl'

const PortalMaterial = shaderMaterial(
    {
        time: 0,
        resolution: { value: new THREE.Vector2()}
    },
    portalVertexShader,
    portalFragmentShader
)

extend({ PortalMaterial })

export default function Experience()
{
    const box = useRef()
    const model = useGLTF('./Model/watch.glb')
    // console.log(model)
    const material = new THREE.MeshNormalMaterial()
    const material2 = new THREE.MeshStandardMaterial({
        color: 0xffffff
    })

    const portalMaterial = new PortalMaterial()
    // console.log(portalMaterial)

    useFrame((state, delta) =>
    {
        portalMaterial.uniforms.time.value += delta
        // console.log(portalMaterial.uniforms.time.value)
    })

    useEffect(() => {
        if(model){
            model.castShadow = true
            model.scene.traverse(o => {
                if(o.isMesh)
                {
                    // console.log(o.name)
                    o.castShadow = true
                    // o.material = material2
                    o.material.transparent = true
                    o.material.opacity = 1.
                    o.material.wireframe = false
                }

                if(o.name === 'mod')
                {
                    // console.log(o)
                    o.material = portalMaterial
                    o.scale.y = 1.0001
                    // o.material.transparent = true
                    // o.material.opacity = 0.5
                    o.position.y -= 0.001
                }
                if(o.name === 'Object_6')
                {
                    o.material.transparent = true
                    o.material.opacity = 0.5
                }

            })
        }
    }, [model])

    return <>
        {/* Orbit Controls */}
        <OrbitControls makeDefault enableZoom={true} enablePan={false}/>
        <fog attach="fog" args={[0xffffff, 30, 40]} />
        <Stage adjustCamera={1.5}  intensity={0.5} shadows="contact" matrixWorldNeedsUpdate> 
            {/* control presentation - user rotation of model */}
            {/* <PresentationControls 
                global 
                rotation={ [ 0., 0.0, 0 ] }
                polar={ [ -2, 2 ] }
                azimuth={ [ -Math.PI * 0.5,  Math.PI * 0.5 ] }
                config={ { mass: 2, tension: 50 } }
                snap={ { mass: 2, tension: 50 } }
            >
                Model */}
                
            {/* </PresentationControls> */}
            <primitive object={model.scene} />
            {/* Ground Mesh */}
            {/* <mesh rotation={[-Math.PI * 0.5, 0, 0]}  position={[0, -5, 0]}receiveShadow>
                <planeGeometry args={[50, 50]} />
                <meshStandardMaterial />
            </mesh> */}

        </Stage>
        
        
        {/* Lights */}
        <directionalLight position={[0, 2, 1]} color="red" intensity={1.}/>
        <directionalLight position={[0, 2, -1]} color="red" intensity={1.}/>
        <ambientLight intensity={0.125} />

        
    </>
}