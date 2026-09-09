const { execSync } = require('child_process');

const PROJECT_ID = 'durga-puja-manager-dev';
const API_KEY = 'AIzaSyBTP3KvlpMaupqLQhUQOBLVt8myYednPy0';

const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
console.log('✓ Acquired gcloud access token');

// Helper to convert plain JS object to Firestore REST document format
function toFirestoreValue(val) {
  if (val === null || val === undefined) return { nullValue: null };
  if (typeof val === 'boolean') return { booleanValue: val };
  if (typeof val === 'number') {
    if (Number.isInteger(val)) return { integerValue: val.toString() };
    return { doubleValue: val };
  }
  if (typeof val === 'string') {
    // Check if ISO date string
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(val)) {
      return { timestampValue: val };
    }
    return { stringValue: val };
  }
  if (val instanceof Date) return { timestampValue: val.toISOString() };
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
    console.error(`❌ Failed to write ${collection}/${docId}:`, res.status, await res.text());
  } else {
    console.log(`✓ [Firestore] ${collection}/${docId}`);
  }
}

// 1. DEV Events
const devEvents = [
  {
    id: 'bhasani_utsab_2026',
    eventId: 'bhasani_utsab_2026',
    name: 'Bhasani Utsab (2026)',
    eventName: 'Bhasani Utsab (2026)',
    year: 2026,
    eventType: 'BHASANI_UTSAB',
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    startDate: '2026-10-01T00:00:00.000Z',
    endDate: '2026-10-10T23:59:59.000Z',
    location: 'Main Pandal',
    description: 'Bhasani Utsab 2026 Celebrations (DEV)',
    status: 'ACTIVE',
    createdBy: 'system',
  },
  {
    id: 'opera_jatra_2025',
    eventId: 'opera_jatra_2025',
    name: 'Opera / Jatra (2025)',
    eventName: 'Opera / Jatra (2025)',
    year: 2025,
    eventType: 'OPERA_JATRA',
    organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
    startDate: '2025-10-01T00:00:00.000Z',
    endDate: '2025-10-10T23:59:59.000Z',
    location: 'Opera Stage',
    description: 'Opera / Jatra Festival 2025 (DEV)',
    status: 'COMPLETED',
    createdBy: 'system',
  },
  {
    id: 'opera_jatra_2026',
    eventId: 'opera_jatra_2026',
    name: 'Opera / Jatra (2026)',
    eventName: 'Opera / Jatra (2026)',
    year: 2026,
    eventType: 'OPERA_JATRA',
    organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
    startDate: '2026-10-01T00:00:00.000Z',
    endDate: '2026-10-10T23:59:59.000Z',
    location: 'Opera Stage',
    description: 'Opera / Jatra Festival 2026 (DEV)',
    status: 'ACTIVE',
    createdBy: 'system',
  },
];

