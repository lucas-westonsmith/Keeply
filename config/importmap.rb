# config/importmap.rb

# Pin npm packages by running ./bin/importmap
pin "application", preload: true # Pour charger l'application
pin "@hotwired/turbo-rails", to: "turbo.min.js" # Pour Turbo
pin "@hotwired/stimulus", to: "stimulus.min.js" # Pour Stimulus
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js" # Pour charger les contrôleurs Stimulus
pin_all_from "app/javascript/controllers", under: "controllers", preload: true # Pour précharger tous les contrôleurs Stimulus

# Pour Bootstrap et Popper.js, nécessaires pour les dropdowns et autres composants interactifs
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
