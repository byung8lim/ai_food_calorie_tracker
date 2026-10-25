"""Import official Korean nutrition CSV/XLSX into a traceable offline JSON catalog.

Only rows expressed per 100g are accepted: per 100ml entries must never be
silently treated as weight-based data. Never fabricate missing values.
Usage: python tools/import_nutrition.py official.csv [output.json]
"""
import csv
import json
import pathlib
import sys


def parse_number(value):
    try:
        return float(str(value).replace(',', '').strip())
    except (ValueError, TypeError):
        return None


def convert(rows):
    result = []
    seen = set()
    for row in rows:
        name = str(row.get('식품명') or '').strip()
        code = str(row.get('식품코드') or '').strip()
        unit = str(row.get('영양성분함량기준량') or '').replace(' ', '').lower()
        if not name or not code or unit != '100g' or code in seen:
            continue
        values = [parse_number(row.get(c)) for c in ('에너지(kcal)', '단백질(g)', '지방(g)', '탄수화물(g)')]
        if values[0] is None or values[0] < 0:
            continue
        if any(x is not None and x < 0 for x in values[1:]):
            continue
        seen.add(code)
        result.append(dict(name=name, kcal=values[0], protein=values[1],
                           fat=values[2], carbs=values[3],
                           source=str(row.get('출처명') or '식품의약품안전처'),
                           source_id=code, unit='100g'))
    return result


def main():
    if len(sys.argv) < 2:
        raise SystemExit('Usage: python tools/import_nutrition.py SOURCE.csv [OUTPUT.json]')
    path = pathlib.Path(sys.argv[1])
    if path.suffix.lower() in {'.xls', '.xlsx'}:
        import pandas as pd
        rows = pd.read_excel(path).fillna('').to_dict('records')
    else:
        with path.open(encoding='utf-8-sig', newline='') as stream:
            rows = list(csv.DictReader(stream))
    entries = convert(rows)
    if not entries:
        raise SystemExit('No validated per-100g rows found; original file untouched')
    target = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else pathlib.Path('assets/nutrition/seed.json')
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'Imported {len(entries)} validated 100g rows: {target}')


if __name__ == '__main__':
    main()
