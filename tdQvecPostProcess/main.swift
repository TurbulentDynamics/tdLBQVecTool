//
//  main.swift
//  TDQvecLib
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import Foundation



print("hello")


let help: Bool = CommandLine.arguments.contains("-h")
if help {
    print("USAGE: td_Qvec_post_process [options] <directories>")
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

print(dirs)


