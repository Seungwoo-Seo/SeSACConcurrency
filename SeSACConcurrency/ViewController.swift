//
//  ViewController.swift
//  SeSACConcurrency
//
//  Created by 서승우 on 2023/12/19.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        Network.shared.fetchThumbnailURLSession { [unowned self] (result) in
//            switch result {
//            case .success(let image):
//                self.imageView.image = image
//
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.imageView.backgroundColor = .gray
//                    print(error.localizedDescription)
//                }
//            }
//        }

//        Task {
//            do {
//                let result = try await Network.shared.fetchThumbnailAsyncAwait(value: "eDps1ZhI8IOlbEC7nFg6eTk4jnb")
//                let result1 = try await Network.shared.fetchThumbnailAsyncAwait(value: "5Afx73NwXPdgHd3Kt1tU7ig4Vox")
//                let result2 = try await Network.shared.fetchThumbnailAsyncAwait(value: "9f9YsmXoy9ghqZKIVuKHkmGGZCY")
//
//                imageView.image = result
//                secondImageView.image = result1
//                thirdImageView.image = result2
//                
//            } catch {
//                print("❌ ", error.localizedDescription)
//            }
//        }
//
//        Task {
//            let results = try await Network.shared.fetchThumbnailAsyncLet()
//
//            imageView.image = results[0]
//            secondImageView.image = results[1]
//            thirdImageView.image = results[2]
//        }

        Task {
            let value = try await Network.shared.fetchThumbnailTaskGroup()

            imageView.image = value[0]
            secondImageView.image = value[1]
            thirdImageView.image = value[2]
        }
    }

}
