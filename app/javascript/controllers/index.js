// app/javascript/controllers/index.js

import { application } from "./application";
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";

console.log("Eager loading controllers from 'controllers' directory...");
eagerLoadControllersFrom("controllers", application);

console.log("Stimulus Controllers loaded:", application.controllers);
