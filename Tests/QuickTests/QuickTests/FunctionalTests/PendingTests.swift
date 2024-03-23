import XCTest
import Quick
import Nimble

private var oneExampleBeforeEachExecutedCount = 0
private var onlyPendingExamplesBeforeEachExecutedCount = 0

class FunctionalTests_PendingSpec_Behavior: Behavior<Void> {
    override static func spec(_ aContext: @escaping () -> Void) {
        it("an example that will not run") {
            expect(true).to(beFalsy())
        }
    }
}
class FunctionalTests_PendingSpec: QuickSpec {
    override class func spec() {
        sharedExamples("shared pending behavior") { aContext in
            it("will not run") {
                fail()
            }
        }

        xit("an example that will not run") {
            expect(true).to(beFalsy())
        }
        pending("it doesn't run code inside a pending at all") {
            fatalError("this should not be run")
        }
        xitBehavesLike(FunctionalTests_PendingSpec_Behavior.self) { () -> Void in }
        xitBehavesLike("shared pending behavior")
        xitBehavesLike("shared pending behavior", sharedExampleContext: { [:] })
        describe("a describe block containing only one enabled example") {
            beforeEach { oneExampleBeforeEachExecutedCount += 1 }
            it("an example that will run") {}
            pending("an example that will not run") {}
        }

        describe("a describe block containing only pending examples") {
            beforeEach { onlyPendingExamplesBeforeEachExecutedCount += 1 }
            pending("an example that will not run") {}
        }
        describe("a describe block with a disabled context that will not run") {
            xcontext("these examples will not run") {
               it("does not run") {
                  fail()
               }
            }
        }
        xdescribe("a describe block that will not run") {
            it("does not run") {
               fail()
            }
        }
    }
}

final class PendingTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (PendingTests) -> () throws -> Void)] {
        return [
            ("testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail", testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail),
            ("testPendingExamplesAllAreMarkedAsSkipped", testPendingExamplesAllAreMarkedAsSkipped),
            ("testBeforeEachOnlyRunForEnabledExamples", testBeforeEachOnlyRunForEnabledExamples),
            ("testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples", testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples),
        ]
    }

    func testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail() {
        let result = qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertTrue(result!.hasSucceeded)
    }

    func testPendingExamplesAllAreMarkedAsSkipped() {
        let result = qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertEqual(result?.skipCount, 9)
    }

    func testBeforeEachOnlyRunForEnabledExamples() {
        oneExampleBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertEqual(oneExampleBeforeEachExecutedCount, 1)
    }

    func testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples() {
        onlyPendingExamplesBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertEqual(onlyPendingExamplesBeforeEachExecutedCount, 0)
    }
}
