# ============================================
# PowerShell Setup - Mock-Contineo Markscard
# Grade System: S, A, B, C, D, F
# ============================================

Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Mock-Contineo Database Setup        ║" -ForegroundColor Cyan
Write-Host "║  Grade System: S, A, B, C, D, F      ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============ STEP 1: CREATE MIGRATION FILE ============
Write-Host "Step 1️⃣  Creating migration file..." -ForegroundColor Yellow

$migration = @'
-- ============================================
-- Migration: Add Markscard Support Fields
-- Grade System: S(10), A(9), B(8), C(7), D(6), F(0)
-- ============================================

-- Add year & semester to students
ALTER TABLE students ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE students ADD COLUMN IF NOT EXISTS semester INTEGER;
ALTER TABLE students ADD COLUMN IF NOT EXISTS password_dob VARCHAR(20);

-- Populate password_dob from date_of_birth
UPDATE students SET password_dob = CAST(date_of_birth AS VARCHAR) WHERE password_dob IS NULL AND date_of_birth IS NOT NULL;

-- Add year, semester, course_code to courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS semester INTEGER;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS course_code VARCHAR(50) UNIQUE;

-- Add gpa to marks
ALTER TABLE marks ADD COLUMN IF NOT EXISTS gpa DECIMAL(3,2) DEFAULT 0.00;

-- Populate GPA values from grades (S, A, B, C, D, F)
UPDATE marks SET gpa = CASE 
  WHEN grade = 'S' THEN 10.00
  WHEN grade = 'A' THEN 9.00
  WHEN grade = 'B' THEN 8.00
  WHEN grade = 'C' THEN 7.00
  WHEN grade = 'D' THEN 6.00
  WHEN grade = 'F' THEN 0.00
  ELSE 0.00
END WHERE gpa IS NULL OR gpa = 0.00;

