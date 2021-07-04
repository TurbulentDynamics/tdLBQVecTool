//
//  main.swift
//
//
//  Created by Niall Ó Broin on 21/06/2020.
//

import ArgumentParser
import Foundation
import tdLB

struct LSQVec: ParsableCommand {

  //lsQVec "glob"
  //Lists files with glob in some sort of summary

  @Argument() var glob: [String]

  //lsQVec --rmglob "glob"
  @Flag(name: .short, help: "Removes all files with the glob")
  var rmglob: Bool = false

  //lsQVec --check_step_integrety "glob"
  //shows:
  //Batch «plot_axis__Q4_step_*»:
  //Gap size      : 20
  //Files present : [200000,200040-222800]
  //Files missing : [200020]
  @Flag(name: .shortAndLong, help: "Check if there are any gaps in the steps")
  var check_step_integrety: Bool = false

  //lsQVec --break_step "plot_XY*" 20 #Quotes are necessary
  @Flag(name: .shortAndLong, help: "Moves files into subfolders based on step group")
  var break_step: Bool = false

  func run() throws {

    if glob.isEmpty {
      print("Assuming glob is \"*\"")
    }

  }  //end of run

}

LSQVec.main()
