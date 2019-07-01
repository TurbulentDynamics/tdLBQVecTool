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
    case NotImplementedYet
}



class InputFilesV4 {

    let version = 4

    let dataDirURL: URL

//    var setDir: URL

    init(withDataDir: String) throws {

        let home = FileManager.default.homeDirectoryForCurrentUser
        self.dataDirURL = home.appendingPathComponent(withDataDir)

        //        if !self.dataDirURL.isURL {
        //            throw diskErrors.directoryNotFound
        //        }
    }


    init(withDataDir: URL) {
        self.dataDirURL = withDataDir
    }


    private func format(step: Int) -> String {
        //    sstream << std::setw(8) << std::setfill('0') << patch::to_string(step);
        return String(format: "%08d", step)
    }

    private func formatDirRoot(name: String = "plot", type: dirType, QLength: Int, step: Int) -> String {
        return "(name).\(type).V_\(version).Q_\(QLength).step_\(format(step: step))"
    }



//    func loadDir(_ loadDir: String){
//        dir = dataDirURL.appendPathComponent(loadDir)
//    }
//
//    func mkDir() throws -> URL {
//    }
//
//    func mkXYPlaneDir(name: String = "plot", QLength: Int, step: Int, atK:Int) throws -> URL {
//    }



    func getXYPlaneDirURL(name: String = "plot", QLength: Int, step: Int, atK:Int) throws -> URL {

        let root = formatDirRoot(name: name, type: dirType.XYplane, QLength: QLength, step: step)
        let dir = "\(root).cut_\(atK)"
        let url = dataDirURL.appendingPathComponent(dir)
        return url
    }

//    func isXYPlane() -> Bool {
//        return setDir.lastPathComponent.contains(".XYPlane.")
//    }



    func getXZPlaneDirURL(name: String = "plot", QLength: Int, step: Int, atJ:Int) throws -> URL {

        let root = formatDirRoot(name: name, type: dirType.XZplane, QLength: QLength, step: step)
        let dir = "\(root).cut_\(atJ)"
        let url = dataDirURL.appendingPathComponent(dir)
        return url

    }


    func getYZPlaneDirURL(name: String = "plot", QLength: Int, step: Int, atI:Int) throws -> URL {

        let root = formatDirRoot(name: name, type: dirType.YZplane, QLength: QLength, step: step)
        let dir = "\(root).cut_\(atI)"
        let url = dataDirURL.appendingPathComponent(dir)
        return url

    }


    func getVolumeDirURL(name: String = "volume", QLength: Int, step: Int) throws -> URL {

        let dir = formatDirRoot(name: name, type: dirType.volume, QLength: QLength, step: step)
        let url = dataDirURL.appendingPathComponent(dir)
        return url

    }

    func getCaptureAtBladeAngleDirURL(step: Int, angle: Int, bladeId: Int, QLength: Int, name: String="plot") throws -> URL {

        let root = formatDirRoot(name: name, type: dirType.rotational, QLength: QLength, step: step)
        let dir = "\(root).angle_\(angle).blade_id_\(bladeId)"
        let url = dataDirURL.appendingPathComponent(dir)
        return url
    }

    func getAxisWhenBladeAngleDirURL(step: Int, angle: Int, QLength: Int, name: String="plot") throws -> URL {

        let root = formatDirRoot(name: name, type: dirType.YZplane, QLength: QLength, step: step)
        let dir = "\(root).angle_\(angle)"

        let url = dataDirURL.appendingPathComponent(dir)
        return url
    }



    func getRotatingSectorDir(step: Int, angle: Int, QLength: Int, name: String="plot") {
    }


    //----------------------------------------------Working on directories


    func getName(fromDir dir: String) -> String? {
        return dir.components(separatedBy: ".")[0]
    }

    func getDirType(fromDir dir: String) -> dirType? {

        if dir.contains("XYplane") {return .XYplane}
        else if dir.contains("XZplane") {return dirType.XZplane}
        else if dir.contains("YZplane") {return dirType.YZplane}
        else if dir.contains("volume") {return dirType.volume}
        else if dir.contains("XYplane") {return dirType.rotational}
            //else if dir.contains("sector") {return dirType.sector}
        else {
            return nil
        }
    }

    func getVersion(fromDir dir: String) -> Int? {

        if let result = dir.range(of: #"V_[0-9]"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }


    func getQLength(fromDir: String) -> Int? {
        if let result = dir.range(of: #"Q_[0-9]"#, options: .regularExpression){
            let i = dir[result].index(dir[result].startIndex, offsetBy: 2)
            return Int(dir[result][i...])
        } else {
            return nil
        }
    }


    func getStep(fromDir: String) -> Int? {
        if let result = fromDir.range(of: #"step_[0-9]"#, options: .regularExpression){
            let i = fromDir[result].index(fromDir[result].startIndex, offsetBy: 5)
            return Int(fromDir[result][i...])
        } else {
            return nil
        }
    }

    func getCut(fromDir: String) -> Int? {
        if let result = fromDir.range(of: #"cut_[0-9]"#, options: .regularExpression){
            let i = fromDir[result].index(fromDir[result].startIndex, offsetBy: 4)
            return Int(fromDir[result][i...])
        } else {
            return nil
        }
    }

    func getDirDeltaURL(delta: Int, fromDir: String) -> URL? {
        if let cut = getCut(fromDir: dir) {
            let newDir = fromDir.replacingOccurrences(of: #"cut_([0-9])"#, with: "cut_\(cut)", options: .regularExpression)

            let url = dataDirURL.appendingPathComponent(newDir)
            return url
        } else {
            return nil
        }
    }



    //------------------------Working with the bin and bin.json files




    private func formatQVecFileRoot(_ dir: String, _ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(dir)/\(name).node.\(idi).\(idj).\(idk).V\(version)"
    }

    func getQVecBinURL(dir: String, name: String, idi: Int, idj: Int, idk: Int) -> String {

        return "\(formatQVecFileRoot(dir, name, idi, idj, idk)).bin"
    }

    func getNode000QVecBinURL(dir: String, name: String) -> String {
        return getQVecBinURL(dir: dir, name: name, idi: 0, idj: 0, idk: 0)
    }











} //end of class
