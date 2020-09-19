//
//  NobelPrizeDataParser.swift
//  TimeTravelApp
//
//  Created by Srivalli Kanchibotla on 9/14/19.
//  Copyright © 2019 Srivalli Kanchibotla. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct NobelPrizeLaureates {
    var id : Int
    var year: Int
    var latitude: Double
    var longitude: Double
    var category: String
    var died: String
    var diedCity: String
    var bornCity: String
    var born: String
    var surname: String
    var firstName: String
    var motivation: String
    var city: String
    var bornCountry: String
    var diedCountry: String
    var country: String
    var gender: String
    var name: String
    
}

class NobelPrizeDataParser {
    
    public static let shared = NobelPrizeDataParser()
    
    func dataParser() -> [NobelPrizeLaureates] {
        
        var jsonResult: [NobelPrizeLaureates] = []
        var jsonData: [[String: Any]] = []
        guard let jsonFile = Bundle.main.url(forResource: "nobel-prize-laureates", withExtension: "json") else { return jsonResult }
        
        do {
            let data = try Data(contentsOf: jsonFile)
            jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] ?? []
            for data in jsonData {
                if let id = data["id"] as? Int,
                    let location = data["location"] as? [String: Double],
                    let year = data["year"] as? String, let yearInt = Int(year),
                    let category = data["category"] as? String, let died = data["died"] as? String,
                    let diedcity = data["diedcity"] as? String, let borncity = data["borncity"] as? String,
                    let born = data["born"] as? String, let surname = data["surname"] as? String,
                    let firstname = data["firstname"] as? String, let motivation = data["motivation"] as? String,
                    let city = data["city"] as? String, let borncountry = data["borncountry"] as? String,
                    let diedcountry = data["diedcountry"] as? String, let country = data["country"] as? String,
                    let gender = data["gender"] as? String, let name = data["name"] as? String {
                    
                        let nobelPrizeData = NobelPrizeLaureates(id: id, year: yearInt, latitude: location["lat"] ?? 0, longitude: location["lng"] ?? 0, category: category, died: died, diedCity: diedcity, bornCity: borncity, born: born, surname: surname, firstName: firstname, motivation: motivation, city: city, bornCountry: borncountry, diedCountry: diedcountry, country: country, gender: gender, name: name)
                            
                    
                        jsonResult.append(nobelPrizeData)
                }
            }
            
        } catch {
            print("error \(error)")
        }
        
        return jsonResult
    }
    
    public func getCoreDataContents() -> [NobelPrizeLaureates]{
        
        var nobelPrizeLaureates: [NobelPrizeLaureates] = []
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nobelPrizeLaureates
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NobelPrize")
        
        do {
            let reponseData = try managedContext.fetch(fetchRequest)
            let nobelPrizeData  = reponseData as! [NobelPrize]
            for data in nobelPrizeData {
                let nobelPrize = NobelPrizeLaureates(id: Int(data.id), year: Int(data.year), latitude: data.latitude, longitude: data.longitude, category: data.category ?? "", died: data.died ?? "", diedCity: data.diedCity ?? "", bornCity: data.bornCountry ?? "", born: data.born ?? "", surname: data.surname ?? "", firstName: data.firstName ?? "", motivation: data.motivation ?? "", city: data.city ?? "", bornCountry: data.bornCountry ?? "", diedCountry: data.diedCountry ?? "", country: data.country ?? "", gender: data.gender ?? "", name: data.name ?? "")
                
                nobelPrizeLaureates.append(nobelPrize)
            }
        } catch let error as NSError {
            print("Could not fetch data. \(error), \(error.userInfo)")
        }
        return nobelPrizeLaureates
    }
    
    func setCoreDataContents() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "NobelPrize", in: managedContext) else {return}
        let jsonData = dataParser()
        
        for data in jsonData {
            let nobelPrize = NSManagedObject(entity: entity, insertInto: managedContext)
            nobelPrize.setValue(data.id, forKey: "id")
            nobelPrize.setValue(data.latitude, forKey: "latitude")
            nobelPrize.setValue(data.longitude, forKey: "longitude")
            nobelPrize.setValue(data.year, forKey: "year")
            nobelPrize.setValue(data.category, forKey: "category")
            nobelPrize.setValue(data.died, forKey: "died")
            nobelPrize.setValue(data.diedCity, forKey: "diedCity")
            nobelPrize.setValue(data.diedCountry, forKey: "diedCountry")
            nobelPrize.setValue(data.born, forKey: "born")
            nobelPrize.setValue(data.bornCity, forKey: "bornCity")
            nobelPrize.setValue(data.bornCountry, forKey: "bornCountry")
            nobelPrize.setValue(data.surname, forKey: "surname")
            nobelPrize.setValue(data.name, forKey: "name")
            nobelPrize.setValue(data.firstName, forKey: "firstName")
            nobelPrize.setValue(data.motivation, forKey: "motivation")
            nobelPrize.setValue(data.gender, forKey: "gender")
            nobelPrize.setValue(data.country, forKey: "country")
            nobelPrize.setValue(data.city, forKey: "city")
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("could not save. \(error), \(error.userInfo)")
            }
        }
            
    }

}
