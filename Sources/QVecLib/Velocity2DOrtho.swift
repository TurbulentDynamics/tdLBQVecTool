//
//  Velocity2DOrtho.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation
import tdLB

//import simd

/// A dense 2D plane of Velocity types, these are square or orthogonal to the axes (see also `Velocity2DPlaneAngledAxisOfRotationJ`
///
struct Velocity2DPlaneOrtho<T: BinaryFloatingPoint> {

  var u: [Velocity<T>]
  var cols: Int
  var rows: Int

  /// Initialise with size cols and rows.
  /// - note: column is the first index, maintaining coordinate axes shown TODO:link  elsewhere
  init(cols: Int, rows: Int) {
    self.cols = cols
    self.rows = rows
    self.u = Array(repeating: Velocity<T>(), count: cols * rows)
  }

  subscript(_ c: Int, _ r: Int) -> Velocity<T> {
    get {
      return u[r * rows + c]
    }
    set(newValue) {
      u[r * rows + c] = newValue
    }
  }

  mutating func loadBinFile(_ fileName: URL) {

    //Initialising the QVecBinFile loads the binary from disk into Data
    if let qvr = try? QVecBinFileRead<T>(binURL: fileName) {
      let plotDir = fileName.deletingLastPathComponent().path

      print("Loading Velocity2DPlaneOrthoMulti.loadPlane \(plotDir)/\(fileName.lastPathComponent)")

      qvr.loadVelocityFromData(addIntoPlane: &self)

    } else {
      print("Cannot load \(fileName)")
    }
  }

  /// Writes the 2D Velocity Plane to file at fileName
  ///
  /// - parameters
  ///   - fleName The location of file
  func writeRho(to fileName: URL, withBorder border: Int = 1) {

    var writeBuffer = Data()
    for col in border..<cols - border {
      for row in border..<rows - border {
        writeBuffer.append(withUnsafeBytes(of: self[col, row].rho) { Data($0) })
      }
    }

    do {
      try writeBuffer.write(to: fileName)
    } catch {
      print("Cannot write velocity files to \(fileName.path)")
    }
  }

  /// Writes the 2D Velocity Plane to file at fileName
  ///
  /// - parameters
  ///   - fleName The location of file
  func writeUX(to fileName: URL, withBorder border: Int = 1) {

    var writeBuffer = Data()
    for col in border..<cols - border {
      for row in border..<rows - border {
        writeBuffer.append(withUnsafeBytes(of: self[col, row].ux) { Data($0) })
      }
    }

    do {
      try writeBuffer.write(to: fileName)
    } catch {
      print("Cannot write velocity files to \(fileName.path)")
    }
  }

  /// Writes the 2D Velocity Plane to file at fileName
  ///
  /// - parameters
  ///   - fleName The location of file
  func writeUY(to fileName: URL, withBorder border: Int = 1) {

    var writeBuffer = Data()
    for col in border..<cols - border {
      for row in border..<rows - border {
        writeBuffer.append(withUnsafeBytes(of: self[col, row].uy) { Data($0) })
      }
    }

    do {
      try writeBuffer.write(to: fileName)
    } catch {
      print("Cannot write velocity files to \(fileName.path)")
    }
  }

  /// Writes the 2D Velocity Plane to file at fileName
  ///
  /// - parameters
  ///   - fleName The location of file
  func writeUZ(to fileName: URL, withBorder border: Int = 1) {

    var writeBuffer = Data()
    for col in border..<cols - border {
      for row in border..<rows - border {
        writeBuffer.append(withUnsafeBytes(of: self[col, row].uz) { Data($0) })
      }
    }

    do {
      try writeBuffer.write(to: fileName)
    } catch {
      print("Cannot write velocity files to \(fileName.path)")
    }
  }

}  //end of struct

protocol Velocity2DPlaneOrthoMulti {
  associatedtype T: BinaryFloatingPoint

  var p: [Int: Velocity2DPlaneOrtho<T>] { get set }

  subscript(i: Int, j: Int, k: Int) -> Velocity<T> { get set }

}

extension Velocity2DPlaneOrthoMulti {
  //
  //    func getPlane(at: Int) -> Velocity2DPlaneOrtho<T> {
  //        precondition(p.keys.contains(at))
  //        return p[at]!
  //    }
  //
  var cols: Int {
    return p.first!.value.cols
  }

  var rows: Int {
    return p.first!.value.rows
  }

  mutating func loadBinFiles(files: [URL], cols: Int, rows: Int, cutAt: Int) {

    var v = Velocity2DPlaneOrtho<T>(cols: cols + 2, rows: rows + 2)

    for f in files {
      v.loadBinFile(f)
    }

    p[cutAt] = v
  }

