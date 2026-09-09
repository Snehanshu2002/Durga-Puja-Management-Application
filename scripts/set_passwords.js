const fs = require('fs');
const os = require('os');
const path = require('path');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const configPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const refreshToken = config.tokens.refresh_token;

async function getAccessToken() {
  const params = new URLSearchParams({
    client_id: '563584335869-fgrhgmd47bqnekij5i8b5pr03ho85qd6.apps.googleusercontent.com',
    grant_type: 'refresh_token',
    refresh_token: refreshToken,
  });

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params.toString(),
  });

  const data = await res.json();
  return data.access_token;
}

const accounts = [
  { email: 'admin@durgapuja.org', pass: 'admin@123' },
  { email: 'president@durgapuja.org', pass: 'president@123' },
  { email: 'treasurer@durgapuja.org', pass: 'treasurer@123' },
  { email: 'manager@durgapuja.org', pass: 'manager@123' },
  { email: 'collector@durgapuja.org', pass: 'collector@123' },
  { email: 'viewer@durgapuja.org', pass: 'viewer@123' },
  { email: 'rashmiranjan@gmail.com', pass: 'Rashmi@123' },
  { email: 'filu@gmail.com', pass: 'Filu@123' },
  { email: 'biren@gmail.com', pass: 'Biren@123' },
];

async function main() {
  const accessToken = await getAccessToken();
  console.log('✓ Acquired Access Token');

  // List users
  const listRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchGet?maxResults=100`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const listData = await listRes.json();
  const existingUsers = listData.users || [];
  console.log(`Found ${existingUsers.length} accounts in batchGet`);

  for (const acc of accounts) {
    const matched = existingUsers.find(u => u.email === acc.email);
    if (matched) {
      // Update existing user password
      const updateRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:update`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          localId: matched.localId,
          password: acc.pass,
        }),
      });
      const updateData = await updateRes.json();
      console.log(`✓ Updated password for ${acc.email} (UID: ${matched.localId})`);
    } else {
      // Create user
      const createRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:signUp`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: acc.email,
          password: acc.pass,
          returnSecureToken: true,
        }),
      });
      const createData = await createRes.json();
      console.log(`✓ Created user ${acc.email} (UID: ${createData.localId})`);
    }
  }

  console.log('\n--- VERIFYING LOGIN FOR ALL ACCOUNTS ---');
  let allPass = true;
  for (const acc of accounts) {
    const signinRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        returnSecureToken: true,
      }),
    });

    const signinData = await signinRes.json();
    if (signinRes.ok) {
      console.log(`🎉 [SUCCESS 200 OK] ${acc.email} -> UID: ${signinData.localId}`);
    } else {
      allPass = false;
      console.error(`❌ [FAILED] ${acc.email} ->`, signinData.error);
    }
  }

  if (allPass) {
    console.log('\n🚀 ALL DEV ACCOUNTS VERIFIED AND READY FOR LOGIN!');
  }
}

main().catch(console.error);
