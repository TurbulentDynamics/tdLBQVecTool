//
//  main.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation


let help: Bool = CommandLine.arguments.contains("-h")
if help {
    print("USAGE: tdQvecPostProcess [options] <directories>")
    print("-o overwrite files")
    print("-v make vorticity files")
    print("-u make ux uy uz files")
    print("-p print verbose")
    exit(0)
}


let print_log: Bool = CommandLine.arguments.contains("-p")
let overwrite: Bool = CommandLine.arguments.contains("-o")

let uxuyuz: Bool = CommandLine.arguments.contains("-u")
let vort: Bool = CommandLine.arguments.contains("-v")

//String temporal_data_points_path = CommandLine.contains("-t")

var dirs = [String]()
for d in CommandLine.arguments.dropFirst() {
    if !d.hasPrefix("-") {
        dirs.append(d)
    }
}


//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00000050"]




//let a = Bundle.path(forResource: "/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/Qvec.F3.node.1.1.1.V4.bin.json",
//                    ofType: "json", inDirectory: "TinyTestData")
//print(a)



let home = FileManager.default.homeDirectoryForCurrentUser

let dataPath = "Workspace/xcode/tdQvecPostProcess/TinyTestData/"
let dataUrl = home.appendingPathComponent(dataPath)

let jsonFile = "/plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28/Qvec.F3.node.1.1.1.V4.bin.json"
let jsonUrl = dataUrl.appendingPathComponent(jsonFile)

let dim2 = try qVecDim(fromURL: jsonUrl)
print(dim2)

