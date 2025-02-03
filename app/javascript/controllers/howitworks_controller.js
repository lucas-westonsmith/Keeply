import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("🚀 How It Works animations initialized!");

    gsap.utils.toArray(".step").forEach((step, index) => {
      gsap.from(step, {
        opacity: 0,
        x: index % 2 === 0 ? -50 : 50, // Alternance gauche/droite
        duration: 1.2,
        ease: "power2.out",
        scrollTrigger: {
          trigger: step,
          start: "top 85%",
          toggleActions: "play none none reverse",
        },
      });
    });
  }
}
