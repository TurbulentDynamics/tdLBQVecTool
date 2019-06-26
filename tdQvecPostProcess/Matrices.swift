
//  QvecDims.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation




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








struct Slice2D <tPP>{
    let nRow: Int, nCol: Int
    let nRowg: Int, nColg: Int

    var plane: [[tPP]]

    init(nRow: Int, nCol: Int, val: tPP) {
        self.nRow = nRow
        self.nCol = nCol

        self.nRowg = nRow + 2
        self.nColg = nCol + 2

        plane = Array(repeating: Array(repeating: val, count: self.nRowg), count: self.nColg)
    }
}




struct Slice2DPlanes <tPP>{
    let nRow: Int, nCol: Int
    let nRowg: Int, nColg: Int
    let nPlane: Int

    var plane: [[[tPP]]]

    init(nRow: Int, nCol: Int, nPlane: Int, val: tPP) {
        self.nRow = nRow
        self.nCol = nCol
        self.nPlane = nPlane

        self.nRowg = nRow + 2
        self.nColg = nCol + 2

        plane = Array(repeating: Array(repeating: Array(repeating: val, count: self.nRowg), count: self.nColg), count: self.nPlane)
    }
}











//final class tDisk_colrow_Q4_V4: Serializable, CustomStringConvertible {
//    var i: Int = 0, j: Int = 0
//    var s: Float = Float(repeating: 0.0, count: 4)
//
//    override func read( from file: UnsafeMutablePointer<FILE>) {
//        read(value: &col, from: file)
//        read(value: &row, from: file)
//
//        read(array: &s, from: file)
//    }
//
//    var description: String { return String("c:\(col) r:\(row) s:\(s) ")}
//
//
//}
//
//
//
//func malloc_and_load<tDisk: Serializable>(q: tQvecDim, qVecPath: String) -> Matrix1D<tDisk> {
//
//    var tmp = Matrix1D<tDisk>(rows: Int(q.bin_file_size_in_structs))
//    let fp: UnsafeMutablePointer<FILE>! = fopen(qvec_path.c_str(), "r");
//
//    for index in 0..<tmp.rows {
//        tmp[index].read(from: fp)
//    }
//
//    fclose(fp);
//
//    return tmp;
//}
