import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class TestProject(unittest.TestCase):
 def test_files(self):
  for f in ['infra/main.bicep','scripts/deploy.sh','app/app.py','docs/PORTAL-AND-CLI-GUIDE.md','diagrams/architecture.mmd']:
   self.assertTrue((ROOT/f).exists(),f)
 def test_bicep_services(self):
  text=(ROOT/'infra/main.bicep').read_text()
  for word in ['storageAccounts','blobServices','fileServices','queueServices','tableServices','Microsoft.Compute/disks','managementPolicies']:
   self.assertIn(word,text)
if __name__=='__main__':unittest.main()
