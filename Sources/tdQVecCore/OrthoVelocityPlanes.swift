//
//  mQVecPostProcess.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
import tdLBApi
//import simd


struct Vorticity {

    var vort: [[Float32]]

    init(cols: Int, rows: Int){
        self.vort = Array(repeating: Array(repeating: Float32(0.0), count: cols), count: rows)
    }

    subscript(c: Int, r: Int) -> Float32 {
        get {
            return vort[c][r]
        }
        set(newValue) {
            vort[c][r] = newValue
        }
    }
    func cols() -> Int {
        return vort[0].count
    }

    func rows() -> Int {
        return vort.count
    }

    func writeVorticity(to url: URL, withBorder border: Int = 1){

        var buffer = Array(repeating: Float32(), count: ((cols() - border * 2) * (rows() - border * 2)))

        for col in border..<cols() - border {
            for row in border..<rows() - border {

                buffer[(col - border) * (cols() - border * 2) + (row - border) ] = vort[col][row]

            }
        }



        let wData = Data(bytes: &buffer, count: buffer.count * MemoryLayout<Float32>.stride)

        let fileName = url.lastPathComponent + ".vorticity.bin"

        var modURL = url.deletingLastPathComponent()
        modURL.appendPathComponent(fileName)

        try! wData.write(to: modURL)

        print(modURL)
    }

}







protocol MultiOrthoVelocity2DPlane {
    var p: [Int: OrthoVelocity2DPlane] {get set}
}


extension MultiOrthoVelocity2DPlane {


    func getPlane(at: Int) -> OrthoVelocity2DPlane {
        precondition(p.keys.contains(at))
        return p[at]!
    }

    mutating func loadPlane(withDir dir: URL) {

        let cutAt = dir.cut()!

        let dim = dir.getPPDim()!


        //TODO:  Check this +2 here, seems necessary on axis cut, but not slice
        p[cutAt] = OrthoVelocity2DPlane(cols: dim.totalHeight + 2, rows: dim.totalWidth + 2)

        do {
            for qVec in try dir.getQvecFiles() {

                print("Loading \(qVec)")

                let disk = try diskSparseBuffer(binURL: qVec)

                disk.getVelocityFromDisk(addIntoPlane: &p[cutAt]!)



            }
        } catch {
            print("binFile error: \(dir)")
        }
    }


    mutating func loadManyPlanes(withDirs dirs: [URL]) {

        for dir in dirs {
            //TODO Check all dirs have same size of dim
            loadPlane(withDir: dir)
        }
    }

    func cols() -> Int {
        return p.first!.value.cols()
    }

    func rows() -> Int {
        return p.first!.value.rows()
    }


    func writeVelocity(to: URL, at: Int){
        p[at]!.writeVelocity(to: to)

    }
}




struct MultiOrthoVelocity2DPlanesXY: MultiOrthoVelocity2DPlane  {

    var p = [Int: OrthoVelocity2DPlane]()

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[k]![i, j]
        }
        set(newValue) {
            p[k]![i, j] = newValue
        }
    }


    func calcVorticity(at: Int) -> Vorticity {

        precondition(p[at - 1] != nil)
        precondition(p[at + 1] != nil)

        var vort = Vorticity(cols: cols(), rows: rows())

        let k = at
        for i in 1..<cols() - 1 {
            for j in 1..<rows() - 1 {


//              let uxy = 0.5 * (p[k  ]![i+1, j  ].ux - p[k  ]![i-1, j  ].ux)
                let uxy = 0.5 * (p[k  ]![i  , j+1].ux - p[k  ]![i  , j-1].ux)
                let uxz = 0.5 * (p[k+1]![i  , j  ].ux - p[k-1]![i  , j  ].ux)

                let uyx = 0.5 * (p[k  ]![i+1, j  ].uy - p[k  ]![i-1, j  ].uy)
//              let uyy = 0.5 * (p[k  ]![i  , j+1].uy - p[k  ]![i  , j-1].uy)
                let uyz = 0.5 * (p[k+1]![i  , j  ].uy - p[k-1]![i  , j  ].uy)

                let uzx = 0.5 * (p[k  ]![i+1, j  ].uz - p[k  ]![i-1, j  ].uz)
                let uzy = 0.5 * (p[k  ]![i  , j+1].uz - p[k  ]![i  , j-1].uz)
//              let uzz = 0.5 * (p[k+1]![i  , j  ].uz - p[k-1]![i  , j  ].uz)

                let uyz_uzy = uyz - uzy
                let uzx_uxz = uzx - uxz
                let uxy_uyx = uxy - uyx

                vort[i, j] = log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)
            }
        }

            return vort
    }
}


