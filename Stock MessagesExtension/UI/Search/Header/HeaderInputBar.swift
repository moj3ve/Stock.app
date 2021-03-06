//
//  HeaderInputBar.swift
//  Stock MessagesExtension
//
//  Created by Ayden Panhuyzen on 2019-07-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class HeaderInputBar: UIStackView {
    let searchBar = UISearchBar()
    let settingsButton = UIButton(type: .system)
    private var shouldFocusSearchBarOnExpansion = false, presentationStyleChangeTokens = [UUID]()
    let searchStateController = SearchStateController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        axis = .horizontal
        spacing = 2
        translatesAutoresizingMaskIntoConstraints = false
        isLayoutMarginsRelativeArrangement = true
        
        heightAnchor.constraint(equalToConstant: 62).isActive = true
        layoutMargins = UIEdgeInsets(horizontal: 8, vertical: 0)
        
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search stock photos"
        searchBar.delegate = self
        searchBar.autocorrectionType = .yes
        searchBar.enablesReturnKeyAutomatically = false
        
        settingsButton.setImage(#imageLiteral(resourceName: "Settings"), for: .normal)
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        
        addArrangedSubview(searchBar)
        addArrangedSubview(settingsButton)
        
        presentationStyleChangeTokens = [
            // On expand: If we requested to focus search bar on the next expansion, go!
            PresentationStyleManager.shared.onDidChange(to: .expanded) {
                guard self.shouldFocusSearchBarOnExpansion else { return }
                DispatchQueue.main.async {
                    self.searchBar.becomeFirstResponder()
                }
                self.shouldFocusSearchBarOnExpansion = false
            },
            // On compact: Dismiss keyboard if was open
            PresentationStyleManager.shared.onWillChange(to: .compact) {
                self.searchBar.resignFirstResponder()
            }
        ]
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        presentationStyleChangeTokens.forEach { PresentationStyleManager.shared.deregisterChangeNotifications(token: $0) }
    }
}

extension HeaderInputBar: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard PresentationStyleManager.shared.style != .expanded else { return true }
        shouldFocusSearchBarOnExpansion = true
        PresentationStyleManager.shared.style = .expanded
        return false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStateController.searchBarTextDidChange(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchStateController.searchBarDidEndEditing(searchBar)
    }
}
