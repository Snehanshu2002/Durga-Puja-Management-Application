const bcrypt = require('bcryptjs');
const fs = require('fs');

const accounts = [
  { email: 'admin@durgapuja.org', pass: 'admin@123', uid: 'admin_dev_uid', name: 'DEV Super Admin' },
  { email: 'president@durgapuja.org', pass: 'president@123', uid: 'user_dev_president', name: 'DEV President' },
  { email: 'treasurer@durgapuja.org', pass: 'treasurer@123', uid: 'user_dev_treasurer', name: 'DEV Treasurer' },
  { email: 'manager@durgapuja.org', pass: 'manager@123', uid: 'user_dev_manager', name: 'DEV Manager' },
  { email: 'collector@durgapuja.org', pass: 'collector@123', uid: 'user_dev_collector', name: 'DEV Collection Member' },
  { email: 'viewer@durgapuja.org', pass: 'viewer@123', uid: 'user_dev_viewer', name: 'DEV Viewer' },
  { email: 'rashmiranjan@gmail.com', pass: 'Rashmi@123', uid: 'user_rashmi_ranjan', name: 'Rashmi Ranjan' },
  { email: 'filu@gmail.com', pass: 'Filu@123', uid: 'user_filu', name: 'Filu' },
  { email: 'biren@gmail.com', pass: 'Biren@123', uid: 'user_biren', name: 'Biren' },
];

const users = accounts.map(acc => {
  const salt = bcrypt.genSaltSync(10);
  const hash = bcrypt.hashSync(acc.pass, salt);
  return {
    localId: acc.uid,
    email: acc.email,
    emailVerified: true,
    displayName: acc.name,
    passwordHash: Buffer.from(hash).toString('base64'),
  };
});

fs.writeFileSync('users_bcrypt.json', JSON.stringify({ users }, null, 2));
console.log('✓ Wrote users_bcrypt.json with BCRYPT hashes');
