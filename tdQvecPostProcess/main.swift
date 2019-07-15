//
//  main.swift
//  TDQVecLib
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation


let help: Bool = CommandLine.arguments.contains("-h")
if help {
    print("USAGE: tdQVecPostProcess [options] <directories>")
    print("-o overwrite files")
    print("-u make ux uy uz files")
    print("-v make vorticity files")
    print("-p print verbose")
    print("-a analyse")
//    print("-b blob")
    exit(0)
}


let overwrite: Bool = CommandLine.arguments.contains("-o")
let uxuyuz: Bool = CommandLine.arguments.contains("-u")
let vort: Bool = CommandLine.arguments.contains("-v")

let verbose: Bool = CommandLine.arguments.contains("-p")
let analyse: Bool = CommandLine.arguments.contains("-a")
//let blob: Bool = CommandLine.arguments.contains("-b")

//String temporal_data_points_path = CommandLine.contains("-t")



var dirs = [String]()
for d in CommandLine.arguments.dropFirst() {
    if !d.hasPrefix("-") {
        dirs.append(d)
    }
}


let dataDir = "Workspace/xcode/tdQVecPostProcess/TinyTestData/"
//let dataDir = "Workspace/xcode/tdQVecPostProcess/TD_Rushton_Sample_Output_Qvec/"


//dirs = ["plot_vertical_axis.XYplane.V_4.Q_4.step_00000050.cut_21"]
dirs = ["plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28", "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_29", "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_30"]
//dirs = ["plot_axis.YZplane.V_4.Q_4.step_00000050.cut_21"]
//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00002000.cut_133"]

dirs = ["plot_rotational_capture.rotational_capture.V_4.Q_4.step_00000050.angle_15.blade_id_0"]
//=========================================================



let disk = try InputFilesV4(withDataDir: dataDir)

//disk.analyse(dirs: dirs)
//disk.analyse_blob("*.step_*.")

let dir = dirs[0]
let pp = try QVecPostProcess(withDataDir: dataDir, loadDir: dir)
try pp.loadAndCalcVelocityRotation()


//try pp.loadAndCalcVelocityXZ()
//try pp.loadAndCalcVelocityXZ()
//try pp.loadAndCalcVelocityXZ()

//pp.calcVortXZ()
//pp.writeVortXZ()



