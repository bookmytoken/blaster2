# How ShieldGuard Works (A Human-Friendly Explanation)

ShieldGuard is built on a concept called **"Deception Technology"** (sometimes called a honeypot or honeytoken). Traditional security tries to build a huge wall around a system and block the bad guys from getting in. ShieldGuard takes a different, smarter approach: it leaves a fake door wide open and waits to see who walks through it.

Here is exactly how the ShieldGuard "Detection Model" works behind the scenes, step-by-step:

## 1. The Trap (The Honeytoken)
In our backend server, we expose a fake, hidden link called `/deceptionTrigger`. Legitimate users of the app or website will *never* see or click this link. Therefore, if anyone or anything accesses this link, we automatically know with 100% certainty that they are snooping around where they shouldn't be.

## 2. Catching the Intruder
When the trap is triggered, our Node.js backend intercepts the incoming connection before the intruder can do any damage. Instead of just blocking them, the backend pauses to gather intelligence on them:
*   **IP Address & Geolocation:** We extract the true public IP address of the attacker. We then query a geolocation database to find out exactly what city and country they are attacking from, and what Internet Service Provider (ISP) they are using.
*   **User-Agent:** We look at the "User-Agent" string, which reveals what kind of browser or automated tool the hacker is using to run their attack.

## 3. The Threat Scoring Model
Once we have that intelligence, our custom algorithm calculates a **Risk Score** out of 10.0 and labels the intruder with a **Threat Archetype**. 

Here is how the math works:
*   **The Baseline Penalty (8.5 points):** Just by touching the trap, the attacker immediately receives an extremely high base risk score of 8.5. 
*   **The Professional Proxy Penalty (+1.0 points):** We check the ISP data. If the attacker is routing their connection through a massive commercial data center (like Amazon AWS, Google Cloud, or DigitalOcean) instead of a normal home ISP, we label them "The Professional Proxy" and bump their risk score up because they are actively trying to hide their identity.
*   **The Automated Tool Penalty (+0.5 points):** If their User-Agent reveals they are using automated scanning tools or coding scripts (like `curl`, `Postman`, or `python`) instead of a normal web browser, we label them "The Shadow Automater" and max out their risk score.

## 4. The Self-Healing Dashboard
Finally, the backend passes all of this analyzed intelligence to the **Flutter Dashboard**. The dashboard instantly visualizes the threat in real-time. Because of the high risk score, the system provides automated "Self-Healing Actions," recommending that the security team immediately rotate access tokens, block the attacker's ISP network traffic, and enforce a localized zero-trust vault lockdown.

**In summary:** The model tricks attackers into revealing themselves, aggressively analyzes their footprint to score their threat level, and instantly visualizes the danger so defenders can act before real damage occurs.
