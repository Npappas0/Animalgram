//
//  SavedViewController.swift
//  Animalgram
//
//  Created by NPappas on 12/19/16.
//  Copyright © 2016 Nick Pappas. All rights reserved.
//

import UIKit

class SavedViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var savedAnimals = [Animal]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        screenSize(numberOfPicsPerRow: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myPhotoCell", for: indexPath) as! PhotoSavedViewCell
        
        let photo = savedAnimals[indexPath.item]
        cell.cellImage.image = photo.image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return savedAnimals.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let ac = UIAlertController(title: "Delete Image", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: { [unowned self, ac] _ in
            self.savedAnimals.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
            self.save()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated : true)
    }
    
    func screenSize(numberOfPicsPerRow : Int)
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
    
    func save()
    {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: savedAnimals)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "animals")
    }
    
    @IBAction func onePicPerRow(_ sender: Any)
    {
        screenSize(numberOfPicsPerRow: 1)
    }
    
    @IBAction func twoPicsPerRow(_ sender: Any)
    {
        screenSize(numberOfPicsPerRow: 2)
    }

    @IBAction func threePicsPerRow(_ sender: Any)
    {
        screenSize(numberOfPicsPerRow: 3)
    }
    
}