-- Create markscard storage tables
CREATE TABLE IF NOT EXISTS markscard (
  id SERIAL PRIMARY KEY,
  markscard_id VARCHAR(100) UNIQUE NOT NULL,
  student_id VARCHAR(50) NOT NULL,
  department VARCHAR(100) NOT NULL,
  semester INTEGER NOT NULL,
  year INTEGER NOT NULL,
  total_credits INTEGER,
  sgpa DECIMAL(5,2),
  generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  credential_data JSONB,
  FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_markscard_student ON markscard(student_id);
CREATE INDEX IF NOT EXISTS idx_markscard_semester ON markscard(semester, year);

CREATE TABLE IF NOT EXISTS credential_history (
  id SERIAL PRIMARY KEY,
  markscard_id VARCHAR(100),
  student_id VARCHAR(50),
  action VARCHAR(50),
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);
'@

$utf8NoBOM = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("migrations/01-add-markscard-schema.sql", $migration, $utf8NoBOM)
Write-Host "✅ Migration file created" -ForegroundColor Green

# ============ STEP 2: RUN MIGRATION ============
Write-Host ""
Write-Host "Step 2️⃣  Running database migration..." -ForegroundColor Yellow

$pgPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

if (Test-Path $pgPath) {
    & $pgPath -U postgres -d mock_contineo -f migrations/01-add-markscard-schema.sql
    Write-Host "✅ Migration completed" -ForegroundColor Green
} else {
    Write-Host "❌ PostgreSQL not found at: $pgPath" -ForegroundColor Red
    Write-Host "Please run migration manually:" -ForegroundColor Yellow
    Write-Host "& `"C:\Program Files\PostgreSQL\18\bin\psql.exe`" -U postgres -d mock_contineo -f migrations/01-add-markscard-schema.sql" -ForegroundColor White
}

# ============ STEP 3: CREATE CSV FILES ============
Write-Host ""
Write-Host "Step 3️⃣  Creating CSV files..." -ForegroundColor Yellow

# Students CSV
$studentsCSV = @'
student_id,first_name,last_name,email,phone,date_of_birth,department,batch_year,year,semester,status
STU001,Amit,Singh,amit.singh@university.edu,9876543210,2002-05-15,Computer Science,2020,1,1,active
STU002,Priya,Sharma,priya.sharma@university.edu,9876543211,2002-08-20,Computer Science,2020,1,2,active
STU003,Rajesh,Kumar,rajesh.kumar@university.edu,9876543212,2002-12-10,Electronics,2020,1,1,active
STU004,Neha,Patel,neha.patel@university.edu,9876543213,2003-01-25,Mechanical,2020,1,1,active
STU005,Arjun,Verma,arjun.verma@university.edu,9876543214,2002-03-30,Computer Science,2020,1,1,active
STU006,Deepika,Desai,deepika.desai@university.edu,9876543215,2002-07-12,Electronics,2020,1,2,active
STU007,Vikram,Singh,vikram.singh@university.edu,9876543216,2002-11-05,Mechanical,2020,1,2,active
STU008,Ananya,Gupta,ananya.gupta@university.edu,9876543217,2003-02-18,Civil,2020,1,1,active
STU009,Kabir,Khan,kabir.khan@university.edu,9876543218,2001-09-22,Computer Science,2020,2,1,active
STU010,Sneha,Reddy,sneha.reddy@university.edu,9876543219,2001-06-14,Electronics,2020,2,2,active
'@

[System.IO.File]::WriteAllText("students.csv", $studentsCSV, $utf8NoBOM)
Write-Host "✅ students.csv created (10 students)" -ForegroundColor Green

# Courses CSV
$coursesCSV = @'
course_code,course_name,credits,department,year,semester,max_marks
CS101,Data Structures,4,Computer Science,1,1,100
CS102,Web Development,4,Computer Science,1,2,100
CS201,Database Management,4,Computer Science,2,3,100
CS202,Operating Systems,4,Computer Science,2,4,100
EC101,Digital Electronics,4,Electronics,1,1,100
EC102,Microprocessors,4,Electronics,1,2,100
EC201,Signal Processing,4,Electronics,2,3,100
ME101,Thermodynamics,4,Mechanical,1,1,100
ME102,Fluid Mechanics,4,Mechanical,1,2,100
CE101,Structural Analysis,4,Civil,1,1,100
CE102,Soil Mechanics,4,Civil,1,2,100
'@

[System.IO.File]::WriteAllText("courses.csv", $coursesCSV, $utf8NoBOM)
Write-Host "✅ courses.csv created (11 courses)" -ForegroundColor Green

# Enrollments CSV
$enrollmentsCSV = @'
student_id,course_code,enrollment_date,enrollment_status
STU001,CS101,2023-01-15,active
STU001,CS102,2023-06-15,active
STU001,CS201,2024-01-15,active
STU002,CS101,2023-01-15,active
STU002,CS102,2023-06-15,active
STU002,CS201,2024-01-15,active
STU003,EC101,2023-01-15,active
STU003,EC102,2023-06-15,active
STU004,ME101,2023-01-15,active
STU004,ME102,2023-06-15,active
STU005,CS101,2023-01-15,active
STU005,CS102,2023-06-15,active
STU006,EC101,2023-01-15,active
STU006,EC102,2023-06-15,active
STU007,ME101,2023-01-15,active
STU008,CE101,2023-01-15,active
STU008,CE102,2023-06-15,active
STU009,CS201,2024-01-15,active
STU010,EC201,2024-01-15,active
'@

[System.IO.File]::WriteAllText("enrollments.csv", $enrollmentsCSV, $utf8NoBOM)
Write-Host "✅ enrollments.csv created (19 enrollments)" -ForegroundColor Green

# Marks CSV with S grades
$marksCSV = @'
student_id,course_code,internal_marks,external_marks,total_marks,grade,grading_date
STU001,CS101,35,62,97,A,2023-04-30
STU001,CS102,32,58,90,A,2023-09-30
STU001,CS201,38,65,103,S,2024-04-30
STU002,CS101,30,55,85,B,2023-04-30
STU002,CS102,28,52,80,B,2023-09-30
STU002,CS201,35,60,95,A,2024-04-30
STU003,EC101,32,60,92,A,2023-04-30
STU003,EC102,30,58,88,B,2023-09-30
STU004,ME101,28,52,80,B,2023-04-30
STU004,ME102,32,58,90,A,2023-09-30
STU005,CS101,36,64,100,S,2023-04-30
STU005,CS102,34,61,95,A,2023-09-30
STU006,EC101,33,61,94,A,2023-04-30
STU006,EC102,31,57,88,B,2023-09-30
STU007,ME101,29,54,83,B,2023-04-30
STU008,CE101,30,56,86,B,2023-04-30
STU008,CE102,32,59,91,A,2023-09-30
STU009,CS201,36,63,99,A,2024-04-30
STU010,EC201,31,59,90,A,2024-04-30
'@

[System.IO.File]::WriteAllText("marks.csv", $marksCSV, $utf8NoBOM)
Write-Host "✅ marks.csv created (19 marks with S grades)" -ForegroundColor Green

# ============ STEP 4: DISPLAY SUMMARY ============
Write-Host ""
Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ SETUP COMPLETE                    ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Grade Mapping:" -ForegroundColor Cyan
Write-Host "   S = 10.00 (Excellent)" -ForegroundColor Gray
Write-Host "   A = 9.00  (Very Good)" -ForegroundColor Gray
Write-Host "   B = 8.00  (Good)" -ForegroundColor Gray
Write-Host "   C = 7.00  (Satisfactory)" -ForegroundColor Gray
Write-Host "   D = 6.00  (Pass)" -ForegroundColor Gray
Write-Host "   F = 0.00  (Fail)" -ForegroundColor Gray
Write-Host ""

Write-Host "📁 Files Created:" -ForegroundColor Cyan
Write-Host "   ✅ migrations/01-add-markscard-schema.sql" -ForegroundColor Green
Write-Host "   ✅ students.csv (10 students)" -ForegroundColor Green
Write-Host "   ✅ courses.csv (11 courses)" -ForegroundColor Green
Write-Host "   ✅ enrollments.csv (19 enrollments)" -ForegroundColor Green
Write-Host "   ✅ marks.csv (19 marks)" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Go to Admin Dashboard" -ForegroundColor White
Write-Host "   http://localhost:3001" -ForegroundColor Gray
Write-Host ""
Write-Host "2️⃣  Upload CSV Files (in this order):" -ForegroundColor White
Write-Host "   • students.csv" -ForegroundColor Gray
Write-Host "   • courses.csv" -ForegroundColor Gray
Write-Host "   • enrollments.csv" -ForegroundColor Gray
Write-Host "   • marks.csv" -ForegroundColor Gray
Write-Host ""
Write-Host "3️⃣  Verify Data Loaded" -ForegroundColor White
Write-Host "   & `"C:\Program Files\PostgreSQL\18\bin\psql.exe`" -U postgres -d mock_contineo -c `"SELECT COUNT(*) FROM students; SELECT COUNT(*) FROM marks;`"" -ForegroundColor Gray
Write-Host ""
Write-Host "4️⃣  Test Markscard API" -ForegroundColor White
Write-Host "   curl `"http://localhost:3001/api/markscard?studentId=STU001&semester=1&year=2024`"" -ForegroundColor Gray
Write-Host ""

Write-Host "✨ All done! System is ready! ✨" -ForegroundColor Green
Write-Host ""
