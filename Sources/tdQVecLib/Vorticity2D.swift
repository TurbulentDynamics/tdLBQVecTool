//
//  File.swift
//
//
//  Created by Niall Ó Broin on 08/07/2020.
//

import Foundation
import tdLBApi

struct Vorticity2D<T: BinaryFloatingPoint> {

    var vort: [[T]]

    init(cols: Int, rows: Int) {
        self.vort = Array(repeating: [T](repeating: 0, count: cols), count: rows)
    }

    subscript(c: Int, r: Int) -> T {
        get {
            return vort[c][r]
        }
        set(newValue) {
            vort[c][r] = newValue
        }
    }
    var cols: Int {
        return vort[0].count
    }

    var rows: Int {
        return vort.count
    }

    func writeVorticity(to dir: PlotDir, overwrite: Bool = false, withBorder border: Int = 2) {

        var writeBuffer = Data()

        for col in border..<cols - border {
            for row in border..<rows - border {

                writeBuffer.append(withUnsafeBytes(of: vort[col][row]) { Data($0) })
            }
        }

        do {
            if !(overwrite == false && dir.vorticityURL().exists()) {
                try writeBuffer.write(to: dir.vorticityURL())
            }
        } catch {
            print("Cannot write to file \(dir.vorticityURL().path)")
        }
    }

}


