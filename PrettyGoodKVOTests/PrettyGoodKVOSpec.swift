import Quick
import Nimble
@testable import PrettyGoodKVO

class Observer: PGKVOObserving { }

class PrettyGoodKVOSpec: QuickSpec {
    override func spec() {

        var observable: ObservableObject!
        var observedValue: String?
        var observer: Observer!
        var observationCount = 0

        describe("Observing something") {

            beforeEach {
                observable = ObservableObject()
                observedValue = nil
                observer = Observer()
                observationCount = 0
            }

            context("Observing nonoptional") {

                beforeEach {
                    observer.observe(observable, keyPath: "text", initialValue: observable.text) {
                        observedValue = $0.value
                    }
                }

                it("Should initially have observed the initial value") {
                    expect(observedValue).to(equal(""))
                }

                it("Should be able to observe a changed value") {
                    observable.text = "new value"
                    expect(observedValue).to(equal("new value"))
                }

            }

            context("Observing optional") {

                beforeEach {
                    observer.observe(observable, keyPath: "optionalText", initialValue: observable.optionalText) {
                        observedValue = $0.value
                        observationCount += 1
                    }
                }

                it("Should initially have observed the initial value") {
                    expect(observedValue).to(beNil())
                }

                it ("Should have observed two changes") {
                    observable.optionalText = "new value"
                    expect(observationCount).to(equal(2))
                }

                it("Should be able to observe a changed value") {
                    observable.optionalText = "new value"
                    expect(observedValue).toEventually(equal("new value"))
                }
            }
        }
    }
}
