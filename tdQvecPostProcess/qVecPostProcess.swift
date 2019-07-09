//
//  mQVecPostProcess.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation


enum loadError: Error {
    case NotYetDefined
}

struct Size {
    var x, y, z: Int
}

struct Pos {
    var i, j, k: Int
}

struct Velocity {
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
}

enum DirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
}









class QVecPostProcess {
    let dataDirURL: URL
    let dirURL: URL
    var size: Size
    var depth: Int

    var u: [[[Velocity]]]
    let dim: ppDim
    let disk: InputFilesV4
    let isType: DirType
    let buff: diskBuffer

    var vortXY: [[Float32]]
    var vortXZ: [[Float32]]
    var Q4diskBuffer = [[[Float32]]]()
    var F3diskBuffer = [[[Float32]]]()


    init(withDataDir: String, loadDir: String) throws {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.dataDirURL = home.appendingPathComponent(withDataDir)
        self.dirURL = home.appendingPathComponent(withDataDir).appendingPathComponent(loadDir)


        disk = try InputFilesV4(withDataDir: self.dirURL)
        isType = disk.getDirType(fromDir: loadDir)!

        let calcVort = true
        depth = 1
        if calcVort == true {depth = 3}
        if isType == .rotational {depth = 5}

        buff = try diskBuffer(withDataDir: withDataDir)


        dim = try ppDim(dir: self.dirURL)
        size = Size(x: dim.gridX, y: dim.gridY, z: dim.gridZ)

        switch isType {

        case .XYplane:
            size.z = depth
        case .XZplane:
            size.y = depth
        case .YZplane:
            size.x = depth
        case .rotational:
            throw loadError.NotYetDefined
        case .volume:
            throw loadError.NotYetDefined
        }

        print(size.x, size.y, size.z)
        u = Array(repeating: Array(repeating: Array(repeating: Velocity(), count: size.z), count: size.y), count: size.x)

        vortXY = Array(repeating: Array(repeating: Float(0.0), count: size.y), count: size.x)
        vortXZ = Array(repeating: Array(repeating: Float(0.0), count: size.z), count: size.x)


    }



    fileprivate func calcVort(i: Int, j: Int, k: Int) -> Float {

        //  uxx = 0.5 * (u[i+1][j  ][k  ].ux - u[i-1][j  ][k  ].ux)
        let uxy = 0.5 * (u[i  ][j+1][k  ].ux - u[i  ][j-1][k  ].ux)
        let uxz = 0.5 * (u[i  ][j  ][k+1].ux - u[i  ][j  ][k-1].ux)

        let uyx = 0.5 * (u[i+1][j  ][k  ].uy - u[i-1][j  ][k  ].uy)
        //  uyy = 0.5 * (u[i  ][j+1][k  ].uy - u[i  ][j-1][k  ].uy)
        let uyz = 0.5 * (u[i  ][j  ][k+1].uy - u[i  ][j  ][k-1].uy)

        let uzx = 0.5 * (u[i+1][j  ][k  ].uz - u[i-1][j  ][k  ].uz)
        let uzy = 0.5 * (u[i  ][j+1][k  ].uz - u[i  ][j-1][k  ].uz)
        //  uzz = 0.5 * (u[i  ][j  ][k+1].uz - u[i  ][j  ][k-1].uz)

        let uyz_uzy = uyz - uzy
        let uzx_uxz = uzx - uxz
        let uxy_uyx = uxy - uyx

        return log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)
    }


    func calcVortXY() {
        let ignoreCells = 1
        for i in ignoreCells..<size.x - ignoreCells {
            for j in ignoreCells..<size.y - ignoreCells {
                vortXY[i][j] = calcVort(i:i, j:j, k:1)
            }
        }
    }


    func calcVortXZ() {
        let ignoreCells = 1
        for i in ignoreCells..<size.x - ignoreCells {
            for k in ignoreCells..<size.z - ignoreCells {
                vortXZ[i][k] = calcVort(i:i, j:1, k:k)
            }
        }
    }



    fileprivate func loadSparseBuffer(dir: URL) throws {
        Q4diskBuffer = try buff.loadQVecFiles(fromDir: dir)
        F3diskBuffer = try buff.loadF3Files(fromDir: dir)
    }

    fileprivate func calcVelocity(_ Q4diskBuffer: [[[Float32]]], _ F3diskBuffer: [[[Float32]]], _ row: Int, _ col: Int) -> Velocity {

        var v = Velocity()
        v.rho = Q4diskBuffer[col][row][0]

        v.ux = (Q4diskBuffer[col][row][1] + 0.5 * F3diskBuffer[col][row][0]) / v.rho
        v.uy = (Q4diskBuffer[col][row][2] + 0.5 * F3diskBuffer[col][row][1]) / v.rho
        v.uz = (Q4diskBuffer[col][row][3] + 0.5 * F3diskBuffer[col][row][2]) / v.rho

        return v

    }

    func loadAndCalcVelocityXY() throws {
        try loadSparseBuffer(dir: dirURL)
        let atK = dim.cutAt
        for i in 0..<size.x {
            for j in 0..<size.y {
                u[i][j][atK] = calcVelocity(Q4diskBuffer, F3diskBuffer, i, j)
            }
        }
    }


    func loadAndCalcVelocityXZ() throws {
        try loadSparseBuffer(dir: dirURL)

//        let atJ = dim.cutAt

        for j in 0...2 {

        for i in 0..<size.x {
            for k in 0..<size.z {
                u[i][j][k] = calcVelocity(Q4diskBuffer, F3diskBuffer, i, k)
            }
        }
        }
    }




    func writeVortXY(fileName: String = "file.vort.bin", withBorder border: Int = 2){

        var writeBuffer = Array(repeating: Float32(), count: ((size.x - border * 2) * (size.y - border * 2)))

        for col in border..<size.x - border {
            for row in border..<size.y - border {

                writeBuffer[ (col - border) * (size.y - border * 2) + (row - border) ] = vortXY[col][row]
            }
        }



        let url = dataDirURL.appendingPathComponent(fileName)
        let wData = Data(bytes: &writeBuffer, count: writeBuffer.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)

    }

    func writeVortXZ(fileName: String = "file.vort.bin", withBorder border: Int = 1){

        var writeBuffer = Array(repeating: Float32(), count: ((size.x - border * 2) * (size.z - border * 2)))

        for col in border..<size.x - border {
            for row in border..<size.z - border {

                writeBuffer[ (col - border) * (size.z - border * 2) + (row - border) ] = vortXZ[col][row]
                print(col, row, vortXZ[col][row])
            }
        }


        let url = dirURL.appendingPathComponent(fileName)
        let wData = Data(bytes: &writeBuffer, count: writeBuffer.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)

        print(writeBuffer.count, url)

    }




}


