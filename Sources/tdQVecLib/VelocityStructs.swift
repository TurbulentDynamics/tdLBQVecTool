//
//  mQVecPostProcess.swift
//  tdQVecTool
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

    func cols() -> Int {
        return p[0].count
    }

    func rows() -> Int {
        return p.count
    }


    subscript(c: Int, r: Int) -> Velocity {
        get {
            return p[c][r]
        }
        set(newValue) {
            p[c][r] = newValue
        }
    }





    func formatWriteFileName(writeTo dir: URL, withSuffix: String) -> URL {

        let fileName: String = dir.lastPathComponent + withSuffix
        var modURL: URL = dir.deletingLastPathComponent()
        modURL.appendPathComponent(fileName)
        return modURL
    }


    func writeVelocity(to fileName: URL, withBorder border: Int = 1){

        let height = cols() - border * 2
        let width = rows() - border * 2

        var writeBufferRHO = Array(repeating: Float32(), count: height * width)
        var writeBufferUX = Array(repeating: Float32(), count: height * width)
        var writeBufferUY = Array(repeating: Float32(), count: height * width)
        var writeBufferUZ = Array(repeating: Float32(), count: height * width)

        for col in border..<cols() - border {
            for row in border..<rows() - border {

                writeBufferRHO[(col - border) * height + (row - border) ] = p[col][row].rho
                writeBufferUX[ (col - border) * height + (row - border) ] = p[col][row].ux
                writeBufferUY[ (col - border) * height + (row - border) ] = p[col][row].uy
                writeBufferUZ[ (col - border) * height + (row - border) ] = p[col][row].uz

            }
        }


        //TODO Eventually need to pass, height and width to file, or json or something.  Maybe use PPjson?


        var wData = Data(bytes: &writeBufferRHO, count: writeBufferRHO.count * MemoryLayout<Float32>.stride)
        var url = formatWriteFileName(writeTo: fileName, withSuffix: ".rho.bin")
        try! wData.write(to: url)



        wData = Data(bytes: &writeBufferUX, count: writeBufferUX.count * MemoryLayout<Float32>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".ux.bin")
        try! wData.write(to: url)

        wData = Data(bytes: &writeBufferUY, count: writeBufferUY.count * MemoryLayout<Float32>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".uy.bin")
        try! wData.write(to: url)

        wData = Data(bytes: &writeBufferUZ, count: writeBufferUZ.count * MemoryLayout<Float32>.stride)
        url = formatWriteFileName(writeTo: fileName, withSuffix: ".uz.bin")
        try! wData.write(to: url)


//        print(url)



    }

}



struct Velocity3DGrid {

    var g: [[[Velocity]]]

    init(x: Int, y: Int, z: Int){
        self.g = Array(repeating: Array(repeating: Array(repeating: Velocity(), count: z + 2), count: y + 2), count: x + 2)
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









