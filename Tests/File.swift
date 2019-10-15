//
//  File.swift
//  
//
//  Created by Nile Ó Broin on 15/10/2019.
//
import XCTest
@testable import tdQVecCore



import Foundation


class tdQVecCore: XCTestCase {
    func testInitSetsTitle() {
        let todo = Todo(title: "test", completed: false, order: 1)
        XCTAssertEqual(todo.title, "test", "Incorrect title")
    }
}

