//
//  mqVecPostProcess.swift
//  tdQvecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation



class postProcess {

    //    var rho, ux, uy, uz: Slice2DPlanes<tPP>
    //    var uxyz_log_vort: Slice2DPlanes<tPP>

    let rootURL: URL

    init(rootDir: String){
        let home = FileManager.default.homeDirectoryForCurrentUser

        self.rootURL = home.appendingPathComponent(rootDir)
    }


    func loadPPDim(withDir dir: String, ppDimJson: String = "Post_Processing_Dims_dims.0.0.0.V4.json") throws -> ppDim {

        let jsonURL = rootURL.appendingPathComponent(dir).appendingPathComponent(ppDimJson)
//        print("Loading PPDim \(jsonURL)")
        return try ppDim(fromURL: jsonURL)
    }


    func loadQvecDim(withDir dir: String, jsonFile: String) throws -> qVecDim {

        let jsonURL = rootURL.appendingPathComponent(dir).appendingPathComponent(jsonFile)
//        print("Loading Qvec \(jsonURL)")
        return try qVecDim(fromURL: jsonURL)
    }




    func loadQvecBinFile(withDir dir: String, fileName: String) throws {

        let qVecDim = try loadQvecDim(withDir: dir, jsonFile: fileName + ".json")
        print(qVecDim.binFileSizeInStructs, qVecDim.structName)

        let QvecURL = rootURL.appendingPathComponent(dir).appendingPathComponent(fileName)
        print(QvecURL)

        //Need to allocate memory and load form Disk


//        try loadBuffer<tDisk_colrow_Q4_V4>(url: QvecURL, numStructs: 10)



    }



    //    func initMatrices(nRow: Int, nCol: Int, nPlane: Int){
    //
    //        var rho = Slice2DPlanes<tPP>(nRow: nRow, nCol: nCol, nPlane: nPlane, val: 0.0)
    //        var ux = Slice2DPlanes<tPP>(nRow: nRow, nCol: nCol, nPlane: nPlane, val: 0.0)
    //        var uy = Slice2DPlanes<tPP>(nRow: nRow, nCol: nCol, nPlane: nPlane, val: 0.0)
    //        var uz = Slice2DPlanes<tPP>(nRow: nRow, nCol: nCol, nPlane: nPlane, val: 0.0)
    //
    //        var uxyz_log_vort = Slice2DPlanes<tPP>(nRow: nRow, nCol: nCol, nPlane: nPlane, val: 0.0)
    //
    //    }







    func load(withDir dir: String) throws {
        let fileName = "/Qvec.node.0.1.1.V4.bin"

        try loadQvecBinFile(withDir: dir, fileName: fileName)
    }



}

