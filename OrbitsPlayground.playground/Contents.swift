import UIKit
import SceneKit
import QuartzCore   // for the basic animation
import PlaygroundSupport

/*
 Source of inspiration and resources: https://github.com/TimeMagazine/node-astronomy -
 "Given the major orbital elements, calculate the three-dimensional orbits for planets and comets
 The Jet Propulsion Labratory has a lucid explanation of approximating planetary positions here:
 http://ssd.jpl.nasa.gov/txt/aprx_pos_planets.pdf
 The mathematics for comet positions, which differs depending on eccentricity, is gratefully borrowed
 from the free and open-source Orbit Viewer by Osamu Ajiki and Ron Baalke
 http://www.astroarts.com/products/orbitviewer/#LICENCE
 DATA
 Planets: http://ssd.jpl.nasa.gov/txt/p_elem_t1.txt
 Comets: http://ssd.jpl.nasa.gov/dat/ELEMENTS.COMET "
 */

 //create a scene view with an empty scene
var sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
var scene = SCNScene()
sceneView.scene = scene
PlaygroundPage.current.liveView = sceneView

// default lighting
sceneView.autoenablesDefaultLighting = true

// a camera
var cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
scene.rootNode.addChildNode(cameraNode)

var sunObject = SCNSphere(radius: 0.1)
sunObject.firstMaterial?.diffuse.contents = UIColor.yellow
var sunNode = SCNNode(geometry: sunObject)
scene.rootNode.addChildNode(sunNode)

func addEarth()->SCNNode{
    let earthObject = SCNSphere(radius:0.05)
    earthObject.firstMaterial?.diffuse.contents = UIColor.blue
    let earthNode = SCNNode(geometry: earthObject)
    earthNode.position = SCNVector3(4, 5.0, 4.0)
    sunNode.addChildNode(earthNode)
    return earthNode
}

func addVenus()->SCNNode {
    let venusObject = SCNSphere(radius:0.05)
    venusObject.firstMaterial?.diffuse.contents = UIColor.orange
    let venusNode = SCNNode(geometry: venusObject)
    venusNode.position = SCNVector3(4, 5.0, 4.0)
    sunNode.addChildNode(venusNode)
    return venusNode
}

func addMercury()->SCNNode {
    let mercuryObject = SCNSphere(radius:0.03)
    mercuryObject.firstMaterial?.diffuse.contents = UIColor.brown
    let mercuryNode = SCNNode(geometry: mercuryObject)
    mercuryNode.position = SCNVector3(4, 5.0, 4.0)
    sunNode.addChildNode(mercuryNode)
    return mercuryNode
}

var theEarth = addEarth()
var theVenus = addVenus()
var theMercury = addMercury()

class Astronomy {
    
    static func sin(degrees: Double)->Double{
        return __sinpi(degrees/180)
    }
    static func cos(degrees: Double)->Double {
        return __cospi(degrees/180)
    }
    
    static func dateToJulian(date: Date)->Double{
        return 2440587.5 + date.timeIntervalSince1970/86400
    }
    
    static func ecliptic(data:PlanetData, xp: Double, yp: Double, zp: Double) -> (Double, Double, Double) {
        let xecl = (cos(degrees:data.w) * cos(degrees:data.node) - sin(degrees:data.w) * sin(degrees:data.node) * cos(degrees:data.I)) * xp + (-sin(degrees:data.w) * cos(degrees:data.node) - cos(degrees:data.w) * sin(degrees:data.node) * cos(degrees:data.I)) * yp
        let yecl = (cos(degrees: data.w) * sin(degrees: data.node) + sin(degrees: data.w) * cos(degrees: data.node) * cos(degrees: data.I)) * xp + (-sin(degrees: data.w) * sin(degrees: data.node) + cos(degrees: data.w) * cos(degrees: data.node) * cos(degrees: data.I)) * yp
        let zecl = sin(degrees:data.w) * sin(degrees:data.I) * xp + cos(degrees:data.w) * sin(degrees:data.I) * yp
        return (xecl, yecl, zecl)
    }
    
