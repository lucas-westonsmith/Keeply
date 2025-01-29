pin "application", to: "application.js", preload: true  # Chargement du fichier application.js principal
pin "@hotwired/turbo-rails", to: "turbo.min.js"  # Pour Turbo
pin "@hotwired/stimulus", to: "stimulus.min.js"  # Pour Stimulus
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"  # Pour charger les contrôleurs Stimulus
pin_all_from "app/javascript/controllers", under: "controllers", preload: true  # Préchargement des contrôleurs Stimulus

# Pour Bootstrap et Popper.js
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
