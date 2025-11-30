import admin from "firebase-admin";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

// Vì dùng ES Module nên cần làm bước này để đọc file JSON
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Đọc file serviceAccountKey.json
const serviceAccount = JSON.parse(
  fs.readFileSync(path.join(__dirname, "./serviceAccountKey.json"), "utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export default admin;