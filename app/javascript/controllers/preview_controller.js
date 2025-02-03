import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("🚀 Preview section animations initialized!");

    // ✅ Animation des images (slide-in depuis la droite avec effet superposition)
    gsap.from(".preview-image", {
      opacity: 0,
      x: 50,
      duration: 1.5,
      ease: "power2.out",
      stagger: 0.3,
      scrollTrigger: {
        trigger: ".preview-section",
        start: "top 80%",
        toggleActions: "play none none reverse",
      },
    });

    // ✅ Animation du texte (slide-in depuis la gauche)
    gsap.from(".preview-text", {
      opacity: 0,
      x: -50,
      duration: 1.5,
      ease: "power2.out",
      delay: 0.3, // Légère attente pour que les images arrivent en premier
      scrollTrigger: {
        trigger: ".preview-section",
        start: "top 80%",
        toggleActions: "play none none reverse",
      },
    });
  }
}
