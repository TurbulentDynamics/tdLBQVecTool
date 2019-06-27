
//  QvecDims.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation





class Buffer {
    //Assessing C from Swift
    //https://www.raywenderlich.com/780-unsafe-swift-using-pointers-and-interacting-with-c

    //https://academy.realm.io/posts/nate-cook-tryswift-tokyo-unsafe-swift-and-pointer-types/

    //https://stackoverflow.com/questions/38983277/how-to-get-bytes-out-of-an-unsafemutablerawpointer



    init(binFileURL: URL, count: Int){

        let rData = try! Data(contentsOf: binFileURL)
        print(rData)

    }


    func load(){
        let nColg = 50
        let nRowg = 50
        var plane = Array(repeating: Array(repeating: Float32(0.0), count: nRowg), count: nColg)


        do {


            let data = try! Data(contentsOf: binFileURL)

            data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in

                for i in  stride(from: 0, to: dim.binFileSizeInStructs * 24, by: 24)  {


                    let col = Int(ptr.load(fromByteOffset: i + 0, as: UInt16.self))
                    let row = Int(ptr.load(fromByteOffset: i + 2, as: UInt16.self))

                    let q0 = ptr.load(fromByteOffset: i + 4, as: Float32.self)
                    let q1 = ptr.load(fromByteOffset: i + 12, as: Float32.self)
                    let q2 = ptr.load(fromByteOffset: i + 16, as: Float32.self)
                    let q3 = ptr.load(fromByteOffset: i + 20, as: Float32.self)

                    print(i, col, row, q0, q1, q2, q3)

//                                plane[col][row] = q0

                }

            }

        }


    }


}









