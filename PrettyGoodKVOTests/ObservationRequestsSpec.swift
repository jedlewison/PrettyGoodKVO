import Quick
import Nimble
@testable import PrettyGoodKVO

let defaultClosure: PGKVOObservationClosure = { _, _, _ in }

class ObservationRequestsSpec: QuickSpec {
    override func spec() {

        describe("The observation requests struct") {

            var requests: ObservationRequests!
            var client: NSObject!
            var client2: NSObject!

            beforeEach {
                client = NSObject()
                client2 = NSObject()
                requests = ObservationRequests()
            }

            describe("Adding the first request") {

                var addObserverBlockDidFire = false

                beforeEach {
                    requests.addForClient(client, keyPath: "kp0", options: [.New], closure: defaultClosure, observationBlock: { addObserverBlockDidFire = true } )
                }

                it("should fire the add observer block") {
                    expect(addObserverBlockDidFire).to(beTrue())
                }

                it("should return one requests for a matching observation") {
                    let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                    expect(reqs.count).to(equal(1))
                }

                it("should return zero requests for a mismatching observation") {
                    let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeOldKey])
                    expect(reqs.count).to(equal(0))
                }


                context("Adding another request identical except for client") {

                    var addObserverBlockDidFireAgain = false

                    beforeEach {
                        requests.addForClient(client2, keyPath: "kp0", options: [.New], closure: defaultClosure, observationBlock: { addObserverBlockDidFireAgain = true } )
                    }

                    it("should fire the add observer block") {
                        expect(addObserverBlockDidFireAgain).to(beFalse())
                    }

                    it("should return one keypath to remove") {
                        expect(requests.allKeyPaths.count).to(equal(1))
                    }

                    it("should return two requests for a matching observation") {
                        let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                        expect(reqs.count).to(equal(2))
                    }

                    it("should return zero requests for a mismatching observation") {
                        let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeOldKey])
                        expect(reqs.count).to(equal(0))
                    }

                    context("Only one client has an external strong reference to it") {

                        beforeEach {
                            client2 = nil
                        }

                        it("should still have one keypath") {
                            expect(requests.allKeyPaths.count).to(equal(1))
                        }

                        it("should still return two requests for a matching observation") {
                            let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                            expect(reqs.count).to(equal(2))
                        }

                        it("Only one matching requests should have a nil client") {
                            let nilReqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey]).filter { $0.client.isNilClient }
                            expect(nilReqs.count).to(equal(1))
                        }

                        context("Removing the requests for the nil client") {

                            var keypathsToRemove = Set<String>()

                            beforeEach {
                                keypathsToRemove = requests.dropNilClients()
                            }

                            it("should return no keypath to remove") {
                                expect(keypathsToRemove.count).to(equal(0))
                            }

                            it("report one keypath being observaed") {
                                expect(requests.allKeyPaths.count).to(equal(1))
                            }
                            
                            it("should return just one request for a matching observation") {
                                let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                                expect(reqs.count).to(equal(1))
                            }

                        }

                        context("Neither client has an external strong reference to it") {

                            beforeEach {
                                client = nil
                                client2 = nil
                            }

                            it("should still have one keypath") {
                                expect(requests.allKeyPaths.count).to(equal(1))
                            }

                            it("should still return two requests for a matching observation") {
                                let reqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                                expect(reqs.count).to(equal(2))
                            }

                            it("Both matching requests should have nil clients") {
                                let nilReqs = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey]).filter { $0.client.isNilClient }
                                expect(nilReqs.count).to(equal(2))
                            }

                            context("Removing the requests for the nil clients") {

                                var keypathsToRemove = Set<String>()

                                beforeEach {
                                    keypathsToRemove = requests.dropNilClients()
                                }

                                it("should return one keypath to remove") {
                                    expect(keypathsToRemove.count).to(equal(1))
                                }

                                it("report no keypaths being observaed") {
                                    expect(requests.allKeyPaths.count).to(equal(0))
                                }

                            }
                            
                        }

                    }

                }

                context("Adding another request identical except for options") {

                    var addObserverBlockDidFireAgain = false

                    beforeEach {
                        requests.addForClient(client, keyPath: "kp0", options: [.Old], closure: defaultClosure, observationBlock: { addObserverBlockDidFireAgain = true } )
                    }

                    it("should fire the add observer block") {
                        expect(addObserverBlockDidFireAgain).to(beTrue())
                    }

                    it("should return one keypath to remove") {
                        expect(requests.allKeyPaths.count).to(equal(1))
                    }

                    it("should return one requests for a matching observation") {
                        let reqsA = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey])
                        expect(reqsA.count).to(equal(1))

                        let reqsB = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeOldKey])
                        expect(reqsB.count).to(equal(1))
                    }

                    it("should return two requests for an observation that matches two requests") {
                        let reqsA = requests.requestsForKeyPath("kp0", changeKeys: [NSKeyValueChangeNewKey,NSKeyValueChangeOldKey])
                        expect(reqsA.count).to(equal(2))
                    }

                }

            }

            afterEach {
                requests = nil
                client = nil
                client2 = nil
            }
        }
    }
    
}
