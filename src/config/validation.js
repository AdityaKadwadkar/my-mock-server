module.exports = {
  validateStudent: (data) => {
    const required = ['student_id', 'first_name', 'last_name'];
    return required.every(field => data[field]);
  },
  validateCourse: (data) => {
    const required = ['course_code', 'course_name'];
    return required.every(field => data[field]);
  }
};
