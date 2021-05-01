//
//  WeatherCell.swift
//  OpenWeatherApp
//
//  Created by Sudha Rani on 01/05/21.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    
    //Properties and IBOutlets
    @IBOutlet weak var minAndMaxLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var viewModel: WeatherCellViewModelType?
    weak var delegate: WeatherCellDelegate?
       
    
    /// Awake from Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
       
    }
    
    /// Configure UI for Collectionview cell
    
    /// - Parameters:
    ///   - viewModel: weatherViewModel type
    ///   - index: current index
    func configureCell(viewModel: WeatherCellViewModelType) {
        self.viewModel = viewModel
        self.cityNameLabel.text = viewModel.placeName
        self.tempLabel.text = viewModel.temparature
        self.minAndMaxLabel.text = "\(viewModel.maxTemperature ?? "-")" + "   " + "\(viewModel.minTemperature ?? "-")"
        self.favoriteButton.isSelected = true
        self.favoriteButton.tintColor = .systemYellow
    }
    
    //MARK: - Favorite Button Action
    @objc func favoriteButtonAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.isSelected {
            button.isSelected = false
            button.tintColor = .white
            self.delegate?.favouriteButtonDidTap(isFavourite: false, weatherInfo: self.viewModel?.weatherInfo)
        } else {
            button.isSelected = true
            button.tintColor = .systemYellow
            self.delegate?.favouriteButtonDidTap(isFavourite: true, weatherInfo: self.viewModel?.weatherInfo)
        }
    }

}


protocol WeatherCellDelegate: AnyObject {
    func favouriteButtonDidTap(isFavourite: Bool, weatherInfo: WeatherInfo?)
}
