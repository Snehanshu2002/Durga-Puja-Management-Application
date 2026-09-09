const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Got gcloud access token');

async function main() {
  // 1. Get all accounts
  const listRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchGet?maxResults=100`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const listData = await listRes.json();
  const users = listData.users || [];
  console.log(`Found ${users.length} accounts in DEV`);

  // 2. Delete all existing DEV accounts
  if (users.length > 0) {
    const localIds = users.map(u => u.localId);
    console.log('Deleting UIDs:', localIds);
    const delRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ localIds }),
    });
    console.log('Delete result:', delRes.status, await delRes.text());
  }

  // 3. Create all accounts freshly
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

  console.log('\nCreating fresh accounts with plain passwords...');
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

  console.log('\n--- VERIFYING LOGIN FOR ALL ACCOUNTS ---');
  let allPass = true;
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
      console.log(`🎉 [SUCCESS 200 OK] ${acc.email} Logged In! UID: ${signinData.localId}`);
    } else {
      allPass = false;
      console.error(`❌ [FAILED] ${acc.email} ->`, signinData.error);
    }
  }

  if (allPass) {
    console.log('\n🚀 ALL 9 DEV ACCOUNTS FULLY CREATED AND LOGINS 100% VERIFIED!');
  }
}

main().catch(console.error);
