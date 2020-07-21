//
//  File.swift
//
//
//  Created by Niall Ó Broin on 01/07/2020.
//

import Foundation
@testable import tdQVecLib
//import Numerics

///Represented by Real for testing, in reality always BinaryFloatingPoint
//struct Q<tQ: Real> {
struct Q<tQ: BinaryFloatingPoint> {
    var q: [tQ]

    init(qLen: Int) {
        self.q = Array(repeating: tQ.zero, count: qLen)
    }

    init(q: [tQ]) {
        self.q = q
    }

    var rho: tQ {
        return q[1] * q[2] * q[3]
    }

}

///Represented by Real for testing, in reality always BinaryFloatingPoint
//struct LB<tQ: Real> {
struct LB<tQ: BinaryFloatingPoint> {
    var grid: [[[ Q<tQ> ]]]
    let x: Int = 3
    let y: Int = 3
    let z: Int = 3

    init(qLen: Int) {
        grid = Array(repeating: Array(repeating: Array(repeating: Q<tQ>(qLen: qLen), count: z), count: y), count: x)
        for i in 0..<x {
            for j in 0..<y {
                for k in 0..<z {

                    let o = tQ(i * 10000  + j * 1000 + k * 100)

                    var u = [tQ]()
                    u.append(contentsOf: stride(from: 0, to: tQ(qLen), by: 1))
                    let vectors = u.map({o + $0})

                    grid[i][j][k].q = vectors
                }}}
    }
}

extension LB {

    func writeSparse2DPlaneXY<tCoordType: BinaryInteger, QVecType: BinaryFloatingPoint>(to binFileURL: URL, at cutAt: Int, qOutputLength: Int, tCoordType: tCoordType.Type, QVecType: QVecType.Type) {

        if type(of: tCoordType) == Int.self {
            fatalError("Do not write as Type 'Int' as it is platform dependant.")
        }

        var myData = Data()
        var numStructs = 0

        for i in 0..<x {
            for j in 0..<y {

                let k: Int = Int(cutAt)

                //https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data

                myData.append(withUnsafeBytes(of: tCoordType.init(i)) { Data($0) })
                myData.append(withUnsafeBytes(of: tCoordType.init(j)) { Data($0) })

                for l in 0..<qOutputLength {

                    myData.append(withUnsafeBytes(of: QVecType.init(grid[i][j][k].q[ l ])) { Data($0) })
                }

                numStructs += 1
            }}

        try! myData.write(to: binFileURL)

        let d = QVecDim(qDataType: String(describing: QVecType), qOutputLength: qOutputLength, binFileSizeInStructs: numStructs, coordsType: String(describing: tCoordType), gridX: x, gridY: y, gridZ: z, hasColRowtCoords: true, hasGridtCoords: false, idi: 1, idj: 1, idk: 1, name: "Written from mockLB in QVecTool Tests", ngx: 1, ngy: 1, ngz: 1, structName: "tDisk_colrow")

        try! d.write(to: URL(fileURLWithPath: binFileURL.path + ".json"))

    }

    func writeSparseVolume() {

    }

    func writeDenseVolume() {

    }

}//end of LB Entension
