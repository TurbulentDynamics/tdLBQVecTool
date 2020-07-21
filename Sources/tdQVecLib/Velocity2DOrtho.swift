//
//  mQVecPostProcess.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
import tdLBApi
//import simd

/// A dense 2D plane of Velocity types, these are square or orthogonal to the axes (see also `Velocity2DPlaneAngled_AxisOfRotationJ`
///
struct Velocity2DPlaneOrtho<T: BinaryFloatingPoint> {

    var p: [[Velocity<T>]]

    /// Initialise with size cols and rows.
    /// - note: column is the first index, maintaining coordinate axes shown TODO:link  elsewhere
    init(cols: Int, rows: Int) {
        self.p = Array(repeating: Array(repeating: Velocity<T>(), count: rows), count: cols)
    }

    var cols: Int {
        return p.count
    }

    var rows: Int {
        return p[0].count
    }

    subscript(c: Int, r: Int) -> Velocity<T> {
        get {
            return p[c][r]
        }
        set(newValue) {
            p[c][r] = newValue
        }
    }

    /// Writes the 2D Velocity Plane to 4 separate files
    /// - note: All  output files are written to the same location where the binary files were read from, and they take the name of the directory
    /// and suffixs rho.bin, ux.bin, uy.bin, and uz.bin
    ///
    /// - parameters
    ///   - plotDir The plotDir where the decomposed binary data was read from
    func writeVelocity(to dir: PlotDir, overwrite: Bool = false, withBorder border: Int = 1) {

//        let height = cols - border * 2
//        let width = rows - border * 2

        var writeBufferRHO = Data()
        var writeBufferUX = Data()
        var writeBufferUY = Data()
        var writeBufferUZ = Data()

        for col in border..<cols - border {
            for row in border..<rows - border {

                writeBufferRHO.append(withUnsafeBytes(of: p[col][row].rho) { Data($0) })
                writeBufferUX.append(withUnsafeBytes(of: p[col][row].ux ) { Data($0) })
                writeBufferUY.append(withUnsafeBytes(of: p[col][row].uy ) { Data($0) })
                writeBufferUZ.append(withUnsafeBytes(of: p[col][row].uz ) { Data($0) })
            }
        }

        do {
            // TODO: Eventually need to pass, height and width to file, or json or something.  Maybe use PPjson?
            if !(overwrite == false && dir.rhoURL().exists()) {
                try writeBufferRHO.write(to: dir.rhoURL())
            }
            if !(overwrite == false && dir.uxURL().exists()) {
                try writeBufferUX.write(to: dir.uxURL())
            }
            if !(overwrite == false && dir.uyURL().exists()) {
                try writeBufferUY.write(to: dir.uyURL())
            }
            if !(overwrite == false && dir.uzURL().exists()) {
                try writeBufferUZ.write(to: dir.uzURL())
            }

        } catch {
            print("Cannot write velocity files to \(dir.lastTwoPathComponents)")
        }

    }
}

protocol Velocity2DPlaneOrthoMulti {
    associatedtype T: BinaryFloatingPoint

    var p: [Int: Velocity2DPlaneOrtho<T>] {get set}
}

extension Velocity2DPlaneOrthoMulti {

    func getPlane(at: Int) -> Velocity2DPlaneOrtho<T> {
        precondition(p.keys.contains(at))
        return p[at]!
    }

    mutating func loadPlane(withDir dir: PlotDir) {

        guard let cutAt = dir.cut() else {
            return
        }

        guard let dim = try? PPDim(url: dir.ppDimURL()) else {
            return
        }

        //The + 2 (+2) is due to some data on disk written with a halo.
        p[cutAt] = Velocity2DPlaneOrtho<T>(cols: dim.gridY + 2, rows: dim.gridX + 2)

        for qVecURL in dir.getQvecFiles() {

            if let qvr = try? QVecRead<T>(binURL: qVecURL) {
                print("Loading Velocity2DPlaneOrthoMulti.loadPlane \(qVecURL.lastTwoPathComponents)")

                qvr.getVelocityFromDisk(addIntoPlane: &p[cutAt]!)

            } else {
                print("Cannot load \(qVecURL)")
            }
        }
    }

    mutating func loadManyPlanes(withDirs dirs: [URL]) {

        for dir in dirs {
            //TODO Check all dirs have same size of dim

            print("in load many planes", dir)
            loadPlane(withDir: dir)
        }
    }

    var cols: Int {
        return p.first!.value.cols
    }

    var rows: Int {
        return p.first!.value.rows
    }

    func writeVelocity(to: URL, at: Int, overwrite: Bool = false) {
        p[at]!.writeVelocity(to: to, overwrite: overwrite)

    }
}

struct Velocity2DPlaneOrthoMultiXY<T: BinaryFloatingPoint>: Velocity2DPlaneOrthoMulti {

    var p = [Int: Velocity2DPlaneOrtho<T>]()

    subscript(i: Int, j: Int, k: Int) -> Velocity<T> {
        get {
            return p[k]![i, j]
        }
        set(newValue) {
            p[k]![i, j] = newValue
        }
    }

