//
//  RestaurantTableTableViewController.swift
//  FoodPin_UIKit
//
//  Created by Андрей Бородкин on 16.03.2022.
//

import UIKit

class RestaurantTableTableViewController: UITableViewController {

    
    var restaurantNames = ["Cafe Deadend", "Homei", "Teakha", "Cafe Loisl", "Petite Oyster", "For Kee Restaurant", "Po's Atelier", "Bourke Street Bakery", "Haigh's Chocolate", "Palomino Espresso", "Upstate", "Traif", "Graham Avenue Meats And Deli", "Waffle & Wolf", "Five Leaves", "Cafe Lore", "Confessional", "Barrafina", "Donostia", "Royal Oak", "CASK Pub and Kitchen"]
    
    var restaurantImages = ["cafedeadend", "homei", "teakha", "cafeloisl", "petiteoyster", "forkee", "posatelier", "bourkestreetbakery", "haigh", "palomino", "upstate", "traif", "graham", "waffleandwolf", "fiveleaves", "cafelore", "confessional", "barrafina", "donostia", "royaloak", "cask"]
    
    var restaurantLocations = ["Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Hong Kong", "Sydney", "Sydney", "Sydney", "New York", "New York", "New York", "New York", "New York", "New York", "New York", "London", "London", "London", "London"]
    
    var restaurantTypes = ["Coffee & Tea Shop", "Cafe", "Tea House", "Austrian / Casual Drink", "French", "Bakery", "Bakery", "Bakery", "Chocolate", "Cafe", "American / Seafood", "American", "American", "Breakfast and Brunch", "Coffee & Tea", "Latin American", "Spanish", "Spanish", "Spanish", "British", "Thai"]
    
    var restaurantIsFavourites = Array(repeating: false, count: 21)
    
    enum Section {
        case all
    }
    
    lazy var dataSource = configureDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true

        tableView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurantNames, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
        
        if let popoverController = optionMenu.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }
        
        let reserveActionHandler = {(action: UIAlertAction!) -> Void in
            let alertMessage = UIAlertController(title: "Not available yet!", message: "Sorry, this feature is not available yer. Please try later.", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        let reserveAction = UIAlertAction(title: "Reserve a table", style: .default, handler: reserveActionHandler)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let favoriteAction = UIAlertAction(title: restaurantIsFavourites[indexPath.row] ? "Remove from favourites" : "Add to favourites", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            
            cell.imageHeart.isHidden = self.restaurantIsFavourites[indexPath.row]
            self.restaurantIsFavourites[indexPath.row].toggle()
        })
        
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(reserveAction)
        optionMenu.addAction(favoriteAction)
        
        present(optionMenu, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func configureDataSource() -> UITableViewDiffableDataSource<Section, String> {
        
        let cellIdentifier = "favoritecell"
        
        let dataSource = UITableViewDiffableDataSource<Section, String>(
            tableView: tableView,
            cellProvider: { tableView, indexPath, restaurantName in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
                cell.nameLabel.text = restaurantName
                cell.thumbnailImageView.image = UIImage(named: self.restaurantImages[indexPath.row])
                cell.locationLabel.text = self.restaurantLocations[indexPath.row]
                cell.typeLabel.text = self.restaurantTypes[indexPath.row]
                cell.imageHeart.isHidden = self.restaurantIsFavourites[indexPath.row] ? false : true
            
                return cell
            }
        )
        return dataSource
    }
    
   
}
