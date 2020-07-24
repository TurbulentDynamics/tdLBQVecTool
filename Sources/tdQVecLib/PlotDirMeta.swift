//
//  PostProcessingDims.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation


/// This struct reads the json file that holds various information on the PlotDir folder.
///
struct PPDim: Codable {
    //https://app.quicktype.io/#

    public let qOutputLength, cutAt: Int
    public let dirname: String
    public let fileHeight, fileWidth: Int
    public let function: String
    public let gridX, gridY, gridZ, initialRho: Int
    public let name: String
    public let ngx, ngy, ngz: Int
    public let note: String
    public let reMNondimensional, step: Int
    public let teta: Double
    public let totalHeight, totalWidth: Int
    public let uav: Double

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

    public init(qOutputLength: Int,
                cutAt: Int,
                dirname: String,
                fileHeight: Int,
                fileWidth: Int,
                function: String,
                gridX: Int,
                gridY: Int,
                gridZ: Int,
                initialRho: Int,
                name: String,
                ngx: Int,
                ngy: Int,
                ngz: Int,
                note: String,
                reMNondimensional: Int,
                step: Int,
                teta: Double,
                totalHeight: Int,
                totalWidth: Int,
                uav: Double
    ) {
        self.qOutputLength = qOutputLength
        self.cutAt = cutAt
        self.dirname = dirname
        self.fileHeight = fileHeight
        self.fileWidth = fileWidth
        self.function = function
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.initialRho = initialRho
        self.name = name
        self.ngx = ngx
        self.ngy = ngy
        self.ngz = ngz
        self.note = note
        self.reMNondimensional = reMNondimensional
        self.step = step
        self.teta = teta
        self.totalHeight = totalHeight
        self.totalWidth = totalWidth
        self.uav = uav

    }

}

extension PPDim {

    public init(dir: PlotDir) throws {

        //        logger.info("Loading Post Process Dimension File: \(jsonURL)")
        try self.init(url: dir.ppDimURL())
    }

    public init(url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    public init(data: Data) throws {
        self = try newJSONDecoder().decode(PPDim.self, from: data)
    }

    public init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    //    public func with(
    //        qOutputLength: Int? = nil,
    //        cutAt: Int? = nil,
    //        dirname: String? = nil,
    //        fileHeight: Int? = nil,
    //        fileWidth: Int? = nil,
    //        function: String? = nil,
    //        gridX: Int? = nil,
    //        gridY: Int? = nil,
    //        gridZ: Int? = nil,
    //        initialRho: Int? = nil,
    //        name: String? = nil,
    //        ngx: Int? = nil,
    //        ngy: Int? = nil,
    //        ngz: Int? = nil,
    //        note: String? = nil,
    //        reMNondimensional: Int? = nil,
    //        step: Int? = nil,
    //        teta: Double? = nil,
    //        totalHeight: Int? = nil,
    //        totalWidth: Int? = nil,
    //        uav: Double? = nil
    //        ) -> ppDim {
    //        return ppDim(
    //            qOutputLength: qOutputLength ?? self.qOutputLength,
    //            cutAt: cutAt ?? self.cutAt,
    //            dirname: dirname ?? self.dirname,
    //            fileHeight: fileHeight ?? self.fileHeight,
    //            fileWidth: fileWidth ?? self.fileWidth,
    //            function: function ?? self.function,
    //            gridX: gridX ?? self.gridX,
    //            gridY: gridY ?? self.gridY,
    //            gridZ: gridZ ?? self.gridZ,
    //            initialRho: initialRho ?? self.initialRho,
    //            name: name ?? self.name,
    //            ngx: ngx ?? self.ngx,
    //            ngy: ngy ?? self.ngy,
    //            ngz: ngz ?? self.ngz,
    //            note: note ?? self.note,
    //            reMNondimensional: reMNondimensional ?? self.reMNondimensional,
    //            step: step ?? self.step,
    //            teta: teta ?? self.teta,
    //            totalHeight: totalHeight ?? self.totalHeight,
    //            totalWidth: totalWidth ?? self.totalWidth,
    //            uav: uav ?? self.uav
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

}
