//
//  main.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation


//let help: Bool = CommandLine.arguments.contains("-h")
//if help {
//    print("USAGE: tdQvecPostProcess [options] <directories>")
//    print("-o overwrite files")
//    print("-v make vorticity files")
//    print("-u make ux uy uz files")
//    print("-p print verbose")
//    exit(0)
//}
//
//
//let print_log: Bool = CommandLine.arguments.contains("-p")
//let overwrite: Bool = CommandLine.arguments.contains("-o")
//
//let uxuyuz: Bool = CommandLine.arguments.contains("-u")
//let vort: Bool = CommandLine.arguments.contains("-v")
//
////String temporal_data_points_path = CommandLine.contains("-t")
//
//var dirs = [String]()
//for d in CommandLine.arguments.dropFirst() {
//    if !d.hasPrefix("-") {
//        dirs.append(d)
//    }
//}


//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00000050"]


//var pp = postProcess(rootDir: "Workspace/xcode/tdQvecPostProcess/TinyTestData/")
//try pp.load(withDir: "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28")
//pp.calc_log_vort()
//pp.write_all()


//=========================================================


let home = FileManager.default.homeDirectoryForCurrentUser

let rootURL = home.appendingPathComponent("Workspace/xcode/tdQvecPostProcess/TinyTestData/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28")


let fileName = "Qvec.node.0.1.1.V4.bin"

let jsonURL = rootURL.appendingPathComponent(fileName + ".json")
let dim = try qVecDim(fromURL: jsonURL)

//This dim holds information on the binary file "Qvec.node.0.1.1.V4.bin"
print(dim)
print(dim.binFileSizeInStructs)


let binFileURL = rootURL.appendingPathComponent(fileName)



let array = loadBuffer<tDisk_colrow_Q4_V4>(binFileURL: binFileURL, count: dim.binFileSizeInStructs)


let array = loadBuffer<tDisk_grid_colrow_Q19_V4>(binFileURL: binFileURL, count: dim.binFileSizeInStructs)
