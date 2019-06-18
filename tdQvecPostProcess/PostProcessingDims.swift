//
//  PostProcessingDims.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation

//https://app.quicktype.io/#
struct ppDim: Codable {
    let qOutputLength, cutAt: Int
    let dirname: String
    let fileHeight, fileWidth: Int
    let function: String
    let gridX, gridY, gridZ, initialRho: Int
    let name: String
    let ngx, ngy, ngz: Int
    let note: String
    let reMNondimensional, step: Int
    let teta: Double
    let totalHeight, totalWidth: Int
    let uav: Double

    enum CodingKeys: String, CodingKey {
        case qOutputLength = "Q_output_length"
        case cutAt = "cut_at"
        case dirname
        case fileHeight = "file_height"
        case fileWidth = "file_width"
        case function
        case gridX = "grid_x"
        case gridY = "grid_y"
        case gridZ = "grid_z"
        case initialRho = "initial_rho"
        case name, ngx, ngy, ngz, note
        case reMNondimensional = "re_m_nondimensional"
        case step, teta
        case totalHeight = "total_height"
        case totalWidth = "total_width"
        case uav
    }
}


extension ppDim {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ppDim.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        qOutputLength: Int? = nil,
        cutAt: Int? = nil,
        dirname: String? = nil,
        fileHeight: Int? = nil,
        fileWidth: Int? = nil,
        function: String? = nil,
        gridX: Int? = nil,
        gridY: Int? = nil,
        gridZ: Int? = nil,
        initialRho: Int? = nil,
        name: String? = nil,
        ngx: Int? = nil,
        ngy: Int? = nil,
        ngz: Int? = nil,
        note: String? = nil,
        reMNondimensional: Int? = nil,
        step: Int? = nil,
        teta: Double? = nil,
        totalHeight: Int? = nil,
        totalWidth: Int? = nil,
        uav: Double? = nil
        ) -> ppDim {
        return ppDim(
            qOutputLength: qOutputLength ?? self.qOutputLength,
            cutAt: cutAt ?? self.cutAt,
            dirname: dirname ?? self.dirname,
            fileHeight: fileHeight ?? self.fileHeight,
            fileWidth: fileWidth ?? self.fileWidth,
            function: function ?? self.function,
            gridX: gridX ?? self.gridX,
            gridY: gridY ?? self.gridY,
            gridZ: gridZ ?? self.gridZ,
            initialRho: initialRho ?? self.initialRho,
            name: name ?? self.name,
            ngx: ngx ?? self.ngx,
            ngy: ngy ?? self.ngy,
            ngz: ngz ?? self.ngz,
            note: note ?? self.note,
            reMNondimensional: reMNondimensional ?? self.reMNondimensional,
            step: step ?? self.step,
            teta: teta ?? self.teta,
            totalHeight: totalHeight ?? self.totalHeight,
            totalWidth: totalWidth ?? self.totalWidth,
            uav: uav ?? self.uav
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}


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
