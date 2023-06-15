import './style.css'
import ReactDOM from 'react-dom/client'
import { Canvas } from '@react-three/fiber'
import Experience from './Experience'

const root = ReactDOM.createRoot(document.querySelector('#root'))

root.render(
    <>
        <Canvas shadows camera={{fov: 50, position: [0, 2.5, 5]}} >
            <Experience  />
        </Canvas>
    </>
)