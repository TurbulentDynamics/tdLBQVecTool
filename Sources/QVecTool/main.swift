//
//  main.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 30/04/2019.
//

import ArgumentParser
import Foundation

import tdLB
import QVecLib

//Examples:
//./tdLBQVecTool -u SmallSampleData/*
//./tdLBQVecTool -c SmallSampleData/plot_output_np1_gridx44
//./tdLBQVecTool -u SmallSampleData/plot_output_np1_gridx44/plot.XZplane.V5.step_00000020.cut_14
//./tdLBQVecTool -a /path/to/outputdir
//./tdLBQVecTool --xzplane SmallSampleData/plot_output_np1_gridx44

//TODO
//./tdLBQVecTool --xzplane --step 800k-1m SmallSampleData/plot_output_np1_gridx44

struct tdLBQvecTool: ParsableCommand {

  enum ArgsErrors: Swift.Error {
    case blobInvalid
  }

  ///dirs can be either an Output Directory (containing lots of PlotDirs) or a list of individual PlotDirs
  @Argument() var dirs: [String]

//  @Flag(name: [.customShort("d"), .long], help: "Process RootDir")
//  var rootDir: Bool = false

  @Flag(name: .long, help: "Process All Sub Directories")
  var all: Bool = false

  @Flag(name: .shortAndLong, help: "Process from these step directories")
  var fromStep: Bool = false

  @Flag(name: .shortAndLong, help: "Process until these step directories")
  var toStep: Bool = false

  @Flag(name: .shortAndLong, help: "Process all XY Plane Sub Directories")
  var xyplane: Bool = false

  @Flag(name: .shortAndLong, help: "Process all YZ Plane Sub Directories")
  var yzplane: Bool = false

  @Flag(name: [.customShort("z"), .long], help: "Process all XZ Plane Sub Directories")
  var xzplane: Bool = false

  @Flag(name: [.customShort("a"), .long], help: "Process all orthoAngle Sub Directories")
  var orthoAngle: Bool = false

  @Flag(name: [.long], help: "Process all Full Volume Sub Directories")
  var volume: Bool = false

  @Flag(
    name: [.customShort("n"), .long], help: "Analyse the Directories only (ie No output created)")
  var analyseOnly: Bool = false

  @Flag(name: .shortAndLong, help: "Overwrite files if they already exist")
  var overwrite: Bool = false

  @Flag(name: .shortAndLong, help: "Specifies ux, uy and uz only")
  var uxyz: Bool = false

  @Flag(name: [.customShort("c"), .long], help: "Specifies vorticity only")
  var vorticity: Bool = false

  @Flag(name: [.customShort("v"), .long], help: "Verbose output")
  var verbose: Bool = false

  func run() throws {

    var processPlotDirs = [PlotDirKind]()
    var processOptions = [OutputOptions]()

    if xyplane { processPlotDirs.append(.xyPlane) }
    if xzplane { processPlotDirs.append(.xzPlane) }
    if yzplane { processPlotDirs.append(.yzPlane) }
//    if orthoAngle { processPlotDirs.append(.orthoAngle) }
//    if volume { processPlotDirs.append(.volume) }

    if all {
          processPlotDirs = PlotDirKind.allCases
    }

    if overwrite { processOptions.append(.overwrite) }
    if uxyz { processOptions.append(.velocities) }
    if vorticity { processOptions.append(.vorticity) }
    if verbose { processOptions.append(.verbose) }

    //Set up some defaults
    if processPlotDirs.isEmpty && dirs.count <= 3 {
        processPlotDirs = PlotDirKind.allCases
    }
    if processOptions.isEmpty {
      print("Using default: all options")
      processOptions = [.velocities, .vorticity]
    }

    print(dirs)
    let outputTree = try DiskOutputTree(dirs: dirs)

    let q = QVecLib<Float32>(outputTree: outputTree, dirs: dirs, kind: processPlotDirs)

    q.analyse()

    if !analyseOnly {
      q.process(opts: processOptions)
    }

}

}

tdLBQvecTool.main()
