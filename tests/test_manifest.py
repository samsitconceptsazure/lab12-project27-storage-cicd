import unittest,subprocess,json
class ManifestTests(unittest.TestCase):
 def test_manifest(self):
  result=subprocess.check_output(['python3','scripts/create_manifest.py','dev','stdevabc123'])
  data=json.loads(result)
  self.assertEqual(data['environment'],'dev')
  self.assertEqual(data['project'],'LAB12-P27')
 def test_html(self):
  self.assertIn('deployment.json',open('app/index.html').read())
if __name__=='__main__': unittest.main()
