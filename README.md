# SHIELDGUARD: Zero-Trust Deception Dashboard

## Problem Statement
Traditional perimeter security often fails to detect sophisticated, low-and-slow intrusion attempts. Reactive security measures only respond after data has been compromised, leaving organizations vulnerable to "quiet" attackers who bypass standard firewalls.

## Project Description
**ShieldGuard** is a proactive cybersecurity command center that utilizes a **Deception-as-a-Service** model. It features an active "Honeytoken" trigger—a fake administrative endpoint that, when accessed, immediately traps and analyzes the intruder. 

Built with **Flutter** (Frontend) and **Node.js** (Backend), ShieldGuard performs sub-second geospatial analysis and risk scoring. It identifies the attacker’s true IP, ISP, and location even through proxies, classifying them into "Threat Archetypes" (e.g., The Shadow Automater, State-Sponsored Actor) to enable immediate, automated self-healing actions.

---

## Google AI Usage
### Tools / Models Used
- **Gemini 1.5 Flash**: Used for intelligent threat classification and generating dynamic risk mitigation strategies.
- **Google Fonts**: Orbitron and Exo 2 for high-fidelity security UI.

### How Google AI Was Used
Gemini 1.5 Flash was integrated to analyze incoming threat metadata and generate human-readable "Threat Intelligence Reports." It powers the classification engine that determines the **Threat Archetype**, moving beyond simple rule-based detection to understand the *intent* and *sophistication* of the intruder based on their request patterns and geospatial origin.

---

## Proof of Google AI Usage
Attach screenshots in a `/proof` folder:

![AI Proof](./proof/screenshot1.png)

---

## Screenshots 
Add project screenshots:

![Dashboard Overview](./assets/screenshot1.png)  
![Threat Detected](./assets/screenshot2.png)

---

## Demo Video
Upload your demo video to Google Drive and paste the shareable link here(max 3 minutes).
[Watch Demo](#)

---

## Installation Steps

```bash
# 1. Clone the repository
git clone <your-repo-link>

# 2. Setup the Backend Trap (Node.js)
cd shieldguard/firebase/functions
npm install
node mock_trap.js

# 3. Setup the Dashboard (Flutter)
# Open a new terminal
cd shieldguard
flutter pub get

# 4. Run the Project
# For Desktop (Recommended)
flutter run -d windows

# For Web
flutter run -d chrome --web-port 8080
```
