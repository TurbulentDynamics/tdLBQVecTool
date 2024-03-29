//
//  mQVecPostProcess.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
//import simd

/// Grid coordiates and every neighbouring ortho (face) position
enum FacesIJK: CaseIterable {
    case im1
    case ip1
    case jm1
    case jp1
    case km1
    case kp1
}

/// Grid Coordinates for a Vertical Angled slice through the grid [see](docs/Yrotation.png)
enum FacesIK: CaseIterable {
    case ik0
    case im1
    case ip1
    case km1
    case kp1
}

/// The Angled Plane is represented either by 2D indexing, or 3D indexing, and can be rotated around any axes.
/// - note: Only the Vertical axis, `J` is implemented
struct Velocity2DPlaneAngled_AxisOfRotationJ<T: BinaryFloatingPoint> {

    var p = [FacesIK: Velocity2DPlaneOrtho<T>]()

    var cols: Int {
        return p.first!.value.cols
    }

    var rows: Int {
        if let firstElem = p.first {
            return p[firstElem.key]!.rows
        } else {
            return 0
        }
    }

    subscript(face: FacesIK, col: Int, row: Int) -> Velocity<T> {
        get {
            return p[face]![col, row]
        }
        set(newValue) {
            p[face]![col, row] = newValue
        }
    }

    func load(dir: URL) {

        //        for offset in dir.offsets() {
        //
        //            p[offset] = OrthoVelocity2DPlane(cols:cols, rows:rows)
        //
        //
        //
        //            p.addPlane(face: facesIK.im1)
        //            p.addPlane(face: facesIK.ip1)
        //            p.addPlane(face: facesIK.km1)
        //            p.addPlane(face: facesIK.kp1)
        //
        //
        //            do {
        //                for qVec in try dir.getQvecFiles() {
        //
        //                    let disk = try diskSparseBuffer(binURL: qVec)
        //
        //                    disk.getVelocityFromDisk(addIntoPlane: &p[.im1]!)
        //                }
        //
        //            } catch {
        //                print("binFile error: \(dir)")
        //            }
        //        }
    }

    func calcVorticity() -> [[T]] {

        // Offsets
        //      | kp1 |
        //| im1 | c,r | ip1 |
        //      | km1 |

        //OLD C CODE

        //inline void calc_ROTATIONAL_vorticity(tNi c, tNi r, tNi h, tQvec
        //**ux, tQvec **uy, tQvec **uz, tQvec *uxyz_log_vort, tQvec &uxx, tQvec &uxy, tQvec &uxz,
        //tQvec &uyx, tQvec &uyy, tQvec &uyz, tQvec &uzx, tQvec &uzy, tQvec &uzz) {
        //
        //
        ////col is i
        ////    row is z or y depending
        //
        //
        ////    dir[0] = load_dir; root[0] = "Qvec";
        ////
        ////    dir[1] = load_dir; root[1] = "Qvec.im1";
        ////    dir[2] = load_dir; root[2] = "Qvec.ip1";
        ////
        ////    dir[3] = load_dir; root[3] = "Qvec.km1";
        ////    dir[4] = load_dir; root[4] = "Qvec.kp1";
        //
        //
        //
        //    uxx = 0.5*(ux[2][twoD_colrow(c,   r  , h)] - ux[1][twoD_colrow(c,   r  , h)]);
        //    uxy = 0.5*(ux[0][twoD_colrow(c,   r+1, h)] - ux[0][twoD_colrow(c,   r-1, h)]);
        //    uxz = 0.5*(ux[4][twoD_colrow(c,   r  , h)] - ux[3][twoD_colrow(c  , r  , h)]);
        //
        //    uyx = 0.5*(uy[2][twoD_colrow(c,   r  , h)] - uy[1][twoD_colrow(c,   r  , h)]);
        //    uyy = 0.5*(uy[0][twoD_colrow(c,   r+1, h)] - uy[0][twoD_colrow(c,   r-1, h)]);
        //    uyz = 0.5*(uy[4][twoD_colrow(c  , r  , h)] - uy[3][twoD_colrow(c  , r  , h)]);
        //
        //
        //    uzx = 0.5*(uz[2][twoD_colrow(c,   r  , h)] - uz[1][twoD_colrow(c,   r  , h)]);
        //    uzy = 0.5*(uz[0][twoD_colrow(c,   r+1, h)] - uz[0][twoD_colrow(c,   r-1, h)]);
        //    uzz = 0.5*(uz[4][twoD_colrow(c  , r  , h)] - uz[3][twoD_colrow(c  , r  , h)]);
        //
        //
        //}
        //

        var vort = Array(repeating: Array(repeating: T.zero, count: cols), count: rows)

        for c in 1..<cols - 1 {
            for r in 1..<rows - 1 {

                //                let uxx = 0.5 * (p[.ip1]![r+1, c].ux - p[.im1]![r-1, c].ux)
                let uxy = 0.5 * (p[.ik0]![r, c].ux - p[.ik0]![r, c].ux)
                let uxz = 0.5 * (p[.kp1]![r, c].ux - p[.km1]![r, c].ux)

                let uyx = 0.5 * (p[.ip1]![r, c].uy - p[.im1]![r, c].uy)
                //                let uyy = 0.5 * (p[.ik0]![r+1, c].uy - p[.ik0]![r-1, c].uy)
                let uyz = 0.5 * (p[.kp1]![r, c].uy - p[.km1]![r, c].uy)

                let uzx = 0.5 * (p[.ip1]![r, c].uz - p[.im1]![r, c].uz)
                let uzy = 0.5 * (p[.ik0]![r, c].uz - p[.ik0]![r, c].uz)
                //                let uzz = 0.5 * (p[.kp1]![r+1, c].uz - p[.km1]![r-1, c].uz)

                let uyzuzy = uyz - uzy
                let uzxuxz = uzx - uxz
                let uxyuyx = uxy - uyx

                vort[c][r] = T(log(Double(uyzuzy * uyzuzy + uzxuxz * uzxuxz + uxyuyx * uxyuyx)))

            }
        }

        return vort
    }

}
