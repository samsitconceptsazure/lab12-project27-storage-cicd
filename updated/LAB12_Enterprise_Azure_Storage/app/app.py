import os
from flask import Flask, render_template_string, request, redirect, url_for, flash
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient
from azure.storage.queue import QueueClient
from azure.data.tables import TableServiceClient, UpdateMode
from azure.core.exceptions import ResourceNotFoundError

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY', 'local-training-only-change-me')
account = os.environ.get('STORAGE_ACCOUNT', '')
credential = DefaultAzureCredential(exclude_interactive_browser_credential=True)

def blob(): return BlobServiceClient(f'https://{account}.blob.core.windows.net', credential=credential).get_container_client('documents')
def queue(): return QueueClient(f'https://{account}.queue.core.windows.net', 'workitems', credential=credential)
def table(): return TableServiceClient(f'https://{account}.table.core.windows.net', credential=credential).get_table_client('LabInventory')
HTML = """<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>SamsITConcepts Storage Lab</title><style>body{font-family:system-ui;background:#edf3fa;color:#122b49;margin:0}header{background:#092544;color:white;padding:28px 6%}main{max-width:1100px;margin:28px auto;padding:0 20px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:18px}.card{background:white;border-radius:12px;padding:22px;box-shadow:0 3px 18px #17395b18}button{background:#087bdc;color:white;border:0;border-radius:6px;padding:10px;cursor:pointer}input{padding:9px;max-width:90%}li{margin:8px 0}.msg{background:#fff1cb;padding:10px;margin-bottom:12px}small{color:#63788b}</style></head><body><header><h1>SamsITConcepts | Enterprise Azure Storage</h1><p>LAB 12 • Blob • Queue • Table • Azure Files • Managed Disks</p></header><main><p>Account: <b>{{account}}</b> | Local teaching portal • Never expose this demo to the public internet</p>{% for m in get_flashed_messages() %}<div class="msg">{{m}}</div>{% endfor %}<div class="grid"><section class="card"><h2>Blob Documents</h2><form action="/upload" method="post" enctype="multipart/form-data"><input type="file" name="file" required><button>Upload</button></form><ul>{% for b in blobs %}<li>{{b.name}} <small>{{b.size}} bytes</small></li>{% endfor %}</ul></section><section class="card"><h2>Queue Work Items</h2><form action="/enqueue" method="post"><input name="message" maxlength="256" placeholder="New work item" required><button>Enqueue</button></form><form action="/process" method="post"><button>Process one message</button></form><small>Approximate pending: {{count}}</small></section><section class="card"><h2>Table Inventory</h2><form action="/entity" method="post"><input name="item" maxlength="60" placeholder="Item ID" required><input name="description" maxlength="120" placeholder="Description" required><button>Save entity</button></form><ul>{% for e in entities %}<li>{{e.RowKey}} — {{e.description}}</li>{% endfor %}</ul></section></div><p><small>Azure Files, SAS, lifecycle, redundancy, disks and private networking are taught in the CLI/Portal manual.</small></p></main></body></html>"""
@app.get('/health')
def health(): return {'status':'ok','storage_account_configured':bool(account)}
@app.get('/')
def home():
 if not account: return 'Set STORAGE_ACCOUNT environment variable', 500
 try:
  blobs=list(blob().list_blobs(results_per_page=20))[:20]
  entities=list(table().list_entities(results_per_page=20))[:20]
  props=queue().get_queue_properties()
  return render_template_string(HTML,blobs=blobs,entities=entities,count=props.approximate_message_count,account=account)
 except Exception as e: return f'Storage connection failed: {type(e).__name__}. Check RBAC, network and configuration.',503
@app.post('/upload')
def upload():
 f=request.files.get('file')
 if not f or not f.filename: return 'File required',400
 if f.content_length and f.content_length>2*1024*1024: return 'File too large',413
 from werkzeug.utils import secure_filename
 name=secure_filename(f.filename)
 if not name: return 'Invalid filename',400
 data=f.read(2*1024*1024+1)
 if len(data)>2*1024*1024: return 'File too large',413
 blob().upload_blob(name,data,overwrite=True)
 flash('Uploaded '+name);return redirect(url_for('home'))
@app.post('/enqueue')
def enqueue():
 message=request.form.get('message','').strip()[:256]
 if not message:return 'Message required',400
 queue().send_message(message);flash('Queued work item');return redirect(url_for('home'))
@app.post('/process')
def process():
 msgs=queue().receive_messages(messages_per_page=1,visibility_timeout=30)
 item=next(iter(msgs),None)
 if item:queue().delete_message(item.id,item.pop_receipt);flash('Processed one work item')
 else:flash('Queue is empty')
 return redirect(url_for('home'))
@app.post('/entity')
def entity():
 key=request.form.get('item','').strip()[:60];desc=request.form.get('description','').strip()[:120]
 if not key or not desc:return 'Missing fields',400
 table().upsert_entity({'PartitionKey':'lab','RowKey':key,'description':desc},mode=UpdateMode.REPLACE)
 flash('Inventory entity saved');return redirect(url_for('home'))
if __name__=='__main__':app.run(host='127.0.0.1',port=8000,debug=False)
