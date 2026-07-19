# Data Layer

Menangani komunikasi data eksternal, serialisasi API, database lokal, dan implementasi repository sebagai Single Source of Truth.

## Struktur
- `models/`: Representasi data mentah dari API (misal: JSON parsing).
- `repositories/`: Mengonsumsi service dan memetakan model API ke domain model.
- `services/`: API client (HTTP / WebSockets) dan local storage wrappers.
