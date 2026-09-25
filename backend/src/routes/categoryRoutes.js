const express = require('express');
const router = express.Router();
const {
    getCategories,
    createCategory,
    updateCategory,
    toggleCategoryStatus,
    deleteCategory
} = require('../controllers/categoryController');

router.get('/', getCategories);
router.post('/', createCategory);
router.put('/:categoryId', updateCategory);
router.patch('/:categoryId/toggle-status', toggleCategoryStatus);
router.delete('/:categoryId', deleteCategory);

module.exports = router;
