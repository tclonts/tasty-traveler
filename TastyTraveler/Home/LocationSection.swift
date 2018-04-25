//
//  LocationSection.swift
//  TastyTraveler
//
//  Created by Michael Bart on 4/20/18.
//  Copyright © 2018 Michael Bart. All rights reserved.
//

import UIKit
import Stevia

class LocationSection: BaseCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hexString: "F8F8FB")
        return collectionView
    }()
    
    var filtersLauncher: FiltersLauncher!
    var countries = ["Ascension Island", "Andorra", "United Arab Emirates", "Afghanistan", "Antigua & Barbuda", "Anguilla", "Albania", "Armenia", "Angola", "Antarctica", "Argentina", "American Samoa", "Austria", "Australia", "Aruba", "Åland Islands", "Azerbaijan", "Bosnia & Herzegovina", "Barbados", "Bangladesh", "Belgium", "Burkina Faso", "Bulgaria", "Bahrain", "Burundi", "Benin", "St. Barthélemy", "Bermuda", "Brunei", "Bolivia", "Caribbean Netherlands", "Brazil", "Bahamas", "Bhutan", "Bouvet Island", "Botswana", "Belarus", "Belize", "Canada", "Cocos [Keeling] Islands", "Congo - Kinshasa", "Central African Republic", "Congo - Brazzaville", "Switzerland", "Côte d’Ivoire", "Cook Islands", "Chile", "Cameroon", "China", "Colombia", "Clipperton Island", "Costa Rica", "Cuba", "Cape Verde", "Curaçao", "Christmas Island", "Cyprus", "Czechia", "Germany", "Diego Garcia", "Djibouti", "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ceuta & Melilla", "Ecuador", "Estonia", "Egypt", "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji", "Falkland Islands", "Micronesia", "Faroe Islands", "France", "Gabon", "United Kingdom", "Grenada", "Georgia", "French Guiana", "Guernsey", "Ghana", "Gibraltar", "Greenland", "Gambia", "Guinea", "Guadeloupe", "Equatorial Guinea", "Greece", "So. Georgia & So. Sandwich Isl.", "Guatemala", "Guam", "Guinea-Bissau", "Guyana", "Hong Kong [China]", "Heard & McDonald Islands", "Honduras", "Croatia", "Haiti", "Hungary", "Canary Islands", "Indonesia", "Ireland", "Israel", "Isle of Man", "India", "British Indian Ocean Territory", "Iraq", "Iran", "Iceland", "Italy", "Jersey", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "Kiribati", "Comoros", "St. Kitts & Nevis", "North Korea", "South Korea", "Kuwait", "Cayman Islands", "Kazakhstan", "Laos", "Lebanon", "St. Lucia", "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania", "Luxembourg", "Latvia", "Libya", "Morocco", "Monaco", "Moldova", "Montenegro", "St. Martin", "Madagascar", "Marshall Islands", "Macedonia", "Mali", "Myanmar [Burma]", "Mongolia", "Macau [China]", "Northern Mariana Islands", "Martinique", "Mauritania", "Montserrat", "Malta", "Mauritius", "Maldives", "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "New Caledonia", "Niger", "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal", "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru", "French Polynesia", "Papua New Guinea", "Philippines", "Pakistan", "Poland", "St. Pierre & Miquelon", "Pitcairn Islands", "Puerto Rico", "Palestinian Territories", "Portugal", "Palau", "Paraguay", "Qatar", "Réunion", "Romania", "Serbia", "Russia", "Rwanda", "Saudi Arabia", "Solomon Islands", "Seychelles", "Sudan", "Sweden", "Singapore", "St. Helena", "Slovenia", "Svalbard & Jan Mayen", "Slovakia", "Sierra Leone", "San Marino", "Senegal", "Somalia", "Suriname", "South Sudan", "São Tomé & Príncipe", "El Salvador", "Sint Maarten", "Syria", "Swaziland", "Tristan da Cunha", "Turks & Caicos Islands", "Chad", "French Southern Territories", "Togo", "Thailand", "Tajikistan", "Tokelau", "Timor-Leste", "Turkmenistan", "Tunisia", "Tonga", "Turkey", "Trinidad & Tobago", "Tuvalu", "Taiwan", "Tanzania", "Ukraine", "Uganda", "U.S. Outlying Islands", "United States", "Uruguay", "Uzbekistan", "Vatican City", "St. Vincent & Grenadines", "Venezuela", "British Virgin Islands", "U.S. Virgin Islands", "Vietnam", "Vanuatu", "Wallis & Futuna", "Samoa", "Kosovo", "Yemen", "Mayotte", "South Africa", "Zambia", "Zimbabwe"]
    var countryCodes = ["AC", "AD", "AE", "AF", "AG", "AI", "AL", "AM", "AO", "AQ", "AR", "AS", "AT", "AU", "AW", "AX", "AZ", "BA", "BB", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BL", "BM", "BN", "BO", "BQ", "BR", "BS", "BT", "BV", "BW", "BY", "BZ", "CA", "CC", "CD", "CF", "CG", "CH", "CI", "CK", "CL", "CM", "CN", "CO", "CP", "CR", "CU", "CV", "CW", "CX", "CY", "CZ", "DE", "DG", "DJ", "DK", "DM", "DO", "DZ", "EA", "EC", "EE", "EG", "EH", "ER", "ES", "ET", "FI", "FJ", "FK", "FM", "FO", "FR", "GA", "GB", "GD", "GE", "GF", "GG", "GH", "GI", "GL", "GM", "GN", "GP", "GQ", "GR", "GS", "GT", "GU", "GW", "GY", "HK", "HM", "HN", "HR", "HT", "HU", "IC", "ID", "IE", "IL", "IM", "IN", "IO", "IQ", "IR", "IS", "IT", "JE", "JM", "JO", "JP", "KE", "KG", "KH", "KI", "KM", "KN", "KP", "KR", "KW", "KY", "KZ", "LA", "LB", "LC", "LI", "LK", "LR", "LS", "LT", "LU", "LV", "LY", "MA", "MC", "MD", "ME", "MF", "MG", "MH", "MK", "ML", "MM", "MN", "MO", "MP", "MQ", "MR", "MS", "MT", "MU", "MV", "MW", "MX", "MY", "MZ", "NA", "NC", "NE", "NF", "NG", "NI", "NL", "NO", "NP", "NR", "NU", "NZ", "OM", "PA", "PE", "PF", "PG", "PH", "PK", "PL", "PM", "PN", "PR", "PS", "PT", "PW", "PY", "QA", "RE", "RO", "RS", "RU", "RW", "SA", "SB", "SC", "SD", "SE", "SG", "SH", "SI", "SJ", "SK", "SL", "SM", "SN", "SO", "SR", "SS", "ST", "SV", "SX", "SY", "SZ", "TA", "TC", "TD", "TF", "TG", "TH", "TJ", "TK", "TL", "TM", "TN", "TO", "TR", "TT", "TV", "TW", "TZ", "UA", "UG", "UM", "US", "UY", "UZ", "VA", "VC", "VE", "VG", "VI", "VN", "VU", "WF", "WS", "XK", "YE", "YT", "ZA", "ZM", "ZW"]
    
    override func setUpViews() {
        super.setUpViews()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(LocationCell.self, forCellWithReuseIdentifier: "locationCell")
        
        sv(collectionView)
        collectionView.fillContainer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deselectFilter(_:)), name: Notification.Name("RemoveFilterNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllFilters), name: Notification.Name("RemoveAllFiltersNotification"), object: nil)
    }
    
    @objc func deselectFilter(_ notification: Notification) {
        if let filterText = notification.userInfo?["filterText"] as? String {
            if let index = countries.index(of: filterText) {
                collectionView.deselectItem(at: IndexPath(item: index, section: 0), animated: true)
            }
        }
    }
    
    @objc func removeAllFilters() {
        let indexPaths = collectionView.indexPathsForSelectedItems
        indexPaths?.forEach({ collectionView.deselectItem(at: $0, animated: false) })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! LocationCell
        
        cell.locationLabel.text = countries[indexPath.item]
        cell.imageView.image = UIImage(named: countryCodes[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LocationCell
        
        guard let location = cell.locationLabel.text else { return }
        
        filtersLauncher.selectedFilters.append(location)
        filtersLauncher.selectedLocations.append(location)
        let index = IndexPath(item: filtersLauncher.selectedFilters.count - 1, section: 0)
        filtersLauncher.selectedFiltersCollectionView.insertItems(at: [index])
        filtersLauncher.selectedFiltersCollectionView.scrollToItem(at: index, at: .right, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! LocationCell
        
        guard let location = cell.locationLabel.text else { return }
        
        if let locationIndex = filtersLauncher.selectedLocations.index(of: location) {
            filtersLauncher.selectedLocations.remove(at: locationIndex)
        }
        
        if let index = filtersLauncher.selectedFilters.index(of: location) {
            filtersLauncher.selectedFilters.remove(at: index)
            filtersLauncher.selectedFiltersCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        }
    }
}

class LocationCell: BaseCell {
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: adaptConstant(16))
        label.textColor = Color.darkText
        return label
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.height(adaptConstant(15)).width(adaptConstant(22))
        return iv
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        let stackView = UIStackView(arrangedSubviews: [imageView, locationLabel])
        stackView.axis = .horizontal
        stackView.spacing = adaptConstant(8)
        
        sv(stackView)
        
        stackView.centerVertically()
        stackView.left(self.frame.width / 4)
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.alpha = 0.3
            } else {
                self.alpha = 1.0
            }
        }
    }
}
