//
//  main.swift
//  tdQVecPostProcess
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

//print(CommandLine.arguments)
//let dataDir = "TD_Rushton_Sample_Output_Qvec/"


//let overwrite: Bool = CommandLine.arguments.contains("-o")
let uxuyuz: Bool = CommandLine.arguments.contains("-u")
let vort: Bool = CommandLine.arguments.contains("-v")

//let verbose: Bool = CommandLine.arguments.contains("-p")
//let analyse: Bool = CommandLine.arguments.contains("-a")
//let blob: Bool = CommandLine.arguments.contains("-b")

//String temporal_data_points_path = CommandLine.contains("-t")




var dirs = [String]()
for d in CommandLine.arguments.dropFirst() {
    if !d.hasPrefix("-") {
        dirs.append(d)
    }
}




if !dirs.isEmpty {
    var dir = dirs[0]

    let fm = FileManager.default
    let runDir: String = fm.currentDirectoryPath


    if !fm.fileExists(atPath: dir) {
        dir = runDir + dir
    }


    let dataDirURL = URL.init(fileURLWithPath: dir, isDirectory: true)
    print("Trying \(dataDirURL)")


//    dataDirURL.processAll(velocity: uxuyuz, vorticity: vort)

}





//let plane2DXY = loadThisDir.loadConsecutivePlanes()

//disk.analyse(dirs: dirs)
//disk.analyse_blob("*.step_*.")


//dirs = ["plot_vertical_axis.XYplane.V_4.Q_4.step_00000050.cut_21"]
//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00000050.cut_28", "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_29", "plot_slice.XZplane.V_4.Q_4.step_00000050.cut_30"]
//dirs = ["plot_axis.YZplane.V_4.Q_4.step_00000050.cut_21"]
//dirs = ["plot_slice.XZplane.V_4.Q_4.step_00002000.cut_133"]

//dirs = ["plot_rotational_capture.rotational_capture.V_4.Q_4.step_00000050.angle_15.blade_id_0"]


