# AGenomics Claim Checker

Responsive Flutter Claim Checker app built with GetX and Repository Pattern.

## Stack

- Flutter + Material 3
- GetX (state, routing, DI)
- Dio (API client, multipart-ready)
- GetStorage (auth token / user)
- Mulish font family
- file_picker (PDF / VCF)

## Run

```bash
flutter pub get

# Desktop (no browser CORS issues)
flutter run -d windows

# Web — requires CORS enabled on the API host
flutter run -d chrome
```

## Demo login

- Username: `admin@dch.com`
- Password: `hadmin123`

API base: `https://32dd-115-246-26-2.ngrok-free.app`

## Modules

1. Login → Patient List
2. Patient Registration (Save / Continue)
3. Upload Documents (genomics PDF/VCF + report PDFs)

## Structure

```
lib/
  app/          # routes, bindings
  core/         # theme, network, storage, widgets
  data/         # models, repositories (dummy → Laravel)
  modules/      # login, patient_list, registration, upload, shell
```
