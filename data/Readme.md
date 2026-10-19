# Salesforce Migration - 4 September 2026
## 📌 Overview
Central repository for the Salesforce migration initiative. This documentation tracks database development, Python automation scripts, and human-readable operational guides for future reference.

## 🔗 Linked Documents
| Document | Path |
|----------|------|
| Migration Runbook & Task Breakdown | [b.md](file:///E:/Development/20260316%20Salesforce%20Migration/b.md) |

## 📁 Project Documents
| Directory/File | Purpose |
|----------------|---------|
| `E:\Development\20260316 Salesforce Migration` | Development root folder |
| `\Post Day1 Data Migration` | SSMS database project for MSSQL components for SF Migration database - **SalesforceMigration** |
| `\UnstructuredDataMigration` | Python scripts for migrating **unstructured documents** in Salesforce|
| `20260316 Salesforce Migration.sln` | - SSMS database project for MSSQL components for SF Migration database - **SalesforceMigration** |
| `Development Artefacts.md` | This document as the master document and 
| `Readme.md` | This document as the master document and index of other markdown files
| `Running automatically in UAT.md` | This document as the master document and 
| `Running manually in UAT.md` | This document as the master document and 

## 📁 Project Executables
| Directory/File | Purpose |
|----------------|---------|
| `E:\LocalExec` | Execution root folder |
| `\PROD` | PROD execution folder. This folder also holds the python scripts and cmd files for automation |
| `\PROD\PROD\DataLoader` | PROD DataLoader configuration and executables targeting Salesforce orgs in PRODUCTION|
| `\UAT` | Development execution folder. This folder also holds the python scripts and cmd files for automation for development and testing mode. |
| `\UAT\RHUAT\DataLoader` | Development DataLoader configuration and executables targeting Salesforce development / testing sandboxes |

## 💡 Usage Notes
- Links are configured for local Windows paths. Open in VS Code, Typora, or any markdown viewer that supports `file://` URLs.
- If your markdown renderer doesn't auto-resolve spaces, replace `%20` with a literal space or use forward slashes: `E:/Development/20260316 Salesforce Migration/b.md`
- Update relative paths if the directory structure changes.
