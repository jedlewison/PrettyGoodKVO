import Quick
import Nimble
@testable import PrettyGoodKVO

class HashableTestClient: Hashable {
    var hashValue: Int {
        return 9
    }
}
func ==(lhs: HashableTestClient, rhs: HashableTestClient) -> Bool {
    return lhs === rhs
}

class WeakClientBoxSpec: QuickSpec {

    override func spec() {

        describe("Weak client box conformance to weak memory semantics") {

            var strongClient: AnyObject?
            var weakClientBox: WeakClientBox!

            beforeEach {
                strongClient = NSObject()
                weakClientBox = WeakClientBox(client: strongClient!)
            }

            context("the client is still alive") {

                it("should maintain a reference to the client") {
                    expect(weakClientBox.client).to(beIdenticalTo(strongClient))
                }

            }

            context("the client dies") {

                beforeEach {
                    strongClient = nil
                }

                it("should not maintain a reference to the client") {
                    expect(weakClientBox.client).to(beNil())
                }

            }

            afterEach {
                strongClient = nil
                weakClientBox = nil
            }


        }

        describe("Equality") {

            context("Two different weak client boxes with same client") {

                var strongClient: AnyObject!
                var weakClientBoxA: WeakClientBox!
                var weakClientBoxB: WeakClientBox!

                beforeEach {
                    strongClient = NSObject()
                    weakClientBoxA = WeakClientBox(client: strongClient)
                    weakClientBoxB = WeakClientBox(client: strongClient)
                }

                context("the client is still alive") {

                    it("The client boxes should be equal") {
                        expect(weakClientBoxA).to(equal(weakClientBoxB))
                    }

                }

                context("the client dies") {

                    beforeEach {
                        strongClient = nil
                    }
                    
                    it("The client boxes should still be") {
                        expect(weakClientBoxA).to(equal(weakClientBoxB))
                    }

                }
                
                afterEach {
                    strongClient = nil
                    weakClientBoxA = nil
                    weakClientBoxB = nil
                }
                
            }

            context("Two different weak client boxes with different clients, at least one of which returns a non-zero hashValue") {

                var strongClientA: AnyObject!
                var strongClientB: AnyObject!
                var weakClientBoxA: WeakClientBox!
                var weakClientBoxB: WeakClientBox!

                beforeEach {
                    strongClientA = NSObject()
                    strongClientB = HashableTestClient()
                    weakClientBoxA = WeakClientBox(client: strongClientA)
                    weakClientBoxB = WeakClientBox(client: strongClientB)
                }

                context("the clients are still alive") {

                    it("The client boxes should not be equal") {
                        expect(weakClientBoxA).toNot(equal(weakClientBoxB))
                    }

                }

                context("the clients die") {

                    beforeEach {
                        strongClientA = nil
                        strongClientB = nil
                    }

                    it("The client boxes should not be equal") {
                        expect(weakClientBoxA).toNot(equal(weakClientBoxB))
                    }

                }

                afterEach {
                    strongClientA = nil
                    strongClientB = nil
                    weakClientBoxA = nil
                    weakClientBoxB = nil
                }
                
            }

        }
        
    }
    
}
