const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

exports.myFunc = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const { employees, supabaseFunctionUrl, supabaseServiceRole } = req.body;

  if (!Array.isArray(employees)) {
    return res.status(400).json({ error: "Invalid payload" });
  }

  const results = [];

  for (const emp of employees) {
    try {
      const password = Math.random().toString(36).slice(-8);
      const userRecord = await admin.auth().createUser({
        email: emp.email,
        password,
      });

      const response = await fetch(supabaseFunctionUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${supabaseServiceRole}`,
        },
        body: JSON.stringify({
          ...emp,
          firebase_uid: userRecord.uid,
          password,
        }),
      });

      const responseData = await response.json();

      results.push({
        email: emp.email,
        uid: userRecord.uid,
        status: response.ok ? "success" : "failed",
        supabaseResponse: responseData,
      });
    } catch (err) {
      results.push({
        email: emp.email,
        error: err.message || String(err),
      });
    }
  }

  res.status(200).json({ results });
});

