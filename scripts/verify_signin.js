const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

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

async function testAll() {
  for (const acc of accounts) {
    const res = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        returnSecureToken: true,
      }),
    });

    const data = await res.json();
    if (res.ok) {
      console.log(`✅ [SUCCESS] ${acc.email} -> UID: ${data.localId}`);
    } else {
      console.error(`❌ [FAILED] ${acc.email} -> ${JSON.stringify(data.error)}`);
    }
  }
}

testAll();
