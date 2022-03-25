//
//  RestaurantTableTableViewController.swift
//  FoodPin_UIKit
//
//  Created by Андрей Бородкин on 16.03.2022.
//

import UIKit
import CoreData

class RestaurantTableTableViewController: UITableViewController {
    
    //MARK: - Outlets and Variables
    @IBOutlet var emptyRestaurantView: UIView!
    
    //var restaurants = Restaurant.sampleData
    var restaurants: [Restaurant] = []
    var fetchResultController: NSFetchedResultsController<Restaurant>!
    var searchController: UISearchController!
    
    lazy var dataSource = configureDataSource()
    
    // MARK: - View controller life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = true
        
        searchController.searchBar.isHidden = restaurants.isEmpty ? true : false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set-up appearance
        if let appearance = navigationController?.navigationBar.standardAppearance {
            
            appearance.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
//                appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 218, green: 96, blue: 51, alpha: 1.0)]
//                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 218, green: 96, blue: 51, alpha: 1.0), .font: customFont]
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Search bar implementation
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        //self.navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(named: "NavigationBarTitle")
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        

        // Prepare the empty view
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
        // Set-up data source
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        
        fetchRestaurantData()
        
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
//        snapshot.appendSections([.all])
//        snapshot.appendItems(restaurants, toSection: .all)
//
//        dataSource.apply(snapshot, animatingDifferences: false)
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
       
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: String(describing: WalkthroughViewController.self)) as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Core Data
    
    func fetchRestaurantData(searchText: String = "") {
        // Fetch data from data store
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        
        if !searchText.isEmpty {
           
            let namePredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            let locationPredicate = NSPredicate(format: "location CONTAINS[c] %@", searchText)
            let typePredicate = NSPredicate(format: "type CONTAINS[c] %@", searchText)
            
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, locationPredicate, typePredicate])
            
//            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                updateSnapshot(animatingChange: searchText.isEmpty ? false : true)
            } catch {
                print(error)
            }
        }
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        if let fetchedObjects = fetchResultController.fetchedObjects {
            restaurants = fetchedObjects
        }
        
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
        
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
    }

    // MARK: - UITableViewDelegate Protocol
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//
//        if let popoverController = optionMenu.popoverPresentationController {
//            if let cell = tableView.cellForRow(at: indexPath) {
//                popoverController.sourceView = cell
//                popoverController.sourceRect = cell.bounds
//            }
//        }
//
//        let reserveActionHandler = {(action: UIAlertAction!) -> Void in
//
//            let alertMessage = UIAlertController(title: "Not available yet!", message: "Sorry, this feature is not available yet. Please retry later.", preferredStyle: .alert)
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertMessage, animated: true, completion: nil)
//        }
//
//        let reserveAction = UIAlertAction(title: "Reserve a table", style: .default, handler: reserveActionHandler)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        let favouriteActionTitle = self.restaurants[indexPath.row].isFavourite ? "Remove from favourites" : "Add to favourites"
//        let favoriteAction = UIAlertAction(title: favouriteActionTitle, style: .default, handler: {
//            (action: UIAlertAction!) -> Void in
//
//            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
//
//            cell.imageHeart.isHidden = self.restaurants[indexPath.row].isFavourite
//            self.restaurants[indexPath.row].isFavourite.toggle()
//
//        })
//
//        optionMenu.addAction(cancelAction)
//        optionMenu.addAction(reserveAction)
//        optionMenu.addAction(favoriteAction)
//
//        present(optionMenu, animated: true, completion: nil)
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if searchController.isActive {
            return UISwipeActionsConfiguration()
        }
        
        // get selected restaurant
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else {
            return UISwipeActionsConfiguration()
        }
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                
                // Delete the item
                context.delete(restaurant)
                appDelegate.saveContext()
                
                // Update the view
                self.updateSnapshot(animatingChange: true)
            }
            
//            var snapshot = self.dataSource.snapshot()
//            snapshot.deleteItems([restaurant])
//            self.dataSource.apply(snapshot, animatingDifferences: true)
            
            // Call completion handler to dismiss the action button
            completionHandler(true)
        }
        
        // Share action
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, sourceView, completionHandler) in
            
            let defaultText = "Just checking in at " + restaurant.name
            
            let activityController: UIActivityViewController
            
            if let imageToShare = UIImage(data: restaurant.image) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            if let popoverController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        shareAction.backgroundColor = UIColor.systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        // Configure both actions as swipe action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Favourite action
        //let favouriteActionTitle = restaurant.isFavourite ? "Remove from favourites" : "Mark as favourite"
        let favouriteAction = UIContextualAction(style: .normal, title: nil) {(action, sourceView, completionHandler) in
            
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            
            cell.imageHeart.isHidden = self.restaurants[indexPath.row].isFavourite
            self.restaurants[indexPath.row].isFavourite.toggle()
            
            completionHandler(true)
        }
        
        favouriteAction.backgroundColor = UIColor.systemYellow
        favouriteAction.image = restaurants[indexPath.row].isFavourite ? UIImage(systemName: "heart.slash.fill") : UIImage(systemName: "heart.fill")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [favouriteAction])
        
        return swipeConfiguration
    }
    
    // MARK: - UITableView Diffable Data Source
    
    func configureDataSource() -> RestaurantDiffableDataSource {
        
        let cellIdentifier = "datacell"
        
        let dataSource = RestaurantDiffableDataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, restaurant in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
                
                cell.nameLabel.text = restaurant.name
                cell.locationLabel.text = restaurant.location
                cell.typeLabel.text = restaurant.type
                cell.thumbnailImageView.image = UIImage(data: restaurant.image)
                cell.imageHeart.isHidden = restaurant.isFavourite ? false : true
            
                return cell
            }
        )
        return dataSource
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = self.restaurants[indexPath.row]
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
   
}


// MARK: - Extensions

extension RestaurantTableTableViewController: NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

extension RestaurantTableTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else {return}
        
        fetchRestaurantData(searchText: searchText)
    }
}