struct MultiOrthoVelocity2DPlanesXZ: MultiOrthoVelocity2DPlane {

    var p = [Int: OrthoVelocity2DPlane]()

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[j]![i, k]
        }
        set(newValue) {
            p[j]![i, k] = newValue
        }
    }



        func calcVorticity(at: Int) -> Vorticity {

            precondition(p[at - 1] != nil)
            precondition(p[at + 1] != nil)

            var vort = Vorticity(cols: cols(), rows: rows())

            let j = at
                for i in 1..<cols() - 1 {
                    for k in 1..<rows() - 1 {


//                      let uxy = 0.5 * (p[j  ]![i+1, k  ].ux - p[j  ]![i-1, k  ].ux)
                        let uxy = 0.5 * (p[j+1]![i  , k  ].ux - p[j-1]![i  , k  ].ux)
                        let uxz = 0.5 * (p[j  ]![i  , k+1].ux - p[j  ]![i  , k-1].ux)

                        let uyx = 0.5 * (p[j  ]![i+1, k  ].uy - p[j  ]![i-1, k  ].uy)
//                      let uyy = 0.5 * (p[j+1]![i  , k  ].uy - p[j-1]![i  , k  ].uy)
                        let uyz = 0.5 * (p[j  ]![i  , k+1].uy - p[j  ]![i  , k-1].uy)

                        let uzx = 0.5 * (p[j  ]![i+1, k  ].uz - p[j  ]![i-1, k  ].uz)
                        let uzy = 0.5 * (p[j+1]![i  , k  ].uz - p[j-1]![i  , k  ].uz)
//                      let uzz = 0.5 * (p[j  ]![i  , k+1].uz - p[j  ]![i  , k-1].uz)


                        let uyz_uzy = uyz - uzy
                        let uzx_uxz = uzx - uxz
                        let uxy_uyx = uxy - uyx

                        vort[i, k] = log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)


                    }

            }

                return vort
        }

}


struct MultiOrthoVelocity2DPlanesYZ: MultiOrthoVelocity2DPlane {

    var p = [Int: OrthoVelocity2DPlane]()

    subscript(i: Int, j: Int, k: Int) -> Velocity {
        get {
            return p[i]![j, k]
        }
        set(newValue) {
            p[i]![j, k] = newValue
        }
    }


    func calcVorticity(at: Int) -> Vorticity {

        precondition(p[at - 1] != nil)
        precondition(p[at + 1] != nil)

        var vort = Vorticity(cols: cols(), rows: rows())

        let i = at
            for j in 1..<cols() - 1 {
                for k in 1..<rows() - 1 {


//                  let uxy = 0.5 * (p[i+1]![j  , k  ].ux - p[i-1]![j  , k  ].ux)
                    let uxy = 0.5 * (p[i  ]![j  , k+1].ux - p[i  ]![j  , k-1].ux)
                    let uxz = 0.5 * (p[i  ]![j+1, k  ].ux - p[i  ]![j-1, k  ].ux)

                    let uyx = 0.5 * (p[i+1]![j  , k  ].uy - p[i-1]![j  , k  ].uy)
//                  let uyy = 0.5 * (p[i  ]![j  , k+1].uy - p[i  ]![j  , k-1].uy)
                    let uyz = 0.5 * (p[i  ]![j+1, k  ].uy - p[i  ]![j-1, k  ].uy)

                    let uzx = 0.5 * (p[i+1]![j  , k  ].uz - p[i-1]![j  , k  ].uz)
                    let uzy = 0.5 * (p[i  ]![j  , k+1].uz - p[i  ]![j  , k-1].uz)
//                  let uzz = 0.5 * (p[i  ]![j+1, k  ].uz - p[i  ]![j-1, k  ].uz)

                    let uyz_uzy = uyz - uzy
                    let uzx_uxz = uzx - uxz
                    let uxy_uyx = uxy - uyx

                    vort[j, k] = log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)
                }

        }

            return vort
    }


}










