
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








struct Slice2D <tPP> {
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




struct Slice2DPlanes <tPP> {
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











