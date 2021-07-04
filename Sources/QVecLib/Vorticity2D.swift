//
//  Vorticity2D.swift
//
//
//  Created by Niall Ó Broin on 08/07/2020.
//

import Foundation
import SwiftImage
import tdLB

struct Vorticity2D<T: BinaryFloatingPoint> {

  var vort: [T]

  var cols: Int
  var rows: Int

  var min: T = 0
  var max: T = 0

  init(cols: Int, rows: Int) {
    self.cols = cols
    self.rows = rows
    self.vort = Array(repeating: 0.0, count: cols * rows)
  }

  @inline(__always) func indexPos(col: Int, row: Int) -> Int {
    return row * self.rows + col
  }

  subscript(c: Int, r: Int) -> T {
    get {
      //precondition
      return vort[r * self.rows + c]
    }
    set(newValue) {
      if newValue.isFinite {

        if newValue < min { min = newValue }
        if newValue > max { max = newValue }

        vort[indexPos(col: c, row: r)] = newValue
      }
    }
  }

  func writeVorticity(to file: URL, overwrite: Bool = false, withBorder border: Int = 2) {

    var writeBuffer = Data()

    for col in border..<cols - border {
      for row in border..<rows - border {

        writeBuffer.append(withUnsafeBytes(of: vort[indexPos(col: col, row: row)]) { Data($0) })
      }
    }

    do {
      try writeBuffer.write(to: file)

    } catch {
      print("Cannot write to file \(file.path)")
    }

    writeGrayscaleImage(to: file)

  }

  func writeGrayscaleImage(to file: URL, withBorder border: Int = 2) {

    let steps: T = 256
    let step = (max - min) / (steps - 1)

    var image = Image<RGB<UInt8>>(width: cols * 2, height: rows * 2, pixel: .white)

    for col in border..<cols - border {
      for row in border..<rows - border {

        let val = UInt8((vort[indexPos(col: col, row: row)]) / step * -1)

        image[col * 2, row * 2] = RGB(red: val, green: val, blue: val)
        image[col * 2, row * 2 + 1] = RGB(red: val, green: val, blue: val)
        image[col * 2 + 1, row * 2] = RGB(red: val, green: val, blue: val)
        image[col * 2 + 1, row * 2 + 1] = RGB(red: val, green: val, blue: val)

      }
    }

    let pngFilename = file.appendingPathExtension("png")
    do {
      try image.write(to: pngFilename, atomically: true, format: .png)
    } catch {

    }

  }

}
