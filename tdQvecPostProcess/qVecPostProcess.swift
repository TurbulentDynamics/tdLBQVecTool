//
//  mQVecPostProcess.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation



class qVecPostProcess {
    let velocity: Bool
    let vorticity: Bool
    let dirs: [URL]


    init(dirs: [URL], velocity: Bool, vorticity: Bool){
        self.velocity = velocity
        self.vorticity = vorticity
        self.dirs = dirs
        //        self.dirs = self.analyse(dirs: dirs)
    }

    func analyse() -> [URL] {
        //TODO
        //Break into steps,
        //then break into types,
        //then into position groups.

        var xy = [URL]()
        for d in dirs {
            if d.dirType(is: .XYplane){

                //TODO: Load consecutive dirs.  Pass consecutive dirs into MultiOrthoVelocity2DPlanesXZ
                xy.append(d)
            }
        }

        return xy
    }


    func process(){

        let xy = analyse()

        let dim = xy[0].getPPDim()!
        var p = MultiOrthoVelocity2DPlanesXY(x:dim.gridX, y:dim.gridY, depth: xy.count)
        load(p: &p, dirs:xy)
        print(p.p.keys)
        calcVorticityAndWrite(p: &p, writeTo: xy[1])

        writeVelocity(p: &p, at: 20, writeTo: xy[0])
        writeVelocity(p: &p, at: 21, writeTo: xy[1])
        writeVelocity(p: &p, at: 22, writeTo: xy[2])

    }



    func load(p:inout MultiOrthoVelocity2DPlanesXY, dirs: [URL]) {
        p.dirs = dirs
        for dir in dirs {
            let cutAt = dir.cut()!
            do {
                for qVec in try dir.getQvecFiles(){

                    print(qVec)
                    let disk = try diskSparseBuffer(binURL: qVec)

                    p.addPlane(atK: cutAt)

                    disk.getVelocityFromDisk(velocity: &p.p[cutAt]!)
                }
            } catch {
                print("binFile error: \(dir)")
            }
        }
    }



    func formatWriteFile(_ dir: URL, withSuffix: String) -> URL {

        let fileName = dir.lastPathComponent + withSuffix
        return dir.appendingPathComponent(fileName)
    }



    func calcVorticityAndWrite(p: inout MultiOrthoVelocity2DPlanesXY, writeTo: URL, withSuffix fileName: String = ".vort.bin", withBorder border: Int = 2){


        var vort = Array(repeating: Array(repeating: Float32(0.0), count: p.cols), count: p.rows)

        print(p.iStart, p.iEnd, p.jStart, p.jEnd, p.kStart, p.kEnd, p.kStart + 1, p.kEnd - 1)
        for i in p.iStart + 1..<p.iEnd - 1 {
            for j in p.jStart + 1..<p.jEnd - 1 {
                for k in p.kStart + 1..<p.kEnd - 1 {

                    //                    let uxx = 0.5 * (p[i+1, j,   k  ].ux - p[i-1, j,   k  ].ux)
                    let uxy = 0.5 * (p[i,   j+1, k  ].ux - p[i,   j-1, k  ].ux)
                    let uxz = 0.5 * (p[i,   j,   k+1].ux - p[i,   j,   k-1].ux)

                    let uyx = 0.5 * (p[i+1, j,   k  ].uy - p[i-1, j,   k  ].uy)
                    //                    let uyy = 0.5 * (p[i,   j+1, k  ].uy - p[i,   j-1, k  ].uy)
                    let uyz = 0.5 * (p[i,   j,   k+1].uy - p[i,   j,   k-1].uy)

                    let uzx = 0.5 * (p[i+1, j,   k  ].uz - p[i-1, j  , k  ].uz)
                    let uzy = 0.5 * (p[i,   j+1, k  ].uz - p[i,   j-1, k  ].uz)
                    //                    let uzz = 0.5 * (p[i,   j,   k+1].uz - p[i,   j,   k-1].uz)

                    let uyz_uzy = uyz - uzy
                    let uzx_uxz = uzx - uxz
                    let uxy_uyx = uxy - uyx

                    vort[i][j] = log(uyz_uzy * uyz_uzy + uzx_uxz * uzx_uxz + uxy_uyx * uxy_uyx)

                }}}


        var writeBuffer = Array(repeating: Float32(), count: ((p.cols - border * 2) * (p.rows - border * 2)))

        for col in border..<p.cols - border {
            for row in border..<p.rows - border {
                writeBuffer[ (col - border) * (p.cols - border * 2) + (row - border) ] = vort[col][row]
            }
        }


        //TODO Eventually need to pass, height and width to file, or json or something.  Maybe use PPjson?

        let url = formatWriteFile(writeTo, withSuffix: fileName)
        print(url)
        let wData = Data(bytes: &writeBuffer, count: writeBuffer.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)

    }






    func writeVelocity(p: inout MultiOrthoVelocity2DPlanesXY, at: Int, writeTo: URL, withSuffix fileName: String = ".velocity", withBorder border: Int = 1){

        var writeBufferRHO = Array(repeating: Float32(), count: ((p.cols - border * 2) * (p.rows - border * 2)))
        var writeBufferUX = Array(repeating: Float32(), count: ((p.cols - border * 2) * (p.rows - border * 2)))
        var writeBufferUY = Array(repeating: Float32(), count: ((p.cols - border * 2) * (p.rows - border * 2)))
        var writeBufferUZ = Array(repeating: Float32(), count: ((p.cols - border * 2) * (p.rows - border * 2)))

        for col in border..<p.cols - border {
            for row in border..<p.rows - border {
                writeBufferRHO[(col - border) * (p.cols - border * 2) + (row - border) ] = p[col, row, at].rho
                writeBufferUX[ (col - border) * (p.cols - border * 2) + (row - border) ] = p[col, row, at].ux
                writeBufferUY[ (col - border) * (p.cols - border * 2) + (row - border) ] = p[col, row, at].uy
                writeBufferUZ[ (col - border) * (p.cols - border * 2) + (row - border) ] = p[col, row, at].uz
            }
        }


        //TODO Eventually need to pass, height and width to file, or json or something.  Maybe use PPjson?


        var url = formatWriteFile(writeTo, withSuffix: fileName + ".rho.bin")
        var wData = Data(bytes: &writeBufferRHO, count: writeBufferUX.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)


        url = formatWriteFile(writeTo, withSuffix: fileName + ".ux.bin")
        wData = Data(bytes: &writeBufferUX, count: writeBufferUX.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)

        url = formatWriteFile(writeTo, withSuffix: fileName + ".uy.bin")
        wData = Data(bytes: &writeBufferUY, count: writeBufferUX.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)

        url = formatWriteFile(writeTo, withSuffix: fileName + ".uz.bin")
        wData = Data(bytes: &writeBufferUZ, count: writeBufferUX.count * MemoryLayout<Float32>.stride)
        try! wData.write(to: url)





    }


}




