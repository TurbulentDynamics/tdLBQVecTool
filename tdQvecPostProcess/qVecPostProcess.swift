//
//  mQVecPostProcess.swift
//  tdQVecPostProcess
//
//  Created by Niall Ó Broin on 23/06/2019.
//

import Foundation



struct velocity {
    var rho: Float32
    var ux: Float32
    var uy: Float32
    var uz: Float32

    init(){
        rho = 0.0
        ux = 0.0
        uy = 0.0
        uz = 0.0
    }
}

enum dirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
}






class QVecPostProcess {

    let dataDirURL: URL

    init(withDataDir: String) throws {
        let home = FileManager.default.homeDirectoryForCurrentUser

        //TODO Check if exists
        self.dataDirURL = home.appendingPathComponent(withDataDir)
    }

    init(withDataDir: URL) throws {
        self.dataDirURL = withDataDir
    }




    func load(fromDir loadDir: String) throws {

    }



}


