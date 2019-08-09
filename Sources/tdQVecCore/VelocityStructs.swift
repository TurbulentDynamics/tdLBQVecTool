//
//  mQVecPostProcess.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
//import simd


struct Size3d{
    var x, y, z: Int
}

struct Pos3d {
    var i, j, k: Int
}

struct Size2d {
    var cols, rows: Int
}

struct Pos2d {
    var c, r: Int
}





struct Velocity {
    //    var v = simd_float4(rho, ux, uy, uz)

    var rho: Float32
    var ux: Float32
    var uy: Float32
    var uz: Float32

    init(){
        rho = 0.0
        ux = 0.0
        uy = 0.0
        uz = 0.0
    }

    init(rho: Float32, ux: Float32, uy: Float32, uz: Float32){
        self.rho = rho
        self.ux = ux
        self.uy = uy
        self.uz = uz
    }
}



struct OrthoVelocity2DPlane {

    var p: [[Velocity]]

    init(cols:Int, rows: Int){
        self.p = Array(repeating: Array(repeating: Velocity(), count: cols), count: rows)
    }

    subscript(c: Int, r: Int) -> Velocity {
        get {
            return p[c][r]
        }
        set(newValue) {
            p[c][r] = newValue
        }
    }
}




protocol TwoD {
    var cols: Int {get}
    var rows: Int {get}
    var depth: Int {get}
    var p: [Int: OrthoVelocity2DPlane] {get set}

}



struct MultiOrthoVelocity2DPlanesXY: TwoD  {

    var cols, rows: Int
    var depth: Int
    var dirs = [URL]()
    var p = [Int: OrthoVelocity2DPlane]()

    let iStart: Int = 0
    let jStart: Int = 0
    var kStart: Int {return p.keys.min()!}

    let iEnd, jEnd: Int
    var kEnd: Int {return p.keys.max()! + 1}

    init(x: Int, y: Int, depth: Int){
        self.cols = x + 2
        self.rows = y + 2
        self.depth = dirs.count
        self.iEnd = self.cols
        self.jEnd = self.rows
    }

    mutating func addPlane(atK: Int){
        p[atK] = OrthoVelocity2DPlane(cols:cols, rows:rows)
    }

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[k]![i, j]
        }
        set(newValue) {
            p[k]![i, j] = newValue
        }
    }

}



struct MultiOrthoVelocity2DPlanesXZ: TwoD {

    var cols, rows: Int
    var depth: Int
    var dirs = [URL]()

    var p = [Int: OrthoVelocity2DPlane]()

    let iStart: Int = 0
    var jStart: Int {return p.keys.min()!}
    let kStart: Int = 0

    let iEnd, kEnd: Int
    var jEnd: Int {return p.keys.max()! + 1}

    init(x: Int, depth: Int, z: Int){
        self.cols = x + 2
        self.rows = z + 2
        self.depth = depth
        self.iEnd = self.cols
        self.kEnd = self.rows
    }

    mutating func addPlane(atJ: Int){
        p[atJ] = OrthoVelocity2DPlane(cols:cols, rows:rows)
    }

    func getPlane(atJ: Int) -> OrthoVelocity2DPlane {
        assert(p.keys.contains(atJ))

        return p[atJ]!
    }



    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[j]![i, k]
        }
        set(newValue) {
            p[j]![i, k] = newValue
        }
    }

}




struct MultiOrthoVelocity2DPlanesYZ: TwoD {

    var cols, rows: Int
    var depth: Int
    var p = [Int: OrthoVelocity2DPlane]()

    var iStart: Int {return p.keys.min()!}
    let jStart: Int = 0
    let kStart: Int = 0

    var iEnd: Int {return p.keys.max()! + 1}
    let jEnd, kEnd: Int

    init(depth: Int, y: Int, z: Int){
        self.cols = y + 2
        self.rows = z + 2
        self.depth = depth
        self.jEnd = self.cols
        self.kEnd = self.rows
    }

    mutating func addPlane(atI: Int){
        p[atI] = OrthoVelocity2DPlane(cols:cols, rows:rows)
    }

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[i]![j, k]
        }
        set(newValue) {
            p[i]![j, k] = newValue
        }
    }



}












//struct AxisVelocity2DPlane {
//
//    //".im1.", ".ip1.", ".km1.", ".kp1."
//
//    init(col: Int, row: Int){
//        self.init(col: col, row: row, depth: 5)
//    }
//
//
//    func loadPlanes(at dirs: [URL]) {
//        let numPlanes = dirs.count()
//
//        //TOFIX Assumes all dirs have same shape
//        let dim = ppDim(dir: dirs[0])
//
//        var planes = Plane2DXY(numPlanes: numPlanes, dim.totalHeight, dim.totalWidth)
//
//        for d in dirs{
//
//
//        }
//
//    }
//
//
//
//}






struct OrthoVelocity3DGrid {

    var g: [[[Velocity]]]

    init(x:Int, y: Int, z: Int){
        self.g = Array(repeating: Array(repeating: Array(repeating: Velocity(), count: z), count: y), count: x)
    }

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return g[i][j][k]
        }
        set(newValue) {
            g[i][j][k] = newValue
        }
    }
}

