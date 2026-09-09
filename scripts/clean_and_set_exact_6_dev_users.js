const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Got gcloud access token for:', PROJECT_ID);

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

async function main() {
  console.log('\n--- 1. CLEANING OLD FIRESTORE USERS ---');
  let nextPageToken = null;
  do {
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users?pageSize=100${nextPageToken ? '&pageToken=' + nextPageToken : ''}`;
    const listRes = await fetch(url, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const listData = await listRes.json();
    const docs = listData.documents || [];
    console.log(`Found ${docs.length} Firestore user documents to delete`);

    for (const doc of docs) {
      const delRes = await fetch(`https://firestore.googleapis.com/v1/${doc.name}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
      });
      console.log(`Deleted Firestore user doc: ${doc.name.split('/').pop()} -> ${delRes.status}`);
    }
    nextPageToken = listData.nextPageToken;
  } while (nextPageToken);

  console.log('\n--- 2. CLEANING OLD FIREBASE AUTH ACCOUNTS ---');
  const authListRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchGet?maxResults=100`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const authListData = await authListRes.json();
  const authUsers = authListData.users || [];
  console.log(`Found ${authUsers.length} Auth accounts in DEV`);

  if (authUsers.length > 0) {
    const localIds = authUsers.map(u => u.localId);
    const delAuthRes = await fetch(`https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:batchDelete`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ localIds }),
    });
    console.log('Deleted Auth accounts status:', delAuthRes.status);
  }

  console.log('\n--- 3. CREATING EXACT 6 ROLE-BASED DEV USERS ---');
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

  const exact6Users = [
    {
      email: 'admin.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV Super Admin',
      mobile: '9876543210',
      roleId: 'super_admin',
      assignedEventIds: allEvents,
      eventAccess: allEventAccess,
    },
    {
      email: 'president.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV President',
      mobile: '9876543211',
      roleId: 'president',
      assignedEventIds: allEvents,
      eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'president' })),
    },
    {
      email: 'treasurer.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV Treasurer',
      mobile: '9876543212',
      roleId: 'treasurer',
      assignedEventIds: allEvents,
      eventAccess: allEventAccess.map(e => ({ ...e, roleId: 'treasurer' })),
    },
    {
      email: 'manager.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV Manager',
      mobile: '9876543213',
      roleId: 'manager',
      assignedEventIds: ['opera_jatra_2026'],
      eventAccess: [
        {
          eventId: 'opera_jatra_2026',
          eventType: 'OPERA_JATRA',
          year: 2026,
          organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
          roleId: 'manager',
        },
      ],
    },
    {
      email: 'collector.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV Collector',
      mobile: '9876543214',
      roleId: 'collection_member',
      assignedEventIds: ['opera_jatra_2026'],
      eventAccess: [
        {
          eventId: 'opera_jatra_2026',
          eventType: 'OPERA_JATRA',
          year: 2026,
          organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
          roleId: 'collection_member',
        },
      ],
    },
    {
      email: 'viewer.dev@durgapuja.org',
      pass: 'admin@123',
      name: 'DEV Viewer',
      mobile: '9876543215',
      roleId: 'viewer',
      assignedEventIds: ['bhasani_utsab_2026'],
      eventAccess: [
        {
          eventId: 'bhasani_utsab_2026',
          eventType: 'BHASANI_UTSAB',
          year: 2026,
          organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
          roleId: 'viewer',
        },
      ],
    },
  ];

  for (const acc of exact6Users) {
    // 1. Create in Firebase Auth
    const createRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        displayName: acc.name,
        returnSecureToken: true,
      }),
    });
    const createData = await createRes.json();
    if (!createRes.ok) {
      console.error(`❌ Failed to create Auth user: ${acc.email}`, createData.error);
      continue;
    }

    const uid = createData.localId;
    console.log(`✅ [Auth Created] ${acc.email} -> UID: ${uid}`);

    // 2. Create in Firestore users collection
    const firestoreUser = {
      uid: uid,
      name: acc.name,
      email: acc.email,
      mobile: acc.mobile,
      roleId: acc.roleId,
      status: 'ACTIVE',
      assignedEventIds: acc.assignedEventIds,
      eventAccess: acc.eventAccess,
      isOnline: false,
      createdBy: 'system_dev_init',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const fields = {};
    for (const [k, v] of Object.entries(firestoreUser)) {
      fields[k] = toFirestoreValue(v);
    }

    const docUrl = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${uid}`;
    const docRes = await fetch(docUrl, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'x-goog-user-project': PROJECT_ID,
      },
      body: JSON.stringify({ fields }),
    });

    if (docRes.ok) {
      console.log(`✅ [Firestore Created] users/${uid} (${acc.email})`);
    } else {
      console.error(`❌ [Firestore Failed] users/${uid}:`, await docRes.text());
    }
  }

  console.log('\n--- 4. VERIFYING LOGIN FOR ALL 6 DEV ACCOUNTS ---');
  for (const acc of exact6Users) {
    const signinRes = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: acc.email,
        password: acc.pass,
        returnSecureToken: true,
      }),
    });
    const signinData = await signinRes.json();
    if (signinRes.ok) {
      console.log(`🎉 [LOGIN VERIFIED] ${acc.email} (Password: ${acc.pass}) -> UID: ${signinData.localId}`);
    } else {
      console.error(`❌ [LOGIN FAILED] ${acc.email} ->`, signinData.error);
    }
  }

  console.log('\n🚀 CLEANUP COMPLETE: EXACTLY 6 CLEAN DEV USERS ARE NOW LIVE IN DEV!');
}

main().catch(console.error);
