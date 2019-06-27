
//  QvecDims.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation





class Buffer {
    //Useful reference
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c
    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/
    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer


    //    let buffer = Buffer(binFileURL: binFileURL, count: dim.binFileSizeInStructs)
    //    buffer.load()

    let binFileURL: URL
    let nColg: Int
    let nRowg: Int


    init(binFileURL: URL, with dim: qVecDim){

        self.binFileURL = binFileURL
        nColg = dim.gridY
        nRowg = dim.gridX
    }


    func load(){

    var planeQ0 = Array(repeating: Array(repeating: Float32(0.0), count: nRowg), count: nColg)
        var planeQ1 = Array(repeating: Array(repeating: Float32(0.0), count: nRowg), count: nColg)
        var planeQ2 = Array(repeating: Array(repeating: Float32(0.0), count: nRowg), count: nColg)
        var planeQ3 = Array(repeating: Array(repeating: Float32(0.0), count: nRowg), count: nColg)

        //                    1   23  7.983959  0.001160 -0.000019 -0.002873
        //                    1   24  7.991158  0.000800 -0.000117 -0.002823

        do {


            let data = try! Data(contentsOf: binFileURL)

            data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in

                for i in  stride(from: 0, to: dim.binFileSizeInStructs * 20, by: 20)  {


                    let col = Int(ptr.load(fromByteOffset: i + 0, as: UInt16.self))
                    let row = Int(ptr.load(fromByteOffset: i + 2, as: UInt16.self))

                    let q0 = ptr.load(fromByteOffset: i + 4, as: Float32.self)
                    let q1 = ptr.load(fromByteOffset: i + 8, as: Float32.self)
                    let q2 = ptr.load(fromByteOffset: i + 12, as: Float32.self)
                    let q3 = ptr.load(fromByteOffset: i + 16, as: Float32.self)

                    print(col, row, q0, q1, q2, q3)

                    planeQ0[row][col] = q0
                    planeQ1[row][col] = q1
                    planeQ2[row][col] = q2
                    planeQ3[row][col] = q3
                }

            }

        }


    }


}