    static func planetPosition(date: Date, planet: PlanetData)-> (Double, Double, Double){
        let julian = dateToJulian(date: date)
        let T = (julian - 2451545)/36525
        let newA = planet.a + (planet.aCy * T)
        let newE = planet.e + (planet.eCy * T)
        let newI = planet.I + (planet.ICy * T)
        let newL = planet.L + (planet.LCy * T)
        let newW = planet.w + (planet.wCy * T)
        let newNode = planet.node + (planet.nodeCy * T)
        let elements = PlanetData(name: "new", a: newA, e: newE, I: newI, L: newL, w: newW, node: newNode, aCy: 0, eCy: 0, ICy: 0, LCy: 0, wCy: 0, nodeCy: 0)
        
        var oldE = elements.L - (elements.w + elements.node)
        let M = oldE
        var E = M
        let e_star = elements.e * 180/Double.pi
        while abs(E - oldE) > 1/10000 * 180.0/Double.pi {
            oldE = E
            E = M + e_star * self.sin(degrees: oldE)
        }
        let xp = elements.a * (cos(degrees: E) - elements.e)
        let yp = elements.a * sqrt(1 - elements.e * elements.e) * sin(degrees: E)
        let zp:Double = 0
        return ecliptic(data: elements, xp: xp, yp: yp, zp: zp)
    }
}

struct PlanetData {
    var name: String
    var a: Double
    var e: Double
    var I: Double
    var L: Double
    var w: Double
    var node: Double
    var aCy: Double
    var eCy: Double
    var ICy: Double
    var LCy: Double
    var wCy: Double
    var nodeCy: Double
}

enum SolarSystemData {
    static let mercury: PlanetData = PlanetData(name: "Mercury",
                                                    a: 0.38709927,
                                                    e: 0.20563593,
                                                    I: 7.00497902,
                                                    L: 252.25032350,
                                                    w: 77.45779628,
                                                    node: 48.33076593,
                                                    aCy: 0.00000037,
                                                    eCy: 0.00001906,
                                                    ICy: -0.00594749,
                                                    LCy: 149472.67411175,
                                                    wCy: 0.16047689,
                                                    nodeCy: -0.12534081)
    
    static let venus: PlanetData = PlanetData(name: "Venus",
                                       a: 0.72333566,
                                       e: 0.00677672,
                                       I: 3.39467605,
                                       L: 181.97909950,
                                       w: 131.60246718,
                                       node: 76.67984255,
                                       aCy: 0.00000390,
                                       eCy: -0.00004107,
                                       ICy: -0.00078890,
                                       LCy: 58517.81538729,
                                       wCy: 0.00268329,
                                       nodeCy: -0.27769418)
    
    static let earth: PlanetData = PlanetData(name: "Earth",
                                       a: 1.00000261,
                                       e: 0.01671123,
                                       I: -0.00001531,
                                       L: 100.46457166,
                                       w: 102.93768193,
                                       node: 0.0,
                                       aCy: 0.00000562,
                                       eCy: -0.00004392,
                                       ICy: -0.01294668,
                                       LCy: 35999.37244981,
                                       wCy: 0.32327364,
                                       nodeCy: 0.0)
    
    //    static let blankPlanet: PlanetData = PlanetData(name: "",
    //                                              a: ,
    //                                              e: ,
    //                                              I: ,
    //                                              L: ,
    //                                              w: ,
    //                                              node: ,
    //                                              aCy: ,
    //                                              eCy: ,
    //                                              ICy: ,
    //                                              LCy: ,
    //                                              wCy: ,
    //                                              nodeCy: )
}

func getCoordinateForOrbit(date:Date, planet: PlanetData)-> SCNVector3{
    let positionResults = Astronomy.planetPosition(date: date, planet: planet)
    return SCNVector3(positionResults.0, positionResults.1
        , positionResults.2)
}

var today = Date()

func fireTimer(){
    let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { theTimer in
        today = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let mercuryPosition = getCoordinateForOrbit(date: today, planet: SolarSystemData.mercury)
        theMercury.position = mercuryPosition
        let venusPosition = getCoordinateForOrbit(date: today, planet: SolarSystemData.venus)
        theVenus.position = venusPosition
        let earthPosition = getCoordinateForOrbit(date: today, planet: SolarSystemData.earth)
        theEarth.position = earthPosition
        
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
fireTimer()

