import { Controller } from "@hotwired/stimulus";
import gsap from "gsap";
import ScrollTrigger from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export default class extends Controller {
  connect() {
    console.log("🚀 Longevity animations initialized!");

    gsap.from(".longevity-text", {
      opacity: 0,
      x: -50,
      duration: 1.5,
      ease: "power2.out",
      scrollTrigger: {
        trigger: ".longevity-section",
        start: "top 85%",
        toggleActions: "play none none reverse",
      },
    });

    gsap.from(".longevity-image", {
      opacity: 0,
      x: 50,
      duration: 1.5,
      stagger: 0.3,
      ease: "power2.out",
      scrollTrigger: {
        trigger: ".longevity-section",
        start: "top 85%",
        toggleActions: "play none none reverse",
      },
    });
  }
}
