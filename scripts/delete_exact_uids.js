const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Got token');

async function main() {
  const uidsToDelete = ['admin_dev_uid', 'user_dev_viewer', 'user_dev_super_admin'];

  for (const uid of uidsToDelete) {
    const res = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:delete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'x-goog-user-project': PROJECT_ID,
      },
      body: JSON.stringify({ localId: uid }),
    });
    console.log(`Delete ${uid}:`, res.status, await res.text());
  }

  // Now create admin@durgapuja.org and viewer@durgapuja.org freshly
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

  // Verify all
  const accounts = [
    { email: 'admin@durgapuja.org', pass: 'admin@123' },
    { email: 'president@durgapuja.org', pass: 'president@123' },
    { email: 'treasurer@durgapuja.org', pass: 'treasurer@123' },
    { email: 'manager@durgapuja.org', pass: 'manager@123' },
    { email: 'collector@durgapuja.org', pass: 'collector@123' },
    { email: 'viewer@durgapuja.org', pass: 'viewer@123' },
  ];

  console.log('\n--- VERIFYING ALL 6 CORE ACCOUNTS ---');
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
      console.log(`🎉 [SUCCESS 200 OK] ${acc.email} -> UID: ${sData.localId}`);
    } else {
      console.error(`❌ [FAILED] ${acc.email} ->`, sData.error);
    }
  }
}

main().catch(console.error);
