//
//  File.swift
//
//
//  Created by Niall Ó Broin on 01/07/2020.
//

import Foundation

extension Data {

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {

        var array = [T](repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}

/// Class to read binary files from the disk. Generic Class because files can be very large, for example a cube simulation space of size 3000, would be 27bn cells, and if the 27 vectors were saved, would amount to 5.8 Terrabytes of Doubles.  Even a likely angled slice through this space could be 300Megabytes of Doubles, but this precision is probably not necessary for visualisations.
///
/// - parameters
///   - T FloatingPoint type to be used for calculations
struct QVecRead<T: BinaryFloatingPoint> {

    let binURL: URL
    let data: Data

    let jsonBinURL: URL
    let dim: QVecDim

    init(binURL: URL) throws {

        self.binURL = binURL

        self.jsonBinURL = binURL.appendingPathExtension("json")

        self.dim = try QVecDim(jsonBinURL)

        self.data = try Data(contentsOf: binURL)
    }

    ///Returns an array of tDisk_colrow_grid structs. Each struct contains coordinate information
    ///
    /// - note: The binary files on disk can be of different types than those returned by this function
    func readSparseFromDisk(fromQindex: Int = 0, toQindex: Int = 0) -> [DiskSparse2DAnd3D<Int, T>] {

        precondition(toQindex <= dim.qOutputLength)
        let readUntilQIndex = (toQindex == 0) ? dim.qOutputLength : toQindex

        var sparseItems = [DiskSparse2DAnd3D<Int, T>]()

        func get<DiskColRow: BinaryInteger, DiskQ: BinaryFloatingPoint>(diskColRow: DiskColRow.Type, diskQ: DiskQ.Type) {

            //https://forums.swift.org/t/unaligned-load/22916
            //https://www.uraimo.com/2016/04/07/swift-and-c-everything-you-need-to-know/
            //https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data

            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                for index in stride(from: 0, to: dim.binFileSizeInStructs * dim.sizeStructInBytes, by: dim.sizeStructInBytes) {

                    var col: Int = 0
                    var row: Int = 0
                    var i: Int = 0
                    var j: Int = 0
                    var k: Int = 0

                    if dim.hasColRowtCoords {
                        col = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow, as: DiskColRow.self))
                        row = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow + dim.sizeColRowTypeInBytes, as: DiskColRow.self))
                    }

                    if dim.hasGridtCoords {
                        i = ptr.load(fromByteOffset: index + dim.byteOffsetGrid, as: Int.self)
                        j = ptr.load(fromByteOffset: index + dim.byteOffsetGrid + dim.sizeGridTypeInBytes, as: Int.self)
                        k = ptr.load(fromByteOffset: index + dim.byteOffsetGrid + dim.sizeGridTypeInBytes + dim.sizeGridTypeInBytes, as: Int.self)
                    }

                    //Cannot load bytes offset, due to possible unaligned memory
                    let q = Data(bytes: ptr.baseAddress!.advanced(by: index + dim.byteOffsetQVec), count: readUntilQIndex * dim.sizeQTypeInBytes)

                    let a = q.toArray(type: diskQ.self)

                    let item = DiskSparse2DAnd3D<Int, T>(c: col, r: row, i: i, j: j, k: k, q: a)

                    sparseItems.append(item)

                }
            }
        }//end of get

        if dim.coordsTypeString == "UInt16" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt16.self, diskQ: Float32.self)

        } else {
            fatalError("Currently only working with UInt16 and Float")
        }

        return sparseItems

    }

    /// Reads binary files from disk with coordinate information and inserts into an array.  The data on the disk is decomposed into smaller parts, so this function could be called simulataneously to write  separate non-overlapping files into the 2D Array.  The third dimension being the QVectors.
    ///
    /// - note: The binary files on disk can be of different types than those returned by this function
    func getPlaneFromDisk(plane: inout [[[T]]], fromQindex: Int = 0, toQindex: Int = 0) {

        //TODO Need to generalise this function

        //TODO Need to allow for disk structs that contain 2d AND / OR 3d coords.
        precondition(dim.hasColRowtCoords)

        precondition(toQindex <= dim.qOutputLength)
        let readUntilQIndex = (toQindex == 0) ? dim.qOutputLength : toQindex

        func get<DiskColRow: BinaryInteger, DiskQ: BinaryFloatingPoint>(diskColRow: DiskColRow.Type, diskQ: DiskQ.Type) {

            //https://forums.swift.org/t/unaligned-load/22916
            //https://www.uraimo.com/2016/04/07/swift-and-c-everything-you-need-to-know/
            //https://stackoverflow.com/questions/38023838/round-trip-swift-number-types-to-from-data

            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                for index in stride(from: 0, to: dim.binFileSizeInStructs * dim.sizeStructInBytes, by: dim.sizeStructInBytes) {

                    let col = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow, as: diskColRow.self))
                    let row = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow + dim.sizeColRowTypeInBytes, as: diskColRow.self))

                    //TODO Need to allow for disk structs that contain 2d AND 3d coords.

                    //Cannot load bytes offset, due to possible unaligned memory
                    let q = Data(bytes: ptr.baseAddress!.advanced(by: index + dim.byteOffsetQVec), count: readUntilQIndex * dim.sizeQTypeInBytes)

                    let a = q.toArray(type: diskQ.self)

                    plane[col][row] = a.map {T($0)}

                }
            }
        }

        //TODO Need to find better way to do this...

        if dim.coordsTypeString == "Int16" && dim.qDataTypeString == "Float" {
            get(diskColRow: Int16.self, diskQ: Float32.self)

        } else if dim.coordsTypeString == "UInt16" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt16.self, diskQ: Float32.self)

        } else if dim.coordsTypeString == "uint16_t" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt16.self, diskQ: Float32.self)

        } else if dim.coordsTypeString == "Int32" && dim.qDataTypeString == "Float" {
            get(diskColRow: Int32.self, diskQ: Float32.self)

        } else if dim.coordsTypeString == "UInt32" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt32.self, diskQ: Float32.self)

        } else if dim.coordsTypeString == "Int16" && dim.qDataTypeString == "Double" {
            get(diskColRow: Int16.self, diskQ: Double.self)

        } else if dim.coordsTypeString == "UInt16" && dim.qDataTypeString == "Double" {
            get(diskColRow: UInt16.self, diskQ: Double.self)

        } else if dim.coordsTypeString == "uint16_t" && dim.qDataTypeString == "Double" {
            get(diskColRow: UInt16.self, diskQ: Double.self)

        } else if dim.coordsTypeString == "Int32" && dim.qDataTypeString == "Double" {
            get(diskColRow: Int32.self, diskQ: Double.self)

        } else if dim.coordsTypeString == "UInt32" && dim.qDataTypeString == "Double" {
            get(diskColRow: UInt32.self, diskQ: Double.self)

        } else {
            //TOFIX
            dim.printMe()
            print(jsonBinURL)

            print(dim.qDataType)
            fatalError("Need to find a better way to pass in types to the get method. Cannot handle \(dim.coordsType), \(dim.qDataType)")
        }

    }

    //    func readPartialFileIntoLargerVelocity3DMatrix(velocity: inout [[[Velocity]]]) {
    //    func readPartialFileIntoLargerVelocity2DMatrix(velocity: inout [[Velocity]]) {

    /// Reads binary files from disk with coordinate information and inserts into an Velocity Plane.  The data on the disk is decomposed into smaller parts, so this function could be called simulataneously to write  separate non-overlapping files into the 2D Array.
    ///
    /// - note: The binary files on disk can be of different types than those returned by this function
    func getVelocityFromDisk(addIntoPlane: inout Velocity2DPlaneOrtho<T>) {

        precondition(dim.hasColRowtCoords)

        func get<DiskColRow: BinaryInteger, DiskQ: BinaryFloatingPoint>(diskColRow: DiskColRow.Type, diskQ: DiskQ.Type) {

            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                for index in stride(from: 0, to: dim.binFileSizeInStructs * dim.sizeStructInBytes, by: dim.sizeStructInBytes) {

                    let col = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow, as: diskColRow.self))
                    let row = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow + dim.sizeColRowTypeInBytes, as: diskColRow.self))

                    //Cannot load bytes offset, due to possible unaligned memory
                    let q = Data(bytes: ptr.baseAddress!.advanced(by: index + dim.byteOffsetQVec), count: 4 * dim.sizeQTypeInBytes)

                    let a = q.toArray(type: diskQ.self)

                    addIntoPlane[col, row].rho = T(a[0])
                    addIntoPlane[col, row].ux = T(a[1])
                    addIntoPlane[col, row].uy = T(a[2])
                    addIntoPlane[col, row].uz = T(a[3])

                }
            }
        }

        if dim.coordsTypeString == "UInt16" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt16.self, diskQ: Float32.self)

        } else {
            fatalError("Currently only working with UInt16 and Float.  Found \(dim.coordsType) and \(dim.qDataType) in file \(jsonBinURL.path)")
        }

    }

    /// Reads binary Forcing files from disk with coordinate information and mutates the Velocity Plane. There is much less forcing data, less than one percent, so these files are read separately to teh velocity data.
    ///
    /// - note: The binary files on disk can be of different types than those returned by this function
    func addForcingToPartialVelocity(velocity: inout Velocity2DPlaneOrtho<T>) {

        precondition(dim.hasColRowtCoords)

        func get<DiskColRow: BinaryInteger, DiskQ: BinaryFloatingPoint>(diskColRow: DiskColRow.Type, diskQ: DiskQ.Type) {

            data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
                for index in stride(from: 0, to: dim.binFileSizeInStructs * dim.sizeStructInBytes, by: dim.sizeStructInBytes) {

                    let col = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow, as: diskColRow.self))
                    let row = Int(ptr.load(fromByteOffset: index + dim.byteOffsetColRow + dim.sizeColRowTypeInBytes, as: diskColRow.self))

                    //Cannot load bytes offset, due to possible unaligned memory
                    let q = Data(bytes: ptr.baseAddress!.advanced(by: index + dim.byteOffsetQVec), count: 3 * dim.sizeQTypeInBytes)

                    let a = q.toArray(type: diskQ.self)

                    let fx = T(a[0])
                    let fy = T(a[0])
                    let fz = T(a[0])

                    //v.ux = (q[1] + 0.5 * forcing.x) / q[0]
                    velocity[col, row].ux += fx / velocity[col, row].rho
                    velocity[col, row].uy += fy / velocity[col, row].rho
                    velocity[col, row].uz += fz / velocity[col, row].rho

                }
            }
        }

        if dim.coordsTypeString == "UInt16" && dim.qDataTypeString == "Float" {
            get(diskColRow: UInt16.self, diskQ: Float32.self)

        } else {
            fatalError("Currently only working with UInt16 and Float")
        }

    }

    func getVolumeFromDisk() {
        fatalError("Not Yet Implemented")
    }

}//end of QVec class
