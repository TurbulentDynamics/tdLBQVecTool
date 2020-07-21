//
//  QVecDims.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation

/// This struct reads the json file that holds the meta information to read the binary files. The binary files can be written by C++ or Swift.
///
struct QVecDim: Codable {
    //https://app.quicktype.io#

    public let qDataType: String
    public let qOutputLength, binFileSizeInStructs: Int
    public let coordsType: String
    public let gridX, gridY, gridZ: Int
    public let hasColRowtCoords, hasGridtCoords: Bool
    public let idi, idj, idk: Int
    public let name: String
    public let ngx, ngy, ngz: Int
    public let structName: String

    enum CodingKeys: String, CodingKey {
        case qDataType = "Q_data_type"
        case qOutputLength = "Q_output_length"
        case binFileSizeInStructs = "bin_file_size_in_structs"
        case coordsType = "coords_type"
        case gridX = "grid_x"
        case gridY = "grid_y"
        case gridZ = "grid_z"
        case hasColRowtCoords = "has_col_row_coords"
        case hasGridtCoords = "has_grid_coords"
        case idi, idj, idk
        case name
        case ngx, ngy, ngz

        /// Deprecated.  The name of the struct in C that wrote the file.  Now just hasGridtCoords and hasColRowtCords are used.
        case structName = "struct_name"
    }

    public init(
        qDataType: String,
        qOutputLength: Int, binFileSizeInStructs: Int,
        coordsType: String,
        gridX: Int, gridY: Int, gridZ: Int,
        hasColRowtCoords: Bool,
        hasGridtCoords: Bool,
        idi: Int, idj: Int, idk: Int,
        name: String,
        ngx: Int,
        ngy: Int,
        ngz: Int,
        structName: String
    ) {
        self.qDataType = qDataType
        self.qOutputLength = qOutputLength
        self.binFileSizeInStructs = binFileSizeInStructs
        self.coordsType = coordsType
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.hasColRowtCoords = hasColRowtCoords
        self.hasGridtCoords = hasGridtCoords
        self.idi = idi
        self.idj = idj
        self.idk = idk
        self.name = name
        self.ngx = ngx
        self.ngy = ngy
        self.ngz = ngz
        self.structName = structName

    }

}

