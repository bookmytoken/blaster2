const express = require("express");
const axios = require("axios");

const app = express();
const port = 5001;

// Global state to link Terminal Hack to Flutter UI
let activeThreat = null;

// Allow CORS so the Flutter Web app (port 8080) can read this
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

// Endpoint for the Flutter frontend to poll
app.get("/threatStatus", (req, res) => {
  res.json({
    threatDetected: activeThreat !== null,
    threatData: activeThreat
  });
});

// Endpoint to reset the dashboard for a new demo run
app.get("/reset", (req, res) => {
  activeThreat = null;
  console.log(`\n\x1b[42m\x1b[30m [OK] ShieldGuard System Reset to Secure State \x1b[0m\n`);
  res.json({ success: true, status: "secure" });
});

app.get("/deceptionTrigger", async (req, res) => {
  const userAgent = req.headers["user-agent"] || "Unknown User Agent";

  // Check the true public IP and accurate geolocation of the machine running the attack
  let geoData = {};
  
  // Cloudflare sets cf-connecting-ip, which is the most reliable way to trace the real mobile user.
  let trueIp = req.headers["cf-connecting-ip"] || req.headers["x-forwarded-for"] || req.connection.remoteAddress;
  
  // Clean up if x-forwarded-for gives a comma-separated list
  if (trueIp && trueIp.includes(",")) {
    trueIp = trueIp.split(",")[0].trim();
  }

  // If testing completely locally without Cloudflare, let ip-api auto-detect
  let apiQueryIp = (trueIp === '::1' || trueIp === '127.0.0.1') ? '' : trueIp;
  
  try {
    const response = await axios.get(`http://ip-api.com/json/${apiQueryIp}`);
    geoData = response.data;
    if (geoData.query) {
      trueIp = geoData.query; // Ensure we always have the normalized public IP
    }
  } catch (error) {
    console.error("GeoIP resolution failed");
  }

  console.log(`\n\x1b[41m\x1b[37m [!] SHIELDGUARD ALERT: HONEYTOKEN TRIGGERED [!] \x1b[0m`);
  console.log(`⚡ Intercepting Incoming Request...`);
  console.log(`🌐 Exact Public IP: ${trueIp}`);
  console.log(`🕵️  User-Agent: ${userAgent}`);

  // Professional-Grade Risk Scoring (0-10)
  // Base risk is EXTREMELY HIGH (8.5) because ANY access to a Honeypot endpoint is an intrusion.
  let riskScore = 8.5;
  let archetype = "Unauthorized Intruder";
  
  // 1. Data Center / Proxy Detection
  if (geoData.hosting === true || geoData.org?.includes("Amazon") || geoData.org?.includes("DigitalOcean") || geoData.isp?.includes("Google")) {
    riskScore += 1.0;
    archetype = "The Professional Proxy";
  }
  
  // 2. Automated Tooling Detection
  if (userAgent.includes("curl") || userAgent.includes("Postman") || userAgent.includes("python") || userAgent.includes("Hacker")) {
    riskScore += 0.5;
    archetype = "The Shadow Automater";
  }

  // 3. Geographic Anomaly (e.g., if you're in India but hitting from US)
  // For demo purposes, we'll keep it simple but add a "High Intensity" label
  if (riskScore >= 9.5) {
    archetype = "State-Sponsored Actor";
  }

  console.log(`\n--- 🔍 THREAT ANALYSIS ---`);
  console.log(`📍 Geospatial Origin: \x1b[33m${geoData.city || 'Unknown'}, ${geoData.country || 'Unknown'}\x1b[0m (ISP: ${geoData.isp})`);
  console.log(`👹 Threat Archetype: \x1b[31m\x1b[1m${archetype}\x1b[0m`);
  console.log(`⚠️  Calculated Risk Score: \x1b[31m${Math.min(riskScore, 10.0).toFixed(1)} / 10.0\x1b[0m`);
  console.log(`🔒 Action: Threat Logged & Connection Zero-Trust Blocked. \n`);

  // Save the exact threat to global state so the Flutter Dashboard sees it!
  activeThreat = {
    riskScore: Math.min(riskScore, 10.0),
    archetype: archetype,
    location: `${geoData.city || 'Unknown'}, ${geoData.country || 'Unknown'}`,
    isp: geoData.isp || 'Unknown',
    ip: trueIp
  };

  // Return realistic-looking fake data to trick the hacker
  res.status(403).json({
    error: "Unauthorized",
    hint: "Production environment restricted. Attempt logged.",
    vault_status: "LOCKED",
    admin_node: "US-EAST-1",
    trace_id: Math.random().toString(36).substring(7)
  });
});

app.listen(port, () => {
  console.log(`\n🛡️  ShieldGuard Backend Trap is LIVE and actively listening on port ${port} `);
  console.log(`To simulate a hack, run this command in another terminal:`);
  console.log(`👉 curl -X GET http://localhost:${port}/deceptionTrigger -H "User-Agent: curl/7.88.1 (Hacker Scanner)"\n`);
});
