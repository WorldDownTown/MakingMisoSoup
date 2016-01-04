//
//  MisoSoupMaker.swift
//  MakingMisoSoup
//
//  Created by shoji on 2016/01/04.
//  Copyright © 2016年 com.shoji. All rights reserved.
//

import Foundation
import ReactiveCocoa

typealias Temperature = Int
typealias Ingredient = String
typealias Ingredients = [Ingredient]
typealias SaucePan = [Ingredient]

class MisoSoupMaker {

    private let boilingTemperature: Temperature = 100
    private let cooledTemperature: Temperature = 60
    private let name = "miso soup (味噌汁)"
    private var ingredients: Ingredients = ["water (水)", "dashi (ダシ)", "tofu (豆腐)", "wakame (ワカメ)",
    "mirin (みりん)", "miso (味噌)", "green onion (青葱)"]

    // Holds the cooked incredients.
    private var saucePan = SaucePan()

    init() {
        print("Cooking \(name)")
        cookMisoSoup()
    }

    private func cookMisoSoup() {
        addIngredient(boilIsComplete: false, coolingIsComplete: false)
    }

    private func noop() {
    }

    private func addIngredient(boilIsComplete boilIsComplete: Bool, coolingIsComplete: Bool) {
        guard ingredients.count > 0 else {
            return
        }

        // Grab the next ingredient.
        ingredientsSignal().observeNext { ingredient in
            print("Adding ingredient \(ingredient).")
            self.saucePan.append(ingredient)
            print("Saucepan contains \(self.saucePan)")

            if !boilIsComplete && !coolingIsComplete && self.saucePan.contains("water (水)") && self.saucePan.count == 1 {
                // Let the water come to a boil before adding the dashi, tofu, wakame, and mirin.
                self.observeWaterTemperature()  // let the water boil
            } else if boilIsComplete && !coolingIsComplete && self.saucePan.count == 5 {
                // Don't add more ingredients until the water has cooled.
                self.noop()
            } else {
                self.addIngredient(boilIsComplete: boilIsComplete, coolingIsComplete: coolingIsComplete)
            }
        }
    }

    private func observeWaterTemperature() {
        print("Watching the water.")

        temperatureSignal().observeOn(UIScheduler()).observeNext { temperature in
            guard let temperature = temperature else { return }

            if temperature == self.boilingTemperature {
                print("Water is boiling.")
                self.addIngredient(boilIsComplete: true, coolingIsComplete: false)
            } else if temperature == self.cooledTemperature {
                print("Water is cooled.")
                self.addIngredient(boilIsComplete: true, coolingIsComplete: true)
            }
        }
    }

    private func ingredientsSignal() -> Signal<Ingredient, NoError> {
        return Signal { observer in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if let ingredient = self.ingredients.first {
                    observer.sendNext(ingredient)
                    self.ingredients.removeFirst()
                } else {
                    print("Disposing ingredient signal.")
                    observer.sendCompleted()
                }
            }
            return nil
        }
    }

    private func temperatureSignal() -> Signal<Temperature?, NoError> {
        var count = 0

        return Signal { observer in

            var processTemperatureAfterTime: (ReactiveCocoa.Observer<Temperature?, NoError> -> Void)!

            processTemperatureAfterTime = { (observer: ReactiveCocoa.Observer<Temperature?, NoError>) in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    if count == 10 {
                        observer.sendNext(self.boilingTemperature)
                    } else if count == 30 {
                        observer.sendNext(self.cooledTemperature)
                    } else if count == 39 {
                        print("Disposing temperature signal.")
                        observer.sendCompleted()
                    } else {
                        observer.sendNext(nil)
                    }

                    if count != 39 {
                        processTemperatureAfterTime(observer)
                    }

                    count++
                }
            }

            processTemperatureAfterTime(observer)

            return nil
        }
    }
}
