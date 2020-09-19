//
//  TableViewController.swift
//  TimeTravelApp
//
//  Created by Srivalli Kanchibotla on 9/15/19.
//  Copyright © 2019 Srivalli Kanchibotla. All rights reserved.
//

import UIKit
import CoreLocation

class TableViewController: UITableViewController {

    var tableData: [NobelPrizeLaureates] = MainViewController.nearestTwentyEvents
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        self.clearsSelectionOnViewWillAppear = false
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        let data = tableData[indexPath.row]
        //TODO: change the display text
        cell.textLabel?.text = "\(data.surname.uppercased()) \(data.name.uppercased())"
        cell.detailTextLabel?.text = "\(data.city), \(data.country) - \(String(data.year))"
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue", let selectedIndexPath = tableView.indexPathForSelectedRow {
            let detailVC = segue.destination as? DetailViewController
            let dataCell = tableData[selectedIndexPath.row]
            detailVC?.detailTextViewText = "\(dataCell.surname.uppercased()) \(dataCell.firstName.uppercased())\n\(dataCell.gender),\nBorn : \(dataCell.born) \(dataCell.bornCity), \(dataCell.bornCountry)\nDied : \(dataCell.died) \(dataCell.diedCity),\(dataCell.diedCountry)\nNOBEL PRIZE :\n\t\(dataCell.category),\n\t\(dataCell.city), \(dataCell.country) in \(dataCell.year)\n\t\(dataCell.motivation)"
            detailVC?.detailMapViewLocation = CLLocationCoordinate2D(latitude: dataCell.latitude, longitude: dataCell.longitude)
        }
    }
}
