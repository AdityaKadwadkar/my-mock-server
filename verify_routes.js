const fs = require('fs');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

const API_URL = 'http://localhost:3001/api';

async function uploadFile(filename, type) {
    try {
        const filePath = path.join(__dirname, filename);
        if (!fs.existsSync(filePath)) {
            console.error(`File not found: ${filename}`);
            return false;
        }

        const form = new FormData();
        form.append('file', fs.createReadStream(filePath));

        console.log(`Uploading ${filename} to /upload/${type}...`);
        const response = await axios.post(`${API_URL}/upload/${type}`, form, {
            headers: {
                ...form.getHeaders()
            }
        });

        console.log(`✅ Upload ${type} success:`, response.data);
        return true;
    } catch (error) {
        console.error(`❌ Upload ${type} failed:`, error.response ? error.response.data : error.message);
        return false;
    }
}

async function verifyGet(endpoint) {
    try {
        console.log(`Fetching ${endpoint}...`);
        const response = await axios.get(`${API_URL}/${endpoint}`);
        console.log(`✅ Get ${endpoint} success. Count:`, response.data.data.length);
        return true;
    } catch (error) {
        console.error(`❌ Get ${endpoint} failed:`, error.response ? error.response.data : error.message);
        return false;
    }
}

async function main() {
    // 1. Upload Courses
    if (!await uploadFile('courses.csv', 'courses')) return;

    // 2. Upload Students
    if (!await uploadFile('students.csv', 'students')) return;

    // 3. Upload Enrollments
    if (!await uploadFile('enrollments.csv', 'enrollments')) return;

    // 4. Upload Marks
    if (!await uploadFile('marks.csv', 'marks')) return;

    console.log('--- Verifying GET endpoints ---');

    // 5. Verify GET endpoints
    await verifyGet('courses');
    await verifyGet('students');
    await verifyGet('enrollments');
    await verifyGet('marks');
}

main();
