const fs = require('fs');
const os = require('os');
const path = require('path');

const PROJECT_ID = 'durga-puja-manager-dev';

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

async function run() {
  const token = await getAccessToken();
  console.log('Got token');

  // Delete admin_dev_uid and user_dev_viewer
  const delRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      localIds: ['admin_dev_uid', 'user_dev_viewer', 'user_dev_super_admin'],
    }),
  });

  console.log('Delete status:', delRes.status, await delRes.text());
}

run().catch(console.error);
