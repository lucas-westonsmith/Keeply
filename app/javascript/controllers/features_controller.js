import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("🚀 Features animations initialized!");

    gsap.from(".feature-card", {
      opacity: 0,
      y: 40,
      duration: 1.2,
      stagger: 0.3,
      ease: "power2.out",
      scrollTrigger: {
        trigger: ".feature-cards",
        start: "top 90%",
        toggleActions: "play none none reverse",
      },
    });
  }
}
