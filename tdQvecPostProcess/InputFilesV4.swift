//
//  main.swift
//  TDQVecLib
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation


enum diskErrors: Error {
    case fileNotFound
    case directoryNotFound
    case fileNotReadable
    case fileNotJsonParsable
    case OtherDiskError
}



class InputFilesV4 {


    let version = 4

    let dataDirURL: URL

    init(withDataDir: String) throws {
        let home = FileManager.default.homeDirectoryForCurrentUser

        //TODO Check if exists
        self.dataDirURL = home.appendingPathComponent(withDataDir)
    }

    init(withDataDir: URL) throws {
        self.dataDirURL = withDataDir
    }



    //----- Working with directories


    func getDirURL(with dir: String) -> URL {

        let url = dataDirURL.appendingPathComponent(dir)
        return url
    }

    func mkDir(dir: String) {
    }

    func dirExists(with dir: String) -> Bool {
        return dataDirURL.appendingPathComponent(dir).hasDirectoryPath
    }

    func dirPath(with dir: String) -> String {
        return dataDirURL.appendingPathComponent(dir).absoluteString
    }



    //------------ Formatting directories

    private func format(step: Int) -> String {
        return String(format: "%08d", step)
    }

    private func formatDirRoot(name: String = "plot", type: dirType, QLength: Int, step: Int) -> String {
        return "\(name).\(type).V_\(version).Q_\(QLength).step_\(format(step: step))"
    }


    func formatXYPlaneDir(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatDirRoot(name: name, type: dirType.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"
    }


    func formatXZPlaneDir(name: String = "plot_slice", QLength: Int, step: Int, atJ:Int) -> String{

        let root = formatDirRoot(name: name, type: dirType.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    func formatYZPlaneDir(name: String = "plot_axis", QLength: Int, step: Int, atI:Int) -> String {

        let root = formatDirRoot(name: name, type: dirType.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }

    func formatVolumeDir(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatDirRoot(name: name, type: dirType.volume, QLength: QLength, step: step)
    }

    func formatCaptureAtBladeAngleDir(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: dirType.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    func formatAxisWhenBladeAngleDir(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: dirType.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }

    func formatRotatingSectorDir(name: String="plot", step: Int, angle: Int, QLength: Int) {
    }


    func formatDirDelta(delta: Int, fromDir: String) throws -> String {
        if let cut = getCut(fromDir: dir) {

            let replace: String = "cut_\(cut + delta)"

            let newDir = fromDir.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)
            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }

    func formatDirDelta(replaceCut: Int, fromDir: String) throws -> String {
        if let _ = getCut(fromDir: dir) {

            let replace: String = "cut_\(replaceCut)"

            let newDir = fromDir.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            //            print(fromDir, replace, newDir)
            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }




    //----------------------------------------------Query6 directories


    func getName(fromDir dir: String) -> String? {
        return dir.components(separatedBy: ".")[0]
    }

    func getDirType(fromDir dir: String) -> dirType? {

        if dir.contains("XYplane") {return .XYplane}
        else if dir.contains("XZplane") {return dirType.XZplane}
        else if dir.contains("YZplane") {return dirType.YZplane}
        else if dir.contains("volume") {return dirType.volume}
        else if dir.contains("XYplane") {return dirType.rotational}
            //            else if dir.contains("sector") {return dirType.sector}
        else {
            return nil
        }
    }

    func getVersion(fromDir dir: String) -> Int? {

        if let result = dir.range(of: #"V_([0-9]*)\."#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }

    func getQLength(fromDir: String) -> Int? {
        if let result = dir.range(of: #"Q_([0-9]*)\."#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }

    func getStep(fromDir: String) -> Int? {
        if let result = fromDir.range(of: #"step_([0-9]*)\."#, options: .regularExpression){
            let i = fromDir[result].index(fromDir[result].startIndex, offsetBy: 5)
            return Int(fromDir[result][i...])
        } else {
            return nil
        }
    }

    func getCut(fromDir: String) -> Int? {
        if let result = fromDir.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = fromDir[result].index(fromDir[result].startIndex, offsetBy: 4)
            return Int(fromDir[result][i...])
        } else {
            return nil
        }
    }



    //------------------------Working with bin and bin.json files



    private func formatQVecFileRoot(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(version)"
    }

    func formatQVecBin(name: String, idi: Int, idj: Int, idk: Int) -> String {
        return "\(formatQVecFileRoot(name, idi, idj, idk)).bin"
    }

    func formatNode000QVecBin(name: String) -> String {
        return formatQVecBin(name: name, idi: 0, idj: 0, idk: 0)
    }



} //end of class