// 2. DEV Users
const devUsers = [
  {
    uid: 'user_dev_super_admin',
    name: 'DEV Super Admin',
    email: 'admin@durgapuja.org',
    mobile: '9876543210',
    roleId: 'super_admin',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
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
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'zkXTpQiFm9SOSRSOWT72nbwqOdY2', // admin.dev@durgapuja.org UID
    name: 'DEV Super Admin (Admin Dev)',
    email: 'admin.dev@durgapuja.org',
    mobile: '9876543210',
    roleId: 'super_admin',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
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
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 's2BbVQdAo7NkAap8AZD2Jz8NiNy1', // superadmin@durgapuja.org UID
    name: 'DEV Super Admin (Superadmin)',
    email: 'superadmin@durgapuja.org',
    mobile: '9876543210',
    roleId: 'super_admin',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
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
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'Rjd3MZmMZxXL8z43wMGGpogGWB03', // president@durgapuja.org UID
    name: 'DEV President',
    email: 'president@durgapuja.org',
    mobile: '9876543211',
    roleId: 'president',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
      {
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        year: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        roleId: 'president',
      },
      {
        eventId: 'opera_jatra_2025',
        eventType: 'OPERA_JATRA',
        year: 2025,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'president',
      },
      {
        eventId: 'opera_jatra_2026',
        eventType: 'OPERA_JATRA',
        year: 2026,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'president',
      },
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1', // treasurer@durgapuja.org UID
    name: 'DEV Treasurer',
    email: 'treasurer@durgapuja.org',
    mobile: '9876543212',
    roleId: 'treasurer',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
      {
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        year: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        roleId: 'treasurer',
      },
      {
        eventId: 'opera_jatra_2025',
        eventType: 'OPERA_JATRA',
        year: 2025,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'treasurer',
      },
      {
        eventId: 'opera_jatra_2026',
        eventType: 'OPERA_JATRA',
        year: 2026,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'treasurer',
      },
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2', // manager@durgapuja.org UID
    name: 'DEV Manager (Opera 2026)',
    email: 'manager@durgapuja.org',
    mobile: '9876543213',
    roleId: 'manager',
    status: 'ACTIVE',
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
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1', // collector@durgapuja.org UID
    name: 'DEV Collector (Opera 2026)',
    email: 'collector@durgapuja.org',
    mobile: '9876543214',
    roleId: 'collection_member',
    status: 'ACTIVE',
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
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: '4ZG9wRkhWqXv56BeAFRXhbakfXl1', // viewer.dev@durgapuja.org UID
    name: 'DEV Viewer (Bhasani 2026)',
    email: 'viewer.dev@durgapuja.org',
    mobile: '9876543215',
    roleId: 'viewer',
    status: 'ACTIVE',
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
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: '8Ed2LmVAPxVhgbZorc9p9HZzQlF2', // rashmiranjan@gmail.com UID
    name: 'Rashmi Ranjan',
    email: 'rashmiranjan@gmail.com',
    mobile: '9876543216',
    roleId: 'manager',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026', 'opera_jatra_2025', 'opera_jatra_2026'],
    eventAccess: [
      {
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        year: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        roleId: 'manager',
      },
      {
        eventId: 'opera_jatra_2025',
        eventType: 'OPERA_JATRA',
        year: 2025,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'manager',
      },
      {
        eventId: 'opera_jatra_2026',
        eventType: 'OPERA_JATRA',
        year: 2026,
        organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
        roleId: 'collection_member',
      },
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: 'qqx5INO03EUhADvoUatcffFSWm73', // filu@gmail.com UID
    name: 'Filu',
    email: 'filu@gmail.com',
    mobile: '9876543217',
    roleId: 'collection_member',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026'],
    eventAccess: [
      {
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        year: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        roleId: 'collection_member',
      },
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
  {
    uid: '2v3fBCN8rSXgutv60klPbCkDPKb2', // biren@gmail.com UID
    name: 'Biren',
    email: 'biren@gmail.com',
    mobile: '9876543218',
    roleId: 'collection_member',
    status: 'ACTIVE',
    assignedEventIds: ['bhasani_utsab_2026'],
    eventAccess: [
      {
        eventId: 'bhasani_utsab_2026',
        eventType: 'BHASANI_UTSAB',
        year: 2026,
        organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
        roleId: 'collection_member',
      },
    ],
    isOnline: false,
    createdBy: 'dev_init',
  },
];

// 3. Expense Categories
const devCategories = [
  { id: 'decoration', name: 'Decoration & Pandal', description: 'Pandal and entrance decoration', isActive: true, usageCount: 1 },
  { id: 'sound', name: 'Sound & Lighting', description: 'Audio systems, generators and lighting', isActive: true, usageCount: 1 },
  { id: 'food_prasad', name: 'Food & Prasad', description: 'Bhog, prasad and community feast', isActive: true, usageCount: 1 },
  { id: 'tent', name: 'Tent & Infrastructure', description: 'Tent, stage and barricading', isActive: true, usageCount: 1 },
  { id: 'puja_material', name: 'Puja Materials & Samagri', description: 'Idol materials, ghee and puja essentials', isActive: true, usageCount: 1 },
  { id: 'electricity', name: 'Electricity & Generator', description: 'Power supply and diesel', isActive: true, usageCount: 0 },
  { id: 'transport', name: 'Transport & Logistics', description: 'Vehicles, immersion transit and fuel', isActive: true, usageCount: 0 },
  { id: 'cleaning', name: 'Cleaning & Sanitation', description: 'Housekeeping and disposal', isActive: true, usageCount: 0 },
  { id: 'security', name: 'Security & Safety', description: 'Volunteers and security staff', isActive: true, usageCount: 0 },
  { id: 'advertisement', name: 'Advertisement & Banners', description: 'Flex banners and publicity', isActive: true, usageCount: 0 },
  { id: 'other', name: 'Other Miscellaneous', description: 'Uncategorized emergency expenses', isActive: true, usageCount: 0 },
];

// 4. Chanda Targets
const devChandaTargets = [
  {
    id: 'target_bhasani_rashmi',
    userId: '8Ed2LmVAPxVhgbZorc9p9HZzQlF2',
    personName: 'Rashmi Ranjan',
    mobileNumber: '9876543216',
    targetAmount: 10000,
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    status: 'PENDING',
    createdBy: 'zkXTpQiFm9SOSRSOWT72nbwqOdY2',
  },
  {
    id: 'target_bhasani_filu',
    userId: 'qqx5INO03EUhADvoUatcffFSWm73',
    personName: 'Filu',
    mobileNumber: '9876543217',
    targetAmount: 5000,
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    status: 'PARTIAL',
    createdBy: 'zkXTpQiFm9SOSRSOWT72nbwqOdY2',
  },
  {
    id: 'target_bhasani_biren',
    userId: '2v3fBCN8rSXgutv60klPbCkDPKb2',
    personName: 'Biren',
    mobileNumber: '9876543218',
    targetAmount: 3000,
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    status: 'PAID',
    createdBy: 'zkXTpQiFm9SOSRSOWT72nbwqOdY2',
  },
  {
    id: 'target_opera26_chandan',
    userId: 'user_chandan',
    personName: 'Chandan Pradhan',
    mobileNumber: '9876543219',
    targetAmount: 5000,
    eventId: 'opera_jatra_2026',
    eventType: 'OPERA_JATRA',
    eventYear: 2026,
    organizationName: 'MAA DURGA DEVI YOUTH ASSOCIATION',
    status: 'PAID',
    createdBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
  },
];

// 5. Collections
const devCollections = [
  {
    id: 'col_bhasani_main_sponsor',
    eventId: 'bhasani_utsab_2026',
    userId: null,
    donorName: 'Sri Jagannath Steel Works (Patron)',
    mobileNumber: '9876543200',
    amount: 50000,
    paymentMode: 'bank_transfer',
    transactionId: 'NEFT/20260901/112233',
    purpose: 'Grand Pandal & Bhasani Main Sponsorship',
    collectedBy: 'DEV President',
    date: '2026-09-01T09:00:00.000Z',
    remark: 'Corporate patron donation received via NEFT',
    status: 'APPROVED',
    createdBy: 'Rjd3MZmMZxXL8z43wMGGpogGWB03',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-01T10:00:00.000Z',
  },
  {
    id: 'col_bhasani_community',
    eventId: 'bhasani_utsab_2026',
    userId: null,
    donorName: 'Ward No. 5 Residents Welfare Association',
    mobileNumber: '9876543201',
    amount: 25000,
    paymentMode: 'cheque',
    transactionId: 'CHQ-998877',
    purpose: 'Community Chanda Collection',
    collectedBy: 'DEV Collection Member',
    date: '2026-09-01T09:30:00.000Z',
    remark: 'Cheque cleared into Samiti SBI account',
    status: 'APPROVED',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-01T10:30:00.000Z',
  },
  {
    id: 'col_bhasani_filu_1',
    eventId: 'bhasani_utsab_2026',
    userId: 'qqx5INO03EUhADvoUatcffFSWm73',
    donorName: 'Filu',
    mobileNumber: '9876543217',
    amount: 3000,
    paymentMode: 'cash',
    transactionId: null,
    purpose: 'Chanda Donation',
    collectedBy: 'DEV Collection Member',
    date: '2026-09-01T10:00:00.000Z',
    remark: 'First installment paid in cash',
    status: 'APPROVED',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    chandaTargetId: 'target_bhasani_filu',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-01T12:00:00.000Z',
  },
  {
    id: 'col_bhasani_biren_1',
    eventId: 'bhasani_utsab_2026',
    userId: '2v3fBCN8rSXgutv60klPbCkDPKb2',
    donorName: 'Biren',
    mobileNumber: '9876543218',
    amount: 3000,
    paymentMode: 'upi',
    transactionId: 'UPI/20260901/789123',
    purpose: 'Chanda Donation',
    collectedBy: 'DEV Collection Member',
    date: '2026-09-01T11:00:00.000Z',
    remark: 'Paid full target via GooglePay UPI',
    status: 'APPROVED',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    chandaTargetId: 'target_bhasani_biren',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-01T12:30:00.000Z',
  },
  {
    id: 'col_opera26_chandan_1',
    eventId: 'opera_jatra_2026',
    userId: 'user_chandan',
    donorName: 'Chandan Pradhan',
    mobileNumber: '9876543219',
    amount: 6000,
    paymentMode: 'bank_transfer',
    transactionId: 'NEFT/20260902/554433',
    purpose: 'Opera Patron Chanda',
    collectedBy: 'DEV Manager',
    date: '2026-09-02T14:00:00.000Z',
    remark: 'Direct NEFT transfer with 1000 excess donation',
    status: 'APPROVED',
    createdBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
    chandaTargetId: 'target_opera26_chandan',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-02T16:00:00.000Z',
  },
  {
    id: 'col_bhasani_public_pending',
    eventId: 'bhasani_utsab_2026',
    userId: null,
    donorName: 'Amitabh Sen (General Public)',
    mobileNumber: '9876543220',
    amount: 5000,
    paymentMode: 'cheque',
    transactionId: 'CHQ-445566',
    purpose: 'Public Pandal Sponsorship',
    collectedBy: 'DEV Collection Member',
    date: '2026-09-03T09:00:00.000Z',
    remark: 'Cheque handed over, pending bank clearing',
    status: 'PENDING',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
  },
  {
    id: 'col_bhasani_rejected_1',
    eventId: 'bhasani_utsab_2026',
    userId: null,
    donorName: 'Test Rejected Entry',
    mobileNumber: '9876543221',
    amount: 2000,
    paymentMode: 'cash',
    transactionId: null,
    purpose: 'Duplicate Entry',
    collectedBy: 'DEV Collection Member',
    date: '2026-09-03T10:00:00.000Z',
    remark: 'Duplicate cash entry entered by mistake',
    status: 'REJECTED',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    rejectionReason: 'Duplicate cash entry by collector',
  },
];

// 6. Expenses
const devExpenses = [
  {
    id: 'exp_bhasani_tent_1',
    eventId: 'bhasani_utsab_2026',
    categoryId: 'tent',
    description: 'Pandal structure advance payment',
    amount: 15000,
    paidTo: 'M/S Maa Samaleswari Tent Works',
    paymentMode: 'cash',
    date: '2026-09-02T11:00:00.000Z',
    remark: 'First installment of tent fabric & poles',
    status: 'APPROVED',
    addedBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-02T13:00:00.000Z',
  },
  {
    id: 'exp_bhasani_samagri_1',
    eventId: 'bhasani_utsab_2026',
    categoryId: 'puja_material',
    description: 'Ghee, Havan Samagri, Flowers & Sweets',
    amount: 4500,
    paidTo: 'Sri Durga Bhandar',
    paymentMode: 'upi',
    date: '2026-09-03T15:00:00.000Z',
    remark: 'Items received for Maha Ashtami Puja',
    status: 'APPROVED',
    addedBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
    approvedBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    approvedAt: '2026-09-03T17:00:00.000Z',
  },
  {
    id: 'exp_bhasani_light_pending',
    eventId: 'bhasani_utsab_2026',
    categoryId: 'electricity',
    description: 'Lighting & Generator Stage 1 quotation',
    amount: 8000,
    paidTo: 'Star Lightings Ltd',
    paymentMode: 'bank_transfer',
    date: '2026-09-04T09:00:00.000Z',
    remark: 'Quotation submitted for review',
    status: 'PENDING',
    addedBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
  },
  {
    id: 'exp_bhasani_rejected_1',
    eventId: 'bhasani_utsab_2026',
    categoryId: 'other',
    description: 'Unverified local conveyance claim',
    amount: 1000,
    paidTo: 'Local Driver',
    paymentMode: 'cash',
    date: '2026-09-04T10:00:00.000Z',
    remark: 'Claim without fuel slip',
    status: 'REJECTED',
    addedBy: 'HO9Yo5pK7MXNQWYyzOo2ivCWWkh2',
    rejectionReason: 'Voucher missing proper bill receipts',
  },
];

// 7. Collection Custody
const devCustody = [
  {
    id: 'custody_bhasani_handover_1',
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    amount: 2000,
    fromUserId: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    fromUserName: 'DEV Collection Member',
    toUserId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    toUserName: 'DEV Treasurer',
    handoverType: 'CASH_HANDOVER',
    status: 'RECEIVED',
    handedOverAt: '2026-09-02T12:00:00.000Z',
    receivedAt: '2026-09-02T13:00:00.000Z',
    notes: 'Partial cash collection handover from Pandal counter',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
  },
  {
    id: 'custody_bhasani_bank_dep_1',
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    amount: 1500,
    fromUserId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    fromUserName: 'DEV Treasurer',
    toUserId: 'BANK_SBI',
    toUserName: 'State Bank of India (Samiti A/C)',
    handoverType: 'BANK_DEPOSIT',
    status: 'DEPOSITED',
    handedOverAt: '2026-09-03T11:00:00.000Z',
    receivedAt: '2026-09-03T11:30:00.000Z',
    notes: 'Deposited into SBI Current Account',
    createdBy: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
  },
  {
    id: 'custody_bhasani_pending_handover',
    eventId: 'bhasani_utsab_2026',
    eventType: 'BHASANI_UTSAB',
    eventYear: 2026,
    organizationName: 'Maa Durga Debi Bhashani Ustav SamitI',
    amount: 500,
    fromUserId: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
    fromUserName: 'DEV Collection Member',
    toUserId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    toUserName: 'DEV Treasurer',
    handoverType: 'CASH_HANDOVER',
    status: 'PENDING',
    handedOverAt: '2026-09-04T10:00:00.000Z',
    notes: 'Handover requested by collector, pending treasurer receipt',
    createdBy: 'ycl4P6m79KOZ9Jsb4gNcWODbcLk1',
  },
];

// 8. Audit Logs
const devAuditLogs = [
  {
    id: 'audit_dev_login_1',
    eventId: 'global',
    userId: 'zkXTpQiFm9SOSRSOWT72nbwqOdY2',
    userName: 'DEV Super Admin',
    action: 'LOGIN',
    entityType: 'SESSION',
    entityId: 'sess_initial',
    timestamp: '2026-09-01T08:00:00.000Z',
    metadata: { email: 'admin.dev@durgapuja.org', platform: 'Chrome Web' },
  },
  {
    id: 'audit_dev_col_app_1',
    eventId: 'bhasani_utsab_2026',
    userId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    userName: 'DEV Treasurer',
    action: 'COLLECTION_APPROVED',
    entityType: 'COLLECTION',
    entityId: 'col_bhasani_filu_1',
    timestamp: '2026-09-01T12:00:00.000Z',
    metadata: { amount: 3000, donor: 'Filu' },
  },
  {
    id: 'audit_dev_exp_app_1',
    eventId: 'bhasani_utsab_2026',
    userId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    userName: 'DEV Treasurer',
    action: 'EXPENSE_APPROVED',
    entityType: 'EXPENSE',
    entityId: 'exp_bhasani_tent_1',
    timestamp: '2026-09-02T13:00:00.000Z',
    metadata: { amount: 15000, category: 'tent' },
  },
  {
    id: 'audit_dev_custody_1',
    eventId: 'bhasani_utsab_2026',
    userId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    userName: 'DEV Treasurer',
    action: 'CASH_RECEIVED',
    entityType: 'CUSTODY',
    entityId: 'custody_bhasani_handover_1',
    timestamp: '2026-09-02T13:00:00.000Z',
    metadata: { amount: 2000, from: 'DEV Collection Member' },
  },
  {
    id: 'audit_dev_bank_dep_1',
    eventId: 'bhasani_utsab_2026',
    userId: 'ZJAxc0qJQ8a8qNrakgpxQJbXl9v1',
    userName: 'DEV Treasurer',
    action: 'BANK_DEPOSIT',
    entityType: 'CUSTODY',
    entityId: 'custody_bhasani_bank_dep_1',
    timestamp: '2026-09-03T11:30:00.000Z',
    metadata: { amount: 1500, bank: 'SBI' },
  },
];

async function main() {
  console.log('====================================================');
  console.log(`🚀 WRITING ALL 8 COLLECTIONS TO FIRESTORE VIA REST`);
  console.log(`   Project: ${PROJECT_ID}`);
  console.log('====================================================\n');

  console.log('1. Seeding puja_events...');
  for (const e of devEvents) await writeDoc('puja_events', e.id, e);

  console.log('\n2. Seeding users...');
  for (const u of devUsers) await writeDoc('users', u.uid, u);

  console.log('\n3. Seeding expense_categories...');
  for (const c of devCategories) await writeDoc('expense_categories', c.id, c);

  console.log('\n4. Seeding chanda_targets...');
  for (const t of devChandaTargets) await writeDoc('chanda_targets', t.id, t);

  console.log('\n5. Seeding collections...');
  for (const col of devCollections) await writeDoc('collections', col.id, col);

  console.log('\n6. Seeding expenses...');
  for (const exp of devExpenses) await writeDoc('expenses', exp.id, exp);

  console.log('\n7. Seeding collection_custody...');
  for (const c of devCustody) await writeDoc('collection_custody', c.id, c);

  console.log('\n8. Seeding audit_logs...');
  for (const a of devAuditLogs) await writeDoc('audit_logs', a.id, a);

  console.log('\n====================================================');
  console.log('🎉 ALL 8 COLLECTIONS ARE NOW LIVE IN FIRESTORE DEV!');
  console.log('====================================================');
}

main().catch(console.error);
