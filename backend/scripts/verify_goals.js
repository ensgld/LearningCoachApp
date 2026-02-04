// Native fetch is available in Node 18+

const BASE_URL = 'http://localhost:3000/api/v1';

async function run() {
  console.log('1. Logging in...');
  const loginRes = await fetch(`${BASE_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'demo@learningcoach.com',
      password: 'password123'
    })
  });

  if (!loginRes.ok) {
    console.error('Login failed:', await loginRes.text());
    process.exit(1);
  }

  const loginData = await loginRes.json();
  const token = loginData.accessToken;
  console.log('Login successful. Token obtained.');

  console.log('\n2. Creating Goal...');
  const createRes = await fetch(`${BASE_URL}/goals`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      title: 'Verification Goal',
      description: 'Created by verification script',
      tasks: [{ title: 'Verify Backend' }, { title: 'Celebrate' }]
    })
  });

  if (!createRes.ok) {
    console.error('Create Goal failed:', await createRes.text());
    process.exit(1);
  }

  const createData = await createRes.json();
  console.log('Goal created:', JSON.stringify(createData, null, 2));

  console.log('\n3. Listing Goals...');
  const listRes = await fetch(`${BASE_URL}/goals`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  if (!listRes.ok) {
    console.error('List Goals failed:', await listRes.text());
    process.exit(1);
  }

  const listData = await listRes.json();
  console.log('Goals List:', JSON.stringify(listData, null, 2));
}

run().catch(console.error);
