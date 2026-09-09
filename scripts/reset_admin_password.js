const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

async function resetPassword(email, newPassword) {
  console.log(`Requesting password reset for ${email}...`);
  const oobRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${API_KEY}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      requestType: 'PASSWORD_RESET',
      email: email,
    }),
  });

  const oobData = await oobRes.json();
  console.log('OOB response:', oobData);

  if (!oobRes.ok) {
    console.error('Failed to request OOB code:', oobData.error);
    return;
  }

  const oobCode = oobData.oobCode;
  if (oobCode) {
    console.log(`Setting new password with oobCode: ${oobCode}...`);
    const confirmRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:resetPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        oobCode: oobCode,
        newPassword: newPassword,
      }),
    });
    const confirmData = await confirmRes.json();
    console.log('Confirm response:', confirmData);
  }
}

async function main() {
  await resetPassword('admin@durgapuja.org', 'admin@123');
  await resetPassword('viewer@durgapuja.org', 'viewer@123');
}

main().catch(console.error);
