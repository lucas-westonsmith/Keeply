import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";

export default class extends Controller {
  connect() {
    console.log("📌 Homepage animations initialized!");

    // ✅ Cacher les éléments avant l'animation pour éviter le flash
    this.element.querySelectorAll(".animate-text, .animate-button").forEach(el => {
      el.style.opacity = "0";
      el.style.visibility = "visible";
    });

    // ✅ Animation des textes avec un effet progressif + plus lent
    gsap.to(".animate-text", {
      opacity: 1,
      y: 0,
      duration: 1.2, // 🔥 Légèrement plus long
      stagger: 0.4, // 🔥 Délai entre chaque texte augmenté
      ease: "power2.out", // 🔥 Une courbe plus douce
    });

    // ✅ Animation des boutons avec un effet "springy"
    gsap.fromTo(
      ".animate-button",
      { opacity: 0, y: 40, scale: 0.9 }, // 🔥 Départ plus bas et légèrement réduit
      {
        opacity: 1,
        y: 0,
        scale: 1,
        duration: 1.5, // 🔥 Plus long pour plus de fluidité
        delay: 1.5, // 🔥 Arrive juste après les textes
        ease: "elastic.out(1, 0.5)", // 🔥 Effet rebond dynamique
      }
    );
  }
}
