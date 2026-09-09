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

const accountsToCreate = [
  { email: 'admin@durgapuja.org', pass: 'admin@123', name: 'DEV Super Admin' },
  { email: 'president@durgapuja.org', pass: 'president@123', name: 'DEV President' },
  { email: 'treasurer@durgapuja.org', pass: 'treasurer@123', name: 'DEV Treasurer' },
  { email: 'manager@durgapuja.org', pass: 'manager@123', name: 'DEV Manager' },
  { email: 'collector@durgapuja.org', pass: 'collector@123', name: 'DEV Collection Member' },
  { email: 'viewer@durgapuja.org', pass: 'viewer@123', name: 'DEV Viewer' },
  { email: 'rashmiranjan@gmail.com', pass: 'Rashmi@123', name: 'Rashmi Ranjan' },
  { email: 'filu@gmail.com', pass: 'Filu@123', name: 'Filu' },
  { email: 'biren@gmail.com', pass: 'Biren@123', name: 'Biren' },
];

async function main() {
  console.log(`[Auth Provisioner] Target Project: ${PROJECT_ID}`);
  const accessToken = await getAccessToken();
  console.log('✓ Acquired Google OAuth2 Access Token');

  // 1. Get all current users in DEV project
  const listRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchGet?maxResults=100`, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  const listData = await listRes.json();
  const users = listData.users || [];
  console.log(`Found ${users.length} existing accounts in DEV Firebase Auth`);

  // 2. Delete all existing DEV accounts
  if (users.length > 0) {
    const uids = users.map(u => u.localId);
    const delRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ localIds: uids }),
    });
    console.log('✓ Cleared old accounts:', await delRes.text());
  }

  // 3. Create all accounts freshly with direct plain passwords
  console.log('\nCreating fresh DEV accounts with valid passwords...');
  for (const acc of accountsToCreate) {
    const createRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        displayName: acc.name,
        returnSecureToken: true,
      }),
    });

    const createData = await createRes.json();
    if (createRes.ok) {
      console.log(`✅ [CREATED] ${acc.email} -> UID: ${createData.localId}`);
    } else {
      console.error(`❌ [ERROR] ${acc.email} ->`, createData.error);
    }
  }

  console.log('\nTesting Sign In for all accounts...');
  for (const acc of accountsToCreate) {
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
      console.log(`🎉 [VERIFIED 200 OK] ${acc.email} Logged In! UID: ${signinData.localId}`);
    } else {
      console.error(`❌ [SIGNIN FAILED] ${acc.email} ->`, signinData.error);
    }
  }
}

main().catch(console.error);
