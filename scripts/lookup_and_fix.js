const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Got token');

async function lookupAndDelete(emails) {
  const lookupRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:lookup`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'x-goog-user-project': PROJECT_ID,
    },
    body: JSON.stringify({ email: emails }),
  });

  const lookupData = await lookupRes.json();
  const users = lookupData.users || [];
  console.log(`Lookup found ${users.length} users:`, users.map(u => ({ email: u.email, localId: u.localId })));

  for (const u of users) {
    const delRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:delete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'x-goog-user-project': PROJECT_ID,
      },
      body: JSON.stringify({ localId: u.localId }),
    });
    console.log(`Deleted ${u.email} (${u.localId}):`, delRes.status);
  }
}

async function main() {
  await lookupAndDelete(['admin@durgapuja.org', 'viewer@durgapuja.org']);

  // Create freshly
  const toCreate = [
    { email: 'admin@durgapuja.org', pass: 'admin@123', name: 'DEV Super Admin' },
    { email: 'viewer@durgapuja.org', pass: 'viewer@123', name: 'DEV Viewer' },
  ];

  for (const acc of toCreate) {
    const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        displayName: acc.name,
        returnSecureToken: true,
      }),
    });
    console.log(`Create ${acc.email}:`, res.status, await res.text());
  }

  // Final verification of ALL 9 accounts
  const allAccounts = [
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

  console.log('\n======================================================');
  console.log('--- VERIFYING ALL 9 DEV ACCOUNTS AUTHENTICATION ---');
  console.log('======================================================');
  for (const acc of allAccounts) {
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
      console.log(`🎉 [VERIFIED 200 OK] ${acc.email} -> UID: ${sData.localId}`);
    } else {
      console.error(`❌ [FAILED] ${acc.email} ->`, sData.error);
    }
  }
}

main().catch(console.error);
