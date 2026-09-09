const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Got token');

async function run() {
  // Query all users
  const qRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:query`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({}),
  });

  const qData = await qRes.json();
  const users = qData.records || qData.users || [];
  console.log(`Found ${users.length} accounts in query:`, users.map(u => ({ email: u.email, localId: u.localId })));

  // Delete them
  if (users.length > 0) {
    const localIds = users.map(u => u.localId);
    const delRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ localIds }),
    });
    console.log('Deleted:', delRes.status, await delRes.text());
  }

  // Create clean accounts
  const accounts = [
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

  console.log('\nCreating fresh accounts...');
  for (const acc of accounts) {
    const cRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        displayName: acc.name,
        returnSecureToken: true,
      }),
    });
    const cData = await cRes.json();
    console.log(`Created ${acc.email} -> UID: ${cData.localId}`);
  }

  console.log('\nTesting Sign In...');
  let allPass = true;
  for (const acc of accounts) {
    const sRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        returnSecureToken: true,
      }),
    });
    const sData = await sRes.json();
    if (sRes.ok) {
      console.log(`🎉 [SUCCESS 200 OK] ${acc.email} Logged In! UID: ${sData.localId}`);
    } else {
      allPass = false;
      console.error(`❌ [FAILED] ${acc.email} ->`, sData.error);
    }
  }

  if (allPass) {
    console.log('\n🚀 ALL 9 DEV ACCOUNTS 100% PROVISIONED AND VERIFIED!');
  }
}

run().catch(console.error);