extension QVecDim {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(QVecDim.self, from: data)
    }

    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(_ url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    //    public func with(
    //        qDataType: String? = nil,
    //        qOutputLength: Int? = nil,
    //        binFileSizeInStructs: Int? = nil,
    //        coordsType: String? = nil,
    //        gridX: Int? = nil,
    //        gridY: Int? = nil,
    //        gridZ: Int? = nil,
    //        hasColRowtCoords: Bool? = nil,
    //        hasGridtCoords: Bool? = nil,
    //        idi: Int? = nil,
    //        idj: Int? = nil,
    //        idk: Int? = nil,
    //        name: String? = nil,
    //        ngx: Int? = nil,
    //        ngy: Int? = nil,
    //        ngz: Int? = nil,
    //        structName: String? = nil
    //    ) -> QVecDim {
    //        return QVecDim(
    //            qDataType: qDataType ?? self.qDataType,
    //            qOutputLength: qOutputLength ?? self.qOutputLength,
    //            binFileSizeInStructs: binFileSizeInStructs ?? self.binFileSizeInStructs,
    //            coordsType: coordsType ?? self.coordsType,
    //            gridX: gridX ?? self.gridX,
    //            gridY: gridY ?? self.gridY,
    //            gridZ: gridZ ?? self.gridZ,
    //            hasColRowtCoords: hasColRowtCoords ?? self.hasColRowtCoords,
    //            hasGridtCoords: hasGridtCoords ?? self.hasGridtCoords,
    //            idi: idi ?? self.idi,
    //            idj: idj ?? self.idj,
    //            idk: idk ?? self.idk,
    //            name: name ?? self.name,
    //            ngx: ngx ?? self.ngx,
    //            ngy: ngy ?? self.ngy,
    //            ngz: ngz ?? self.ngz,
    //            structName: structName ?? self.structName
    //        )
    //    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }

    public func write(to dir: URL) throws {
        let json: String = try jsonString()!

        try json.write(to: dir, atomically: true, encoding: .utf8)
    }

    var coordsTypeString: String {

        //TODO Complete or replace
        if coordsType == "uint16_t" {return "UInt16"} else if coordsType == "Int" {
            fatalError("Cannot determine size of type Int, could be 32 or 64 bits.")

        } else {
            return coordsType
        }

    }

    var sizeColRowTypeInBytes: Int {

//        if ["UInt8", "Int8"].contains(coordsType) {
//            return 1

        if ["UInt16", "Int16", "uint16_t"].contains(coordsType) {
            return 2

        } else if ["UInt32", "Int32"].contains(coordsType) {
            return 4

//        } else if ["UInt64", "Int64"].contains(coordsType) {
//            return 8

        } else if coordsType == "Int" {
            fatalError("Cannot determine size of type Int, could be 32 or 64 bits.")

        } else {
            fatalError("Cannot determine size of type \(coordsType)")
        }
    }

    func typeOfColRow() -> AnyObject {
        switch coordsType {
//            case "Int8":
//                return Int8.self as AnyObject
            case "Int16":
                return Int16.self as AnyObject
            case "Int32":
                return Int32.self as AnyObject
//            case "Int64":
//                return Int64.self as AnyObject
            default:
                fatalError("Cannot determine size of type \(coordsType)")
        }
    }

    var byteOffsetColRow: Int {
        return 0
    }

    ///Grid and ColRow use the same Type
    var sizeGridTypeInBytes: Int {
        return sizeColRowTypeInBytes
    }

    var byteOffsetGrid: Int {
        if hasColRowtCoords {
            return sizeColRowTypeInBytes * 2
        } else {
            return 0
        }
    }

    var qDataTypeString: String {
        if ["Float16", "float16", "half"].contains(qDataType) {
            return "Half"

        } else if ["Float32", "float32", "Float", "float"].contains(qDataType) {
            return "Float"

        } else if ["Float64", "float64", "Double", "double"].contains(qDataType) {
            return "Double"

        } else {
            fatalError("Cannot determine type of \(qDataType)")
        }
    }

    var sizeQTypeInBytes: Int {
        if ["Float16", "float16", "half"].contains(qDataType) {
            return 2

        } else if ["Float32", "float32", "Float", "float"].contains(qDataType) {
            return 4

        } else if ["Float64", "float64", "Double", "double"].contains(qDataType) {
            return 8

        } else {
            fatalError("Cannot determine size of type \(qDataType)")
        }
    }

    var byteOffsetQVec: Int {
        if hasColRowtCoords && !hasGridtCoords {
            return sizeColRowTypeInBytes * 2
        } else if !hasColRowtCoords && hasGridtCoords {
            return sizeGridTypeInBytes * 3
        } else {
            return sizeColRowTypeInBytes * 2 + sizeGridTypeInBytes * 3
        }
    }

    var sizeStructInBytes: Int {
        return byteOffsetQVec + sizeQTypeInBytes * qOutputLength
    }

    func printMe() {
        print("Struct Name: \(structName).  Total Num Structs \(binFileSizeInStructs)")
        print("HasColRow \(hasColRowtCoords), Type \(coordsType), sizeInBytes \(sizeColRowTypeInBytes)")
        print("HasGridtCoords \(hasGridtCoords), Type \(coordsType), sizeInBytes, \(sizeGridTypeInBytes)")
        print("QLen \(qOutputLength), Type \(qDataType) sizeInBytes \(sizeQTypeInBytes)")

        print("Total size of Space in xyz:  \(gridX) \(gridY) \(gridZ)")
        print("Total number of Nodes in xyz: \(ngx) \(ngy) \(ngz)")
        print("Node id in ijk: \(idi) \(idj) \(idk)")
        print("Name of writing function: \(name)")

    }

}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
