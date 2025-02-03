import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("🚀 Value section animations initialized!");

    // Sélectionne toutes les cartes de la section "value"
    const rows = this.element.querySelectorAll(".card-row");

    rows.forEach((row, index) => {
      const direction = index % 2 === 0 ? -100 : 100; // Alternance gauche / droite
      const icons = row.querySelectorAll("i");

      gsap.from(row, {
        opacity: 0,
        x: direction,
        duration: 1.2,
        ease: "power2.out",
        delay: index * 0.2, // Petit effet progressif
        scrollTrigger: {
          trigger: row,
          start: "top 85%",
          toggleActions: "play none none reverse",
        },
      });

      gsap.from(icons, {
        opacity: 0,
        scale: 0.8,
        rotate: -15,
        duration: 1,
        delay: index * 0.2 + 0.3,
        ease: "elastic.out(1, 0.5)",
        scrollTrigger: {
          trigger: row,
          start: "top 85%",
          toggleActions: "play none none reverse",
        },
      });
    });
  }
}
