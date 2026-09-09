const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

async function createAccount(email, pass, name) {
  const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: email,
      password: pass,
      displayName: name,
      returnSecureToken: true,
    }),
  });

  const data = await res.json();
  console.log(`Create ${email}:`, res.status, data);
}

async function verifyAll() {
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

  console.log('\n--- VERIFYING ALL 9 DEV ACCOUNTS ---');
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
    console.log('\n🚀 ALL 9 DEV ACCOUNTS 100% READY AND VERIFIED!');
  }
}

async function main() {
  await createAccount('admin@durgapuja.org', 'admin@123', 'DEV Super Admin');
  await createAccount('viewer@durgapuja.org', 'viewer@123', 'DEV Viewer');
  await verifyAll();
}

main().catch(console.error);
