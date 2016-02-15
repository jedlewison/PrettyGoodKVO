//
//  ViewController.swift
//  HostApp
//
//  Created by Jed Lewison on 2/5/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import UIKit
import KVOController
import PrettyGoodKVO

func measureBlock(@noescape block: () -> ()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    block()
    let stopTime = CFAbsoluteTimeGetCurrent()
    debugPrint((stopTime-startTime)*1000)
}

var observabledeinits = 0
var observationCount = 0

public func incrementObservableDeinits() {
    NSOperationQueue.mainQueue().addOperationWithBlock {
        observabledeinits += 1
    }
}

public func incrementObservationCount() {
    NSOperationQueue.mainQueue().addOperationWithBlock {
        observationCount += 1
    }
}


class ObservableObject: NSObject, PGKVOObserving {
        deinit {
            incrementObservableDeinits()
        }

    dynamic var value: NSIndexPath? = NSIndexPath(forItem: 0, inSection: 99)
    dynamic var kind: PGKVOChangeValueKind = .Initial

    dynamic var text: String = "nonoptional"

    func startObservingSelf() {
        observe(self, keyPath: "text", initialValue: text) {
            change in
            debugPrint(change)
        }
    }

}

enum ObservationMode {
    case None
    case KVOController
    case PrettyGoodKVOSwift
    case PrettyGoodKVOObjc
}

class Observationist: NSObject, PGKVOObserving {
    let opQ = NSOperationQueue()
    let obCount = 2000

    var obsCount = 0

    func incrementOpsCount() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.obsCount += 1
        }
    }

    func startObserving(mode: ObservationMode) {
        print(mode)
        self.KVOController = nil
        let ops: [[NSOperation]] = (0..<obCount).map {
            obsCount = 0
            let index = $0
            let changeText = "\($0)"

            var observableObject: ObservableObject! = ObservableObject()

            let addObserversOperation: NSBlockOperation

            switch mode {
            case .None:
                addObserversOperation = NSBlockOperation()
            case .KVOController:
                addObserversOperation = NSBlockOperation {

                    self.KVOController.observe(observableObject, keyPath: "value", options: [.Old, .New, .Initial]) {
                        [weak self] observation in
                        self?.incrementOpsCount()
                        incrementObservationCount()
                    }

                    self.KVOController.observe(observableObject, keyPath: "text", options: [.Old, .New, .Initial]) {
                        [weak self] observation in
                        self?.incrementOpsCount()
                        incrementObservationCount()
                    }

                    self.KVOController.observe(observableObject, keyPath: "kind", options: [.Old, .New, .Initial]) {
                        [weak self] observation in
                        self?.incrementOpsCount()
                        incrementObservationCount()
                    }
                }

            case .PrettyGoodKVOSwift:
                addObserversOperation = NSBlockOperation {


                    self.observe(observableObject, keyPath: "value", initialValue: observableObject.value, resultsQueue: .mainQueue()) {
                        [weak self] (change) -> () in
                        self?.incrementOpsCount()
                        incrementObservationCount()
                        if change.kind == .Change {
                            change.unobserveAllKeyPaths()
                        }
                    }

                    self.observe(observableObject, keyPath: "kind", initialValue: observableObject.kind, resultsQueue: .mainQueue()) {
                        [weak self] (change) -> () in
                        self?.incrementOpsCount()
                        incrementObservationCount()
                        change.unobserveKeyPath()
                    }

                    self.observe(observableObject, keyPath: "text", initialValue: observableObject.text, resultsQueue: .mainQueue()) {
                        [weak self] (change) -> () in
                        incrementObservationCount()

                        self?.incrementOpsCount()
                    }
                }

            case .PrettyGoodKVOObjc:
                addObserversOperation = NSBlockOperation {

                    self.pgkvo_observe(observableObject, forKeyPath: "value", options: [.Old, .New]) {
                        [weak self] changes in
                        incrementObservationCount()

                        self?.incrementOpsCount()
                    }

                    self.pgkvo_observe(observableObject, forKeyPath: "kind", options: [.Old, .New]) {
                        [weak self] changes in
                        incrementObservationCount()

                        self?.incrementOpsCount()
                    }

                    self.pgkvo_observe(observableObject, forKeyPath: "text", options: [.Old, .New]) {
                        [weak self] changes in
                        incrementObservationCount()

                        self?.incrementOpsCount()
                    }
                }

            }


            let blockOp = NSBlockOperation {
                observableObject.text = changeText
                observableObject.value = nil
            }

            let blockOp2 = NSBlockOperation {
                observableObject.text = changeText + changeText
                observableObject.kind = .Change
                observableObject.value = NSIndexPath(forItem: index, inSection: 0)
            }

            let blockOp3 = NSBlockOperation {
                observableObject.kind = .Initial
                observableObject.text = changeText
                observableObject.value = nil
            }

            let block4 = NSBlockOperation {
                observableObject = nil
            }


            blockOp.addDependency(addObserversOperation)
            blockOp2.addDependency(addObserversOperation)
            blockOp3.addDependency(addObserversOperation)

            block4.addDependency(blockOp)
            block4.addDependency(blockOp2)
            block4.addDependency(blockOp3)

            return [addObserversOperation, blockOp,  blockOp2, blockOp3, block4]
        }

        opQ.addOperations(ops.flatMap{$0}, waitUntilFinished: true)
    }

}

class ViewController: UIViewController, PGKVOObserving {

    let observationist = Observationist()

    var obsMode: ObservationMode = .None

    @IBAction func didStart(sender: UIButton) {
        observabledeinits = 0
        observationCount = 0
            switch sender.tag {
            case 0:
                obsMode = .None
            case 1:
                obsMode = .KVOController
            case 2:
                obsMode =  .PrettyGoodKVOSwift
            case 3:
                obsMode = .PrettyGoodKVOObjc
            default:
                break
            }

        debugPrint("-------")
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { () -> Void in
            autoreleasepool {
                measureBlock {
                    self.observationist.startObserving(self.obsMode)
                }
            }

        }

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let adsf = CADisplayLink(target: self, selector: Selector("updateDeinits:"))
        adsf.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        observe(scrollView, keyPath: "contentOffset", initialValue: scrollView.contentOffset) {
            change in
            debugPrint(change)
        }


    }
    @IBOutlet var deinitLabel: UILabel!
    func updateDeinits(sender: CADisplayLink) {
        deinitLabel.text = "Observable: \(observabledeinits) || Proxy: UN || Obs: \(observationCount)"
    }

    @IBOutlet var scrollView: UIScrollView!

}

