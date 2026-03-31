const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

/**
 * Deception Layer: The Honeytoken Trigger.
 * Any request to this HTTPS function is considered an intrusion attempt.
 */
exports.deceptionTrigger = functions.https.onRequest(async (req, res) => {
  const ip = req.headers["x-forwarded-for"] || req.connection.remoteAddress;
  const userAgent = req.headers["user-agent"];
  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  // Resolve GeoIP metadata (using common free service for demo)
  let geoData = {};
  try {
    const response = await axios.get(`http://ip-api.com/json/${ip}`);
    geoData = response.data;
  } catch (error) {
    console.error("GeoIP resolution failed:", error);
  }

  // Calculate Initial Risk Score (0-10)
  // Logic: 5.0 base + 3.0 if Data Center (Hosting) + 2.0 if malicious agent
  let riskScore = 5.0;
  let archetype = "The Ghost Bot";
  
  if (geoData.hosting === true || geoData.org?.includes("Amazon") || geoData.org?.includes("DigitalOcean")) {
    riskScore += 3.0;
    archetype = "The Professional Proxy";
  }
  
  if (userAgent?.includes("curl") || userAgent?.includes("Postman")) {
    riskScore += 2.0;
  }

  const threatLog = {
    ip,
    userAgent,
    timestamp,
    geo: {
      city: geoData.city || "Unknown",
      country: geoData.country || "Unknown",
      isp: geoData.isp || "Unknown",
      lat: geoData.lat || 0,
      lon: geoData.lon || 0,
    },
    riskScore: Math.min(riskScore, 10.0),
    archetype,
    status: "active",
  };

  try {
    await admin.firestore().collection("threat_logs").add(threatLog);
    
    // Return a convincing "Honeytoken" response (fake config)
    res.status(403).json({
      error: "Unauthorized",
      hint: "Production environment restricted. Attempt logged.",
      vault_status: "LOCKED",
      admin_node: "US-EAST-1",
      trace_id: Math.random().toString(36).substring(7)
    });
  } catch (error) {
    console.error("Logging threat failed:", error);
    res.status(500).send("Internal Server Error");
  }
});
