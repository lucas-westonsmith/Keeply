pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"  # Pour Turbo
pin "@hotwired/stimulus", to: "stimulus.min.js"  # Pour Stimulus
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"  # Pour charger les contrôleurs Stimulus
pin_all_from "app/javascript/controllers", under: "controllers"

# Pour Bootstrap et Popper.js
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

pin "gsap", to: "https://cdn.skypack.dev/gsap"
pin "gsap/ScrollTrigger", to: "https://cdn.skypack.dev/gsap/ScrollTrigger"
