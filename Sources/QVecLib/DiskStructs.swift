//
//  File.swift
//
//
//  Created by Niall Ó Broin on 03/07/2020.
//

import Foundation
import tdLB

///Types used to read and write data to disk

/// This struct is used for Dense Data (no coord information) for both 2DPlanes and 3DGrids.
/// The meta information contains the information to differentation the two, and give sizes of the dimensions
///
public struct DiskDense<QVec: BinaryFloatingPoint> {
  let q: [QVec]

  init<InitQvec: BinaryFloatingPoint>(q: [InitQvec]) {
    self.q = q.map({ QVec($0) })
  }
}

/// This struct is used for Sparse 2DPlanes, i.e. with coord information
///
public struct DiskSparse2D<Coord: BinaryInteger, QVec: BinaryFloatingPoint> {
  let c, r: Coord
  let q: [QVec]

  init<InitCoord: BinaryInteger, InitQvec: BinaryFloatingPoint>(
    c: InitCoord, r: InitCoord, q: [InitQvec]
  ) {
    self.c = Coord(c)
    self.r = Coord(r)
    self.q = q.map({ QVec($0) })
  }

  var sizeCoord: Int {
    return MemoryLayout<Coord>.size
  }
  var sizeQVec: Int {
    return MemoryLayout<QVec>.size
  }

}

/// This struct is used for Sparse Data with 3D coord information
///
public struct DiskSparse3D<Coord: BinaryInteger, QVec: BinaryFloatingPoint> {
  let i, j, k: Coord
  let q: [QVec]

  init<InitCoord: BinaryInteger, InitQvec: BinaryFloatingPoint>(
    i: InitCoord, j: InitCoord, k: InitCoord, q: [InitQvec]
  ) {
    self.i = Coord(i)
    self.j = Coord(j)
    self.k = Coord(k)
    self.q = q.map({ QVec($0) })
  }

}

/// This struct is used for Sparse Data with both 2D and 3D coord information
///
public struct DiskSparse2DAnd3D<Coord: BinaryInteger, QVec: BinaryFloatingPoint> {
  let c, r: Coord
  let i, j, k: Coord
  let q: [QVec]

  init<InitCoord: BinaryInteger, InitQvec: BinaryFloatingPoint>(
    c: InitCoord, r: InitCoord, i: InitCoord, j: InitCoord, k: InitCoord, q: [InitQvec]
  ) {
    self.c = Coord(c)
    self.r = Coord(r)
    self.i = Coord(i)
    self.j = Coord(j)
    self.k = Coord(k)
    self.q = q.map({ QVec($0) })
  }

}
