
//  QvecDims.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation


//Saved to Disk in C
//struct tDisk_colrow_Q19_V4 {
//    uint16_t col, row;
//    float s[19];
//};


struct tDisk_colrow_Q4_V4 {
    let col: Int
    let row: Int
    let s: [Float]

    init(){
        self.col = 101
        self.row = 202
        self.s = [1.0, 2.0, 3.0, 4.0]
    }
}





//https://github.com/apple/swift-evolution/blob/master/proposals/0107-unsaferawpointer.md#memory-model-explanation
//    // Reading file
//    let rData = try! Data(contentsOf: url)
//
//    let rawPtr = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<tTYPE>.stride,
//                                                  alignment: MemoryLayout<tTYPE>.alignment)
//
//    let ptrToSomeType = rawPtr.initializeMemory(as: tTYPE.self, to: tTYPE())


//https://stackoverflow.com/questions/33813812/write-array-of-float-to-binary-file-and-read-it-in-swift/48654267
//
//var array: [Float] = [0.1, 0.2, 0.3]
//
//func writeArrayToPlist(array: [Float]) {
//    if let arrayPath: String = createArrayPath() {
//        (array as NSArray).writeToFile(arrayPath, atomically: false)
//    }
//}
//
//func readArrayFromPlist() -> [Float]? {
//    if let arrayPath: String = createArrayPath() {
//        if let arrayFromFile: [Float] = NSArray(contentsOfFile: arrayPath) as? [Float] {
//            return arrayFromFile
//        }
//    }
//    return nil
//}
//
//func createArrayPath () -> String? {
//    if let docsPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last {
//        return ((docsPath as NSString).stringByAppendingPathComponent("myArrayFileName") as NSString).stringByAppendingPathExtension("plist")
//    }
//    return nil
//}





func loadBuffer(binFileURL: URL, count: Int){

    let rData = try! Data(contentsOf: binFileURL)
    print(rData)

}




func loadBuffer<T>(binFileURL: URL, count: Int) -> [T]{

    let rData = try! Data(contentsOf: binFileURL)
    print(rData)

    //TODO "cast" the rData to an array of structs T

    return rData

}
