//
//  QVecLib.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation
import tdLB

public enum OutputOptions {
    case velocities
    case vorticity
    case overwrite
    case verbose
}

public enum Reference {
    case relative
    case absolute
}

public struct QVecLib<T: BinaryFloatingPoint> {
    
    let outputTree: DiskOutputTree
    
    var plotDirByStep = [Int: [URL]]()
    
    var xy = Velocity2DPlaneOrthoMultiXY<T>()
    var xz = Velocity2DPlaneOrthoMultiXZ<T>()
    var yz = Velocity2DPlaneOrthoMultiYZ<T>()
    
    //    var orthoAngle
    
    public init(outputTree: DiskOutputTree) {
        self.outputTree = outputTree
        groupByStep(dirs: outputTree.findAllDirs())
    }
    
    
    private mutating func groupByStep(dirs: [URL]) {
        
        for p in dirs {
            
            if let hasStep = outputTree.step(dir: p) {
                
                if !plotDirByStep.keys.contains(hasStep) {
                    
                    self.plotDirByStep[hasStep] = [p]
                }
            }
        }
    }
    
    /// Function to estimate the amount of time to process the files.  Could be 1000's
    public func analyse() {
        
        //DEBUG
        for (step, plotDirs) in self.plotDirByStep {
            for p in plotDirs {
                //TODO
                print("TODO: Analysing: step \(step), dir \(p.path)")
            }
        }
    }
    
    public mutating func process(opts: [OutputOptions]) {
        
        for (_, plotDirs) in self.plotDirByStep {
            
            //Load all files by Step
            for plotDir in plotDirs {
                
                switch self.outputTree.dirKind(dir: plotDir) {
                
                case .XYPlane:
                    xy.loadPlane(withDir: plotDir)
                case .XZPlane:
                    xz.loadPlane(withDir: plotDir)
                case .YZPlane:
                    yz.loadPlane(withDir: plotDir)
                case .OrthoAngle:
                    continue
                case .Volume:
                    continue
                case .none:
                    continue
                }
            }
            
            
            //Process all files by Step
            for plotDir in plotDirs {
                guard let cutAt = outputTree.cutAt(dir: plotDir) else {
                    continue
                }
                
                if opts.contains(.velocities) {
                    
                    
//                    let fm = FileManager.default
//                    let filesExists =
//                        fm.fileExists(atPath: self.outputTree.rho(for: dir).path) &&
//                        fm.fileExists(atPath: self.outputTree.ux(for: dir).path) &&
//                        fm.fileExists(atPath: self.outputTree.uy(for: dir).path) &&
//                        fm.fileExists(atPath: self.outputTree.uz(for: dir).path)
//                    
//                    
//                    guard overwrite == false && filesExists else {
//                        print("Files rho and ux, uy, uz already exist and overwrite = false.")
//                        return
//                    }
//                    
                    
                        xy.writeVelocities(to: plotDir, at: cutAt, overwrite: opts.contains(.overwrite))
                        xz.writeVelocities(to: plotDir, at: cutAt, overwrite: opts.contains(.overwrite))
                        yz.writeVelocities(to: plotDir, at: cutAt, overwrite: opts.contains(.overwrite))
                }
                
                if opts.contains(.vorticity) {
                    
//                    let fm = FileManager.default
//                    guard overwrite == false && fm.fileExists(atPath: file.path) else {
//                        print("Vorticity file already exists and overwrite = false.")
//                        return
//                    }

                        

                    
                    
                        if xy.p.keys.contains(cutAt-1) && xy.p.keys.contains(cutAt+1) {
                            if let vort = xy.calcVorticity(at: cutAt) {
                                let fileName = outputTree.vorticity(for: plotDir)
                                vort.writeVorticity(to: fileName, overwrite: opts.contains(.overwrite))
                            } else {
                                print("Cannot call vorticity, no files at k \(cutAt-1), \(cutAt+1)")
                            }
                        
                    }
                    
                        if xz.p.keys.contains(cutAt-1) && xz.p.keys.contains(cutAt+1) {
                            if let vort = xy.calcVorticity(at: cutAt) {
                                let fileName = outputTree.vorticity(for: plotDir)
                                vort.writeVorticity(to: plotDir, overwrite: opts.contains(.overwrite))
                            } else {
                                print("Cannot call vorticity, no files at j \(cutAt-1), \(cutAt+1)")                        }
                        }
                    }
                    
                        if yz.p.keys.contains(cutAt-1) && yz.p.keys.contains(cutAt+1) {
                            let fileName = outputTree.vorticity(for: plotDir)
                            if let vort = yz.calcVorticity(at: cutAt) {
                                vort.writeVorticity(to: plotDir, overwrite: opts.contains(.overwrite))
                            } else {
                                print("Cannot call vorticity, no files at i \(cutAt-1), \(cutAt+1)")                        }
                        }
                    }
                }
                
            }//end of for plotDir in steps
        }
    }//end of struct
    
}
