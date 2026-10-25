import unittest
from import_nutrition import convert


class NutritionImportTest(unittest.TestCase):
    def test_valid_per_100g_only(self):
        rows = [
            {'식품명': '비빔밥', '식품코드': 'D1', '영양성분함량기준량': '100g',
             '에너지(kcal)': '150', '단백질(g)': '4', '지방(g)': '3', '탄수화물(g)': '22'},
            {'식품명': '미역국', '식품코드': 'D2', '영양성분함량기준량': '100ml',
             '에너지(kcal)': '25', '단백질(g)': '2', '지방(g)': '1', '탄수화물(g)': '1'},
            {'식품명': '오류', '식품코드': 'D3', '영양성분함량기준량': '100g',
             '에너지(kcal)': '', '단백질(g)': '2', '지방(g)': '1', '탄수화물(g)': '1'},
        ]
        result = convert(rows)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]['source_id'], 'D1')
        self.assertEqual(result[0]['kcal'], 150.0)


if __name__ == '__main__':
    unittest.main()
