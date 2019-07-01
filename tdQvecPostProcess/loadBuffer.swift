
//  QVecDims.swift
//  TDQVecLib
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



class loadBuffer {
    //Useful references
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c
    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/
    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer

    let rootDataDir: URL

    init(withDataDirURL: URL) {
        self.rootDataDir = withDataDirURL
    }





    func load(fromDir dir: String, file: String) throws -> [[[Float32]]] {

        return try loadAndAllocate(dir: dir, fileNames: [file])
    }


    func loadFiles(fromDir dir: String, regex: String) throws -> [[[Float32]]] {
        let dirURL = rootDataDir.appendingPathComponent(dir)
        return try loadFiles(fromDir: dirURL, regex: regex)
    }



    func loadFiles(fromDir dirURL: URL, regex: String) throws -> [[[Float32]]] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let directoryContents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        return try loadAndAllocate(dir: dir, fileNames: filteredBinFileNames)

    }




    fileprivate func loadAndAllocate(dir: String, fileNames: [String]) throws -> [[[Float32]]] {

        let ppDimDir = rootDataDir.appendingPathComponent(dir).appendingPathComponent("Post_Processing_Dims_dims.0.0.0.V4.json")
        let dirDim = try ppDim(ppDimDir)

        let nColg = dirDim.gridX + 2
        let nRowg = dirDim.gridX + 2

        var plane = Array(repeating: Array(repeating: Array(repeating: Float32(0.0), count: dirDim.qOutputLength), count: nRowg), count: nColg)


        //TODO Dispatch to GCD
        for binFile in fileNames {

            let jsonBinURL = rootDataDir.appendingPathComponent(dir).appendingPathComponent(binFile + ".json")

            logger.info("Loading \(jsonBinURL)")
            let dim = try QVecDim(jsonBinURL)

            print(dim)


            //ERROR in the OUTPUT
            var qOutputLength = dim.qOutputLength
            if dim.structName == "tDisk_colrow_Q3_V4" {
                qOutputLength = 3
            } else if dim.structName == "tDisk_colrow_Q4_V4" {
                qOutputLength = 4
            }



            let binURL = rootDataDir.appendingPathComponent(dir).appendingPathComponent(binFile)

            let data = try Data(contentsOf: binURL)

            //Pick up length from types (2 for Int, 4 for Float)
            let lenBytesRowCol = 2
            let lenBytesQ = 4
            let lenBytesStruct = lenBytesRowCol + lenBytesRowCol + qOutputLength * lenBytesQ


            data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in

                for i in stride(from: 0, to: dim.binFileSizeInStructs * lenBytesStruct, by: lenBytesStruct)  {

                    let col = Int(ptr.load(fromByteOffset: i, as: UInt16.self))
                    let row = Int(ptr.load(fromByteOffset: i + lenBytesRowCol, as: UInt16.self))

//                                        let q0 = ptr.load(fromByteOffset: i + 4, as: Float32.self)
//                                        let q1 = ptr.load(fromByteOffset: i + 8, as: Float32.self)
//                                        let q2 = ptr.load(fromByteOffset: i + 12, as: Float32.self)
//                    //                    let q3 = ptr.load(fromByteOffset: i + 16, as: Float32.self)
//                                        print(col, row, q0, q1, q2)

                    for q in 0..<qOutputLength {
                        plane[row][col][q] = ptr.load(fromByteOffset: i + lenBytesRowCol * 2 + (q * lenBytesQ), as: Float32.self)
                    }

                    print(col, row, plane[row][col][0], plane[row][col][1], plane[row][col][2])//, plane[row][col][3])

                }
            }//end of for bytes
        }

        return plane
    }




}









