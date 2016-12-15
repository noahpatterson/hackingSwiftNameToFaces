//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Noah Patterson on 12/13/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))

        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "people") as? Data {
            people = NSKeyedUnarchiver.unarchiveObject(with: savedData) as! [Person]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        
//        if let imageData = try? Data(contentsOf: getDocumentsDirectory().appendingPathComponent(people[indexPath.item].image)) {
//            cell.imageView.image = UIImage(data: imageData)
//        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        
        //set image and cell styles
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    //image picker delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView?.reloadData()
        
        dismiss(animated: true)
        save()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Add name or delete?", message: "Would add a name to photo or delete it?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "add name", style: .default) {
            [unowned self, person] _ in
            self.alertRenameImage(person: person)
        })
        ac.addAction(UIAlertAction(title: "delete person", style: .destructive) {
            [unowned self] _ in
            self.people.remove(at: indexPath.item)
            self.collectionView?.reloadData()
            self.save()
        })
        present(ac, animated: true)
    }
    
    func alertRenameImage(person: Person) {
        let ac = UIAlertController(title: "Add name", message: "Add a name to the photo", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default) {
            [unowned self, ac, person] _ in
            if let enteredName = ac.textFields![0].text, enteredName != "" {
                person.name = enteredName
                self.collectionView?.reloadData()
                self.save()
            }
        })
        
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
         if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
        
            let ac = UIAlertController(title: "Choose image...", message: nil, preferredStyle: .actionSheet)
            
            
            ac.addAction(UIAlertAction(title: "From photo library", style: .default) {
                [unowned self, picker] _ in
                self.chooseFromLibrary(picker: picker)
            })
            
            ac.addAction(UIAlertAction(title: "From camera", style: .default) {
                [unowned self, picker] _ in
                self.chooseFromCamera(picker: picker)
            })
            
            present(ac, animated: true)
         } else {
            present(picker, animated: true)
        }
        

    }
    
    func chooseFromLibrary(picker: UIImagePickerController) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func chooseFromCamera(picker: UIImagePickerController) {
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func save() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: people)
        let defaults  = UserDefaults.standard
        defaults.set(savedData, forKey: "people")
    }


}

