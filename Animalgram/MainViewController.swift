//
//  ViewController.swift
//  Animalgram
//
//  Created by NPappas on 12/9/16.
//  Copyright © 2016 Nick Pappas. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    var animals = [Animal]()
    var myAnimals = [Animal]()
    var currentWord = "animals"
    var isSearchEnabled = false
    
    var BASE_URL = "https://api.flickr.com/services/rest/"
    var METHOD_NAME:String! = "flickr.photos.search"
    var API_KEY:String! = "c2a58afddb17a86c74b55270dd054417"
    var GALLERY_ID:String! = "5704-72157622566655097"
    var EXTRAS:String! = "url_m"
    var DATA_FORMAT:String! = "json"
    var SAFE_SEARCH:String!="1"
    var NO_JSON_CALLBACK:String! = "1"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        editSearch(hidden: true, enabled: false)
        
        let defaults = UserDefaults.standard
        if let savedAnimals = defaults.object(forKey: "animals") as? Data
        {
            myAnimals = NSKeyedUnarchiver.unarchiveObject(with: savedAnimals) as! [Animal]
        }
        
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        resizeScreen(numberOfPicsPerRow: 1)
        searchForImage(searchString: currentWord)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return animals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let photo = animals[indexPath.item]
        cell.cellImage.image = photo.image
        //cell.cellLabel.text = photo.photoTitle
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let animal = animals[indexPath.item]
        let ac = UIAlertController(title: "Save Image", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { [unowned self, ac] _ in
            let newAnimal = Animal(photoTitle: "", image: animal.image)
            self.myAnimals.append(newAnimal)
            self.save()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated : true)
    }
    
    func resizeScreen(numberOfPicsPerRow : Int)
    {
        let screenSize : CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if numberOfPicsPerRow == 3
        {
            layout.itemSize = CGSize(width: screenWidth/3 - 3, height: 180)
        }
        else if numberOfPicsPerRow == 2
        {
            layout.itemSize = CGSize(width: screenWidth/2 - 4, height: 180)
        }
        else
        {
            layout.itemSize = CGSize(width: screenWidth, height: 520)
        }
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
    }
    
    func searchForImage(searchString : String)
    {
        let word:String! = searchString
        /* 2 - API method arguments */
        var methodArguments =
        [
            "method": METHOD_NAME!,
            "api_key": API_KEY!,
            "text": currentWord,
            "safe_search": SAFE_SEARCH!,
            "extras": EXTRAS!,
            "format": DATA_FORMAT!,
            "nojsoncallback": NO_JSON_CALLBACK!
        ]
        if methodArguments.isEmpty
        {
            
        }
        else
        {
            getImageFromFlickrSearch(methodArguments: methodArguments)//passes API Key and search term to method
        }
    }
    
    func getImageFromFlickrSearch(methodArguments:[String : String])
    {
        //Initialize session and url  - Use NSURLSessions to connect
        let session = URLSession.shared
        let urlString = BASE_URL + escapedParameters(parameters: methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(url: url as URL)
        
        //Initialize task for getting data  - initialize task
        let task = session.dataTask(with: request as URLRequest)
        {data, response, downloadError in
            if let error = downloadError
            {
                print("Could not complete the request \(error)")
            }
            else
            {
                //Success! Parse the data
                var parsingError: NSError? = nil
                let parsedResult: AnyObject!
                do
                {
                    parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                }
                catch let error as NSError
                {
                    parsingError = error
                    parsedResult = nil
                }
                catch
                {
                    fatalError()
                }
            
                if let photosDictionary = parsedResult.value(forKey: "photos") as? NSDictionary
                {
                    if let photoArray = photosDictionary.value(forKey: "photo") as? [[String: AnyObject]]
                    {
                        for photo in photoArray
                        {
                            let photoDictionary = photo as [String: AnyObject]
                            
                            let photoTitle = photoDictionary["title"] as? String
                            var imageUrlString = photoDictionary["url_m"] as? String
                            if(imageUrlString==nil)
                            {
                                
                            }
                            else
                            {
                                let imageURL = NSURL(string: imageUrlString!)!
                                
                                //Save info to arrays
                                if let imageData = NSData(contentsOf: imageURL as URL)
                                {
                                    DispatchQueue.main.async
                                    {
                                        let newAnimal = Animal(photoTitle: photoTitle!, image: UIImage(data: imageData as Data)!)
                                        self.animals.append(newAnimal)
                                        self.collectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : String]) -> String!
    {
        var urlVars = [String]()
        
        for (key, value) in parameters
        {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    func reset()
    {
        animals.removeAll()
        searchForImage(searchString: currentWord)
    }
    
    func save()
    {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: myAnimals)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "animals")
    }
    
    func editSearch(hidden : Bool, enabled : Bool)
    {
        searchBar.isHidden = hidden
        searchButton.isHidden = hidden
        searchBar.isEnabled = enabled
        searchButton.isEnabled = enabled
    }
    
    @IBAction func onePerRow(_ sender: Any)
    {
        resizeScreen(numberOfPicsPerRow: 1)
    }
    
    @IBAction func twoPerRow(_ sender: Any)
    {
        resizeScreen(numberOfPicsPerRow: 2)
    }
    
    @IBAction func threePerRow(_ sender: Any)
    {
        resizeScreen(numberOfPicsPerRow: 3)
    }
    
    @IBAction func refresh(_ sender: Any)
    {
        reset()
    }
    
    @IBAction func randomButtonPress(_ sender: Any)
    {
        currentWord = "animals"
        reset()
        editSearch(hidden: true, enabled: false)
    }
    
    @IBAction func searchButtonPress(_ sender: Any)
    {
        if isSearchEnabled
        {
            editSearch(hidden: true, enabled: false)
        }
        else
        {
            editSearch(hidden: false, enabled: true)
        }
        isSearchEnabled = !isSearchEnabled
    }
    
    @IBAction func imageSearch(_ sender: Any)
    {
        currentWord = searchBar.text!
        reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let dvc = segue.destination as! SavedViewController
        dvc.savedAnimals = myAnimals
    }
    
    
}

