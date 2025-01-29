// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "@popperjs/core";
import "bootstrap/dist/js/bootstrap.bundle";
window.bootstrap = require("bootstrap");
console.log("Bootstrap forced import loaded:", window.bootstrap);

console.log("Main application.js loaded");
