const express = require('express');
const router = express.Router();
const MarksCardController = require('../controllers/marksCardController');

router.get('/markscard', MarksCardController.getMarksCard);
router.get('/markscard/:marksCardId', MarksCardController.getMarksCardById);
router.get('/markscard/student/:studentId', MarksCardController.getStudentMarkscards);
router.post('/markscard/generate-batch', MarksCardController.generateBatchMarkscards);

module.exports = router;