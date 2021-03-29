//
//  Vorticity2D.swift
//
//
//  Created by Niall Ó Broin on 08/07/2020.
//

import Foundation
import tdLBOutput
import SwiftImage


struct Vorticity2D<T: BinaryFloatingPoint> {

    var vort: [[T]]

    var min: T = 0
    var max: T = 0
    
    init(cols: Int, rows: Int) {
        self.vort = Array(repeating: [T](repeating: 0, count: cols), count: rows)
    }

    subscript(c: Int, r: Int) -> T {
        get {
            return vort[c][r]
        }
        set(newValue) {
            if newValue != 0.0 {
            if newValue.isFinite {
                
                
                if newValue < min {min = newValue}
                if newValue > max {max = newValue}

                vort[c][r] = newValue
                
            }
            
        }
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
        
        
        writeGrayscaleImage(to: dir)
        
    }

    
    func writeGrayscaleImage(to dir: PlotDir, withBorder border: Int = 2){

        let steps:T = 256
        let step = (max - min) / (steps - 1)
        
        
        var image = Image<RGB<UInt8>>(width: cols*2, height: rows*2, pixel: .white)

        
        for col in border..<cols - border {
            for row in border..<rows - border {
                
                
                let val = UInt8((vort[col][row]) / step * -1)
                image[col*2, row*2] = RGB(red:val, green:val, blue:val)
                image[col*2, row*2+1] = RGB(red:val, green:val, blue:val)
                image[col*2+1, row*2] = RGB(red:val, green:val, blue:val)
                image[col*2+1, row*2+1] = RGB(red:val, green:val, blue:val)

            }
        }
        
        
        var fileName:URL = dir.vorticityURL()
        fileName.appendPathExtension("png")
        do{
            try image.write(to: fileName, atomically: true, format: .png)
        } catch {
            
        }


        }


}
