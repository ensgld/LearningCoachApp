import FormData from 'form-data';
import fs from 'fs';
import fetch from 'node-fetch';
import path from 'path';

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

    console.log('\n2. Uploading Document...');
    const formData = new FormData();
    // Create a dummy file
    const startPath = process.cwd();
    const dummyFilePath = path.join(startPath, 'test_doc.txt');
    fs.writeFileSync(dummyFilePath, 'This is a test document content.');

    formData.append('file', fs.createReadStream(dummyFilePath));
    formData.append('title', 'Verification Document');

    const uploadRes = await fetch(`${BASE_URL}/documents`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`,
            ...formData.getHeaders()
        },
        body: formData
    });

    // Cleanup dummy file
    fs.unlinkSync(dummyFilePath);

    if (!uploadRes.ok) {
        console.error('Upload failed:', await uploadRes.text());
        process.exit(1);
    }

    const uploadData = await uploadRes.json();
    const docId = uploadData.document.id;
    console.log('Document uploaded:', docId);

    console.log('\n3. Listing Documents (Verify Persistence)...');
    const listRes = await fetch(`${BASE_URL}/documents`, {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${token}` }
    });

    const listData = await listRes.json();
    const foundDoc = listData.documents.find((d: any) => d.id === docId);

    if (foundDoc) {
        console.log('✅ Document found in database list:', foundDoc.title);
    } else {
        console.error('❌ Document NOT found in list!');
        process.exit(1);
    }

    console.log('\n4. Deleting Document...');
    const deleteRes = await fetch(`${BASE_URL}/documents/${docId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
    });

    if (!deleteRes.ok) {
        console.error('Delete failed:', await deleteRes.text());
        process.exit(1);
    }
    console.log('Delete request successful.');

    console.log('\n5. Listing Documents Again (Verify Deletion)...');
    const listRes2 = await fetch(`${BASE_URL}/documents`, {
        method: 'GET',
        headers: { 'Authorization': `Bearer ${token}` }
    });

    const listData2 = await listRes2.json();
    const deletedDoc = listData2.documents.find((d: any) => d.id === docId);

    if (!deletedDoc) {
        console.log('✅ Document successfully removed from visible list (Soft Delete verified).');
    } else {
        console.error('❌ Document STILL present in list!');
        process.exit(1);
    }
}

run().catch(console.error);
