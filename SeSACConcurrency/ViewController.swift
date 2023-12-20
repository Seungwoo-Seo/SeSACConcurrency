//
//  ViewController.swift
//  SeSACConcurrency
//
//  Created by 서승우 on 2023/12/19.
//

import UIKit

/*
 @MainActor: Swift Concurrency를 작성한 코드에서 다시 메인 쓰레드로 돌려주는 역할을 수행
 */

class MyClassA {
    var target: MyClassB?

    deinit {
        print(#function, "MyClassA")
    }
}

class MyClassB {
    var target: MyClassA?

    deinit {
        print(#function, "MyClassB")
    }
}

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print(#function)
        view.backgroundColor = .systemBackground

        var a: MyClassA? = MyClassA()
        var b: MyClassB? = MyClassB()
        a?.target = b
        b?.target = a
    }

    deinit {
        print(#function, "DetailViewController")
    }

}

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
//            print(#function, Thread.isMainThread)
//            let results = try await Network.shared.fetchThumbnailAsyncLet()
//
//            print(#function, Thread.isMainThread)
//            imageView.image = results[0]
//            secondImageView.image = results[1]
//            thirdImageView.image = results[2]
//            print(#function, Thread.isMainThread)
//        }

        Task {
            print(#function, Thread.isMainThread)

            let value = try await Network.shared.fetchThumbnailTaskGroup()

            print(#function, Thread.isMainThread)
            imageView.image = value[0]
            secondImageView.image = value[1]
            thirdImageView.image = value[2]
            print(#function, Thread.isMainThread)
        }
    }

    @IBAction func didTapButton(_ sender: UIButton) {
        let vc = HostingTestView(rootView: TestView())
        present(vc, animated: true)
//        present(DetailViewController(), animated: true)
    }

}