    func calcVorticity(at k: Int) -> Vorticity2D<T>? {

        guard p[k + 1] != nil else {
            print("k \(k + 1) was not loaded")
            return nil
        }
        guard p[k - 1] != nil else {
            print("k \(k - 1) was not loaded")
            return nil
        }

        var vort = Vorticity2D<T>(cols: cols, rows: rows)

        for i in 1..<cols - 1 {
            for j in 1..<rows - 1 {

                //              let uxy = 0.5 * (p[k  ]![i+1, j  ].ux - p[k  ]![i-1, j  ].ux)
                let uxy = T(0.5) * (p[k  ]![i, j+1].ux - p[k  ]![i, j-1].ux)
                let uxz = T(0.5) * (p[k+1]![i, j  ].ux - p[k-1]![i, j  ].ux)

                let uyx = T(0.5) * (p[k  ]![i+1, j  ].uy - p[k  ]![i-1, j  ].uy)
                //              let uyy = 0.5 * (p[k  ]![i  , j+1].uy - p[k  ]![i  , j-1].uy)
                let uyz = T(0.5) * (p[k+1]![i, j  ].uy - p[k-1]![i, j  ].uy)

                let uzx = T(0.5) * (p[k  ]![i+1, j  ].uz - p[k  ]![i-1, j  ].uz)
                let uzy = T(0.5) * (p[k  ]![i, j+1].uz - p[k  ]![i, j-1].uz)
                //              let uzz = 0.5 * (p[k+1]![i  , j  ].uz - p[k-1]![i  , j  ].uz)

                let uyz_uzy = uyz - uzy
                let uzx_uxz = uzx - uxz
                let uxy_uyx = uxy - uyx

                vort[i, j] = T(log(Double(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)))
            }
        }

        return vort
    }
}

struct Velocity2DPlaneOrthoMultiXZ<T: BinaryFloatingPoint>: Velocity2DPlaneOrthoMulti {

    var p = [Int: Velocity2DPlaneOrtho<T>]()

    subscript(i: Int, j: Int, k: Int) -> Velocity<T> {
        get {
            return p[j]![i, k]
        }
        set(newValue) {
            p[j]![i, k] = newValue
        }
    }

    func calcVorticity(at j: Int) -> Vorticity2D<T>? {

        guard p[j + 1] != nil  else {
            print("j \(j + 1) was not loaded")
            return nil
        }
        guard p[j - 1] != nil  else {
            print("j \(j - 1) was not loaded")
            return nil
        }

        var vort = Vorticity2D<T>(cols: cols, rows: rows)

        for i in 1..<cols - 1 {
            for k in 1..<rows - 1 {

                //                      let uxy = 0.5 * (p[j  ]![i+1, k  ].ux - p[j  ]![i-1, k  ].ux)
                let uxy = T(0.5) * (p[j+1]![i, k  ].ux - p[j-1]![i, k  ].ux)
                let uxz = T(0.5) * (p[j  ]![i, k+1].ux - p[j  ]![i, k-1].ux)

                let uyx = T(0.5) * (p[j  ]![i+1, k  ].uy - p[j  ]![i-1, k  ].uy)
                //                      let uyy = 0.5 * (p[j+1]![i  , k  ].uy - p[j-1]![i  , k  ].uy)
                let uyz = T(0.5) * (p[j  ]![i, k+1].uy - p[j  ]![i, k-1].uy)

                let uzx = T(0.5) * (p[j  ]![i+1, k  ].uz - p[j  ]![i-1, k  ].uz)
                let uzy = T(0.5) * (p[j+1]![i, k  ].uz - p[j-1]![i, k  ].uz)
                //                      let uzz = 0.5 * (p[j  ]![i  , k+1].uz - p[j  ]![i  , k-1].uz)

                let uyz_uzy = uyz - uzy
                let uzx_uxz = uzx - uxz
                let uxy_uyx = uxy - uyx

                vort[i, k] = T(log(Double(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)))

            }

        }

        return vort
    }

}

struct Velocity2DPlaneOrthoMultiYZ<T: BinaryFloatingPoint>: Velocity2DPlaneOrthoMulti {

    var p = [Int: Velocity2DPlaneOrtho<T>]()

    subscript(i: Int, j: Int, k: Int) -> Velocity<T> {
        get {
            return p[i]![j, k]
        }
        set(newValue) {
            p[i]![j, k] = newValue
        }
    }

    func calcVorticity(at i: Int) -> Vorticity2D<T>? {

        guard p[i + 1] != nil  else {
            print("i \(i + 1) was not loaded")
            return nil
        }
        guard p[i - 1] != nil  else {
            print("i \(i - 1) was not loaded")
            return nil
        }

        var vort = Vorticity2D<T>(cols: cols, rows: rows)

        for j in 1..<cols - 1 {
            for k in 1..<rows - 1 {

                //                  let uxy = 0.5 * (p[i+1]![j  , k  ].ux - p[i-1]![j  , k  ].ux)
                let uxy = T(0.5) * (p[i  ]![j, k+1].ux - p[i  ]![j, k-1].ux)
                let uxz = T(0.5) * (p[i  ]![j+1, k  ].ux - p[i  ]![j-1, k  ].ux)

                let uyx = T(0.5) * (p[i+1]![j, k  ].uy - p[i-1]![j, k  ].uy)
                //                  let uyy = 0.5 * (p[i  ]![j  , k+1].uy - p[i  ]![j  , k-1].uy)
                let uyz = T(0.5) * (p[i  ]![j+1, k  ].uy - p[i  ]![j-1, k  ].uy)

                let uzx = T(0.5) * (p[i+1]![j, k  ].uz - p[i-1]![j, k  ].uz)
                let uzy = T(0.5) * (p[i  ]![j, k+1].uz - p[i  ]![j, k-1].uz)
                //                  let uzz = 0.5 * (p[i  ]![j+1, k  ].uz - p[i  ]![j-1, k  ].uz)

                let uyz_uzy = uyz - uzy
                let uzx_uxz = uzx - uxz
                let uxy_uyx = uxy - uyx

                vort[j, k] = T(log(Double(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)))
            }

        }

        return vort
    }

}
