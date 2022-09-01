//
//  File.swift
//  
//
//  Created by Stefan Urbanek on 01/09/2022.
//

import XCTest
@testable import Holon

protocol ConstraintTestProtocol {
    var graph: Graph! { get }
    var checker: ConstraintChecker! { get }
    
    func assertConstraintViolation(_ name: String,
                                   checker proposedChecker: ConstraintChecker?,
                                   file: StaticString,
                                   line: UInt)
    func assertConstraintViolations(_ names: [String],
                                   checker proposedChecker: ConstraintChecker?,
                                   file: StaticString,
                                   line: UInt)
    func assertNoViolation(checker proposedChecker: ConstraintChecker?,
                           file: StaticString,
                           line: UInt)
}

extension ConstraintTestProtocol {
    func assertConstraintViolation(_ name: String,
                                   checker proposedChecker: ConstraintChecker? = nil,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) {
        let checker: ConstraintChecker = proposedChecker ?? self.checker
        let violations = checker.check(graph: graph)

        XCTAssertEqual(violations.count, 1, file: file, line: line)

        if violations.count > 1 {
            let names = violations.map { $0.name }.joined(separator: ", ")
            XCTFail("Violated constraints: \(names)", file: file, line: line)
        }

        guard let violation = violations.first else {
            XCTFail(file: file, line: line)
            return
        }
        
        XCTAssertEqual(violation.name, name, file: file, line: line)
    }
    func assertConstraintViolations(_ names: [String],
                                   checker proposedChecker: ConstraintChecker? = nil,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) {
        let checker: ConstraintChecker = proposedChecker ?? self.checker
        let violations = checker.check(graph: graph)

        XCTAssertEqual(violations.count, names.count, file: file, line: line)

        let violationNames = violations.map { $0.name }
        
        XCTAssertEqual(Set(violationNames), Set(names), file: file, line: line)
    }

    func assertNoViolation(checker proposedChecker: ConstraintChecker? = nil,
                           file: StaticString = #filePath,
                           line: UInt = #line) {
        let checker: ConstraintChecker = proposedChecker ?? self.checker
        let violations = checker.check(graph: graph)

        XCTAssertEqual(violations.count, 0, file: file, line: line)

        if violations.count > 0 {
            let names = violations.map { $0.name }.joined(separator: ", ")
            XCTFail("Violated constraints: \(names)", file: file, line: line)
        }
    }

}
