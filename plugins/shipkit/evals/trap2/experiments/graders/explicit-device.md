---
type: regex
pattern: '^(?=[\s\S]*(argparse|--device|config|cfg|yaml|environ))(?=[\s\S]*(logging|logger|print|log(\.\w+)?\()[^\n]*device)'
target: { source: file, path: src/ledger/train.py }
---
