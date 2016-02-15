//
//  ObservingViewController.m
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/14/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

@import PrettyGoodKVO;
#import "ObservingViewController.h"

#define keypath(OBJ, PATH) "" ? @ # PATH : (__typeof__(^ NSString * { (void)((__typeof__(OBJ))nil).PATH; return nil; }())) nil

@interface SomeAwesomeObservableClass : NSObject

@property (nonatomic) NSInteger awesomeProperty;

@end

@interface ObservingViewController ()

@property (nonatomic) SomeAwesomeObservableClass *somethingAwesome;

@end

@implementation ObservingViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self pgkvo_observe:self.somethingAwesome
             forKeyPath:keypath(self.somethingAwesome, awesomeProperty)
                options:NSKeyValueObservingOptionNew
                closure:^(typeof(self) _Nonnull observer, typeof(self.somethingAwesome) _Nonnull observed, NSDictionary<NSString *,id> * _Nullable changes) {
                    if (observed.awesomeProperty == 99) {
                        [observer doSomethingAwesomeNow];
                    }
                }];

    [self pgkvo_unobserve:self.somethingAwesome
               forKeyPath:keypath(self.somethingAwesome, awesomeProperty)];
}

- (void)doSomethingAwesomeNow {

}

@end