  func calcVorticity(i: Int, j: Int, k: Int) -> T {

    //        let uxy = T(0.5) * (self[i+1, j  , k  ].ux - p[i-1, j,   k  ].ux)
    let uxy = T(0.5) * (self[i, j, k + 1].ux - self[i, j, k - 1].ux)
    let uxz = T(0.5) * (self[i, j + 1, k].ux - self[i, j - 1, k].ux)
    let uyx = T(0.5) * (self[i + 1, j, k].uy - self[i - 1, j, k].uy)
    //        let uyy = T(0.5) * (self[i,   j  , k+1].uy - self[i,   j,   k-1].uy)
    let uyz = T(0.5) * (self[i, j + 1, k].uy - self[i, j - 1, k].uy)
    let uzx = T(0.5) * (self[i + 1, j, k].uz - self[i - 1, j, k].uz)
    let uzy = T(0.5) * (self[i, j, k + 1].uz - self[i, j, k - 1].uz)
    //        let uzz = T(0.5) * (self[i,   j+1, k  ].uz - self[i,   j-1, k  ].uz)

    let uyzuzy = uyz - uzy
    let uzxuxz = uzx - uxz
    let uxyuyx = uxy - uyx

    return T(log(Double(uyzuzy * uyzuzy + uzxuxz * uzxuxz + uxyuyx * uxyuyx)))
  }

  //    mutating func loadPlane(withDir dir: URL, withDeltas: Array<Int>) {
  //
  //        loadPlane(withDir: fileName)
  //
  //        for delta in withDeltas {
  //
  //            if let deltaDir = fileName.formatCutDelta(delta: delta) {
  //                loadPlane(withDir: deltaDir)
  //            } else {
  //                print("Loading a filename \(dir) with cut delta of \(delta).")
  //            }
  //        }
  //    }
  //
  //
  //    mutating func loadPlane(withDir dir: URL) {
  //
  //        guard let cutAt = dir.cut() else {
  //            return
  //        }
  //
  //        //        guard let dim = try? PlotDirMeta(url: dir.plotDirMetaURL) else {
  //        //            print("Cannot find meta file \(dir.plotDirMetaURL)")
  //        //            return
  //        //        }
  //
  //        var gridX: Int = 0
  //        var gridY: Int = 0
  //        for binJsonURL in dir.getQvecJsonFiles() {
  //            let dim = try QVecBinMeta(binJsonURL)
  //            //            if gridX < dim.fileHeight {
  //            //                gridX = dim.fileHeight
  //            //            }
  //            //            if gridY < dim.fileWidth {
  //            //                gridY = dim.fileWidth
  //            //            }
  //        }
  //
  //
  //        //The + 2 (+2) is due to some data on disk written with a halo.
  //        p[cutAt] = Velocity2DPlaneOrtho<T>(cols: gridY + 2, rows: gridX + 2)
  //
  //
  //
  //        for qVecURL in dir.getQvecFiles() {
  //
  //            if let qvr = try? QVecBinFileRead<T>(binURL: qVecURL) {
  //                print("Loading Velocity2DPlaneOrthoMulti.loadPlane \(qVecURL.lastTwoPathComponents)")
  //
  //                qvr.loadVelocityFromData(addIntoPlane: &p[cutAt]!)
  //
  //            } else {
  //                print("Cannot load \(qVecURL)")
  //            }
  //        }
  //    }
  //
  //    mutating func loadManyPlanes(withDirs dirs: [URL]) {
  //
  //        for dir in dirs {
  //            //TODO Check all dirs have same size of dim
  //
  //            print("in load many planes", dir)
  //            loadPlane(withDir: dir)
  //        }
  //    }
  //
  //
  //    func writeVelocities(to: URL, at: Int, overwrite: Bool = false) {
  //
  //        if p.keys.contains(at) {
  //
  //            p[at]!.writeVelocities(to: to, overwrite: overwrite)
  //
  //        } else {
  //            print("Cut \(at) not loaded so cannot calculate Velocity in \(to.path)")
  //        }
  //
  //
  //    }
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

    subscript(k: Int) -> Velocity2DPlaneOrtho<T> {
      get {
        return p[k]!
      }
//      set(newValue) {
//        p[k] = newValue
//      }
    }

  func calcXYVorticity(at k: Int) -> Vorticity2D<T>? {

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

        vort[i, j] = calcVorticity(i: i, j: j, k: k)
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

  func calcXZVorticity(at j: Int) -> Vorticity2D<T>? {

    guard p[j + 1] != nil else {
      print("j \(j + 1) was not loaded")
      return nil
    }
    guard p[j - 1] != nil else {
      print("j \(j - 1) was not loaded")
      return nil
    }

    var vort = Vorticity2D<T>(cols: cols, rows: rows)

    for i in 1..<cols - 1 {
      for k in 1..<rows - 1 {

        vort[i, k] = calcVorticity(i: i, j: j, k: k)
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

  func calcYZVorticity(at i: Int) -> Vorticity2D<T>? {

    guard p[i + 1] != nil else {
      print("i \(i + 1) was not loaded")
      return nil
    }
    guard p[i - 1] != nil else {
      print("i \(i - 1) was not loaded")
      return nil
    }

    var vort = Vorticity2D<T>(cols: cols, rows: rows)

    for j in 1..<cols - 1 {
      for k in 1..<rows - 1 {

        vort[i, k] = calcVorticity(i: i, j: j, k: k)
      }

    }

    return vort
  }

}
