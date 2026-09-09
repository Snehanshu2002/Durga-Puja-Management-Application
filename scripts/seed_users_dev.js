const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();

function toFirestoreValue(val) {
  if (val === null || val === undefined) return { nullValue: null };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (typeof val === 'number') {
    if (Number.isInteger(val)) return { integerValue: val.toString() };
    return { doubleValue: val };
  }
  if (typeof val === 'string') {
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(val)) {
      return { timestampValue: val };
    }
    return { stringValue: val };
  }
  if (Array.isArray(val)) {
    return { arrayValue: { values: val.map(toFirestoreValue) } };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(val) };
}

async function writeDoc(collection, docId, data) {
  const fields = {};
  for (const [k, v] of Object.entries(data)) {
    fields[k] = toFirestoreValue(v);
  }

  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'x-goog-user-project': PROJECT_ID,
    },
    body: JSON.stringify({ fields }),
  });

  if (!res.ok) {
    console.error(`❌ Failed ${docId}:`, res.status, await res.text());
  } else {
    console.log(`✓ [Firestore users] ${docId} (${data.email})`);
  }
}

const allEvents = ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'];
const allEventAccess = [
  {
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    year: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    roleId: 'super_admin',
  },
  {
    eventId: 'opera_jatra_2025',
    eventType: 'OPERA_JATRA',
    year: 2025,
    organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
    roleId: 'super_admin',
  },
  {
    eventId: 'opera_jatra_2026',
    eventType: 'OPERA_JATRA',
    year: 2026,
    organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
    roleId: 'super_admin',
  },
];

const usersToSeed = [
  // admin@durgapuja.org
  {
    uid: 'JV88zFcMagVn6xro1bwJyOfDm4o2',
    name: 'DEV Super Admin',
    email: 'admin@durgapuja.org',
    mobile: '9876543210',
    roleId: 'super_admin',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess,
    isOnline: false,
    createdBy: 'system',
  },
  // superadmin@durgapuja.org
  {
    uid: 'DIODq3kxi3RwkF5EWwDMcnR4Yp73',
    name: 'DEV Super Admin',
    email: 'superadmin@durgapuja.org',
    mobile: '9876543210',
    roleId: 'super_admin',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess,
    isOnline: false,
    createdBy: 'system',
  },
  // president@durgapuja.org
  {
    uid: 'user_dev_president',
    name: 'DEV President',
    email: 'president@durgapuja.org',
    mobile: '9876543211',
    roleId: 'president',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'president' })),
    isOnline: false,
    createdBy: 'system',
  },
  // treasurer@durgapuja.org
  {
    uid: 'user_dev_treasurer',
    name: 'DEV Treasurer',
    email: 'treasurer@durgapuja.org',
    mobile: '9876543212',
    roleId: 'treasurer',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'treasurer' })),
    isOnline: false,
    createdBy: 'system',
  },
  // manager@durgapuja.org
  {
    uid: 'user_dev_manager',
    name: 'DEV Manager',
    email: 'manager@durgapuja.org',
    mobile: '9876543213',
    roleId: 'manager',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'manager' })),
    isOnline: false,
    createdBy: 'system',
  },
  // collector@durgapuja.org
  {
    uid: 'user_dev_collector',
    name: 'DEV Collection Member',
    email: 'collector@durgapuja.org',
    mobile: '9876543214',
    roleId: 'collection_member',
    status: 'ACTIVE',
    assignedEventIds: allEvents,
    eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'collection_member' })),
    isOnline: false,
    createdBy: 'system',
  },
  // viewer@durgapuja.org
  {
    uid: 'vaV0aVJ3gfR9kcC2yH1jAuVgKa72',
    name: 'DEV Viewer',
    email: 'viewer@durgapuja.org',
    mobile: '9876543215',
    roleId: 'viewer',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026'],
    eventAccess: [allEventAccess[0]],
    isOnline: false,
    createdBy: 'system',
  },
];

async function main() {
  for (const u of usersToSeed) {
    await writeDoc('users', u.uid, u);
  }
  console.log('✓ All DEV Firestore user profiles linked!');
}

main().catch(console.error);
