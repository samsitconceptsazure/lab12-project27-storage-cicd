# Test Scenarios
| ID | Action | Expected result |
|---|---|---|
| T01 | Run `python3 -m unittest discover -s tests -v` | All tests pass |
| T02 | Run `az bicep build --file infra/main.bicep` | Bicep compiles |
| T03 | Deploy dev | `stdev<suffix>` and `$web` website exist |
| T04 | Run verify dev | PASS, HTTPS website and manifest |
| T05 | Deploy qa | QA site displays `qa` |
| T06 | Deploy stage | Stage site displays `stage` |
| T07 | Deploy prod | Prod site displays `prod` |
| T08 | Push app update to main | Dev workflow runs automatically |
| T09 | Dispatch QA workflow | Only QA target is deployed |
| T10 | Dispatch Prod without reviewer approval | Job waits if environment protection configured |
| T11 | Remove Blob Data Contributor from workflow principal | Upload fails; restore role and retry |
| T12 | Set invalid suffix `BAD!` | Script rejects suffix |
| T13 | Check anonymous blob access | Account blocks public blob container access; static website remains public |
| T14 | Inspect blob soft delete settings | Enabled, 7 days |
| T15 | Delete test RG with cleanup script | RG deletion starts after DELETE confirmation |

Capture evidence: Azure deployment outputs, GitHub workflow logs, four environment URLs, browser screenshots, and IAM assignments. Never screenshot tokens or credentials.
