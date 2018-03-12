//
//  MyHoursViewController.swift
//  Beta_Scholarship
//
//  Created by James Weber on 3/12/18.
//  Copyright © 2018 James Weber. All rights reserved.
//

import UIKit

class MyHoursViewController: UIViewController {

    @IBOutlet weak var statsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statsCollectionView.delegate = self
        statsCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyHoursViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myDataCell", for: indexPath)
        return cell
    }
}
