class GPACalculator {
  static gradeToGPA(grade) {
    const mapping = { 'O': 10.00, 'A': 9.00, 'B': 8.00, 'C': 7.00, 'P': 6.00, 'F': 0.00 };
    return mapping[grade] || 0.00;
  }

  static marksToGrade(totalMarks, maxMarks = 100) {
    const percentage = (totalMarks / maxMarks) * 100;
    if (percentage >= 90) return 'O';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'P';
    return 'F';
  }

  static calculateSGPA(courseList) {
    let totalCredits = 0;
    let weightedSum = 0;
    courseList.forEach(course => {
      const credits = course.credits || 0;
      const gpa = this.gradeToGPA(course.grade);
      totalCredits += credits;
      weightedSum += gpa * credits;
    });
    return totalCredits > 0 ? (weightedSum / totalCredits).toFixed(2) : 0.00;
  }
}

module.exports = GPACalculator;