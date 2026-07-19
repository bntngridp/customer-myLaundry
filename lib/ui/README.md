# UI Layer (Presentation)

Menerapkan pola MVVM (Model-View-ViewModel). Widget di dalam View tidak boleh mengandung logika bisnis langsung.

## Struktur
- `core/`: Widget bersama, tema, tipografi, utility global UI.
- `features/`: Fitur aplikasi yang dikelompokkan (misal: auth, home, order_history).
  - `views/`: Widget UI murni.
  - `view_models/`: Pengatur state UI yang mendengarkan repository/use case.
