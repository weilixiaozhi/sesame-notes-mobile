# sesame_cloud_backup

A modular cloud backup protocol for Flutter with pluggable backend providers.

## Features

- 🔌 **Pluggable Architecture** - Backend providers (Supabase, WebDAV, S3) register themselves via `CloudProviderRegistry`; the core package never imports an adapter.
- 🔐 **Authentication** - Built-in authentication service abstraction.
- 📦 **Storage** - Unified storage interface for upload/download/list/delete.
- 💾 **Configuration** - `CloudServiceStore` persists the active backend config; credentials go through a pluggable `CloudCredentialStorage` (secure storage injectable).

## Installation

Add the core package to your `pubspec.yaml`:

```yaml
dependencies:
  sesame_cloud_backup:
    path: ../sesame_cloud_backup
```

Then add the backend provider(s) you want to use:

```yaml
dependencies:
  sesame_cloud_backup_supabase:
    path: ../sesame_cloud_backup_supabase
  sesame_cloud_backup_webdav:
    path: ../sesame_cloud_backup_webdav
  sesame_cloud_backup_s3:
    path: ../sesame_cloud_backup_s3
```

## Quick Start

### 1. Register backends in the Composition Root

Each adapter exposes a `register*Backend()` top-level function. Call it once at app startup before any `createCloudServices` usage:

```dart
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';

void main() {
  registerSupabaseBackend();
  registerWebDavBackend();
  registerS3Backend();
}
```

### 2. Create the active backend services

```dart
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

final cfg = await CloudServiceStore().loadActive();
if (cfg.isLocal) return; // not configured

final services = await createCloudServices(cfg);
final provider = services.provider;
if (provider == null) return;

final storage = provider.storage;
await storage.upload(path: 'backups/latest.snbak', data: base64EncodedBytes);
final files = await storage.list(path: 'backups/');
await storage.delete(path: files.first.path);
await provider.dispose();
```

## Available Cloud Providers

| Provider | Package | Authentication | Storage |
|----------|---------|----------------|---------|
| Supabase | `sesame_cloud_backup_supabase` | Account/Password | Supabase Storage API |
| WebDAV | `sesame_cloud_backup_webdav` | Basic Auth | WebDAV |
| AWS S3 | `sesame_cloud_backup_s3` | Signature V4 (access/secret) | S3 API (R2/MinIO compatible) |

## Security Notes

- **Login passwords are never persisted.** Supabase passwords are treated as one-time input: `CloudServiceStore` strips them before writing to storage, so they never land in `SharedPreferences` (plaintext XML on Android).
- **WebDAV / S3 credentials use a pluggable credential backend.** These credentials are required for sync and are stored through `CloudCredentialStorage`. The default `SharedPreferencesCredentialStorage` keeps the historical plaintext behavior for compatibility; for production, inject a secure implementation (e.g. based on `flutter_secure_storage`) via `CloudServiceStore(credentialStorage: ...)`.
- **All cloud config writes go through `CloudServiceStore`.** Business code must not call `SharedPreferences.setString` on cloud config keys directly. Imports use `saveImported(...)`, which always retains local credentials so external files cannot overwrite secrets.

## Architecture

```
        Business Layer (your app)
        │  Composition Root calls register*Backend() once
        ▼
sesame_cloud_backup (Core)
        │  CloudProvider / CloudAuthService / CloudStorageService
        │  CloudProviderRegistry / createCloudServices
        ▼
┌───────────┐ ┌─────────┐ ┌────────┐
│ Supabase  │ │ WebDAV  │ │   S3   │  (adapter packages, register into core)
└───────────┘ └─────────┘ └────────┘
```

## API Reference

### Core Interfaces

- `CloudProvider` - Backend provider abstraction (auth + storage + lifecycle)
- `CloudAuthService` - Authentication abstraction
- `CloudStorageService` - Storage abstraction (upload/download/list/delete)
- `CloudFile` - Remote file metadata

### Configuration

- `CloudBackend` - Backend descriptor submitted by an adapter (id / fields /
  validation / legacy migration)
- `CloudConfigField` - One config field declared by an adapter; `secret` fields
  are stored in the credential store instead of SharedPreferences
- `CloudServiceConfig` - Active backend configuration (backend id + opaque
  adapter-owned `settings`)
- `CloudServiceStore` - Persistent config store
- `CloudCredentialStorage` - Pluggable credential storage
- `CloudProviderRegistry` - Backend builder registry (adapter self-registration)
- `createCloudServices` - Factory that dispatches to the registered builder

### Exceptions

- `CloudAuthException` - Authentication failed
- `CloudConfigurationException` - Invalid configuration
- `CloudStorageException` - Storage operation failed
- `CloudSyncException` - Base exception class (backward-compatible alias)

## License

MIT License - see [LICENSE](../LICENSE) file for details.
