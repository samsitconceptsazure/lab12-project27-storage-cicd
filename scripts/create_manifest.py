import json,sys,datetime
if len(sys.argv)!=3: raise SystemExit('usage: create_manifest.py ENV STORAGE')
print(json.dumps({'environment':sys.argv[1],'storageAccount':sys.argv[2],'deployedAtUtc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'project':'LAB12-P27'},indent=2))
