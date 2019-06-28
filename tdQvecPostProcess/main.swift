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



let calcs = ["ux": uxuyuz, "uy": uxuyuz, "uz": uxuyuz, "vorticity": vort]



var dirs = [String]()
for d in CommandLine.arguments.dropFirst() {
    if !d.hasPrefix("-") {
        dirs.append(d)
    }
}


//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00000050"]



//=========================================================

let home = FileManager.default.homeDirectoryForCurrentUser
let dataDirURL = home.appendingPathComponent("Workspace/xcode/tdQvecPostProcess/TinyTestData/")


let dir = "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_29"

let fileName = "Qvec.node.0.1.1.V4.bin"




let buff = Buffer(withDataDir: dataDirURL)

//Should return the whole layer as one [row][col][q] array
let layer = try buff.load(fromDir: dir, file: fileName)

//TODO FIX THIS
let Qvec = "Qvec.node.*.bin$"
let layerQvec = try buff.load(fromDir: dir, regex: Qvec)

let F3 = "Qvec.F3.node.*.bin$"
let layerF3 = try buff.load(fromDir: dir, regex: F3)







