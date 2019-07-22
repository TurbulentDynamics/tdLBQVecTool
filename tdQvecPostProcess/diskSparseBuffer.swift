
//  QVecDims.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation

import Logging
let logger = Logger(label: "com.turbulentDynamics.QVecPostProcess.loadBuffer")




//activityIndicator.startAnimating()
//DispatchQueue.global(qos: .userInitiated).async {
//    do {
//        try Disk.save(largeData, to: .documents, as: "Movies/spiderman.mp4")
//    } catch {
//        // ...
//    }
//    DispatchQueue.main.async {
//        activityIndicator.stopAnimating()
//        // ...
//    }
//}




struct tDiskBytesIndexNum {

    let colRowBytes = 2
    let gridBytes = 2
    let qBytes = 4

    var colRowNum: Int = 0
    var gridNum: Int = 0
    var qNum: Int = 0

    var colRowIndex: Int = 0
    var gridIndex: Int = 0
    var qIndex: Int = 0

    var structTotalBytes: Int



    init(structName: String) {


        switch structName {
        case "tDisk_colrow_Q3_V4":
            colRowNum = 2
            qNum = 3
            qIndex = colRowNum * colRowBytes

        case "tDisk_colrow_Q4_V4":
            colRowNum = 2
            qNum = 4
            qIndex = colRowNum * colRowBytes

        case "tDisk_grid_colrow_Q3_V4":
            colRowNum = 2
            gridNum = 3
            qNum = 3
            gridIndex = colRowNum * colRowBytes
            qIndex = gridIndex + gridNum * gridBytes

        case "tDisk_grid_colrow_Q4_V4":
            colRowNum = 2
            gridNum = 3
            qNum = 4
            gridIndex = colRowNum * colRowBytes
            qIndex = gridIndex + gridNum * gridBytes

        default:
            print("Hello")

        }

        structTotalBytes = qIndex + qNum * qBytes

    }

}

struct tDisk {
    var col: Int = -1
    var row: Int = -1
    var i: Int = -1
    var j: Int = -1
    var k: Int = -1
    var q = [Float32]()

    func calcPartialVelocity() -> Velocity {
        //Needs to include forcing data here also, however there is much less forcing
        //data, so it might be faster to finish the calc with sparse forcing data later
        //v.ux = (q[1] + 0.5 * forcing.x) / q[0]

        var v = Velocity()
        v.rho = q[0]

        v.ux = q[1] / v.rho
        v.uy = q[2] / v.rho
        v.uz = q[3] / v.rho
        return v
    }

}



extension Data {

    //Need an iterator
    func  getCell(){

    }
}


class diskSparseBuffer {
    //Useful references
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c
    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/
    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer

    let binURL: URL
    let data: Data

    let jsonBinURL: URL
    let dim: QVecDim
    let bytes: tDiskBytesIndexNum

    init(binURL: URL) throws {

        self.binURL = binURL

        let url:URL = binURL.deletingLastPathComponent()
        self.jsonBinURL = url.appendingPathComponent(binURL.lastPathComponent + ".json")


        self.dim = try QVecDim(jsonBinURL)
        self.bytes = tDiskBytesIndexNum(structName: dim.structName)

        self.data = try Data(contentsOf: binURL)
    }


    //    fileprivate func getItem(_ ptr: UnsafeRawBufferPointer, _ i: Int,
    //                             _ bytes: tDiskBytesIndexNum, _ hasColRowCoords: Bool, _ hasGridCoords: Bool) -> tDisk {
    //
    //        var item = tDisk()
    //
    //        if hasColRowCoords {
    //            item.col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: UInt16.self))
    //            item.row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: UInt16.self))
    //        }
    //
    //        if hasGridCoords {
    //            item.i = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
    //            item.j = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
    //            item.k = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
    //
    //        }
    //
    //        for q in 0..<bytes.qNum {
    //            item.q.append(ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: Float32.self))
    //        }
    //        return item
    //    }
    //
    //
    //    func getSparseFromDiskDEBUG() throws -> [tDisk] {
    //
    //        var items = [tDisk]()
    //
    //        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
    //            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {
    //
    //                let item = getItem(ptr, i, bytes, dim.hasColRowCoords, dim.hasGridCoords)
    //                items.append(item)
    //
    //            }
    //        }
    //        return items
    //    }



    func getSparseFromDisk() throws -> [tDisk] {

        var items = [tDisk]()

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var item = tDisk()

                if dim.hasColRowCoords {
                    item.col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: UInt16.self))
                    item.row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: UInt16.self))
                }

                if dim.hasGridCoords {
                    item.i = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    item.j = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    item.k = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                }

                for q in 0..<bytes.qNum {
                    item.q.append(ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: Float32.self))
                }
                items.append(item)
            }
        }
        return items
    }





    func getPlaneFromDisk(plane: inout [[[Float32]]]) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: UInt16.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: UInt16.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                }

                for q in 0..<bytes.qNum {

                    let s = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: Float32.self)

                    plane[col][row][q] = s
                }
            }
        }
    }

    
//    func readPartialFileIntoLargerVelocity3DMatrix(velocity: inout [[[Velocity]]]) {
//    func readPartialFileIntoLargerVelocity2DMatrix(velocity: inout [[Velocity]]) {
    func getVelocityFromDisk(velocity: inout OrthoVelocity2DPlane) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: UInt16.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: UInt16.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                }

                velocity[col, row].rho = ptr.load(fromByteOffset: i + bytes.qIndex + (0 * bytes.qBytes), as: Float32.self)
                velocity[col, row].ux = ptr.load(fromByteOffset: i + bytes.qIndex + (1 * bytes.qBytes), as: Float32.self)
                velocity[col, row].uy = ptr.load(fromByteOffset: i + bytes.qIndex + (2 * bytes.qBytes), as: Float32.self)
                velocity[col, row].uz = ptr.load(fromByteOffset: i + bytes.qIndex + (3 * bytes.qBytes), as: Float32.self)


                //Skip the rest of the q matrix
                for q in 4..<bytes.qNum {
                    let _ = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: Float32.self)
                }


            }
        }
    }


    func addForcingToPartialVelocity(velocity: inout [[Velocity]]) {

        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            for i in stride(from: 0, to: dim.binFileSizeInStructs * bytes.structTotalBytes, by: bytes.structTotalBytes) {

                var col = 0
                var row = 0

                if dim.hasColRowCoords {
                    col = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex, as: UInt16.self))
                    row = Int(ptr.load(fromByteOffset: i + bytes.colRowIndex + bytes.colRowBytes, as: UInt16.self))
                }

                if dim.hasGridCoords {
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                    _ = Int(ptr.load(fromByteOffset: i + bytes.gridIndex + bytes.gridBytes, as: UInt16.self))
                }


                let fx = ptr.load(fromByteOffset: i + bytes.qIndex + (0 * bytes.qBytes), as: Float32.self)
                let fy = ptr.load(fromByteOffset: i + bytes.qIndex + (1 * bytes.qBytes), as: Float32.self)
                let fz = ptr.load(fromByteOffset: i + bytes.qIndex + (2 * bytes.qBytes), as: Float32.self)

                for q in 3..<bytes.qNum {
                    let _ = ptr.load(fromByteOffset: i + bytes.qIndex + (q * bytes.qBytes), as: Float32.self)
                }


                //v.ux = (q[1] + 0.5 * forcing.x) / q[0]
                velocity[col][row].ux += fx / velocity[col][row].rho
                velocity[col][row].uy += fy / velocity[col][row].rho
                velocity[col][row].uz += fz / velocity[col][row].rho

            }
        }
    }







}
