//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 29/04/21.
//

import UIKit

class WeatherViewController: UIViewController {
    
    let cellIdentifier = "WeatherCell"
    //MARK: - Properties and IBOutlets
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minimumAndMaximumTempLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var favoriteButton: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!
    var viewModel: WeatherViewModelType = WeatherViewModel()
    
    //MARK: - UIViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.controller = self
        self.viewModel.fetchWeather(for: self.searchTextField.text ?? "" != "" ? self.searchTextField.text ?? "" : "Bengaluru" )
        self.viewModel.fetchFavourites()
    }
    
    //MARK: - Configure UI
    
    func configureUI() {
        self.placeNameLabel.text = viewModel.placeName
        self.temperatureLabel.text = viewModel.temparature
        self.minimumAndMaximumTempLabel.text = "\(viewModel.maxTemperature ?? "-")" + "   " + "\(viewModel.minTemperature ?? "-")"
    }
    
    /// Configure collectionview for favorites locations
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: cellIdentifier,
                                           bundle: nil),
                                     forCellWithReuseIdentifier: cellIdentifier)
        self.collectionView.reloadData()
    }
    
    //MARK: - Favorite Button Action
    @IBAction func favoriteButtonAction(_ sender: Any) {
        if favoriteButton.isSelected {
            self.favoriteButton.isSelected = false
            self.favoriteButton.tintColor = .white
            self.viewModel.deleteFavourite(weather: self.viewModel.weatherInfo)
        } else {
            self.favoriteButton.isSelected = true
            self.favoriteButton.tintColor = .systemYellow
            self.viewModel.saveToFavourite(weather: self.viewModel.weatherInfo)
        }

    }
    
    
}

//MARK:- UITextField Delegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.viewModel.fetchWeather(for: self.searchTextField.text ?? "Bengaluru")
        self.favoriteButton.isSelected = false
        return self.searchTextField.resignFirstResponder()
       
    }
}

//MARK: - UICollectionView Delegate and DataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                      for: indexPath) as! WeatherCell
        cell.delegate = self
        let item = self.viewModel.favourites[indexPath.row]
        cell.configureCell(viewModel: WeatherCellViewModel(weatherInfo: item))
        cell.favoriteButton.addTarget(cell.self, action: #selector(cell.favoriteButtonAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.size.width - 20) / 2,
                      height: self.collectionView.frame.size.height)
    }
}


extension WeatherViewController: WeatherCellDelegate {
    
    /// Retrieve info for Favorite button from Weather cell class
    /// - Parameters:
    ///   - isFavourite: - is type of Bool
    ///   - weatherInfo: - is type of Weather Info
    func favouriteButtonDidTap(isFavourite: Bool, weatherInfo: WeatherInfo?) {
        guard let weatherInfo = weatherInfo else {
            return
        }
        if isFavourite {
            self.viewModel.saveToFavourite(weather: weatherInfo)
        } else {
            self.viewModel.deleteFavourite(weather: weatherInfo)
        }
    }
}
