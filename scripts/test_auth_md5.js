const crypto = require('crypto');
const fs = require('fs');

const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const accounts = [
  { email: 'admin@durgapuja.org', pass: 'admin@123', uid: 'user_dev_super_admin', name: 'DEV Super Admin' },
  { email: 'president@durgapuja.org', pass: 'president@123', uid: 'user_dev_president', name: 'DEV President' },
  { email: 'treasurer@durgapuja.org', pass: 'treasurer@123', uid: 'user_dev_treasurer', name: 'DEV Treasurer' },
  { email: 'manager@durgapuja.org', pass: 'manager@123', uid: 'user_dev_manager', name: 'DEV Manager' },
  { email: 'collector@durgapuja.org', pass: 'collector@123', uid: 'user_dev_collector', name: 'DEV Collector' },
  { email: 'viewer@durgapuja.org', pass: 'viewer@123', uid: 'user_dev_viewer', name: 'DEV Viewer' },
  { email: 'rashmiranjan@gmail.com', pass: 'Rashmi@123', uid: 'user_rashmi_ranjan', name: 'Rashmi Ranjan' },
  { email: 'filu@gmail.com', pass: 'Filu@123', uid: 'user_filu', name: 'Filu' },
  { email: 'biren@gmail.com', pass: 'Biren@123', uid: 'user_biren', name: 'Biren' },
];

function getMd5Base64(plainText) {
  return crypto.createHash('md5').update(plainText).digest('base64');
}

const users = accounts.map(acc => ({
  localId: acc.uid,
  email: acc.email,
  emailVerified: true,
  displayName: acc.name,
  passwordHash: getMd5Base64(acc.pass),
}));

fs.writeFileSync('users_md5.json', JSON.stringify({ users }, null, 2));
console.log('✓ Wrote users_md5.json with MD5 hashes');
