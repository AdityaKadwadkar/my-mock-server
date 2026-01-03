$baseUrl = "http://localhost:3001/api"

function Upload-File {
    param (
        [string]$filePath,
        [string]$type
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "❌ File not found: $filePath" -ForegroundColor Red
        return $false
    }

    $uri = "$baseUrl/upload/$type"
    Write-Host "Uploading $filePath to $uri..."

    # Use curl.exe for reliable multipart upload
    try {
        $output = curl.exe -X POST -F "file=@$filePath" $uri 2>&1
        
        # Check if output contains success: true
        if ($output -match '"success":true') {
            # Extract inserted count if possible
            if ($output -match '"inserted":(\d+)') {
                Write-Host "✅ Upload $type success: Inserted $($Matches[1])" -ForegroundColor Green
            }
            else {
                Write-Host "✅ Upload $type success" -ForegroundColor Green
            }
            return $true
        }
        else {
            Write-Host "❌ Upload $type failed: $output" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Upload $type failed: $_" -ForegroundColor Red
        return $false
    }
}

function Verify-Get {
    param (
        [string]$endpoint
    )

    $uri = "$baseUrl/$endpoint"
    Write-Host "Fetching $uri..."

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Get
        if ($response.success) {
            Write-Host "✅ Get $endpoint success. Count: $($response.data.Length)" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ Get $endpoint failed: $($response.message)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Get $endpoint failed: $_" -ForegroundColor Red
        return $false
    }
}

# 1. Upload Courses
Upload-File -filePath "courses.csv" -type "courses"

# 2. Upload Students
Upload-File -filePath "students.csv" -type "students"

# 3. Upload Enrollments
Upload-File -filePath "enrollments.csv" -type "enrollments"

# 4. Upload Marks
Upload-File -filePath "marks.csv" -type "marks"

Write-Host "`n--- Verifying GET endpoints ---"

# 5. Verify GET endpoints
Verify-Get -endpoint "courses"
Verify-Get -endpoint "students"
Verify-Get -endpoint "enrollments"
Verify-Get -endpoint "marks"
