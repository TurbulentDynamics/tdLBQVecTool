
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



class diskSparseBuffer {
    //Useful references
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c
    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/
    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer

    let dataDirURL: URL

    let qVecBinRegex = "^Qvec\\.node\\..*\\.bin$"
    let F3BinRegex = "^Qvec\\.F3\\.node\\..*\\.bin$"


    //Example Qvec.F3.km1.node.0.1.0.V4.bin
    let qVecRotationBinRegex = [".", ".im1.", ".ip1.", ".km1.", ".kp1."].map{"^Qvec\($0)node\\..*\\.bin$"}
    let F3RotationBinRegex = [".", ".im1.", ".ip1.", ".km1.", ".kp1."].map{"^Qvec\\.F3\($0)node\\..*\\.bin$"}





    init(withDataDir: String) throws {
        let home = FileManager.default.homeDirectoryForCurrentUser

        //TODO Check if exists
        self.dataDirURL = home.appendingPathComponent(withDataDir)

    }

    init(withDataDir: URL) throws {
        self.dataDirURL = withDataDir
    }





    func load(fromDir dir: String, file: String) throws -> [[[Float32]]] {
        let dirURL = dataDirURL.appendingPathComponent(dir)
        return try loadAndAllocate(dirURL: dirURL, fileNames: [file])
    }


    func loadFiles(fromDir dir: String, regex: String) throws -> [[[Float32]]] {
        let dirURL = dataDirURL.appendingPathComponent(dir)
        return try loadFiles(fromDir: dirURL, regex: regex)
    }



    func loadFiles(fromDir dirURL: URL, regex: String) throws -> [[[Float32]]] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let directoryContents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return try loadAndAllocate(dirURL: dirURL, fileNames: filteredBinFileNames)

    }




    func loadQVecFiles(fromDir dirURL: URL) throws -> [[[Float32]]] {
        return try loadFiles(fromDir: dirURL, regex: qVecBinRegex)
    }

    func loadQVecFiles(fromDir dir: String) throws -> [[[Float32]]] {
        return try loadFiles(fromDir: dir, regex: qVecBinRegex)
    }

    func loadF3Files(fromDir dirURL: URL) throws -> [[[Float32]]] {
        return try loadFiles(fromDir: dirURL, regex: F3BinRegex)
    }

    func loadF3Files(fromDir dir: String) throws -> [[[Float32]]] {
        return try loadFiles(fromDir: dir, regex: F3BinRegex)
    }












    fileprivate func loadAndAllocate(dirURL: URL, fileNames: [String]) throws -> [[[Float32]]] {


        let dirDim = try ppDim(dir: dirURL)

        let nColg = dirDim.totalHeight
        let nRowg = dirDim.totalWidth

        var plane = Array(repeating: Array(repeating: Array(repeating: Float32(0.0), count: dirDim.qOutputLength), count: nRowg), count: nColg)


        //TODO Dispatch to GCD??
        for binFile in fileNames {

            let jsonBinURL = dirURL.appendingPathComponent(binFile + ".json")

            //            logger.info("Loading json File loadAndAllocate \(jsonBinURL)")
            let dim = try QVecDim(jsonBinURL)

            //            print(dim)

            //ERROR in the OUTPUT
            var qOutputLength = dim.qOutputLength


            switch dim.structName {

            case "tDisk_colrow_Q3_V4":
                qOutputLength = 3
            case "tDisk_colrow_Q4_V4":
                qOutputLength = 4
//            case "tDisk_grid_colrow_Q3_V4":
//                qOutputLength = 3
//            case "tDisk_grid_colrow_Q4_V4":
//                qOutputLength = 4
            default:
                print("ERROR")
            }



            let binURL = dirURL.appendingPathComponent(binFile)

            //            logger.info("Loading bin file with func loadAndAllocate \(binURL)")
            let data = try Data(contentsOf: binURL)

            //Pick up length from types (2 for Int, 4 for Float)
            let lenBytesRowCol = 2
            let lenBytesQ = 4
            let lenBytesStruct = lenBytesRowCol + lenBytesRowCol + qOutputLength * lenBytesQ


            data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in

                for i in stride(from: 0, to: dim.binFileSizeInStructs * lenBytesStruct, by: lenBytesStruct)  {

                    let col = Int(ptr.load(fromByteOffset: i, as: UInt16.self))
                    let row = Int(ptr.load(fromByteOffset: i + lenBytesRowCol, as: UInt16.self))

                    for q in 0..<qOutputLength {
                        plane[row][col][q] = ptr.load(fromByteOffset: i + lenBytesRowCol * 2 + (q * lenBytesQ), as: Float32.self)
                    }

                    //                    print(col, row, plane[row][col][0], plane[row][col][1], plane[row][col][2], plane[row][col][3])

                }
            }//end of for bytes
        }

        return plane
    }





}
