# 🔌 Contratos de API para Fleet Tech Mobile

Especificación técnica de endpoints, modelos JSON de petición y respuesta, y protocolo de sincronización offline con **`fleet-tech-api`**.

---

## 1. Autenticación (`POST /api/v1/auth/login`)

```json
// Request Body
{
  "email": "tecnico@fleettech.com",
  "password": "Password123#",
  "device_name": "Samsung-Tab-A9"
}

// Response (200 OK)
{
  "success": true,
  "message": "Autenticación exitosa",
  "data": {
    "user": {
      "id": 14,
      "name": "Carlos Méndez",
      "role": "technician"
    },
    "token": "14|vN8K3L0xZ..."
  }
}
```

---

## 2. Obtener Plantilla Dinámica (`GET /api/v1/checklist-templates/{id}`)

```json
// Response (200 OK)
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Inspección Pre-Uso y Relevo de Patio",
    "version": 3,
    "sections": [
      {
        "id": 10,
        "name": "Cabina y Seguridad Operativa",
        "order_index": 1,
        "items": [
          {
            "id": 101,
            "label": "Cinturones de seguridad funcionales",
            "input_type": "boolean",
            "is_required": true
          },
          {
            "id": 102,
            "label": "Estado y vigencia del extintor de 6kg",
            "input_type": "select",
            "options": ["Vigente / Operativo", "Vencido / Descargado", "No Posee"],
            "is_required": true
          }
        ]
      }
    ]
  }
}
```

---

## 3. Envío de Inspección y Relevo (`POST /api/v1/inspections`)

- **Headers:** `Authorization: Bearer <token>`, `Idempotency-Key: <UUID>`

```json
// Request Body
{
  "vehicle_id": 105,
  "template_id": 1,
  "inspection_type": "pre_use",
  "shift_type": "morning",
  "odometer": 128450.2,
  "fuel_level": "6/8",
  "bay_number": "BAHIA-08",
  "latitude": -12.046374,
  "longitude": -77.042793,
  "outgoing_operator_signature": "data:image/png;base64,iVBORw0KGgo...",
  "incoming_operator_signature": "data:image/png;base64,iVBORw0KGgo...",
  "answers": [
    {
      "template_item_id": 101,
      "status": "pass",
      "value": "Conforme"
    },
    {
      "template_item_id": 102,
      "status": "fail",
      "value": "Vencido / Descargado",
      "defect_severity": "critical",
      "comments": "Manómetro en rojo",
      "photos": [
        "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/..."
      ]
    }
  ]
}

// Response (201 Created)
{
  "success": true,
  "message": "Inspección registrada con éxito. Unidad bloqueada por defecto crítico.",
  "data": {
    "inspection_id": 492,
    "vehicle_status": "in_maintenance",
    "verification_hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  }
}
```

---

## 4. Protocolo de Reintentos Offline

Si no hay red o el servidor responde `500`/`503`:
1. La inspección permanece en la tabla `sync_queue` de Drift con estado `pending_upload`.
2. El worker de segundo plano programa el reintento usando retroceso exponencial:
   $$\text{Espera} = \min(300, 3 \times 2^{\text{intentos}}) \pm 1.5\text{s}$$
3. Al restablecerse la conexión, se envía con el mismo `Idempotency-Key` garantizando que no se dupliquen registros en la base central.
