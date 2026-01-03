const { Pool } = require('pg');
const fs = require('fs');

const db = new Pool({
    user: 'postgres',
    host: 'localhost',
    port: 5432,
    database: 'mock_contineo',
    password: 'root@123'
});

async function inspect() {
    try {
        let output = '';

        // Check marks constraints
        const marksConstraints = await db.query(`
        SELECT conname, pg_get_constraintdef(oid)
        FROM pg_constraint
        WHERE conrelid = 'marks'::regclass;
    `);
        output += 'Marks Constraints:\n' + JSON.stringify(marksConstraints.rows, null, 2) + '\n';

        // Check student_course constraints
        const scConstraints = await db.query(`
        SELECT conname, pg_get_constraintdef(oid)
        FROM pg_constraint
        WHERE conrelid = 'student_course'::regclass;
    `);
        output += 'Student_Course Constraints:\n' + JSON.stringify(scConstraints.rows, null, 2) + '\n';

        fs.writeFileSync('schema_output_utf8.json', output, 'utf8');
        console.log('Wrote schema to schema_output_utf8.json');

    } catch (err) {
        console.error(err);
    } finally {
        await db.end();
    }
}

inspect();
